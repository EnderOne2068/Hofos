/* Wry — the Rust frontend for Hofos.  SHARED HEADER.
 *
 * Wry is built from SEVERAL translation units linked together, rather than one
 * file:
 *     wry-lex.cc    the lexer
 *     wry-mac.cc    macro_rules! and the println!/print! stdlib
 *     wry-clos.cc   closures (lambda lifting)
 *     wry-core.cc   the core:: prelude, as Rust source
 *     wry-parse.cc  expressions, statements, items, codegen
 *     wry-main.cc   the driver
 * They share this header, which carries the token/type enums and the Lexer and
 * Compiler class declarations.  Splitting matters for more than tidiness: a
 * language frontend grows fastest in the parser, and one file meant every edit
 * recompiled the lot.  It also keeps the promise to HISTIC honest — separate
 * compilation is something Histic must handle, so exercising it here is the
 * point rather than a side effect.
 */
#ifndef WRY_H
#define WRY_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../maxima/hofos.h"

/* Which libhofos to load, chosen at COMPILE time by the target's own predefined
 * macros.  Histic predefines these per driver — histic-x86-windows defines
 * _WIN32/_WIN64, histic-x86-linux defines __linux__/__unix__ — so a Wry built by
 * either one picks up the right shared library with no flag and no #ifdef in the
 * build system.  hofos.h already carries the dlopen/LoadLibrary shim itself. */
#if defined(_WIN32)
#  define WRY_DEFAULT_LIB "libhofos.dll"
#elif defined(__linux__) || defined(__unix__)
#  define WRY_DEFAULT_LIB "./libhofos.so"
#else
#  define WRY_DEFAULT_LIB "./libhofos.so"
#endif

#define MAXSRC   (1 << 20)
#define MAXSYM   256
#define MAXFN    256
#define NAMELEN  64
#define MAXLOOP  32
#define MAXEXPAND 16               /* macro expansion nesting depth */
#define MAXMAC   64                /* macro_rules! definitions */
#define MAXRULE  256               /* rules across all macros (a macro may hold several) */
#define MAXARG   32                /* arguments to one macro call (repetition soaks up many) */
#define MACBUF   (1 << 18)         /* arena for captured rules + expansions */
#define MACEXP   (1 << 14)         /* scratch for ONE expansion, before it is interned */
#define MAXSTR   1024              /* longest string literal */
#define MAXTYPE  64                /* struct + enum declarations */
#define MAXFIELD 16                /* fields per struct / variants per enum */
#define LAMBUF   (1 << 15)         /* source text of lifted closures */

/* ---- types ---------------------------------------------------------------
 * A real type table, not decoration.  Rust's integer types differ only in width
 * and signedness, so a small code carries everything the checker needs.
 *
 * WIDTH NOTE: i32/i64 are distinguished for CHECKING but both are emitted as
 * 64-bit machine words, because HANGMAN's arithmetic is word-sized.  That makes
 * the checker useful without dragging in narrowing semantics, and it is where a
 * later pass would add LOAD4/STORE4 truncation.
 *
 * DELIBERATE DEVIATION FROM RUST: an unsuffixed integer literal defaults to i64
 * here, not i32.  The machine word is 64-bit and Hofos has no separate 32-bit
 * arithmetic, so defaulting to i32 would make every literal need a widening
 * conversion that changes nothing. */
/* A USER type (struct or enum) is encoded as TY_USER + its index in the type
 * table.  Keeping a type in ONE int is what lets the whole checker stay as it
 * was — every `int ty` slot, argument and return type keeps working unchanged. */
enum { TY_UNKNOWN = 0, TY_UNIT, TY_BOOL, TY_I32, TY_I64, TY_STR, TY_FN, TY_USER = 64 };

static char *tyname(int t)
{
    if (t == TY_UNIT) return "()";
    if (t == TY_BOOL) return "bool";
    if (t == TY_I32)  return "i32";
    if (t == TY_I64)  return "i64";
    if (t == TY_STR)  return "&str";
    if (t == TY_FN)   return "fn";
    return "?";
}

