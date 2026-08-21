#include "wry.h"

/* ---- match, data-carrying variants, impl blocks --------------------------
 *
 * This is what makes core:: possible: Option<T> and Result<T,E> are
 * data-carrying enums, and they are unusable without `match`.
 */

/* `Enum::Variant` or `Enum::Variant(expr)`.
 *
 * UNBOXED enum: the value is just the tag.
 * BOXED enum: allocate [tag, payload].  A bare variant of a boxed enum still
 * gets a block, so every value of the enum has the same shape and `match` can
 * read word 0 without knowing which variant it holds. */
hword Compiler::enum_construct(int ti, int vi)
{
    hword tag = H->new_temp();
    H->emit(IR_CONST, tag, (hword)tftype[ti * MAXFIELD + vi], 0, 0);
    curty = TY_USER + ti;

    if (!tboxed[ti]) {
        if (lx.tok == T_LP) error("this variant carries no data");
        return tag;
    }
    {
        /* HEAP, not IR_VECALLOC: a boxed enum returned from a function must
         * outlive that function's frame — see heap_alloc in wry-type.cc. */
        hword base = heap_alloc(2);
        hword off  = H->new_temp();
        hword addr = H->new_temp();
        hword pay  = 0;
        H->emit(IR_STORE, 0, base, tag, 0);              /* word 0 = tag */

        if (lx.tok == T_LP) {
            lx.next();
            pay = expr();
            if (tfpay[ti * MAXFIELD + vi] != TY_UNIT)
                need(curty, tfpay[ti * MAXFIELD + vi], "variant payload");
            if (lx.tok != T_RP) error("expected ) after the variant payload");
            else lx.next();
        } else {
            if (tfpay[ti * MAXFIELD + vi] != TY_UNIT)
                error("this variant needs a payload");
            pay = H->new_temp();
            H->emit(IR_CONST, pay, 0, 0, 0);
        }
        H->emit(IR_CONST, off, 8, 0, 0);
        H->emit(IR_ADD, addr, base, off, 0);
        H->emit(IR_STORE, 0, addr, pay, 0);              /* word 1 = payload */
        curty = TY_USER + ti;
        return base;
    }
}

/* `match subject { pat => expr, ... }`
 *
 * Lowered as a CHAIN OF COMPARISONS, not a jump table: arms are few, and a
 * chain needs no contiguity in the tag values (an enum may set `= 10`).
 *
 * Every arm writes its value into ONE result temp and jumps to the end, which
 * is what makes match an EXPRESSION rather than a statement.
 *
 * PATTERNS supported: `Enum::Variant`, `Enum::Variant(binding)`, an integer
 * literal, and `_`.  Bindings are scoped to their arm — pushed before the arm
 * body and popped after, so `Some(v) => v` sees v and the next arm does not.
 */
