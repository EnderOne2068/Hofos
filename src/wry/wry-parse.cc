#include "wry.h"

/* Compiler bookkeeping: init, diagnostics, symbols, types. */
void Compiler::init(struct hofos_api *api)
{
    H = api; nerr = 0; nsym = 0; nloop = 0; nfn = 0; nmac = 0; nrule = 0; macused = 0; macovf = 0; need_writen = 0;
    ntype = 0; ntparam = 0; impl_type = -1; prelude_lines = 0;
    curty = TY_UNKNOWN; currett = TY_UNIT;
}

/* The line number to REPORT: user lines are numbered from 1 with the prelude
 * discounted, and a fault inside the prelude keeps its real line so it is still
 * findable. */
int Compiler::srcline()
{
    if (lx.line > prelude_lines) return lx.line - prelude_lines;
    return lx.line;
}

void Compiler::error(char *msg)
{
    fprintf(stderr, "wry: line %d: %s\n", lx.line, msg);
    nerr = nerr + 1;
}

int Compiler::accept(int t)
{
    if (lx.tok == t) { lx.next(); return 1; }
    return 0;
}

void Compiler::expect(int t, char *what)
{
    if (lx.tok == t) { lx.next(); return; }
    error(what);
}

int Compiler::sym_find(char *nm)
{
    int i = nsym - 1;
    while (i >= 0) {                       /* innermost binding wins: Rust shadowing */
        if (strcmp(snames + i * NAMELEN, nm) == 0) return i;
        i = i - 1;
    }
    return -1;
}

void Compiler::sym_add(char *nm, hword t, int ty)
{
    if (nsym >= MAXSYM) { error("too many locals"); return; }
    strcpy(snames + nsym * NAMELEN, nm);
    svals[nsym] = t;
    stypes[nsym] = ty;
    nsym = nsym + 1;
}

/* Parse a type name.  Unknown names are reported rather than silently accepted:
 * quietly treating `Strng` as valid is how a type checker becomes decoration. */
int Compiler::parse_type()
{
    /* `fn` as a TYPE — a closure parameter.  Rust spells this `impl Fn(T) -> U`;
     * with erasure the argument and return types carry no information here, so
     * the bare keyword is the honest spelling of what is actually checked. */
    if (lx.tok == T_FN) {
        lx.next();
        if (lx.tok == T_LP) skip_type_args_paren();
        if (lx.tok == T_ARROW) { lx.next(); parse_type(); }
        return TY_FN;
    }
    int t = TY_UNKNOWN;
    if (lx.tok != T_IDENT) { error("expected a type"); return TY_UNKNOWN; }
    if (strcmp(lx.name, "i64") == 0)       t = TY_I64;
    else if (strcmp(lx.name, "i32") == 0)  t = TY_I32;
    else if (strcmp(lx.name, "bool") == 0) t = TY_BOOL;
    else if (strcmp(lx.name, "isize") == 0) t = TY_I64;
    else {
        /* A user type: struct or enum, encoded as TY_USER + its index. */
        int ti = type_find(lx.name);
        if (ti >= 0) t = TY_USER + ti;
        /* A type PARAMETER in scope unifies with anything — the erasure model.
         * TY_UNKNOWN is already the checker's "do not complain" value, so this
         * needs no new machinery. */
        else if (tparam_find(lx.name) >= 0) t = TY_UNKNOWN;
        else error("unknown type");
    }
    lx.next();
    /* `Option<i64>` — the argument list is PARSED AND DISCARDED.  With erasure
     * there is nothing to instantiate: Option<i64> and Option<bool> ARE the same
     * type at runtime, so the annotation is accepted for source compatibility
     * with real Rust and contributes nothing to checking.  Nested arguments are
     * counted so `Result<Option<i64>, i64>` closes correctly. */
    if (lx.tok == T_LT) {
        int depth = 0;
        while (lx.tok != T_EOF) {
            if (lx.tok == T_LT) depth = depth + 1;
            if (lx.tok == T_GT) { depth = depth - 1; if (depth == 0) { lx.next(); break; } }
            lx.next();
        }
    }
    return t;
}