/* Is `t` an integer type (so arithmetic and ordering apply)? */
static int tyint(int t) { return t == TY_I32 || t == TY_I64; }

/* ---- tokens -------------------------------------------------------------- */
enum {
    T_EOF = 0, T_IDENT, T_NUM, T_STR,
    T_LP, T_RP, T_LBRACE, T_RBRACE, T_COMMA, T_SEMI, T_COLON, T_ARROW,
    T_PLUS, T_MINUS, T_STAR, T_SLASH, T_PCT, T_ASSIGN,
    T_EQ, T_NE, T_LT, T_LE, T_GT, T_GE,
    T_ANDAND, T_OROR, T_NOT, T_BANG, T_DOTDOT, T_DOLLAR, T_COLONCOLON, T_DOT, T_PIPE,
    /* keywords */
    T_FN, T_LET, T_MUT, T_IF, T_ELSE, T_WHILE, T_LOOP, T_BREAK,
    T_RETURN, T_CONTINUE, T_FOR, T_IN, T_STRUCT, T_ENUM,
    T_MATCH, T_IMPL, T_TRAIT, T_SELF, T_FATARROW
};

/* ---- lexer --------------------------------------------------------------- */
class Lexer {
public:
    char *src;
    int   len;
    int   pos;
    /* Source offset where the CURRENT token BEGAN.  `pos` already points PAST
     * it, so rewinding to `pos` re-lexes the NEXT token and silently loses the
     * current one — which is why one token of lookahead needs this. */
    int   tokpos;
    int   line;
    int   tok;
    long  num;
    char  name[NAMELEN];
    /* Text of the string literal just scanned.  Kept in its own buffer rather
     * than `name`, which is only NAMELEN and is also used for identifiers. */
    char  str[MAXSTR];
    int   strlen_;

    /* Source STACK.  A macro expansion is spliced in by pushing its text as a
     * new source; the lexer pops back to the caller when it runs out.  This is
     * the same shape as an include stack, and it is what lets an expansion
     * itself contain a macro call. */
    char *stk_src[MAXEXPAND];
    int   stk_len[MAXEXPAND];
    int   stk_pos[MAXEXPAND];
    int   stk_line[MAXEXPAND];
    int   nstk;

    void  init(char *s, int n);
    void  next();
    int   cur();
    int   la1();
    void  adv();
    void  skipspace();
    int   keyword(char *s);
    void  push_source(char *s, int n);
};

/* ---- compiler ------------------------------------------------------------ */
/* Single pass: parse and emit HANGMAN as we go, exactly as Histic does for C.
 * A `let` binding becomes an IR temp; there is no separate AST.  That keeps M1
 * small, and the typed mid-layer that a borrow checker will need can be added
 * without disturbing the emission code. */
class Compiler {
public:
    Lexer  lx;
    struct hofos_api *H;
    int    nerr;

    /* locals: parallel arrays, no containers */
    char   snames[MAXSYM * NAMELEN];
    hword  svals[MAXSYM];
    int    stypes[MAXSYM];
    int    nsym;

    /* function signatures, so a call can be checked against the declaration */
    char   fnames[MAXFN * NAMELEN];
    int    frett[MAXFN];                 /* return type */
    int    fnargs[MAXFN];                /* parameter count */
    int    fptype[MAXFN * 8];            /* parameter types */
    int    nfn;

