#include "wry.h"

/* ---- closures -------------------------------------------------------------
 *
 * `|x| x * 2` is LAMBDA-LIFTED: it becomes a top-level `fn __wry_lambdaN(x)`,
 * and the expression's value is that function's ADDRESS.  Calling it is an
 * indirect call, which needs nothing new in the backend — cg-x86-linux's
 * `ax_call` already emits `call rax` whenever the callee temp carries no name,
 * and `IR_FUNCADDR` already materialises a function address.
 *
 * ★ WHY THE BODY IS CAPTURED AS SOURCE TEXT.  A lifted function is a FUNCDEF,
 * and a FUNCDEF cannot be emitted inside another function's IR stream — the
 * arena is linear.  So the body's TEXT is captured and compiled in a second
 * pass, the same deferral `__wry_writen` uses.  The alternative, buffering IR
 * and splicing it later, would mean renumbering every temp and label in it.
 *
 * ★ THE BODY'S EXTENT is found by scanning balanced delimiters to the next
 * top-level `,` `)` `}` or `;` — much as macro_call splits its arguments.  The
 * `;` matters as much as the others: a closure bound by `let` is not an
 * argument, so without it the scan runs off the end of the file.
 *
 * ★ NON-CAPTURING ONLY, AND CHECKED.  A closure naming an enclosing local is
 * REJECTED.  Capture needs an environment block and a two-word closure value
 * [fnaddr, env], with calls passing the env — a real change, not a tweak.
 * Rejecting is the honest position: silently compiling a capture would read a
 * dead stack slot and produce a wrong answer at runtime.
 */

hword Compiler::closure_expr()
{
    char pnames[4][NAMELEN];
    int  npar = 0;
    char name[NAMELEN];
    hword r = H->new_temp();
    int outer_nsym = nsym;

    lx.next();                                   /* the opening `|` */
    while (lx.tok != T_PIPE && lx.tok != T_EOF) {
        if (lx.tok == T_IDENT) {
            if (npar < 4) { strcpy(pnames[npar], lx.name); npar = npar + 1; }
            lx.next();
            /* `|x: i64|` — an annotation is accepted and ignored: the parameter
             * is one machine word whatever it says. */
            if (lx.tok == T_COLON) { lx.next(); parse_type(); }
        } else lx.next();
        if (!accept(T_COMMA)) break;
    }
    if (lx.tok != T_PIPE) { error("expected | to close the closure parameters"); return r; }
    lx.next();

    /* Capture the body text up to the next top-level `,` or `)`. */
    {
        int depth = 0;
        int from  = lx.tokpos;
        int to    = from;
        while (lx.tok != T_EOF) {
            if (lx.tok == T_LP || lx.tok == T_LBRACE) depth = depth + 1;
            if (lx.tok == T_RP || lx.tok == T_RBRACE) {
                if (depth == 0) break;
                depth = depth - 1;
            }
            /* `;` ends the body too.  Without it `let f = |x| x + 1;` ran the
             * scan past the semicolon and swallowed the rest of the file — a
             * closure bound by `let` is not an argument, so `,`/`)` never
             * arrive. */
            if (lx.tok == T_SEMI && depth == 0) break;
            if (lx.tok == T_COMMA && depth == 0) break;
            to = lx.tokpos + 1;
            lx.next();
        }
        to = lx.tokpos;

        /* Emit `fn __wry_lambdaN(p, ...) -> i64 { return <body>; }` into the
         * deferred buffer. */
        sprintf(name, "__wry_lambda%d", nlambda);
        nlambda = nlambda + 1;
        {
            int need = (to - from) + 128;
            if (lambn + need >= LAMBUF) { error("too many closures"); return r; }
            lambn = lambn + sprintf(lambuf + lambn, "fn %s<A>(", name);
            {
                int i = 0;
                while (i < npar) {
                    lambn = lambn + sprintf(lambuf + lambn, "%s%s",
                                            i > 0 ? ", " : "", pnames[i]);
                    i = i + 1;
                }
            }
            /* `<A> ... -> A`: the lifted function is GENERIC in its return
             * type, so `A` resolves to TY_UNKNOWN and unifies with whatever the
             * body produces.  `-> i64` would be wrong the moment a closure
             * returns an Option, as `and_then(|x| Option::Some(x))` does. */
            lambn = lambn + sprintf(lambuf + lambn, ") -> A { return ");
            memcpy(lambuf + lambn, lx.src + from, to - from);
            lambn = lambn + (to - from);
            lambn = lambn + sprintf(lambuf + lambn, "; }\n");
            lambuf[lambn] = 0;
        }
    }

    /* The value: the lifted function's address. */
    H->emit(IR_FUNCADDR, r, 0, (hword)(long)hofos_bcpl(name), 0);
    curty = TY_FN;
    nsym = outer_nsym;
    return r;
}