/* ---- macro_rules! --------------------------------------------------------- */

int Compiler::fn_find(char *nm)
{
    int i = 0;
    while (i < nfn) { if (strcmp(fnames + i * NAMELEN, nm) == 0) return i; i = i + 1; }
    return -1;
}

void Compiler::fn_add(char *nm, int rt, int na, int *pt)
{
    int i = 0;
    if (nfn >= MAXFN) { error("too many functions"); return; }
    strcpy(fnames + nfn * NAMELEN, nm);
    frett[nfn] = rt; fnargs[nfn] = na;
    while (i < na && i < 8) { fptype[nfn * 8 + i] = pt[i]; i = i + 1; }
    nfn = nfn + 1;
}

/* Report a type mismatch.  TY_UNKNOWN is the "already complained" value, so it
 * never produces a second, cascading error. */
void Compiler::need(int got, int want, char *what)
{
    if (got == TY_UNKNOWN || want == TY_UNKNOWN) return;
    if (got == want) return;
    fprintf(stderr, "wry: line %d: %s: expected %s, found %s\n",
            lx.line, what, tyname(want), tyname(got));
    nerr = nerr + 1;
}

/* precedence: higher binds tighter */
static int precof(int t)
{
    if (t == T_OROR)  return 1;
    if (t == T_ANDAND) return 2;
    if (t == T_EQ || t == T_NE || t == T_LT || t == T_LE || t == T_GT || t == T_GE) return 3;
    if (t == T_PLUS || t == T_MINUS) return 4;
    if (t == T_STAR || t == T_SLASH || t == T_PCT) return 5;
    return 0;
}

static int irof(int t)
{
    if (t == T_PLUS)  return IR_ADD;
    if (t == T_MINUS) return IR_SUB;
    if (t == T_STAR)  return IR_MUL;
    if (t == T_SLASH) return IR_DIV;
    if (t == T_PCT)   return IR_MOD;
    if (t == T_EQ)    return IR_CMP_EQ;
    if (t == T_NE)    return IR_CMP_NE;
    if (t == T_LT)    return IR_CMP_LT;
    if (t == T_LE)    return IR_CMP_LE;
    if (t == T_GT)    return IR_CMP_GT;
    if (t == T_GE)    return IR_CMP_GE;
    return IR_ADD;
}