    /* ---- user types: structs and enums ----------------------------------
     * Both live in ONE table because a type name resolves the same way for
     * either, and an expression like `Name { .. }` or `Name::Variant` has to be
     * dispatched on which kind it turned out to be.
     *
     * STRUCT LAYOUT: fields are word slots, so field i sits at byte 8*i of a
     * heap block from VECALLOC.  There is no padding to compute because every
     * field is one machine word — the same choice the rest of Wry makes.
     *
     * ENUMS are C-like: each variant is a distinct integer, and the enum's
     * values ARE i64 at runtime.  That is the honest subset; Rust's data-carrying
     * variants need a tag plus a payload union and are NOT implemented. */
    char   tnames[MAXTYPE * NAMELEN];
    int    tkind[MAXTYPE];                     /* 0 = struct, 1 = enum */
    int    tnfield[MAXTYPE];
    char   tfield[MAXTYPE * MAXFIELD * NAMELEN];
    int    tftype[MAXTYPE * MAXFIELD];         /* struct: field type; enum: value */
    /* Payload type of an enum variant, or TY_UNIT for a bare one.  ONE payload
     * word per variant — enough for Option/Result, which is what core:: needs. */
    int    tfpay[MAXTYPE * MAXFIELD];
    int    tboxed[MAXTYPE];                    /* enum: any variant carries data? */
    int    ntype;

    /* ---- generics -------------------------------------------------------
     * Type parameters are ERASED, not monomorphised.  That is not a shortcut
     * taken to save work: every Wry value is exactly ONE MACHINE WORD, so `T`
     * has the same representation whatever it binds to.  Rust monomorphises
     * because layouts differ per instantiation; here they cannot.  So `<T>` is
     * parsed, T resolves to a wildcard type that unifies with anything, and one
     * body serves every instantiation.
     * The cost is honest and worth stating: a generic body is checked ONCE and
     * loosely, so a misuse inside it surfaces at the call site or not at all. */
    char   tparam[8 * NAMELEN];                /* type params in scope */
    int    ntparam;
    /* Set while parsing an `impl` body: the type whose methods these are, or -1.
     * function() renames `fn m` to `Type__m` and gives it a `self` parameter. */
    int    impl_type;
    /* Lines the core prelude occupies.  Diagnostics report srcline(), not
     * lx.line: the prelude is prepended to the user's file, so a raw line number
     * is offset by its length and points at nothing the user wrote. */
    int    prelude_lines;

    /* ---- closures -------------------------------------------------------
     * LAMBDA LIFTING: `|x| x + 1` becomes a top-level `fn __wry_lambdaN(x)`,
     * and the closure VALUE is that function's ADDRESS (IR_FUNCADDR).  Calling
     * one is an indirect call, which the backend already supports — `ax_call`
     * emits `call rax` whenever the callee temp carries no name.
     *
     * The lifted functions cannot be emitted mid-expression (a FUNCDEF cannot
     * nest inside another function's IR), so their SOURCE TEXT is accumulated
     * here and compiled after the main pass — the same deferral `__wry_writen`
     * and Histic's out-of-line member bodies use.
     *
     * ★ NON-CAPTURING ONLY.  A closure that names an enclosing local is
     * REJECTED with a diagnostic rather than silently reading a dead stack
     * slot: a real capture needs an environment block and a 2-word closure
     * value, which is a bigger change than this. */
    char   lambuf[LAMBUF];
    int    lambn;
    int    nlambda;
    int    srcline();

    /* Type of the expression most recently emitted.  The expression functions
     * return an IR temp; this carries its TYPE alongside. */
    int    curty;
    int    currett;                      /* declared return type of the function being compiled */

    /* ---- macro_rules! -----------------------------------------------------
     * Rules are captured as SOURCE TEXT, not as an AST — the same technique
     * Ofden uses for D templates and Histic for inline member bodies.  An
     * invocation matches its argument token-trees against the pattern, binds
     * each `$name:frag` to the argument's source span, then splices the
     * substituted body back in through the lexer's source stack.
     *
     * A macro OWNS A LIST OF RULES (`mrule0`..`+mnrule`), tried in order —
     * which is why the name table and the rule table are separate.  A rule is
     * either FIXED-arity, or ends in a REPETITION `$($x:expr),*` that soaks up
     * every remaining argument (`rrep` = the repeated parameter's index, and
     * every parameter before it is fixed).  That shape is exactly what the
     * format-style macros need: `($fmt:expr, $($a:expr),*)`.
     * SCOPE: one repetition per rule and no nesting; selection is by ARITY,
     * not by fragment specifier. */
    char   mnames[MAXMAC * NAMELEN];
    int    mrule0[MAXMAC];               /* index of this macro's first rule */
    int    mnrule[MAXMAC];               /* how many rules it has */
    int    nmac;

