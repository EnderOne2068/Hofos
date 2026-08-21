#include "wry.h"

/* Macros: `macro_rules!` (declarative), plus the println!/print!/panic! stdlib
 * (procedural, because a format macro must inspect the TEXT of a string literal
 * — something a declarative macro cannot do). */
int Compiler::mac_find(char *nm)
{
    int i = 0;
    while (i < nmac) { if (strcmp(mnames + i * NAMELEN, nm) == 0) return i; i = i + 1; }
    return -1;
}

char *Compiler::mac_alloc(int n)
{
    char *p;
    if (macused + n + 1 > MACBUF) { error("macro arena exhausted"); return 0; }
    p = macarena + macused;
    macused = macused + n + 1;
    return p;
}

/* `macro_rules! name { ($a:expr, $b:expr) => { body } }`
/* `macro_rules! name { (pat) => { body } ; (pat) => { body } }`
 *
 * Captured as TEXT: each rule's parameter names and its body's source span.
 * A macro may carry SEVERAL rules; `macro_call` picks one by arity.
 *
 * A pattern is a comma-separated list of `$name:frag`, optionally ending in a
 * REPETITION `$($name:frag),*` which binds every remaining argument.  The
 * separator between repeated arguments is recorded so the body can rebuild it.
 */
void Compiler::macro_def()
{
    char nm[NAMELEN];
    int mi;
    lx.next();                                  /* `macro_rules` */
    if (lx.tok != T_BANG) { error("expected ! after macro_rules"); return; }
    lx.next();
    if (lx.tok != T_IDENT) { error("expected a macro name"); return; }
    strcpy(nm, lx.name); lx.next();
    if (lx.tok != T_LBRACE) { error("expected { after the macro name"); return; }
    lx.next();
    if (nmac >= MAXMAC) { error("too many macros"); return; }
    mi = nmac;
    strcpy(mnames + mi * NAMELEN, nm);
    mrule0[mi] = nrule;
    mnrule[mi] = 0;

    /* Each iteration reads ONE rule: `( pattern ) => { body }`. */
    while (lx.tok == T_LP) {
        int ri;
        if (nrule >= MAXRULE) { error("too many macro rules"); return; }
        ri = nrule;
        rnparm[ri] = 0;
        rrep[ri] = -1;
        rsep[ri] = 0;
        lx.next();                              /* past `(` */

        while (lx.tok != T_RP && lx.tok != T_EOF) {
            if (lx.tok == T_DOLLAR) {
                int isrep = 0;
                lx.next();
                /* `$(` opens a repetition group; anything else is one param. */
                if (lx.tok == T_LP) { isrep = 1; lx.next(); if (lx.tok == T_DOLLAR) lx.next(); }
                if (lx.tok != T_IDENT) { error("expected a name after $"); return; }
                if (rnparm[ri] < 8) {
                    char *p = mac_alloc(NAMELEN);
                    if (p == 0) return;
                    strcpy(p, lx.name);
                    rparm[ri * 8 + rnparm[ri]] = p;
                    if (isrep) rrep[ri] = rnparm[ri];
                    rnparm[ri] = rnparm[ri] + 1;
                }
                lx.next();
                /* `:expr` / `:ident` / `:ty` — the fragment specifier.  Parsed
                 * and not enforced: every capture is taken as a token span. */
                if (lx.tok == T_COLON) { lx.next(); if (lx.tok == T_IDENT) lx.next(); }
                if (isrep) {
                    if (lx.tok != T_RP) { error("expected ) to close $( in the pattern"); return; }
                    lx.next();
                    /* The separator sits between `)` and the `*`/`+`. */
                    if (lx.tok == T_COMMA)      { rsep[ri] = ','; lx.next(); }
                    else if (lx.tok == T_SEMI)  { rsep[ri] = ';'; lx.next(); }
                    if (lx.tok == T_STAR || lx.tok == T_PLUS) lx.next();
                    else { error("expected * or + after a repetition group"); return; }
                    break;                      /* a repetition must come last */
                }
            } else lx.next();
            if (!accept(T_COMMA)) break;
        }
        if (lx.tok != T_RP) { error("expected ) to close the macro pattern"); return; }
        lx.next();
        /* One token now — see the lexer note on `=>`. */
        if (lx.tok != T_FATARROW) { error("expected => after the macro pattern"); return; }
        lx.next();

        /* body: { ... } — captured verbatim by source span, braces excluded */
        if (lx.tok != T_LBRACE) { error("expected { to open the macro body"); return; }
        {
            int depth = 0;
            int from;
            int to;
            /* lx.tokpos is at the `{`; the body starts just after it. */
            from = lx.tokpos + 1;
            while (lx.tok != T_EOF) {
                if (lx.tok == T_LBRACE) depth = depth + 1;
                if (lx.tok == T_RBRACE) { depth = depth - 1; if (depth == 0) break; }
                lx.next();
            }
            to = lx.tokpos;                     /* the closing `}` */
            {
                int n = to - from;
                char *b;
                if (n < 0) n = 0;
                b = mac_alloc(n);
                if (b == 0) return;
                memcpy(b, lx.src + from, n);
                b[n] = 0;
                rbody[ri] = b; rblen[ri] = n;
            }
            lx.next();                          /* past the body's `}` */
        }
        nrule = nrule + 1;
        mnrule[mi] = mnrule[mi] + 1;
        /* Rules are separated by `;`, which Rust allows after the last one. */
        if (lx.tok == T_SEMI) lx.next();
    }
    if (lx.tok == T_RBRACE) lx.next();          /* the macro_rules `}` */
    if (mnrule[mi] == 0) { error("macro has no rules"); return; }
    nmac = nmac + 1;
}