hword Compiler::match_expr()
{
    hword subj;
    int subjty;
    hword res  = H->new_temp();
    int lend   = H->new_label();
    hword tagv = 0;
    int boxed  = 0;
    int ti     = -1;
    int armn   = 0;
    int rty    = TY_UNKNOWN;
    int covered[MAXFIELD];
    int haswild = 0;
    { int i = 0; while (i < MAXFIELD) { covered[i] = 0; i = i + 1; } }

    lx.next();                                  /* `match` */
    subj = expr();
    subjty = curty;
    if (subjty >= TY_USER) {
        ti = subjty - TY_USER;
        if (ti < ntype && tkind[ti] == 1) boxed = tboxed[ti];
    }
    if (lx.tok != T_LBRACE) { error("expected { after the match subject"); return res; }
    lx.next();

    /* The tag to compare against: for a boxed enum it is word 0 of the block. */
    if (boxed) {
        hword t = H->new_temp();
        H->emit(IR_LOAD, t, subj, 0, 0);
        tagv = t;
    } else tagv = subj;

    while (lx.tok != T_RBRACE && lx.tok != T_EOF) {
        int lnext = H->new_label();
        int lbody = H->new_label();
        int wild  = 0;
        int nbound = 0;
        hword want = 0;

        if (lx.tok == T_IDENT && strcmp(lx.name, "_") == 0) {
            wild = 1; haswild = 1; lx.next();
        } else if (lx.tok == T_NUM) {
            want = H->new_temp();
            H->emit(IR_CONST, want, (hword)lx.num, 0, 0);
            lx.next();
        } else if (lx.tok == T_IDENT) {
            char tn[NAMELEN];
            int pti;
            strcpy(tn, lx.name);
            lx.next();
            pti = type_find(tn);
            if (lx.tok == T_COLONCOLON) lx.next();
            if (pti < 0 || lx.tok != T_IDENT) { error("expected Enum::Variant"); }
            else {
                int vi = field_find(pti, lx.name);
                if (vi < 0) error("no such variant");
                else {
                    if (pti == ti && vi < MAXFIELD) covered[vi] = 1;
                    want = H->new_temp();
                    H->emit(IR_CONST, want, (hword)tftype[pti * MAXFIELD + vi], 0, 0);
                }
                lx.next();
                /* `Variant(binding)` — bind the payload for this arm only. */
                if (lx.tok == T_LP) {
                    lx.next();
                    if (lx.tok != T_IDENT) error("expected a binding name");
                    else {
                        hword off  = H->new_temp();
                        hword addr = H->new_temp();
                        hword pv   = H->new_temp();
                        H->emit(IR_CONST, off, 8, 0, 0);
                        H->emit(IR_ADD, addr, subj, off, 0);
                        H->emit(IR_LOAD, pv, addr, 0, 0);
                        if (vi >= 0) sym_add(lx.name, pv, tfpay[pti * MAXFIELD + vi]);
                        nbound = 1;
                        lx.next();
                    }
                    if (lx.tok != T_RP) error("expected ) after the binding");
                    else lx.next();
                }
            }
        } else { error("expected a pattern"); lx.next(); }

        if (lx.tok != T_FATARROW) error("expected => after the pattern");
        else lx.next();

        if (wild) H->emit_jmp(lbody);
        else {
            hword c = H->new_temp();
            H->emit(IR_CMP_EQ, c, tagv, want, 0);
            H->emit_br(c, lbody, lnext);
        }
        H->emit_labelop(lbody);
        {
            hword v = expr();
            /* Every arm must agree on a type — that is what gives the whole
             * match a type, and it is checked rather than assumed. */
            if (armn == 0) rty = curty;
            else if (rty != TY_UNKNOWN) need(curty, rty, "match arm");
            H->emit(IR_MOV, res, v, 0, 0);
        }
        /* Pop the arm's binding: it must not be visible to later arms. */
        if (nbound) nsym = nsym - 1;
        H->emit_jmp(lend);
        H->emit_labelop(lnext);
        armn = armn + 1;
        if (!accept(T_COMMA)) break;
    }
    if (lx.tok != T_RBRACE) error("expected } to close the match");
    else lx.next();

    /* ★ EXHAUSTIVENESS.  A match on an enum must cover every variant or carry a
     * `_` arm — this is the check that makes Option/Result safe to use, because
     * without it a forgotten `None` silently yields 0 at runtime instead of
     * being a compile error.  Reported per missing variant, by name, since
     * "non-exhaustive" alone does not tell you what to add. */
    if (ti >= 0 && ti < ntype && tkind[ti] == 1 && !haswild) {
        int i = 0;
        while (i < tnfield[ti]) {
            if (!covered[i]) {
                fprintf(stderr,
                        "wry: line %d: non-exhaustive match: variant %s::%s not covered\n",
                        srcline(), tnames + ti * NAMELEN,
                        tfield + (ti * MAXFIELD + i) * NAMELEN);
                nerr = nerr + 1;
            }
            i = i + 1;
        }
    }

    /* Falling off the end means no arm matched.  With the check above that is
     * unreachable for an enum; it still matters for integer patterns, where
     * exhaustiveness is not decidable. */
    {
        hword z = H->new_temp();
        H->emit(IR_CONST, z, 0, 0, 0);
        H->emit(IR_MOV, res, z, 0, 0);
    }
    H->emit_labelop(lend);
    curty = rty;
    return res;
}

/* `impl Type { fn name(self, ...) { ... } }`
 *
 * A method becomes an ordinary function named `Type__name` whose FIRST argument
 * is the receiver.  `x.m(a)` is then just `Type__m(x, a)`, resolved from x's
 * STATIC type — static dispatch, no vtables.  `dyn Trait` would need those and
 * is not implemented.
 *
 * `impl Trait for Type` parses the same way and lowers identically: the trait
 * name is checked and otherwise unused, because dispatch is static.  That is a
 * real limitation, not a hidden one — a trait cannot yet be a bound or a type.
 */