    char  *rparm[MAXRULE * 8];           /* parameter names, e.g. "a" */
    int    rnparm[MAXRULE];
    char  *rbody[MAXRULE];               /* rule body text */
    int    rblen[MAXRULE];
    int    rrep[MAXRULE];                /* repeated param index, -1 = fixed arity */
    int    rsep[MAXRULE];                /* repetition separator char, 0 = none */
    int    nrule;

    char   macarena[MACBUF];             /* holds captured bodies + expansions */
    /* Scratch for the expansion under construction.  It cannot BE the arena
     * slot: the final length is unknown until the walk finishes, so reserving
     * a worst-case block per call burned a fixed slice of the arena on every
     * expansion and ran it dry after a handful.  Build here, intern the exact
     * length after.  Safe to reuse across NESTED expansions because the inner
     * one only starts once the outer result has already been interned. */
    char   macexp[MACEXP];
    int    macovf;                       /* an expansion overflowed macexp */
    int    macused;

    int    mac_find(char *nm);
    char  *mac_alloc(int n);
    void   macro_def();
    int    mac_subst(char *out, int w, char *b, int bn, int ri,
                     char **acap, int *alen, int rk);
    int    macro_call(char *nm, int wrap);
    int    fmt_macro(char *nm);          /* println! / print! — the stdlib */
    int    panic_macro();                /* panic! — used by unwrap */
    void   emit_writes(char *text);
    void   emit_call1(char *fn, hword arg);
    void   emit_wrch(int ch);
    void   emit_writen_fn();             /* the synthesised decimal printer */
    int    need_writen;

    /* the enclosing loops' break targets, for `break` */
    hword  brk[MAXLOOP];
    hword  cont[MAXLOOP];
    int    nloop;

    void   init(struct hofos_api *api);
    void   error(char *msg);
    int    accept(int t);
    void   expect(int t, char *what);

    int    sym_find(char *nm);
    void   sym_add(char *nm, hword t, int ty);
    int    parse_type();
    int    type_find(char *nm);
    int    field_find(int ti, char *nm);
    void   struct_decl();
    void   enum_decl();
    hword  heap_alloc(int nwords);
    hword  struct_literal(int ti);
    hword  field_access(hword base, int ty);
    hword  postfix(hword v);
    hword  match_expr();
    hword  closure_expr();
    void   impl_block();
    void   trait_decl();
    int    tparam_find(char *nm);
    void   type_params();
    void   skip_type_args();
    void   skip_type_args_paren();
    hword  enum_construct(int ti, int vi);
    hword  method_call(hword recv, int recvty, char *mname);
    int    fn_find(char *nm);
    void   fn_add(char *nm, int rt, int na, int *pt);
    void   need(int got, int want, char *what);

    /* Rust is EXPRESSION-ORIENTED: a block's final expression, written without
     * a trailing semicolon, is the block's value — `fn f() -> i64 { 42 }` needs
     * no `return`.  stmt() reports such a trailing expression through these, and
     * block() returns the last one (0 = the block has no value). */
    hword  tailval;
    int    hastail;

    hword  primary();
    hword  unary();
    hword  binary(int minprec);
    hword  expr();
    void   stmt();
    hword  block();
    void   function();
    void   program();
};

/* The core:: prelude (wry-core.cc): Option/Result and their closure-free
 * methods, as Rust source that Wry compiles itself. */
char *wry_core_prelude();
int   wry_core_prelude_len();

#endif /* WRY_H */