/* Substitute one span of body text into `out` at `w`, returning the new `w`.
 *
 * `rk` selects which repetition element `$repparam` resolves to; -1 means "not
 * inside a repetition", where the repeated parameter has no single value and is
 * left alone.  Splitting this out is what lets the repetition body and the rest
 * of the rule share one substituter.
 */
int Compiler::mac_subst(char *out, int w, char *b, int bn, int ri,
                        char **acap, int *alen, int rk)
{
    int i = 0;
    while (i < bn) {
        /* The scratch is fixed-size and a repetition can multiply the body out,
         * so every path that writes checks first — truncating silently would
         * produce a plausible-looking expansion that is missing its tail. */
        if (w >= MACEXP - NAMELEN - 4) { macovf = 1; return w; }
        if (b[i] == '$') {
            int k = i + 1;
            char id[NAMELEN];
            int j = 0;
            while (k < bn && j < NAMELEN - 1 &&
                   ((b[k] >= 'a' && b[k] <= 'z') || (b[k] >= 'A' && b[k] <= 'Z') ||
                    (b[k] >= '0' && b[k] <= '9') || b[k] == '_')) {
                id[j] = b[k]; j = j + 1; k = k + 1;
            }
            id[j] = 0;
            {
                int p = 0;
                int hit = -1;
                while (p < rnparm[ri]) {
                    if (strcmp(rparm[ri * 8 + p], id) == 0) { hit = p; break; }
                    p = p + 1;
                }
                if (hit >= 0) {
                    int a = hit;
                    /* The repeated parameter indexes FORWARD from its own
                     * position: argument rrep+rk, not argument rrep. */
                    if (hit == rrep[ri]) {
                        if (rk < 0) { out[w] = b[i]; w = w + 1; i = i + 1; continue; }
                        a = rrep[ri] + rk;
                    }
                    /* Parenthesise the substitution: without it `$a * $b`
                     * with a = `1 + 2` would reassociate. */
                    if (w + alen[a] + 4 >= MACEXP) { macovf = 1; return w; }

                    out[w] = '('; w = w + 1;
                    memcpy(out + w, acap[a], alen[a]); w = w + alen[a];
                    out[w] = ')'; w = w + 1;
                    i = k;
                    continue;
                }
            }
        }
        out[w] = b[i]; w = w + 1; i = i + 1;
    }
    return w;
}

/* Expand `nm!(args)`.  Each argument's SOURCE TEXT is captured, a rule is
 * chosen by arity, its `$param`s are substituted, and the result is pushed as a
 * new source.  Returns 1 if it expanded.
 *
 * `wrap` distinguishes the two POSITIONS a macro can appear in.  In EXPRESSION
 * position the expansion is parenthesised (see below).  In STATEMENT position it
 * must not be: a macro whose body is `$s; $s` expands to statements, and
 * wrapping those in parentheses makes them unparseable. */