hword Compiler::primary()
{
    hword t;
    if (lx.tok == T_NUM) {
        t = H->new_temp();
        H->emit(IR_CONST, t, (hword)lx.num, 0, 0);
        lx.next();
        curty = TY_I64;
        return t;
    }
    /* `true` / `false` are ordinary identifiers to the lexer, but they are the
     * only way to get a bool literal, and the checker needs them typed. */
    if (lx.tok == T_IDENT &&
        (strcmp(lx.name, "true") == 0 || strcmp(lx.name, "false") == 0)) {
        int v = strcmp(lx.name, "true") == 0 ? 1 : 0;
        t = H->new_temp();
        H->emit(IR_CONST, t, (hword)v, 0, 0);
        lx.next();
        curty = TY_BOOL;
        return t;
    }
    if (lx.tok == T_MATCH) return match_expr();
    if (lx.tok == T_PIPE)  return closure_expr();   /* |x| ... */
    /* `self` in expression position is just the symbol the parameter list bound;
     * it is a KEYWORD rather than an identifier, so primary() has to name it. */
    if (lx.tok == T_SELF) {
        int i = sym_find("self");
        lx.next();
        if (i < 0) { error("`self` outside a method"); return H->new_temp(); }
        curty = stypes[i];
        return svals[i];
    }
    if (lx.tok == T_STR) {
        t = h_strlit(H, lx.str);
        curty = TY_STR;
        lx.next();
        return t;
    }
    if (lx.tok == T_LP) {
        lx.next();
        t = expr();
        expect(T_RP, "expected )");
        return t;
    }
    if (lx.tok == T_IDENT) {
        char nm[NAMELEN];
        int i;
        strcpy(nm, lx.name);
        lx.next();
        /* panic! is an expression so it can be a match arm. */
        if (lx.tok == T_BANG && strcmp(nm, "panic") == 0) {
            hword z;
            panic_macro();
            z = H->new_temp();
            H->emit(IR_CONST, z, 0, 0, 0);
            curty = TY_UNKNOWN;                  /* unifies with any arm type */
            return z;
        }
        /* `Enum::Variant` — a compile-time constant.  Checked before the macro
         * and call cases because `::` cannot begin either of those. */
        if (lx.tok == T_COLONCOLON) {
            int ti = type_find(nm);
            lx.next();
            if (ti < 0 || tkind[ti] != 1) { error("not an enum"); return H->new_temp(); }
            if (lx.tok != T_IDENT) { error("expected a variant name after ::"); return H->new_temp(); }
            {
                int vi = field_find(ti, lx.name);
                if (vi < 0) { error("no such variant"); lx.next(); return H->new_temp(); }
                lx.next();
                return enum_construct(ti, vi);
            }
        }
        /* `Name { field: ... }` — a struct literal.  Only treated as one when the
         * name really is a struct, so `if x { .. }` is never misread as a
         * literal: that ambiguity is exactly why Rust restricts struct literals
         * in condition position. */
        if (lx.tok == T_LBRACE && type_find(nm) >= 0 && tkind[type_find(nm)] == 0) {
            return struct_literal(type_find(nm));
        }
        /* `name!(...)` — a macro invocation.  The expansion is spliced in as a
         * parenthesised source, so parsing it is just parsing a primary. */
        if (lx.tok == T_BANG && mac_find(nm) >= 0) {
            macro_call(nm, 1);
            return primary();
        }
        /* Checked BEFORE the direct-call branch below: otherwise `f(41)`
         * where f holds a closure compiles as a call to a FUNCTION NAMED
         * "f", and fails at link with `undefined symbol f`. */
        i = sym_find(nm);
        /* A local holding a CLOSURE, called: `f(v)`.  The callee temp carries an
         * address rather than a name, which is exactly the case cg's ax_call
         * lowers to `call rax`. */
        if (i >= 0 && stypes[i] == TY_FN && lx.tok == T_LP) {
            hword args[8];
            int argc = 0;
            hword res = H->new_temp();
            lx.next();
            while (lx.tok != T_RP && lx.tok != T_EOF) {
                if (argc < 8) { args[argc] = expr(); argc = argc + 1; }
                else { expr(); error("too many arguments"); }
                if (!accept(T_COMMA)) break;
            }
            expect(T_RP, "expected ) after the closure arguments");
            if (argc >= 4) H->emit(IR_SETARG, 0, args[3], 4, 0);
            {
                hword a1 = argc >= 1 ? args[0] : 0;
                hword a2 = argc >= 2 ? args[1] : 0;
                hword a3 = argc >= 3 ? args[2] : 0;
                H->set_arg3(H->emit_call(res, svals[i], (hword)argc, a1, a2), a3);
            }
            /* UNKNOWN, not i64: a closure's return type is genuinely not known
             * here — `f` is one machine word and erasure keeps no signature.
             * Claiming i64 made `and_then`'s arms disagree (`f(v)` vs
             * `Option::None`) and rejected the prelude. */
            curty = TY_UNKNOWN;
            return res;
        }
        if (lx.tok == T_LP) {                        /* call */
            hword args[8];
            int atys[8];
            int argc = 0;
            int fi = fn_find(nm);
            hword callee = H->new_temp();
            hword res = H->new_temp();
            hword a1 = 0; hword a2 = 0; hword a3 = 0;
            H->emit(IR_CONST, callee, (hword)(long)hofos_bcpl(nm), 1, 0);
            lx.next();
            while (lx.tok != T_RP && lx.tok != T_EOF) {
                if (argc < 8) { args[argc] = expr(); atys[argc] = curty; argc = argc + 1; }
                else { expr(); error("too many arguments"); }
                if (!accept(T_COMMA)) break;
            }
            expect(T_RP, "expected ) after arguments");
            /* Check the call against the declaration.  A function may legally be
             * called before it is defined, so an unknown name is not an error
             * here — only a MISMATCH against a known signature is. */
            if (fi >= 0) {
                int k = 0;
                if (argc != fnargs[fi]) {
                    fprintf(stderr, "wry: line %d: %s takes %d argument(s), %d given\n",
                            srcline(), nm, fnargs[fi], argc);
                    nerr = nerr + 1;
                }
                while (k < argc && k < fnargs[fi]) {
                    need(atys[k], fptype[fi * 8 + k], "argument");
                    k = k + 1;
                }
            }
            if (argc >= 4) H->emit(IR_SETARG, 0, args[3], 4, 0);
            if (argc >= 5) H->emit(IR_SETARG, 0, args[4], 5, 0);
            if (argc >= 1) a1 = args[0];
            if (argc >= 2) a2 = args[1];
            if (argc >= 3) a3 = args[2];
            H->set_arg3(H->emit_call(res, callee, argc, a1, a2), a3);
            curty = fi >= 0 ? frett[fi] : TY_I64;
            return res;
        }
        i = sym_find(nm);
        if (i < 0) {
            error("unknown name");
            curty = TY_UNKNOWN;
            t = H->new_temp(); H->emit(IR_CONST, t, 0, 0, 0); return t;
        }
        curty = stypes[i];
        return svals[i];
    }
    error("expected an expression");
    curty = TY_UNKNOWN;
    t = H->new_temp();
    H->emit(IR_CONST, t, 0, 0, 0);
    lx.next();
    return t;
}