void Compiler::impl_block()
{
    char tname[NAMELEN];
    int ti;
    lx.next();                                  /* `impl` */
    type_params();                              /* `impl<T> ...` */
    if (lx.tok != T_IDENT) { error("expected a type name after impl"); return; }
    strcpy(tname, lx.name);
    lx.next();
    skip_type_args();                           /* `Option<T>` */
    if (lx.tok == T_FOR) {                      /* `impl Trait for Type` */
        lx.next();
        if (lx.tok != T_IDENT) { error("expected a type name after for"); return; }
        strcpy(tname, lx.name);
        lx.next();
        skip_type_args();
    }
    ti = type_find(tname);
    if (ti < 0) error("impl on an unknown type");
    if (lx.tok != T_LBRACE) { error("expected { after impl"); return; }
    lx.next();
    impl_type = ti;                             /* function() reads this */
    while (lx.tok == T_FN) function();
    impl_type = -1;
    if (lx.tok != T_RBRACE) error("expected } to close the impl block");
    else lx.next();
}

/* `trait Name { fn f(self) -> T; }` — parsed so `impl Trait for Type` can name
 * it.  Signatures are skipped: with static dispatch nothing downstream needs
 * them, and default method bodies are not supported. */
void Compiler::trait_decl()
{
    lx.next();                                  /* `trait` */
    if (lx.tok != T_IDENT) { error("expected a trait name"); return; }
    lx.next();
    if (lx.tok != T_LBRACE) { error("expected { after the trait name"); return; }
    lx.next();
    {
        int depth = 1;
        while (lx.tok != T_EOF && depth > 0) {
            if (lx.tok == T_LBRACE) depth = depth + 1;
            if (lx.tok == T_RBRACE) depth = depth - 1;
            if (depth > 0) lx.next();
        }
    }
    if (lx.tok == T_RBRACE) lx.next();
}

/* `recv.mname(args)` -> `Type__mname(recv, args)`. */
hword Compiler::method_call(hword recv, int recvty, char *mname)
{
    char full[NAMELEN * 2];
    hword args[8];
    int argc = 1;
    hword callee = H->new_temp();
    hword res    = H->new_temp();
    int ti = recvty - TY_USER;
    if (recvty < TY_USER || ti >= ntype) {
        error("method call on a non-user type");
        return res;
    }
    strcpy(full, tnames + ti * NAMELEN);
    strcat(full, "__");
    strcat(full, mname);

    args[0] = recv;
    lx.next();                                   /* `(` */
    while (lx.tok != T_RP && lx.tok != T_EOF) {
        if (argc < 8) { args[argc] = expr(); argc = argc + 1; }
        else { expr(); error("too many arguments"); }
        if (!accept(T_COMMA)) break;
    }
    if (lx.tok != T_RP) error("expected ) after the method arguments");
    else lx.next();

    H->emit(IR_CONST, callee, (hword)(long)hofos_bcpl(full), 1, 0);
    if (argc >= 4) H->emit(IR_SETARG, 0, args[3], 4, 0);
    if (argc >= 5) H->emit(IR_SETARG, 0, args[4], 5, 0);
    {
        hword a1 = argc >= 1 ? args[0] : 0;
        hword a2 = argc >= 2 ? args[1] : 0;
        hword a3 = argc >= 3 ? args[2] : 0;
        H->set_arg3(H->emit_call(res, callee, (hword)argc, a1, a2), a3);
    }
    {
        int fi = fn_find(full);
        curty = fi >= 0 ? frett[fi] : TY_I64;
    }
    return res;
}

/* Skip a balanced `<...>` argument list.  Nested arguments are counted so
 * `Result<Option<i64>, i64>` closes on the right `>`. */
void Compiler::skip_type_args()
{
    if (lx.tok != T_LT) return;
    {
        int depth = 0;
        while (lx.tok != T_EOF) {
            if (lx.tok == T_LT) depth = depth + 1;
            if (lx.tok == T_GT) { depth = depth - 1; if (depth == 0) { lx.next(); return; } }
            lx.next();
        }
    }
}

/* Skip a balanced `( ... )` — the argument list of an `fn(T) -> U` type. */
void Compiler::skip_type_args_paren()
{
    int depth = 0;
    while (lx.tok != T_EOF) {
        if (lx.tok == T_LP) depth = depth + 1;
        if (lx.tok == T_RP) { depth = depth - 1; if (depth == 0) { lx.next(); return; } }
        lx.next();
    }
}

int Compiler::tparam_find(char *nm)
{
    int i = 0;
    while (i < ntparam) { if (strcmp(tparam + i * NAMELEN, nm) == 0) return i; i = i + 1; }
    return -1;
}