int Compiler::macro_call(char *nm, int wrap)
{
    int mi = mac_find(nm);
    char *acap[MAXARG];
    int alen[MAXARG];
    int argc = 0;
    int ri = -1;
    int nrep = 0;
    if (mi < 0) return 0;
    lx.next();                                  /* `!` */
    if (lx.tok != T_LP) { error("expected ( after a macro call"); return 1; }
    lx.next();
    /* Split the argument list on top-level commas by SOURCE SPAN — no parsing,
     * so an argument may be any balanced token sequence. */
    while (lx.tok != T_RP && lx.tok != T_EOF) {
        int depth = 0;
        int from = lx.tokpos;
        int to = from;
        while (lx.tok != T_EOF) {
            if (lx.tok == T_LP || lx.tok == T_LBRACE) depth = depth + 1;
            if (lx.tok == T_RP || lx.tok == T_RBRACE) {
                if (depth == 0) break;
                depth = depth - 1;
            }
            if (lx.tok == T_COMMA && depth == 0) break;
            to = lx.tokpos + 1;
            lx.next();
        }
        to = lx.tokpos;
        if (argc < MAXARG) {
            int n = to - from;
            char *c;
            if (n < 0) n = 0;
            c = mac_alloc(n);
            if (c == 0) return 1;
            memcpy(c, lx.src + from, n);
            c[n] = 0;
            acap[argc] = c; alen[argc] = n; argc = argc + 1;
        }
        if (lx.tok != T_COMMA) break;
        lx.next();
    }
    if (lx.tok == T_RP) lx.next();

    /* Pick the first rule that ACCEPTS this argument count.  A fixed rule wants
     * exactly its parameter count; a repetition rule wants at least the fixed
     * ones before it.  Order matters, so a specific rule written before a
     * general one wins — which is how `()` and `($($a:expr),*)` coexist. */
    {
        int r = mrule0[mi];
        int end = r + mnrule[mi];
        while (r < end) {
            if (rrep[r] < 0) { if (argc == rnparm[r]) { ri = r; break; } }
            else if (argc >= rrep[r]) { ri = r; break; }
            r = r + 1;
        }
    }
    if (ri < 0) {
        fprintf(stderr, "wry: line %d: no rule of macro %s takes %d argument(s)\n",
                srcline(), nm, argc);
        nerr = nerr + 1;
        return 1;
    }
    if (rrep[ri] >= 0) nrep = argc - rrep[ri];

    /* Substitute the body, expanding any `$( ... )sep*` group once per
     * repetition argument. */
    {
        char *out = macexp;                     /* scratch; interned at the end */
        int w = 0;
        int i = 0;
        char *b = rbody[ri];
        int bn = rblen[ri];
        /* Wrap the whole expansion in parentheses.  Without it, `add!(1,2) * 3`
         * would expand to `(1)+(2) * 3` and the caller's `* 3` would bind to the
         * expansion's last term — the classic unhygienic-macro precedence bug.
         * The parens also make the expansion parse as a single primary.
         * STATEMENT position takes neither: see `wrap` above. */
        if (wrap) { out[w] = '('; w = w + 1; }
        while (i < bn) {
            /* `$(` in the BODY opens a repetition to be replayed. */
            if (b[i] == '$' && i + 1 < bn && b[i + 1] == '(') {
                int depth = 0;
                int s = i + 2;
                int e = s;
                int sep = 0;
                int k;
                while (e < bn) {
                    if (b[e] == '(') depth = depth + 1;
                    else if (b[e] == ')') { if (depth == 0) break; depth = depth - 1; }
                    e = e + 1;
                }
                k = e + 1;                      /* past the `)` */
                /* `)sep*` vs `)*` is decided by LOOKAHEAD, not by the character
                 * itself: the repeat operator is always LAST, so a `*`/`+` with
                 * another `*`/`+` behind it is the SEPARATOR.  `$($a)+*` — the
                 * canonical sum macro — separates with `+` and repeats with `*`,
                 * so reading `+` as the operator drops the separator and leaves
                 * a stray `*` in the expansion. */
                if (k + 1 < bn && (b[k + 1] == '*' || b[k + 1] == '+')) { sep = b[k]; k = k + 1; }
                if (k < bn && (b[k] == '*' || b[k] == '+')) k = k + 1;
                {
                    int t = 0;
                    while (t < nrep) {
                        if (t > 0 && sep != 0) { out[w] = sep; w = w + 1; }
                        w = mac_subst(out, w, b + s, e - s, ri, acap, alen, t);
                        t = t + 1;
                    }
                }
                i = k;
                continue;
            }
            /* Anything else: one character's worth of ordinary substitution. */
            {
                int j = i;
                while (j < bn && !(b[j] == '$' && j + 1 < bn && b[j + 1] == '(')) j = j + 1;
                w = mac_subst(out, w, b + i, j - i, ri, acap, alen, -1);
                i = j;
            }
        }
        if (wrap) { out[w] = ')'; w = w + 1; }
        out[w] = 0;
        /* Intern the EXACT length.  The lexer keeps reading from this pointer
         * after we return, so it has to outlive the call and cannot stay in the
         * shared scratch. */
        {
            char *keep;
            if (macovf) { error("macro expansion too large"); macovf = 0; return 1; }
            keep = mac_alloc(w);
            if (keep == 0) return 1;
            memcpy(keep, out, w);
            keep[w] = 0;
            lx.push_source(keep, w);
        }
        lx.next();
    }
    return 1;
}
/* ---- the stdlib: println! / print! ---------------------------------------
 * These are the reason strings exist in Wry at all.
 *
 * WHY BUILTIN AND NOT `macro_rules!`: a format macro has to LOOK INSIDE the
 * literal, split it on `{}`, and emit a different call per fragment.  A
 * declarative macro matches token trees and substitutes them — it cannot inspect
 * the text of a string.  Real Rust makes println! a compiler builtin for exactly
 * this reason, so this follows Rust rather than working around it.
 *
 * LOWERING: straight to the BCPL runtime the generated program is already linked
 * against — `writes` for text, `writen` for an integer.  No allocation, no
 * formatting buffer, and nothing new in the runtime.
 *
 *     println!("x = {}, y = {}", a, b)
 *  -> writes("x = ") writen(a) writes(", y = ") writen(b) writes("\n")
 *
 * SUPPORTED: `{}` for i32/i64/bool/&str, and `{{`/`}}` as literal braces.
 * NOT supported yet: named or positional arguments (`{0}`, `{name}`) and format
 * specs (`{:x}`, `{:>8}`).
 */
