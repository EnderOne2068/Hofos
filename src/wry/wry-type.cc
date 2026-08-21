#include "wry.h"

/* ---- user types: structs and enums --------------------------------------
 *
 * Its own translation unit, which is the point of the split: this is a whole
 * language feature that can be worked on without touching the parser or the
 * macro engine.
 *
 * STRUCTS lower to a heap block of word-sized fields.  `S { a: 1, b: 2 }`
 * allocates a block and stores each field at 8*index; `p.b` loads from it.  No
 * padding or alignment maths is needed because every field is exactly one
 * machine word — the same simplification the rest of Wry already makes.
 *
 * ENUMS come in TWO REPRESENTATIONS, chosen per enum by whether any variant
 * carries data.  The rule is worth stating plainly because it is what keeps
 * C-like enums cheap while making Option/Result possible:
 *
 *   NO variant carries data  ->  UNBOXED.  The value IS the tag integer, so
 *       `Colour::Red` is a constant and costs nothing.
 *   ANY variant carries data ->  BOXED.  EVERY value of that enum is a pointer
 *       to a 2-word block [tag, payload].  Uniform within the enum, so `match`
 *       reads the tag the same way whichever variant it holds.
 *
 * Mixing the two within one enum would mean a tag that is sometimes a value and
 * sometimes a pointer, which nothing downstream could tell apart.
 */

/* `<T, E>` after a type or impl name.  Recorded as type parameters in scope so
 * `parse_type` resolves them to TY_UNKNOWN — the erasure model (see wry.h).
 * Shared by struct, enum and impl because all three spell it the same way. */