/* Postfix chain after a primary: `.field`, repeatedly.  Written as a loop so
 * `a.b.c` works without recursion, and kept separate from primary() so a struct
 * literal (which primary parses) can be selected from immediately. */
hword Compiler::postfix(hword v)
{
    while (lx.tok == T_DOT) {
        int ty = curty;
        lx.next();
        /* `.name(` is a METHOD call; `.name` alone is a field.  One token of
         * lookahead decides, which is why the name is captured first. */
        if (lx.tok == T_IDENT) {
            char nm[NAMELEN];
            int save = lx.tokpos;
            int saveline = lx.line;
            strcpy(nm, lx.name);
            lx.next();
            if (lx.tok == T_LP) { v = method_call(v, ty, nm); continue; }
            lx.pos = save; lx.line = saveline; lx.next();
        }
        v = field_access(v, ty);
    }
    return v;
}

hword Compiler::unary()
{
    if (lx.tok == T_MINUS) {
        hword t;
        hword r;
        lx.next();
        t = unary();
        if (!tyint(curty) && curty != TY_UNKNOWN) need(curty, TY_I64, "unary -");
        r = H->new_temp();
        H->emit(IR_NEG, r, t, 0, 0);
        return r;
    }
    if (lx.tok == T_BANG) {                 /* Rust `!` is both `not` and bitnot */
        hword t;
        hword r;
        lx.next();
        t = unary();
        r = H->new_temp();
        /* On a bool, `!` must produce 0/1 — a bitwise NOT would give ~0, which
         * is truthy, so `!flag` would stay "true".  Compare against 0 instead. */
        if (curty == TY_BOOL) {
            hword z = H->new_temp();
            H->emit(IR_CONST, z, 0, 0, 0);
            H->emit(IR_CMP_EQ, r, t, z, 0);
        } else H->emit(IR_NOT, r, t, 0, 0);
        return r;
    }
    return postfix(primary());
}