void Compiler::emit_call1(char *fn, hword arg)
{
    hword callee = H->new_temp();
    hword res    = H->new_temp();
    H->emit(IR_CONST, callee, (hword)(long)hofos_bcpl(fn), 1, 0);
    H->set_arg3(H->emit_call(res, callee, 1, arg, 0), 0);
}

/* One character to stdout.  `wrch` is a BACKEND primitive — emitted into every
 * program by ax_emit_runtime — whereas `writes`/`writen` are libhdr BCPL SOURCE.
 * A Wry program is pure IR with no BCPL source anywhere, so those two do not
 * exist to link against; that is exactly how the first attempt failed
 * ("undefined symbol writes").  Everything here is built from wrch. */
void Compiler::emit_wrch(int ch)
{
    hword c = H->new_temp();
    H->emit(IR_CONST, c, (hword)ch, 0, 0);
    emit_call1("wrch", c);
}

void Compiler::emit_writes(char *text)
{
    int i = 0;
    while (text[i] != 0) { emit_wrch((int)(unsigned char)text[i]); i = i + 1; }
}

/* Emit `__wry_writen(n)`: print a signed integer in decimal.
 *
 * RECURSIVE, because digits come out of `n MOD 10` in REVERSE order and Wry has
 * no buffer to reverse them in.  Recursion is the standard trick and is what
 * libhdr's own writen does:
 *     if n < 0  { wrch('-'); n := -n }
 *     if n >= 10 { __wry_writen(n / 10) }
 *     wrch('0' + n MOD 10)
 * Emitted ONCE per program, and only when a `{}` actually printed an integer. */
void Compiler::emit_writen_fn()
{
    hword f  = H->new_temp();
    hword n  = H->new_temp();
    hword zero = H->new_temp();
    hword ten  = H->new_temp();
    hword cond = H->new_temp();
    int lneg  = H->new_label();
    int lrec  = H->new_label();
    int ldone = H->new_label();
    int lskip = H->new_label();

    H->emit(IR_FUNCDEF, f, 1, (hword)(long)hofos_bcpl("__wry_writen"), 0);
    H->emit(IR_PARAM, n, 1, (hword)(long)hofos_bcpl("n"), 0);
    H->emit(IR_CONST, zero, 0, 0, 0);
    H->emit(IR_CONST, ten, 10, 0, 0);

    /* if n < 0 { wrch('-'); n = -n } */
    H->emit(IR_CMP_LT, cond, n, zero, 0);
    H->emit_br(cond, lneg, lskip);
    H->emit_labelop(lneg);
    emit_wrch('-');
    H->emit(IR_NEG, n, n, 0, 0);
    H->emit_jmp(lskip);
    H->emit_labelop(lskip);

    /* if n >= 10 { __wry_writen(n / 10) } */
    {
        hword c2 = H->new_temp();
        hword q  = H->new_temp();
        H->emit(IR_CMP_GE, c2, n, ten, 0);
        H->emit_br(c2, lrec, ldone);
        H->emit_labelop(lrec);
        H->emit(IR_DIV, q, n, ten, 0);
        emit_call1("__wry_writen", q);
        H->emit_jmp(ldone);
        H->emit_labelop(ldone);
    }

    /* wrch('0' + n MOD 10) */
    {
        hword r  = H->new_temp();
        hword d  = H->new_temp();
        hword z0 = H->new_temp();
        H->emit(IR_MOD, r, n, ten, 0);
        H->emit(IR_CONST, z0, 48, 0, 0);           /* '0' */
        H->emit(IR_ADD, d, r, z0, 0);
        emit_call1("wrch", d);
    }
    {
        hword z = H->new_temp();
        H->emit(IR_CONST, z, 0, 0, 0);
        H->emit(IR_RETURN, 0, z, 0, 0);
    }
    H->emit(IR_FUNCEND, 0, 0, 0, 0);
}