void Compiler::type_params()
{
    if (lx.tok != T_LT) return;
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

/* Allocate `nwords` machine words that OUTLIVE the current function.
 *
 * ★ NOT IR_VECALLOC.  That is a STACK vector (hofoshdr: "tN = stack vector of
 * a1 words"), so a struct or boxed enum built inside a function dies with its
 * frame.  The symptom is nasty and non-local: `Option::map` returns a Some(..)
 * that prints correctly, and then reads as None a few calls later once the
 * frame is reused.  `__alloc` is the runtime's bump allocator — a BACKEND
 * primitive present in every program — and its blocks live in the .bss heap. */
hword Compiler::heap_alloc(int nwords)
{
    hword n   = H->new_temp();
    hword res = H->new_temp();
    hword callee = H->new_temp();
    H->emit(IR_CONST, n, (hword)nwords, 0, 0);
    H->emit(IR_CONST, callee, (hword)(long)hofos_bcpl("__alloc"), 1, 0);
    H->set_arg3(H->emit_call(res, callee, 1, n, 0), 0);
    return res;
}

int Compiler::type_find(char *nm)
{
    int i = 0;
    while (i < ntype) { if (strcmp(tnames + i * NAMELEN, nm) == 0) return i; i = i + 1; }
    return -1;
}

int Compiler::field_find(int ti, char *nm)
{
    int i = 0;
    while (i < tnfield[ti]) {
        if (strcmp(tfield + (ti * MAXFIELD + i) * NAMELEN, nm) == 0) return i;
        i = i + 1;
    }
    return -1;
}

/* `struct Name { a: i64, b: bool }` */
void Compiler::struct_decl()
{
    int ti;
    lx.next();                                  /* `struct` */
    if (lx.tok != T_IDENT) { error("expected a struct name"); return; }
    if (ntype >= MAXTYPE) { error("too many types"); return; }
    /* A duplicate name is an ERROR, as in Rust.  It matters most with the core
     * prelude in play: a program declaring its own Option would otherwise be
     * silently shadowed by the prelude's and behave in ways its source does not
     * show.  Use `-fno-core` to declare your own. */
    if (type_find(lx.name) >= 0) { error("a type with this name already exists"); }
    ti = ntype;
    strcpy(tnames + ti * NAMELEN, lx.name);
    tkind[ti] = 0;
    tnfield[ti] = 0;
    lx.next();
    type_params();
    if (lx.tok != T_LBRACE) { error("expected { after the struct name"); return; }
    lx.next();
    while (lx.tok != T_RBRACE && lx.tok != T_EOF) {
        if (lx.tok != T_IDENT) { error("expected a field name"); return; }
        if (tnfield[ti] < MAXFIELD) {
            strcpy(tfield + (ti * MAXFIELD + tnfield[ti]) * NAMELEN, lx.name);
        }
        lx.next();
        if (lx.tok != T_COLON) { error("expected : after a field name"); return; }
        lx.next();
        /* The type table must already contain this struct before its own fields
         * are parsed, or a self-referential field could not name it.  ntype is
         * bumped at the end, so a field of this type resolves through ti. */
        if (tnfield[ti] < MAXFIELD) {
            tftype[ti * MAXFIELD + tnfield[ti]] = parse_type();
            tnfield[ti] = tnfield[ti] + 1;
        } else parse_type();
        if (!accept(T_COMMA)) break;
    }
    if (lx.tok != T_RBRACE) { error("expected } to close the struct"); return; }
    lx.next();
    ntype = ntype + 1;
}

/* `enum Name { A, B = 5, C }` — C-like, with optional explicit values. */
void Compiler::enum_decl()
{
    int ti;
    int val = 0;
    lx.next();                                  /* `enum` */
    if (lx.tok != T_IDENT) { error("expected an enum name"); return; }
    if (ntype >= MAXTYPE) { error("too many types"); return; }
    /* A duplicate name is an ERROR, as in Rust.  It matters most with the core
     * prelude in play: a program declaring its own Option would otherwise be
     * silently shadowed by the prelude's and behave in ways its source does not
     * show.  Use `-fno-core` to declare your own. */
    if (type_find(lx.name) >= 0) { error("a type with this name already exists"); }
    ti = ntype;
    strcpy(tnames + ti * NAMELEN, lx.name);
    tkind[ti] = 1;
    tnfield[ti] = 0;
    tboxed[ti] = 0;
    lx.next();
    type_params();
    if (lx.tok != T_LBRACE) { error("expected { after the enum name"); return; }
    lx.next();
    while (lx.tok != T_RBRACE && lx.tok != T_EOF) {
        if (lx.tok != T_IDENT) { error("expected a variant name"); return; }
        if (tnfield[ti] < MAXFIELD) {
            strcpy(tfield + (ti * MAXFIELD + tnfield[ti]) * NAMELEN, lx.name);
        }
        lx.next();
        /* `Variant(Type)` — a data-carrying variant.  ONE payload word, which is
         * exactly what Option<T>/Result<T,E> need and therefore what core::
         * needs.  A variant carrying several values would want a payload block;
         * not implemented, and not claimed. */
        if (tnfield[ti] < MAXFIELD) tfpay[ti * MAXFIELD + tnfield[ti]] = TY_UNIT;
        if (lx.tok == T_LP) {
            lx.next();
            if (tnfield[ti] < MAXFIELD) tfpay[ti * MAXFIELD + tnfield[ti]] = parse_type();
            else parse_type();
            if (lx.tok != T_RP) { error("expected ) after the variant payload"); return; }
            lx.next();
            tboxed[ti] = 1;                     /* this enum is now BOXED */
        }
        if (lx.tok == T_ASSIGN) {               /* `= <int>` sets the counter */
            lx.next();
            if (lx.tok != T_NUM) { error("expected a number after ="); return; }
            val = (int)lx.num;
            lx.next();
        }
        if (tnfield[ti] < MAXFIELD) {
            tftype[ti * MAXFIELD + tnfield[ti]] = val;
            tnfield[ti] = tnfield[ti] + 1;
        }
        val = val + 1;
        if (!accept(T_COMMA)) break;
    }
    if (lx.tok != T_RBRACE) { error("expected } to close the enum"); return; }
    lx.next();
    ntype = ntype + 1;
}

/* `Name { field: expr, ... }` — allocate a block and fill it.
 *
 * Fields may be written in ANY order, so each one is stored at the index its
 * NAME resolves to rather than the order it appears in.  Omitted fields are left
 * as whatever VECALLOC gave back, and a missing field is reported: silently
 * zero-filling would hide a real mistake. */
hword Compiler::struct_literal(int ti)
{
    hword base;
    int seen[MAXFIELD];
    int i = 0;
    while (i < MAXFIELD) { seen[i] = 0; i = i + 1; }

    base = heap_alloc(tnfield[ti]);

    lx.next();                                  /* `{` */
    while (lx.tok != T_RBRACE && lx.tok != T_EOF) {
        char fname[NAMELEN];
        int fi;
        hword v;
        hword off;
        hword addr;
        if (lx.tok != T_IDENT) { error("expected a field name"); return base; }
        strcpy(fname, lx.name);
        lx.next();
        if (lx.tok != T_COLON) { error("expected : after a field name"); return base; }
        lx.next();
        fi = field_find(ti, fname);
        if (fi < 0) { error("no such field"); }
        v = expr();
        if (fi >= 0) {
            need(curty, tftype[ti * MAXFIELD + fi], "struct field");
            seen[fi] = 1;
            off  = H->new_temp();
            addr = H->new_temp();
            H->emit(IR_CONST, off, (hword)(fi * 8), 0, 0);
            H->emit(IR_ADD, addr, base, off, 0);
            H->emit(IR_STORE, 0, addr, v, 0);
        }
        if (!accept(T_COMMA)) break;
    }
    if (lx.tok != T_RBRACE) { error("expected } to close the struct literal"); }
    else lx.next();
    i = 0;
    while (i < tnfield[ti]) {
        if (!seen[i]) {
            fprintf(stderr, "wry: line %d: struct %s: field %s not initialised\n",
                    srcline(), tnames + ti * NAMELEN,
                    tfield + (ti * MAXFIELD + i) * NAMELEN);
            nerr = nerr + 1;
        }
        i = i + 1;
    }
    curty = TY_USER + ti;
    return base;
}

/* `.field` on a value of struct type — the caller has consumed the base
 * expression and the dot. */
hword Compiler::field_access(hword base, int ty)
{
    int ti = ty - TY_USER;
    int fi;
    hword off;
    hword addr;
    hword res;
    if (ty < TY_USER || ti >= ntype || tkind[ti] != 0) {
        error("field access on a non-struct value");
        curty = TY_UNKNOWN;
        return base;
    }
    if (lx.tok != T_IDENT) { error("expected a field name after ."); return base; }
    fi = field_find(ti, lx.name);
    if (fi < 0) { error("no such field"); lx.next(); return base; }
    lx.next();
    off  = H->new_temp();
    addr = H->new_temp();
    res  = H->new_temp();
    H->emit(IR_CONST, off, (hword)(fi * 8), 0, 0);
    H->emit(IR_ADD, addr, base, off, 0);
    H->emit(IR_LOAD, res, addr, 0, 0);
    curty = tftype[ti * MAXFIELD + fi];
    return res;
}