/* Precedence climbing. */
hword Compiler::binary(int minprec)
{
    hword lhs = unary();
    while (1) {
        int p = precof(lx.tok);
        int op = lx.tok;
        hword rhs;
        hword r;
        if (p == 0 || p < minprec) break;
        lx.next();

        /* && and || SHORT-CIRCUIT: the right operand must not be evaluated at
         * all when the left already decides the answer.  Emitting them as
         * bitwise AND/OR (as this first did) is not merely a missed
         * optimisation — it is wrong the moment the right side has an effect or
         * would fault, which is exactly what guards like `p != 0 && *p` exist
         * to prevent.  So the branch has to be emitted BEFORE parsing rhs. */
        if (op == T_ANDAND || op == T_OROR) {
            hword lrhs = H->new_label();
            hword ldone = H->new_label();
            need(curty, TY_BOOL, "left operand of && / ||");
            r = H->new_temp();
            H->emit(IR_MOV, r, lhs, 0, 0);       /* result if we short-circuit */
            if (op == T_ANDAND) H->emit_br(lhs, lrhs, ldone);   /* false wins */
            else                H->emit_br(lhs, ldone, lrhs);   /* true wins  */
            H->emit_labelop(lrhs);
            rhs = binary(p + 1);
            need(curty, TY_BOOL, "right operand of && / ||");
            H->emit(IR_MOV, r, rhs, 0, 0);
            H->emit_labelop(ldone);
            lhs = r;
            curty = TY_BOOL;
            continue;
        }

        {
            int lty = curty;
            int rty;
            rhs = binary(p + 1);
            rty = curty;
            if (p == 3) {                       /* comparison */
                /* == and != accept any matching pair; ordering needs integers. */
                if (op == T_EQ || op == T_NE) need(rty, lty, "comparison");
                else {
                    if (!tyint(lty)) need(lty, TY_I64, "left operand of a comparison");
                    if (!tyint(rty)) need(rty, TY_I64, "right operand of a comparison");
                }
                curty = TY_BOOL;                /* a comparison is a bool, not an int */
            } else {
                if (!tyint(lty)) need(lty, TY_I64, "left operand of an arithmetic operator");
                else need(rty, lty, "right operand of an arithmetic operator");
                curty = lty;
            }
            r = H->new_temp();
            H->emit(irof(op), r, lhs, rhs, 0);
            lhs = r;
        }
    }
    return lhs;
}

hword Compiler::expr() { return binary(1); }

hword Compiler::block()
{
    int save = nsym;                        /* block scope: pop bindings on exit */
    hword tail = 0;
    expect(T_LBRACE, "expected {");
    while (lx.tok != T_RBRACE && lx.tok != T_EOF) {
        hastail = 0;
        stmt();
        /* Only the LAST statement can supply the value; anything after a
         * semicolon-less expression discards it. */
        tail = hastail ? tailval : 0;
    }
    expect(T_RBRACE, "expected }");
    nsym = save;
    return tail;
}