/* `panic!("msg")` — print to stderr and abort.
 *
 * Needed by `Option::unwrap`, which is why it exists now.  It is an EXPRESSION
 * so it can sit in a match arm (`None => panic!(..)`) where a value is required;
 * it never actually produces one because the process is gone by then. */
int Compiler::panic_macro()
{
    char lit[MAXSTR];
    lx.next();                                   /* `!` */
    if (lx.tok != T_LP) { error("expected ( after panic!"); return 1; }
    lx.next();
    lit[0] = 0;
    if (lx.tok == T_STR) { strcpy(lit, lx.str); lx.next(); }
    if (lx.tok != T_RP) { error("expected ) after the panic message"); return 1; }
    lx.next();
    emit_writes("thread 'main' panicked: ");
    emit_writes(lit);
    emit_wrch(10);                               /* newline */
    {
        /* Exit code 101, which is what a real Rust panic returns. */
        hword c = H->new_temp();
        H->emit(IR_CONST, c, 101, 0, 0);
        emit_call1("__exitcode", c);
    }
    return 1;
}

/* Returns 1 if `nm` was a format macro and has been handled. */
int Compiler::fmt_macro(char *nm)
{
    int nl = strcmp(nm, "println") == 0;
    char lit[MAXSTR];
    char chunk[MAXSTR];
    int i = 0;
    int c = 0;
    if (!nl && strcmp(nm, "print") != 0) return 0;

    lx.next();                                   /* `!` */
    if (lx.tok != T_LP) { error("expected ( after println!"); return 1; }
    lx.next();
    if (lx.tok != T_STR) {
        /* `println!()` with no arguments is just a newline. */
        if (lx.tok == T_RP) { lx.next(); if (nl) emit_writes("\n"); return 1; }
        error("println! needs a string literal first");
        return 1;
    }
    strcpy(lit, lx.str);
    lx.next();

    while (lit[i] != 0) {
        /* `{{` and `}}` are escaped braces, not a placeholder. */
        if (lit[i] == '{' && lit[i + 1] == '{') { chunk[c++] = '{'; i += 2; continue; }
        if (lit[i] == '}' && lit[i + 1] == '}') { chunk[c++] = '}'; i += 2; continue; }
        if (lit[i] == '{' && lit[i + 1] == '}') {
            hword v;
            chunk[c] = 0;
            emit_writes(chunk);                  /* flush the text before it */
            c = 0;
            i += 2;
            if (!accept(T_COMMA)) { error("println!: not enough arguments"); return 1; }
            /* A string LITERAL argument is spliced in at compile time: no call,
             * no runtime cost, and it is the common case. */
            if (lx.tok == T_STR) {
                char tmp[MAXSTR];
                strcpy(tmp, lx.str);
                lx.next();
                emit_writes(tmp);
                continue;
            }
            v = expr();
            /* Pick the printer from the ARGUMENT'S TYPE — this is where the type
             * checker earns its keep: an &str must not go through writen. */
            /* Pick the printer from the ARGUMENT'S TYPE — this is where the
             * type checker earns its keep. */
            if (curty == TY_STR) {
                /* A &str VALUE is a pointer; printing it needs a byte loop over
                 * the string, which needs byte loads Wry does not emit yet.
                 * Diagnosing it HERE is far better than the alternative — the
                 * first attempt emitted a call to a function that does not
                 * exist and it surfaced as `hofos-fl: undefined symbol`. */
                error("println!: {} on a &str VARIABLE is not supported yet "
                      "(string literals work)");
            } else { emit_call1("__wry_writen", v); need_writen = 1; }
            continue;
        }
        chunk[c++] = lit[i]; i++;
        if (c >= MAXSTR - 2) { chunk[c] = 0; emit_writes(chunk); c = 0; }
    }
    chunk[c] = 0;
    emit_writes(chunk);
    if (nl) emit_writes("\n");
    if (lx.tok == T_COMMA) { error("println!: more arguments than {} placeholders"); }
    if (lx.tok != T_RP) { error("expected ) after println! arguments"); return 1; }
    lx.next();
    return 1;
}