void Compiler::stmt()
{
    /* `foo!(...)` at statement level.  Needs TWO tokens of lookahead (IDENT then
     * `!`) and the lexer carries one, so peek and REWIND to `tokpos` — the start
     * of the identifier — when it turns out to be an ordinary expression
     * statement.  Rewinding to `pos` would skip the identifier entirely. */
    /* println!/print! in statement position — where they almost always appear.
     * Checked BEFORE user macros so a program cannot shadow the stdlib by
     * accident, and handled here rather than in expr() because they produce no
     * value. */
    if (lx.tok == T_IDENT &&
        (strcmp(lx.name, "println") == 0 || strcmp(lx.name, "print") == 0)) {
        char nm[NAMELEN];
        int save = lx.tokpos;
        int saveline = lx.line;
        strcpy(nm, lx.name);
        lx.next();
        if (lx.tok == T_BANG) {
            fmt_macro(nm);
            curty = TY_UNIT;
            if (lx.tok == T_SEMI) lx.next();
            return;
        }
        lx.pos = save; lx.line = saveline; lx.next();
    }

    if (lx.tok == T_IDENT && mac_find(lx.name) >= 0) {
        char nm[NAMELEN];
        int save = lx.tokpos;
        int saveline = lx.line;
        strcpy(nm, lx.name);
        lx.next();
        if (lx.tok == T_BANG) { macro_call(nm, 0); return; }
        lx.pos = save; lx.line = saveline; lx.next();
    }

    /* `foo!(...);` leaves its terminating `;` behind after the expansion has
     * been consumed, and Rust allows a bare `;` anyway. */
    if (lx.tok == T_SEMI) { lx.next(); return; }

    if (lx.tok == T_LET) {
        char nm[NAMELEN];
        hword v;
        hword t;
        lx.next();
        accept(T_MUT);                      /* mutability is a borrow-checker concern */
        if (lx.tok != T_IDENT) { error("expected a name after let"); return; }
        strcpy(nm, lx.name);
        lx.next();
        {
            int declared = TY_UNKNOWN;
            if (accept(T_COLON)) declared = parse_type();
            expect(T_ASSIGN, "expected = in let");
            v = expr();
            expect(T_SEMI, "expected ; after let");
            /* With an annotation the initialiser must match it; without one the
             * binding INFERS the initialiser's type. */
            if (declared != TY_UNKNOWN) { need(curty, declared, "let initialiser"); curty = declared; }
        }
        /* Bind to a FRESH temp rather than aliasing the value's temp: a later
         * assignment must not write through to whatever produced it. */
        t = H->new_temp();
        H->emit(IR_MOV, t, v, 0, 0);
        sym_add(nm, t, curty);
        return;
    }

    if (lx.tok == T_RETURN) {
        hword v;
        lx.next();
        if (lx.tok == T_SEMI) { v = H->new_temp(); H->emit(IR_CONST, v, 0, 0, 0); curty = TY_UNIT; }
        else v = expr();
        expect(T_SEMI, "expected ; after return");
        need(curty, currett, "return value");
        H->emit(IR_RETURN, 0, v, 0, 0);
        return;
    }

    if (lx.tok == T_IF) {
        hword c;
        hword lthen = H->new_label();
        hword lelse = H->new_label();
        hword lend  = H->new_label();
        lx.next();
        c = expr();
        /* Rust requires a bool here — it does NOT coerce integers. That rule is
         * what turns `if n` and a stray `if x = 1` into errors instead of
         * silently-wrong code. */
        need(curty, TY_BOOL, "if condition");
        H->emit_br(c, lthen, lelse);
        H->emit_labelop(lthen);
        block();
        H->emit_jmp(lend);
        H->emit_labelop(lelse);
        if (accept(T_ELSE)) {
            if (lx.tok == T_IF) stmt();     /* else if */
            else block();
        }
        H->emit_labelop(lend);
        return;
    }

    if (lx.tok == T_WHILE) {
        hword ltop  = H->new_label();
        hword lbody = H->new_label();
        hword lend  = H->new_label();
        hword c;
        lx.next();
        H->emit_labelop(ltop);
        c = expr();
        need(curty, TY_BOOL, "while condition");
        H->emit_br(c, lbody, lend);
        H->emit_labelop(lbody);
        if (nloop < MAXLOOP) { brk[nloop] = lend; cont[nloop] = ltop; nloop = nloop + 1; }
        block();
        if (nloop > 0) nloop = nloop - 1;
        H->emit_jmp(ltop);
        H->emit_labelop(lend);
        return;
    }

    if (lx.tok == T_LOOP) {
        hword ltop = H->new_label();
        hword lend = H->new_label();
        lx.next();
        H->emit_labelop(ltop);
        if (nloop < MAXLOOP) { brk[nloop] = lend; cont[nloop] = ltop; nloop = nloop + 1; }
        block();
        if (nloop > 0) nloop = nloop - 1;
        H->emit_jmp(ltop);
        H->emit_labelop(lend);
        return;
    }

    if (lx.tok == T_BREAK) {
        lx.next();
        accept(T_SEMI);
        if (nloop > 0) H->emit_jmp(brk[nloop - 1]);
        else error("break outside a loop");
        return;
    }

    if (lx.tok == T_CONTINUE) {
        lx.next();
        accept(T_SEMI);
        if (nloop > 0) H->emit_jmp(cont[nloop - 1]);
        else error("continue outside a loop");
        return;
    }

    /* `for x in a..b { }` — the half-open range Rust's for loop is built on.
     * The bound is evaluated ONCE, before the loop, as Rust does. */
    if (lx.tok == T_FOR) {
        char nm[NAMELEN];
        hword lo; hword hi; hword iv;
        hword ltop; hword lbody; hword linc; hword lend; hword c;
        int save;
        lx.next();
        if (lx.tok != T_IDENT) { error("expected a name after for"); return; }
        strcpy(nm, lx.name); lx.next();
        if (lx.tok != T_IN) { error("expected `in` after the for pattern"); return; }
        lx.next();
        lo = expr();
        if (lx.tok != T_DOTDOT) { error("only `for x in a..b` ranges are supported"); return; }
        lx.next();
        hi = expr();
        iv = H->new_temp();
        H->emit(IR_MOV, iv, lo, 0, 0);
        save = nsym;
        sym_add(nm, iv, TY_I64);   /* a range loop variable is an integer */
        ltop = H->new_label(); lbody = H->new_label();
        linc = H->new_label(); lend = H->new_label();
        H->emit_labelop(ltop);
        c = H->new_temp();
        H->emit(IR_CMP_LT, c, iv, hi, 0);
        H->emit_br(c, lbody, lend);
        H->emit_labelop(lbody);
        /* `continue` must land on the INCREMENT, not the test — jumping to the
         * test would never advance the induction variable and would hang. */
        if (nloop < MAXLOOP) { brk[nloop] = lend; cont[nloop] = linc; nloop = nloop + 1; }
        block();
        if (nloop > 0) nloop = nloop - 1;
        H->emit_labelop(linc);
        {
            hword one = H->new_temp();
            hword nx = H->new_temp();
            H->emit(IR_CONST, one, 1, 0, 0);
            H->emit(IR_ADD, nx, iv, one, 0);
            H->emit(IR_MOV, iv, nx, 0, 0);
        }
        H->emit_jmp(ltop);
        H->emit_labelop(lend);
        nsym = save;
        return;
    }

    if (lx.tok == T_LBRACE) { block(); return; }

    /* assignment `x = e;` or a bare expression statement */
    if (lx.tok == T_IDENT) {
        char nm[NAMELEN];
        int save = lx.tokpos;               /* where the IDENT begins, not after it */
        int saveline = lx.line;
        int i;
        strcpy(nm, lx.name);
        lx.next();
        if (lx.tok == T_ASSIGN) {
            hword v;
            lx.next();
            v = expr();
            expect(T_SEMI, "expected ; after assignment");
            i = sym_find(nm);
            if (i < 0) { error("assignment to an unknown name"); return; }
            need(curty, stypes[i], "assignment");
            H->emit(IR_MOV, svals[i], v, 0, 0);
            return;
        }
        /* A macro in STATEMENT position expands to statements, so it is handled
         * here rather than through the expression path (which parenthesises). */
        /* not an assignment — rewind and treat the whole thing as an expression */
        lx.pos = save; lx.line = saveline;
        lx.next();
    }

    /* An expression statement.  WITH a semicolon it is discarded; WITHOUT one it
     * is the enclosing block's value (Rust's rule, and the difference between
     * `x;` and `x` at the end of a function body). */
    {
        hword v = expr();
        if (lx.tok == T_SEMI) { lx.next(); hastail = 0; }
        else { tailval = v; hastail = 1; }
    }
}

void Compiler::function()
{
    char fname[NAMELEN];
    char pnames[8 * NAMELEN];
    int ptypes[8];
    int argc = 0;
    int rett = TY_UNIT;
    hword f;
    int i;

    expect(T_FN, "expected fn");
    if (lx.tok != T_IDENT) { error("expected a function name"); return; }
    strcpy(fname, lx.name);
    lx.next();

    /* Inside an `impl`, a method is emitted as `Type__name`.  Renamed HERE,
     * before the signature is registered, so recursion and later calls both
     * resolve to the mangled name. */
    if (impl_type >= 0) {
        char full[NAMELEN * 2];
        strcpy(full, tnames + impl_type * NAMELEN);
        strcat(full, "__");
        strcat(full, fname);
        strcpy(fname, full);
    }

    /* `<T, U>` — type parameters.  ERASED, not monomorphised: every Wry value is
     * one machine word, so T has the same representation whatever it binds to.
     * Rust monomorphises because layouts differ per instantiation; here they
     * cannot, so one body serves them all. */
    if (lx.tok == T_LT) {
        lx.next();
        ntparam = 0;
        while (lx.tok != T_GT && lx.tok != T_EOF) {
            if (lx.tok == T_IDENT && ntparam < 8) {
                strcpy(tparam + ntparam * NAMELEN, lx.name);
                ntparam = ntparam + 1;
            }
            lx.next();
            if (!accept(T_COMMA)) break;
        }
        if (lx.tok == T_GT) lx.next();
    }

    expect(T_LP, "expected ( after the function name");
    while (lx.tok != T_RP && lx.tok != T_EOF) {
        /* `self` is a parameter like any other; its type is the impl type, which
         * is what makes `self.field` work inside a method with no extra rules. */
        if (lx.tok == T_SELF) {
            if (argc < 8) {
                strcpy(pnames + argc * NAMELEN, "self");
                ptypes[argc] = impl_type >= 0 ? TY_USER + impl_type : TY_I64;
                argc = argc + 1;
            }
            lx.next();
            if (!accept(T_COMMA)) break;
            continue;
        }
        if (lx.tok == T_IDENT) {
            int pt = TY_I64;                    /* untyped parameter defaults to i64 */
            int slot = argc;
            if (argc < 8) { strcpy(pnames + argc * NAMELEN, lx.name); argc = argc + 1; }
            lx.next();
            if (accept(T_COLON)) pt = parse_type();
            if (slot < 8) ptypes[slot] = pt;
        } else lx.next();
        if (!accept(T_COMMA)) break;
    }
    expect(T_RP, "expected ) after parameters");
    /* No `-> T` means the unit type, exactly as in Rust. */
    rett = TY_UNIT;
    if (accept(T_ARROW)) rett = parse_type();
    currett = rett;
    /* Register the signature BEFORE the body, so direct recursion type-checks. */
    if (fn_find(fname) < 0) fn_add(fname, rett, argc, ptypes);

    /* Rust's entry point is `main`; HANGMAN's is `start`. */
    nsym = 0; nloop = 0;
    f = H->new_temp();
    if (strcmp(fname, "main") == 0)
        H->emit(IR_FUNCDEF, f, argc, (hword)(long)hofos_bcpl("start"), 0);
    else
        H->emit(IR_FUNCDEF, f, argc, (hword)(long)hofos_bcpl(fname), 0);

    i = 0;
    while (i < argc) {
        hword pt = H->new_temp();
        H->emit(IR_PARAM, pt, i + 1, (hword)(long)hofos_bcpl(pnames + i * NAMELEN), 0);
        sym_add(pnames + i * NAMELEN, pt, ptypes[i]);
        i = i + 1;
    }

    {
        /* The body's tail expression IS the return value, so idiomatic Rust —
         * `fn add(a, b) -> i64 { a + b }` — needs no `return` at all. */
        hword tail = block();
        if (tail != 0) { need(curty, rett, "function tail expression");
                         H->emit(IR_RETURN, 0, tail, 0, 0); }
    }

    /* A function that falls off the end returns 0 — HANGMAN requires a RETURN.
     * Emitted unconditionally: it is unreachable after a tail expression or an
     * explicit return, and whole-function DCE drops it. */
    {
        hword z = H->new_temp();
        H->emit(IR_CONST, z, 0, 0, 0);
        H->emit(IR_RETURN, 0, z, 0, 0);
    }
    H->emit(IR_FUNCEND, 0, 0, 0, 0);
}

void Compiler::program()
{
    while (lx.tok != T_EOF) {
        if (lx.tok == T_IDENT && strcmp(lx.name, "macro_rules") == 0) { macro_def(); continue; }
        if (lx.tok == T_STRUCT) { struct_decl(); continue; }
        if (lx.tok == T_IMPL)   { impl_block();  continue; }
        if (lx.tok == T_TRAIT)  { trait_decl();  continue; }
        if (lx.tok == T_ENUM)   { enum_decl();   continue; }
        if (lx.tok == T_FN) { function(); continue; }
        error("expected a top-level item (fn, struct, enum, impl or trait)");
        lx.next();
    }
    /* AFTER the user's functions, so it cannot disturb their numbering, and only
     * when something actually printed an integer. */
    if (need_writen) emit_writen_fn();
}

