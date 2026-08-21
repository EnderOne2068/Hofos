/* haxMac -- a native-code compiler for the Maxima language, built on libhofos.
 *
 * A host-side C tool (like NAL).  It lexes/parses REAL Maxima syntax with Maxima's
 * own operator-precedence grammar (nparse.lisp binding powers), evaluates it with
 * haxMac's OWN symbolic-algebra engine (symbolic.h -- diff/expand/ratsimp/subst
 * over exact rationals; it does NOT call Maxima), and emits a native executable via
 * libhofos that reproduces the program's output.  A CL runtime (SBCL) is embedded
 * only for Maxima's :lisp / CL interoperability, never to do the algebra.
 *
 * PARSER: Pratt / top-down operator precedence, Maxima's exact binding powers:
 *   :  :=  180/20 (right)   !  160   ^  140/139 (right)   .  130   *  /  120
 *   +  -  100 (unary rbp 134)   =  #  <  >  <=  >=  80   not 70   and 65   or 60
 * SEMANTICS: `;` evaluates AND displays the result; `$` evaluates silently.
 * load("pkg") searches ., ~/.maxima/ (mxpm layout) for pkg[.mac] and runs it.
 *
 * Build (Unix): cc haxmac.c -ldl -o haxMac
 * Use         : ./haxMac prog.mac -o prog [-L path/to/libhofos.so] [-O<n>]
 */

#include "hofos.h"
#include "symbolic.h"
#include <setjmp.h>
#if defined(__unix__)
#include <dirent.h>
#include <sys/stat.h>
#endif

/* ---- optional embedded Common Lisp (SBCL) for :lisp interop ----------------
 * Built only with -DHAXMAC_LISP, linking the SBCL runtime object:
 *   cc haxmac.c /usr/lib/sbcl/sbcl.o -ldl -lpthread -lzstd -lm \
 *      -Wl,--export-dynamic -DHAXMAC_LISP -o haxMac
 * hax_lisp_eval is filled by haxlisp.core's callable-exports (see build_haxlisp.lisp).
 * initialize_lisp is booted lazily on the first :lisp form. */
#ifdef HAXMAC_LISP
extern int initialize_lisp(int argc, char **argv, char **envp);
void *hax_lisp_eval = 0;
static int hax_lisp_ready = 0;
static void hax_lisp_boot(void)
{
    if (hax_lisp_ready) return;
    const char *core = getenv("HAXLISP_CORE"); if (!core) core = "haxlisp.core";
    char *args[] = { "haxMac", "--core", (char *)core, "--noinform", "--disable-ldb",
                     "--end-runtime-options", "--no-sysinit", "--no-userinit", NULL };
    int n = 0; while (args[n]) n++;
    initialize_lisp(n, args, NULL);
    hax_lisp_ready = 1;
}
static const char *hax_lisp_call(const char *form)
{
    hax_lisp_boot();
    if (!hax_lisp_eval) return "lisp-error: hax_lisp_eval not resolved (rebuild core?)";
    return ((const char *(*)(const char *))hax_lisp_eval)(form);
}
#endif

/* ------------------------------------------------------------------ tokens --- */

enum {
    T_EOF, T_INT, T_FLOAT, T_SYM, T_STR,
    T_PLUS, T_MINUS, T_STAR, T_SLASH, T_CARET, T_CARET2, T_DOT,
    T_EQ, T_HASH, T_LT, T_GT, T_LE, T_GE,
    T_COLON, T_COLON2, T_DEFOP, T_DEFOP2,          /* :  ::  :=  ::= */
    T_BANG, T_BANG2,                                /* !  !! */
    T_LPAR, T_RPAR, T_LBRK, T_RBRK, T_COMMA, T_SEMI, T_DOLLAR, T_QUOTE,
    T_IF, T_THEN, T_ELSE, T_ELSEIF, T_AND, T_OR, T_NOT,
    T_TRUE, T_FALSE, T_BLOCK, T_FOR, T_DO, T_WHILE, T_RETURN,
    T_THRU, T_STEP, T_IN, T_UNLESS, T_LISP
};

static const char *src;
static size_t      srcpos;
static int         line = 1;
static const char *srcname = "<stdin>";

static int    tok;
static long   tok_int;
static double tok_flt;
static char   tok_txt[256];
static int    tok_line;

static jmp_buf *hax_catch = 0;   /* when set, die() unwinds here instead of exiting */
static char hax_lasterr[256];
static void die(const char *msg)
{
    if (hax_catch) { snprintf(hax_lasterr, sizeof hax_lasterr, "%s", msg); longjmp(*hax_catch, 1); }
    fprintf(stderr, "haxMac: %s:%d: %s\n", srcname, tok_line, msg);
    exit(1);
}

static int kw(const char *s)
{
    if (!strcmp(s, "if"))     return T_IF;
    if (!strcmp(s, "then"))   return T_THEN;
    if (!strcmp(s, "else"))   return T_ELSE;
    if (!strcmp(s, "elseif")) return T_ELSEIF;
    if (!strcmp(s, "and"))    return T_AND;
    if (!strcmp(s, "or"))     return T_OR;
    if (!strcmp(s, "not"))    return T_NOT;
    if (!strcmp(s, "true"))   return T_TRUE;
    if (!strcmp(s, "false"))  return T_FALSE;
    /* block and return are ordinary function-call syntax (handled in eval_call),
     * so they stay T_SYM -- do NOT make them keyword tokens. */
    if (!strcmp(s, "for"))    return T_FOR;
    if (!strcmp(s, "do"))     return T_DO;
    if (!strcmp(s, "while"))  return T_WHILE;
    if (!strcmp(s, "thru"))   return T_THRU;
    if (!strcmp(s, "step"))   return T_STEP;
    if (!strcmp(s, "in"))     return T_IN;
    if (!strcmp(s, "unless")) return T_UNLESS;
    return T_SYM;
}

static void lex_next(void)
{
    for (;;) {                                  /* whitespace + block comments */
        int c = src[srcpos];
        if (c == '\n') { line++; srcpos++; continue; }
        if (c == ' ' || c == '\t' || c == '\r') { srcpos++; continue; }
        if (c == '/' && src[srcpos + 1] == '*') {
            srcpos += 2;
            while (src[srcpos] && !(src[srcpos] == '*' && src[srcpos + 1] == '/')) {
                if (src[srcpos] == '\n') line++;
                srcpos++;
            }
            if (src[srcpos]) srcpos += 2;
            continue;
        }
        break;
    }

    tok_line = line;
    int c = src[srcpos];
    if (c == 0) { tok = T_EOF; return; }

    if ((c >= '0' && c <= '9') || (c == '.' && src[srcpos + 1] >= '0' && src[srcpos + 1] <= '9')) {
        size_t start = srcpos; int isflt = 0;
        while (src[srcpos] >= '0' && src[srcpos] <= '9') srcpos++;
        if (src[srcpos] == '.') { isflt = 1; srcpos++; while (src[srcpos] >= '0' && src[srcpos] <= '9') srcpos++; }
        if (src[srcpos] == 'e' || src[srcpos] == 'E' || src[srcpos] == 'd' || src[srcpos] == 'D') {
            isflt = 1; srcpos++;
            if (src[srcpos] == '+' || src[srcpos] == '-') srcpos++;
            while (src[srcpos] >= '0' && src[srcpos] <= '9') srcpos++;
        }
        { char buf[64]; size_t n = srcpos - start; if (n >= sizeof buf) n = sizeof buf - 1;
          memcpy(buf, src + start, n); buf[n] = 0;
          if (isflt) { tok = T_FLOAT; tok_flt = atof(buf); } else { tok = T_INT; tok_int = atol(buf); } }
        return;
    }

    if ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_' || c == '%') {
        size_t n = 0;
        while (((c = src[srcpos]) >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') ||
               (c >= '0' && c <= '9') || c == '_' || c == '%') {
            if (n < sizeof tok_txt - 1) tok_txt[n++] = (char)c;
            srcpos++;
        }
        tok_txt[n] = 0; tok = kw(tok_txt);
        return;
    }

    if (c == '"') {
        size_t n = 0; srcpos++;
        while (src[srcpos] && src[srcpos] != '"') {
            int ch = src[srcpos++];
            if (ch == '\\' && src[srcpos]) ch = src[srcpos++];
            if (n < sizeof tok_txt - 1) tok_txt[n++] = (char)ch;
        }
        if (src[srcpos] == '"') srcpos++;
        tok_txt[n] = 0; tok = T_STR;
        return;
    }

    /* :lisp <form>  -- capture the rest of the line as a Common Lisp form */
    if (c == ':' && src[srcpos+1]=='l' && src[srcpos+2]=='i' && src[srcpos+3]=='s' && src[srcpos+4]=='p'
        && !((src[srcpos+5]>='a'&&src[srcpos+5]<='z')||(src[srcpos+5]>='A'&&src[srcpos+5]<='Z')||
             (src[srcpos+5]>='0'&&src[srcpos+5]<='9')||src[srcpos+5]=='_')) {
        srcpos += 5;
        while (src[srcpos] == ' ' || src[srcpos] == '\t') srcpos++;
        size_t st = srcpos;
        while (src[srcpos] && src[srcpos] != '\n') srcpos++;
        size_t len = srcpos - st;
        while (len > 0 && (src[st+len-1]==';'||src[st+len-1]=='$'||src[st+len-1]==' '||src[st+len-1]=='\t'||src[st+len-1]=='\r')) len--;
        if (len >= sizeof tok_txt) len = sizeof tok_txt - 1;
        memcpy(tok_txt, src + st, len); tok_txt[len] = 0;
        tok = T_LISP; return;
    }

    #define TWO(a,b) (c==(a) && src[srcpos+1]==(b))
    if (c == ':' && src[srcpos+1] == ':' && src[srcpos+2] == '=') { srcpos += 3; tok = T_DEFOP2; return; }
    if (TWO(':','=')) { srcpos += 2; tok = T_DEFOP;  return; }
    if (TWO(':',':')) { srcpos += 2; tok = T_COLON2; return; }
    if (TWO('<','=')) { srcpos += 2; tok = T_LE;     return; }
    if (TWO('>','=')) { srcpos += 2; tok = T_GE;     return; }
    if (TWO('!','!')) { srcpos += 2; tok = T_BANG2;  return; }
    if (TWO('^','^')) { srcpos += 2; tok = T_CARET2; return; }

    srcpos++;
    switch (c) {
        case '+': tok = T_PLUS;   return;
        case '-': tok = T_MINUS;  return;
        case '*': tok = (src[srcpos]=='*') ? (srcpos++, T_CARET) : T_STAR; return;
        case '/': tok = T_SLASH;  return;
        case '^': tok = T_CARET;  return;
        case '.': tok = T_DOT;    return;
        case '=': tok = T_EQ;     return;
        case '#': tok = T_HASH;   return;
        case '<': tok = T_LT;     return;
        case '>': tok = T_GT;     return;
        case ':': tok = T_COLON;  return;
        case '!': tok = T_BANG;   return;
        case '(': tok = T_LPAR;   return;
        case ')': tok = T_RPAR;   return;
        case '[': tok = T_LBRK;   return;
        case ']': tok = T_RBRK;   return;
        case ',': tok = T_COMMA;  return;
        case ';': tok = T_SEMI;   return;
        case '$': tok = T_DOLLAR; return;
        case '\'':tok = T_QUOTE;  return;
        default:  die("unexpected character");
    }
    #undef TWO
}

/* -------------------------------------------------------------------- AST ---- */

enum { N_INT, N_FLOAT, N_SYM, N_STR, N_BIN, N_UNARY, N_POSTFIX, N_CALL,
       N_SUBSCRIPT, N_LIST, N_IF, N_ASSIGN, N_DEF, N_QUOTE, N_MPROGN, N_FOR, N_LISP };
enum { FOR_THRU, FOR_WHILE, FOR_UNLESS, FOR_IN };   /* N_FOR modes (in Node.op) */

typedef struct Node {
    int  kind;
    long ival;
    double fval;
    char name[128];
    int  op;
    char *sval;              /* N_LISP: the raw Common Lisp form text */
    struct Node *a, *b, *c;
    struct Node **elems; int nelems;
} Node;

static Node *node(int kind)
{ Node *n = (Node *)calloc(1, sizeof *n); if (!n) { perror("calloc"); exit(1); } n->kind = kind; return n; }
static Node **grow(Node **v, int *cap, int need)
{ if (need <= *cap) return v; *cap = need < 8 ? 8 : need * 2; return (Node **)realloc(v, (size_t)*cap * sizeof *v); }

/* ---------------------------------------------------------------- Pratt -------- */

static int lbp(int t)
{
    switch (t) {
        case T_COLON: case T_COLON2: case T_DEFOP: case T_DEFOP2: return 180;
        case T_BANG:  case T_BANG2:                                return 160;
        case T_CARET: case T_CARET2:                               return 140;
        case T_DOT:                                                return 130;
        case T_STAR:  case T_SLASH:                                return 120;
        case T_PLUS:  case T_MINUS:                                return 100;
        case T_EQ: case T_HASH: case T_LT: case T_GT: case T_LE: case T_GE: return 80;
        case T_AND:                                                return 65;
        case T_OR:                                                 return 60;
        case T_LPAR:  case T_LBRK:                                 return 200;
        default:                                                   return 0;
    }
}

static Node *parse_expr(int rbp);

static Node *parse_call_tail(Node *fn)
{
    Node *n = node(N_CALL); n->a = fn; int cap = 0;
    lex_next();
    if (tok != T_RPAR) {
        for (;;) {
            n->elems = grow(n->elems, &cap, n->nelems + 1);
            n->elems[n->nelems++] = parse_expr(10);
            if (tok == T_COMMA) { lex_next(); continue; }
            break;
        }
    }
    if (tok != T_RPAR) die("expected ')' in argument list");
    lex_next();
    return n;
}

static Node *parse_if(void)
{
    Node *n = node(N_IF);
    lex_next();
    n->a = parse_expr(25);
    if (tok != T_THEN) die("expected 'then'");
    lex_next();
    n->b = parse_expr(25);
    if (tok == T_ELSE) { lex_next(); n->c = parse_expr(25); }
    else if (tok == T_ELSEIF) { n->c = parse_if(); }
    else n->c = 0;
    return n;
}

/* for VAR : INIT [step STEP] (thru|while|unless) LIMIT do BODY   |   for VAR in LIST do BODY */
static Node *parse_for(void)
{
    Node *n = node(N_FOR);
    lex_next();
    if (tok != T_SYM) die("expected a loop variable after 'for'");
    memcpy(n->name, tok_txt, sizeof n->name); lex_next();
    if (tok == T_IN) { lex_next(); n->a = parse_expr(25); n->op = FOR_IN; }
    else {
        if (tok == T_COLON) { lex_next(); n->a = parse_expr(25); }          /* : init (optional) */
        else { n->a = node(N_INT); n->a->ival = 1; }                        /*   defaults to 1   */
        if (tok == T_STEP) { lex_next(); n->b = parse_expr(25); } else { n->b = node(N_INT); n->b->ival = 1; }
        if      (tok == T_THRU)   { lex_next(); n->c = parse_expr(25); n->op = FOR_THRU; }
        else if (tok == T_WHILE)  { lex_next(); n->c = parse_expr(25); n->op = FOR_WHILE; }
        else if (tok == T_UNLESS) { lex_next(); n->c = parse_expr(25); n->op = FOR_UNLESS; }
        else die("expected ':', 'in', 'thru', 'while', or 'unless' in for-loop");
    }
    if (tok != T_DO) die("expected 'do' in for-loop");
    lex_next();
    { int cap = 0; n->elems = grow(n->elems, &cap, 1); n->elems[n->nelems++] = parse_expr(25); }
    return n;
}

static Node *nud(int t)
{
    switch (t) {
        case T_FOR:   return parse_for();
        case T_LISP:  { Node *n = node(N_LISP); n->sval = strdup(tok_txt); lex_next(); return n; }
        case T_INT:   { Node *n = node(N_INT);   n->ival = tok_int; lex_next(); return n; }
        case T_FLOAT: { Node *n = node(N_FLOAT); n->fval = tok_flt; lex_next(); return n; }
        case T_STR:   { Node *n = node(N_STR); memcpy(n->name, tok_txt, sizeof n->name); lex_next(); return n; }
        case T_TRUE:  { Node *n = node(N_INT); n->ival = 1; lex_next(); return n; }
        case T_FALSE: { Node *n = node(N_INT); n->ival = 0; lex_next(); return n; }
        case T_SYM:   { Node *n = node(N_SYM); memcpy(n->name, tok_txt, sizeof n->name); lex_next(); return n; }
        case T_MINUS: { lex_next(); Node *n = node(N_UNARY); n->op = T_MINUS; n->a = parse_expr(134); return n; }
        case T_PLUS:  { lex_next(); return parse_expr(134); }
        case T_NOT:   { lex_next(); Node *n = node(N_UNARY); n->op = T_NOT; n->a = parse_expr(70); return n; }
        case T_QUOTE: { lex_next(); Node *n = node(N_QUOTE); n->a = parse_expr(190); return n; }
        case T_IF:    return parse_if();
        case T_LPAR: {
            lex_next();
            Node *first = parse_expr(0);
            if (tok == T_COMMA) {
                Node *n = node(N_MPROGN); int cap = 0;
                n->elems = grow(n->elems, &cap, 1); n->elems[n->nelems++] = first;
                while (tok == T_COMMA) { lex_next(); n->elems = grow(n->elems, &cap, n->nelems+1); n->elems[n->nelems++] = parse_expr(0); }
                if (tok != T_RPAR) die("expected ')'");
                lex_next(); return n;
            }
            if (tok != T_RPAR) die("expected ')'");
            lex_next(); return first;
        }
        case T_LBRK: {
            Node *n = node(N_LIST); int cap = 0;
            lex_next();
            if (tok != T_RBRK) {
                for (;;) { n->elems = grow(n->elems, &cap, n->nelems+1); n->elems[n->nelems++] = parse_expr(10);
                           if (tok == T_COMMA) { lex_next(); continue; } break; }
            }
            if (tok != T_RBRK) die("expected ']'");
            lex_next(); return n;
        }
        default: die("expected an expression"); return 0;
    }
}

static Node *led(int t, Node *left)
{
    switch (t) {
        case T_PLUS: case T_MINUS: case T_STAR: case T_SLASH:
        case T_EQ: case T_HASH: case T_LT: case T_GT: case T_LE: case T_GE:
        case T_AND: case T_OR: case T_DOT: {
            Node *n = node(N_BIN); n->op = t; n->a = left; n->b = parse_expr(lbp(t)); return n;
        }
        case T_CARET: case T_CARET2: { Node *n = node(N_BIN); n->op = T_CARET; n->a = left; n->b = parse_expr(139); return n; }
        case T_COLON: case T_COLON2:  { Node *n = node(N_ASSIGN); n->a = left; n->b = parse_expr(20); return n; }
        case T_DEFOP: case T_DEFOP2:  { Node *n = node(N_DEF);    n->a = left; n->b = parse_expr(20); return n; }
        case T_BANG: case T_BANG2:    { Node *n = node(N_POSTFIX); n->op = t; n->a = left; return n; }
        case T_LPAR:  return parse_call_tail(left);
        case T_LBRK:  { Node *n = node(N_SUBSCRIPT); n->a = left; lex_next(); int cap = 0;
                        for (;;) { n->elems = grow(n->elems, &cap, n->nelems+1); n->elems[n->nelems++] = parse_expr(0);
                                   if (tok == T_COMMA) { lex_next(); continue; } break; }
                        n->b = n->elems[0];               /* first index (kept for the symbolic path) */
                        if (tok != T_RBRK) die("expected ']'"); lex_next(); return n; }
        default: die("operator cannot be used in infix position"); return 0;
    }
}

static Node *parse_expr(int rbp)
{
    int t = tok;
    Node *left;
    if (t == T_INT || t == T_FLOAT || t == T_STR || t == T_SYM || t == T_TRUE ||
        t == T_FALSE || t == T_MINUS || t == T_PLUS || t == T_NOT || t == T_QUOTE ||
        t == T_IF || t == T_FOR || t == T_LISP || t == T_LPAR || t == T_LBRK) left = nud(t);
    else { die("expected an expression"); return 0; }
    while (lbp(tok) > rbp) {
        int op = tok;
        if (op != T_LPAR && op != T_LBRK) lex_next();
        left = led(op, left);
    }
    return left;
}

/* --------------------------------------------------------------- evaluator --- */

typedef struct VEnv { struct VEnv *parent; char names[128][64]; Expr *vals[128]; int n; } VEnv;
static VEnv genv;                          /* the global environment */
static Expr *venv_find(VEnv *e, const char *nm)
{ for (; e; e = e->parent) for (int i = 0; i < e->n; i++) if (!strcmp(e->names[i], nm)) return e->vals[i]; return 0; }
static void venv_bind(VEnv *e, const char *nm, Expr *v)
{ for (int i = 0; i < e->n; i++) if (!strcmp(e->names[i], nm)) { e->vals[i] = v; return; }
  if (e->n >= 128) die("too many variables"); strncpy(e->names[e->n], nm, 63); e->vals[e->n++] = v; }
/* assign in the nearest scope that already has `nm` (e.g. a block/loop local),
 * otherwise create it in the global environment. */
static void venv_assign(VEnv *env, const char *nm, Expr *v)
{ for (VEnv *e = env; e; e = e->parent) for (int i = 0; i < e->n; i++) if (!strcmp(e->names[i], nm)) { e->vals[i] = v; return; }
  venv_bind(&genv, nm, v); }

static int   hax_returning = 0;    /* set by return(x) to unwind block / for loops */
static Expr *hax_retval = 0;

typedef struct { char name[64]; char params[8][64]; int nparams; Node *body; int is_float; int ret_shape; } FuncDef;
/* does this AST subtree contain a float literal (=> compile the function in float mode)? */
static int node_has_float(Node *n)
{ if (!n) return 0; if (n->kind == N_FLOAT) return 1;
  if (node_has_float(n->a) || node_has_float(n->b) || node_has_float(n->c)) return 1;
  for (int i = 0; i < n->nelems; i++) if (node_has_float(n->elems[i])) return 1; return 0; }
static FuncDef funcs[1024]; static int nfuncs;
static FuncDef *func_find(const char *nm) { for (int i = 0; i < nfuncs; i++) if (!strcmp(funcs[i].name, nm)) return &funcs[i]; return 0; }

static Expr *eval(Node *n, VEnv *env);

/* apply the 1-arg function named `fn` (user-defined or a symbolic builtin) to x */
static Expr *apply1(const char *fn, Expr *x)
{
    FuncDef *f = func_find(fn);
    if (f) { if (f->nparams != 1) die("map: function does not take exactly 1 argument");
             VEnv c; c.parent = &genv; c.n = 0; venv_bind(&c, f->params[0], x); return eval(f->body, &c); }
    Expr **a = e_vec(1); a[0] = x; return mk_func(fn, a, 1);
}

/* ---- matrices: represented as E_FUNC "matrix" whose args are the rows (E_LIST) --- */
static int is_matrix(Expr *e) { return e->kind == E_FUNC && !strcmp(e->name, "matrix") && e->n > 0 && e->a[0]->kind == E_LIST; }

static Expr *mat_mul(Expr *A, Expr *B)
{
    int m = A->n, k = A->a[0]->n, nn = B->a[0]->n;
    if (k != B->n) die("matrix multiply: dimension mismatch");
    Expr **rows = e_vec(m);
    for (int i = 0; i < m; i++) {
        Expr **row = e_vec(nn);
        for (int j = 0; j < nn; j++) { Expr *s = e_int(0);
            for (int l = 0; l < k; l++) s = s_add(s, s_mul(A->a[i]->a[l], B->a[l]->a[j])); row[j] = s; }
        rows[i] = e_list(row, nn);
    }
    return mk_func("matrix", rows, m);
}
static Expr *mat_minor(Expr *M, int si, int sj)
{
    int nr = M->n, nc = M->a[0]->n; Expr **rows = e_vec(nr - 1); int ri = 0;
    for (int i = 0; i < nr; i++) { if (i == si) continue; Expr **row = e_vec(nc - 1); int cj = 0;
        for (int j = 0; j < nc; j++) { if (j == sj) continue; row[cj++] = M->a[i]->a[j]; } rows[ri++] = e_list(row, nc - 1); }
    return mk_func("matrix", rows, nr - 1);
}
static Expr *mat_det(Expr *M)
{
    int nr = M->n; if (nr != M->a[0]->n) die("determinant: matrix is not square");
    if (nr == 1) return M->a[0]->a[0];
    if (nr == 2) return s_sub(s_mul(M->a[0]->a[0], M->a[1]->a[1]), s_mul(M->a[0]->a[1], M->a[1]->a[0]));
    Expr *det = e_int(0);
    for (int j = 0; j < nr; j++) { Expr *cof = s_mul(M->a[0]->a[j], mat_det(mat_minor(M, 0, j)));
        det = (j % 2 == 0) ? s_add(det, cof) : s_sub(det, cof); }
    return det;
}

/* first symbol appearing in an expression (the variable, for factor) */
static const char *first_sym(Expr *e)
{ if (e->kind == E_SYM) return e->name; for (int i = 0; i < e->n; i++) { const char *s = first_sym(e->a[i]); if (s) return s; } return 0; }

/* assumption database (assume/is/forget) */
static Expr *assumptions[256]; static int nassume;
static int is_assumed(Expr *p) { for (int i = 0; i < nassume; i++) if (e_equal(assumptions[i], p)) return 1; return 0; }

/* quote:  'expr  -> the expression WITHOUT applying functions or looking up values. */
static Expr *eval_quote(Node *n)
{
    switch (n->kind) {
        case N_INT: return e_int(n->ival);
        case N_FLOAT: return e_flt(n->fval);
        case N_SYM: return e_sym(n->name);
        case N_UNARY: return n->op == T_MINUS ? s_neg(eval_quote(n->a)) : eval_quote(n->a);
        case N_BIN: { Expr *a = eval_quote(n->a), *b = eval_quote(n->b);
            switch (n->op) { case T_PLUS: return s_add(a, b); case T_MINUS: return s_sub(a, b);
                case T_STAR: return s_mul(a, b); case T_SLASH: return s_mul(a, s_pow(b, e_int(-1)));
                case T_CARET: return s_pow(a, b); default: { Expr **ar = e_vec(2); ar[0] = a; ar[1] = b; return mk_func("?", ar, 2); } } }
        case N_CALL: { if (n->a->kind != N_SYM) die("quote: bad call"); Expr **a = e_vec(n->nelems ? n->nelems : 1);
            for (int i = 0; i < n->nelems; i++) a[i] = eval_quote(n->elems[i]); return mk_func(n->a->name, a, n->nelems); }
        default: die("quote: unsupported expression"); return 0;
    }
}

static int rat_cmp(Expr *a, Expr *b)   /* both E_NUM; returns sign of a-b */
{ long l = a->num * b->den, r = b->num * a->den; return l < r ? -1 : l > r ? 1 : 0; }
static int num_cmp(Expr *a, Expr *b)   /* numeric (rational or float) compare */
{ if (a->kind == E_NUM && b->kind == E_NUM) return rat_cmp(a, b); double x = to_dbl(a), y = to_dbl(b); return x < y ? -1 : x > y ? 1 : 0; }

static Expr *eval_call(Node *n, VEnv *env)
{
    if (n->a->kind != N_SYM) die("only named functions can be called");
    const char *fn = n->a->name;

    /* special forms: the "variable" argument is evaluated and must yield a symbol.
     * This lets diff/subst work both directly (diff(x^4,x)) and through function
     * parameters (deriv2(f,v):=diff(diff(f,v),v) with v bound to x). */
    if (!strcmp(fn, "diff")) {
        if (n->nelems < 2) die("diff needs (expr, var)");
        Expr *e = eval(n->elems[0], env);
        Expr *v = eval(n->elems[1], env);
        if (v->kind != E_SYM) die("diff: 2nd argument must be a variable");
        int k = 1;
        if (n->nelems >= 3) { Expr *ke = eval(n->elems[2], env); if (ke->kind == E_NUM && ke->den == 1) k = (int)ke->num; }
        for (int i = 0; i < k; i++) e = diff(e, v->name);
        return e;
    }
    if (!strcmp(fn, "subst")) {
        if (n->nelems != 3) die("subst needs (new, old, expr)");
        Expr *nw = eval(n->elems[0], env);
        Expr *old = eval(n->elems[1], env);
        if (old->kind != E_SYM) die("subst: 2nd argument must be a variable");
        Expr *e = eval(n->elems[2], env);
        return subst(e, old->name, nw);
    }
    if (!strcmp(fn, "expand"))                                      return expand(eval(n->elems[0], env));
    if (!strcmp(fn, "ratsimp") || !strcmp(fn, "fullratsimp"))       return simplify(expand(eval(n->elems[0], env)));
    if (!strcmp(fn, "ev"))                                          return simplify(eval(n->elems[0], env));

    if (!strcmp(fn, "return")) { hax_retval = n->nelems ? eval(n->elems[0], env) : e_int(0); hax_returning = 1; return hax_retval; }

    if (!strcmp(fn, "block")) {                       /* block([locals], s1, s2, ...) */
        VEnv child; child.parent = env; child.n = 0; int start = 0;
        if (n->nelems > 0 && n->elems[0]->kind == N_LIST) {
            Node *loc = n->elems[0];
            for (int i = 0; i < loc->nelems; i++) {
                Node *d = loc->elems[i];
                if (d->kind == N_SYM) venv_bind(&child, d->name, e_sym(d->name));
                else if (d->kind == N_ASSIGN && d->a->kind == N_SYM) venv_bind(&child, d->a->name, eval(d->b, &child));
                else die("block: locals must be names or name:init");
            }
            start = 1;
        }
        Expr *last = e_int(0);
        for (int i = start; i < n->nelems; i++) { last = eval(n->elems[i], &child); if (hax_returning) { hax_returning = 0; return hax_retval; } }
        return last;
    }

    if (!strcmp(fn, "lambda")) {                      /* lambda([args], body) -> anon function */
        if (n->nelems < 2 || n->elems[0]->kind != N_LIST) die("lambda([args], body) expected");
        Node *pl = n->elems[0];
        static int lamctr = 0;
        FuncDef *f = &funcs[nfuncs < 1024 ? nfuncs++ : 1023];
        snprintf(f->name, sizeof f->name, "%%lambda%d", lamctr++);
        if (pl->nelems > 8) die("lambda: too many parameters");
        f->nparams = pl->nelems;
        for (int i = 0; i < pl->nelems; i++) { if (pl->elems[i]->kind != N_SYM) die("lambda parameters must be names"); strncpy(f->params[i], pl->elems[i]->name, 63); }
        f->body = n->elems[n->nelems - 1];            /* body = last form */
        return e_sym(f->name);
    }

    if (!strcmp(fn, "makelist")) {                    /* makelist(expr, var, lo, hi) */
        if (n->nelems != 4 || n->elems[1]->kind != N_SYM) die("makelist(expr, var, lo, hi) expected");
        Expr *lo = eval(n->elems[2], env), *hi = eval(n->elems[3], env);
        if (lo->kind != E_NUM || lo->den != 1 || hi->kind != E_NUM || hi->den != 1) die("makelist: bounds must be integers");
        int cnt = (int)(hi->num - lo->num + 1); if (cnt < 0) cnt = 0;
        Expr **a = e_vec(cnt > 0 ? cnt : 1); int k = 0;
        VEnv c; c.parent = env; c.n = 0;
        for (long i = lo->num; i <= hi->num; i++) { venv_bind(&c, n->elems[1]->name, e_int(i)); a[k++] = eval(n->elems[0], &c); }
        return e_list(a, k);
    }

    if (!strcmp(fn, "sum") || !strcmp(fn, "product")) {   /* sum/product(expr, var, lo, hi) */
        int prod = fn[0] == 'p';
        if (n->nelems != 4 || n->elems[1]->kind != N_SYM) die("sum/product(expr, var, lo, hi) expected");
        Expr *lo = eval(n->elems[2], env), *hi = eval(n->elems[3], env);
        if (lo->kind != E_NUM || lo->den != 1 || hi->kind != E_NUM || hi->den != 1) die("sum/product: bounds must be integers");
        Expr *acc = e_int(prod ? 1 : 0); VEnv c; c.parent = env; c.n = 0;
        for (long i = lo->num; i <= hi->num; i++) { venv_bind(&c, n->elems[1]->name, e_int(i));
            Expr *t = eval(n->elems[0], &c); acc = prod ? s_mul(acc, t) : s_add(acc, t); }
        return acc;
    }

    /* ordinary: evaluate all arguments */
    Expr **args = e_vec(n->nelems);
    for (int i = 0; i < n->nelems; i++) args[i] = eval(n->elems[i], env);

    /* list operations */
    if (n->nelems == 1 && !strcmp(fn, "length"))  { if (args[0]->kind != E_LIST) die("length: argument is not a list"); return e_int(args[0]->n); }
    if (n->nelems == 1 && !strcmp(fn, "first"))   { if (args[0]->kind != E_LIST || args[0]->n < 1) die("first: empty or non-list"); return args[0]->a[0]; }
    if (n->nelems == 1 && !strcmp(fn, "last"))    { if (args[0]->kind != E_LIST || args[0]->n < 1) die("last: empty or non-list"); return args[0]->a[args[0]->n - 1]; }
    if (n->nelems == 1 && !strcmp(fn, "rest"))    { if (args[0]->kind != E_LIST) die("rest: not a list"); int m = args[0]->n > 0 ? args[0]->n - 1 : 0; Expr **a = e_vec(m ? m : 1); for (int i = 0; i < m; i++) a[i] = args[0]->a[i + 1]; return e_list(a, m); }
    if (n->nelems == 1 && !strcmp(fn, "reverse")) { if (args[0]->kind != E_LIST) die("reverse: not a list"); int m = args[0]->n; Expr **a = e_vec(m ? m : 1); for (int i = 0; i < m; i++) a[i] = args[0]->a[m - 1 - i]; return e_list(a, m); }
    if (n->nelems == 2 && !strcmp(fn, "cons"))    { if (args[1]->kind != E_LIST) die("cons: 2nd argument not a list"); int m = args[1]->n; Expr **a = e_vec(m + 1); a[0] = args[0]; for (int i = 0; i < m; i++) a[i + 1] = args[1]->a[i]; return e_list(a, m + 1); }
    if (n->nelems == 2 && !strcmp(fn, "endcons")) { if (args[1]->kind != E_LIST) die("endcons: 2nd argument not a list"); int m = args[1]->n; Expr **a = e_vec(m + 1); for (int i = 0; i < m; i++) a[i] = args[1]->a[i]; a[m] = args[0]; return e_list(a, m + 1); }
    if (n->nelems == 2 && !strcmp(fn, "append"))  { if (args[0]->kind != E_LIST || args[1]->kind != E_LIST) die("append: arguments must be lists"); int m = args[0]->n + args[1]->n; Expr **a = e_vec(m ? m : 1); int k = 0; for (int i = 0; i < args[0]->n; i++) a[k++] = args[0]->a[i]; for (int i = 0; i < args[1]->n; i++) a[k++] = args[1]->a[i]; return e_list(a, m); }
    if (n->nelems == 2 && !strcmp(fn, "map"))     { if (args[0]->kind != E_SYM) die("map: 1st argument must be a function"); if (args[1]->kind != E_LIST) die("map: 2nd argument must be a list"); Expr **a = e_vec(args[1]->n ? args[1]->n : 1); for (int i = 0; i < args[1]->n; i++) a[i] = apply1(args[0]->name, args[1]->a[i]); return e_list(a, args[1]->n); }
    if (n->nelems == 2 && !strcmp(fn, "apply"))   {
        if (args[0]->kind != E_SYM) die("apply: 1st argument must be a function");
        if (args[1]->kind != E_LIST) die("apply: 2nd argument must be a list");
        FuncDef *f = func_find(args[0]->name);
        if (f) { if (f->nparams != args[1]->n) die("apply: argument count mismatch"); VEnv c; c.parent = &genv; c.n = 0; for (int i = 0; i < args[1]->n; i++) venv_bind(&c, f->params[i], args[1]->a[i]); return eval(f->body, &c); }
        Expr **a = e_vec(args[1]->n ? args[1]->n : 1); for (int i = 0; i < args[1]->n; i++) a[i] = args[1]->a[i]; return mk_func(args[0]->name, a, args[1]->n);
    }
    if (n->nelems == 1 && !strcmp(fn, "factorial")) { if (args[0]->kind == E_NUM && args[0]->den == 1 && args[0]->num >= 0) { long r = 1; for (long i = 2; i <= args[0]->num; i++) r *= i; return e_int(r); } return mk_func("factorial", args, 1); }

    /* matrices */
    if (!strcmp(fn, "matrix")) {
        int cols = -1;
        for (int i = 0; i < n->nelems; i++) { if (args[i]->kind != E_LIST) die("matrix: each row must be a list"); if (cols < 0) cols = args[i]->n; else if (args[i]->n != cols) die("matrix: rows must have equal length"); }
        return mk_func("matrix", args, n->nelems);
    }
    if (n->nelems == 1 && !strcmp(fn, "transpose")) {
        Expr *M = args[0]; if (!is_matrix(M)) die("transpose: argument is not a matrix");
        int nr = M->n, nc = M->a[0]->n; Expr **rows = e_vec(nc);
        for (int j = 0; j < nc; j++) { Expr **row = e_vec(nr); for (int i = 0; i < nr; i++) row[i] = M->a[i]->a[j]; rows[j] = e_list(row, nr); }
        return mk_func("matrix", rows, nc);
    }
    if (n->nelems == 1 && !strcmp(fn, "determinant")) { if (!is_matrix(args[0])) die("determinant: argument is not a matrix"); return mat_det(args[0]); }

    /* numeric builtins (operate on exact numbers) */
    if (n->nelems == 2 && !strcmp(fn, "mod")) { if (args[0]->kind != E_NUM || args[1]->kind != E_NUM || args[0]->den != 1 || args[1]->den != 1) die("mod: integer arguments"); long a = args[0]->num, b = args[1]->num; if (b == 0) die("mod by zero"); long r = a % b; if (r != 0 && (r < 0) != (b < 0)) r += b; return e_int(r); }
    if (n->nelems == 2 && !strcmp(fn, "gcd")) { if (args[0]->kind != E_NUM || args[1]->kind != E_NUM || args[0]->den != 1 || args[1]->den != 1) die("gcd: integer arguments"); return e_int(sym_gcd(args[0]->num, args[1]->num)); }
    if ((!strcmp(fn, "min") || !strcmp(fn, "max")) && n->nelems >= 1) {
        int mx = fn[1] == 'a'; Expr *best = args[0]; if (best->kind != E_NUM) die("min/max: numeric arguments");
        for (int i = 1; i < n->nelems; i++) { if (args[i]->kind != E_NUM) die("min/max: numeric arguments"); if (mx ? rat_cmp(args[i], best) > 0 : rat_cmp(args[i], best) < 0) best = args[i]; }
        return best;
    }
    if (n->nelems == 1 && !strcmp(fn, "floor"))   { if (args[0]->kind == E_FLT) return e_int((long)floor(args[0]->fval)); if (args[0]->kind != E_NUM) die("floor: numeric"); long q = args[0]->num / args[0]->den; if (args[0]->num % args[0]->den != 0 && args[0]->num < 0) q--; return e_int(q); }
    if (n->nelems == 1 && !strcmp(fn, "ceiling")) { if (args[0]->kind == E_FLT) return e_int((long)ceil(args[0]->fval)); if (args[0]->kind != E_NUM) die("ceiling: numeric"); long q = args[0]->num / args[0]->den; if (args[0]->num % args[0]->den != 0 && args[0]->num > 0) q++; return e_int(q); }
    if (n->nelems == 1 && (!strcmp(fn, "float") || !strcmp(fn, "bfloat"))) {
        if (args[0]->kind == E_NUM) return e_flt(to_dbl(args[0]));
        if (args[0]->kind == E_FLT) return args[0];
        if (args[0]->kind == E_SYM && !strcmp(args[0]->name, "%pi")) return e_flt(M_PI);
        if (args[0]->kind == E_SYM && !strcmp(args[0]->name, "%e"))  return e_flt(M_E);
        die("float: cannot convert a symbolic expression to a number");
    }

    /* factoring, predicates, assumptions */
    if (n->nelems == 1 && !strcmp(fn, "factor")) {
        Expr *e = args[0];
        if (e->kind == E_NUM && e->den == 1) return factor_int(e->num);
        { const char *var = first_sym(e); if (var) { Expr *pf = poly_factor(e, var); if (pf) return pf; } }
        return mk_func("factor", args, 1);
    }
    if (n->nelems == 2 && !strcmp(fn, "equal")) {
        if (is_num(args[0]) && is_num(args[1])) return e_sym(num_cmp(args[0], args[1]) == 0 ? "true" : "false");
        if (e_equal(args[0], args[1])) return e_sym("true");
        Expr **ar = e_vec(2); ar[0] = args[0]; ar[1] = args[1]; return mk_func("equal", ar, 2);
    }
    if (n->nelems == 1 && !strcmp(fn, "is")) {
        Expr *c = args[0];
        if (c->kind == E_NUM) return e_sym(c->num != 0 ? "true" : "false");
        if (c->kind == E_SYM && (!strcmp(c->name, "true") || !strcmp(c->name, "false"))) return c;
        if (is_assumed(c)) return e_sym("true");
        return e_sym("unknown");
    }
    if (n->nelems == 1 && !strcmp(fn, "assume")) { if (nassume < 256) assumptions[nassume++] = args[0]; Expr **l = e_vec(1); l[0] = args[0]; return e_list(l, 1); }
    if (n->nelems == 1 && !strcmp(fn, "forget")) { for (int i = 0; i < nassume; i++) if (e_equal(assumptions[i], args[0])) { assumptions[i] = assumptions[--nassume]; break; } return e_sym("done"); }

    if (n->nelems == 1) {
        if (!strcmp(fn, "sqrt")) return s_pow(args[0], e_num(1, 2));
        if (!strcmp(fn, "sin") || !strcmp(fn, "cos") || !strcmp(fn, "tan") ||
            !strcmp(fn, "exp") || !strcmp(fn, "log") || !strcmp(fn, "abs"))
            return mk_func(fn, args, 1);
    }

    FuncDef *f = func_find(fn);
    if (f) {
        if (f->nparams != n->nelems) die("wrong number of arguments in call");
        VEnv child; child.parent = &genv; child.n = 0;
        for (int i = 0; i < f->nparams; i++) venv_bind(&child, f->params[i], args[i]);
        return eval(f->body, &child);
    }
    /* a variable bound to a lambda:  g : lambda([x], ...);  g(3) */
    { Expr *fv = venv_find(env, fn);
      if (fv && fv->kind == E_SYM) { FuncDef *lf = func_find(fv->name);
          if (lf) { if (lf->nparams != n->nelems) die("wrong number of arguments in call");
              VEnv c; c.parent = &genv; c.n = 0; for (int i = 0; i < n->nelems; i++) venv_bind(&c, lf->params[i], args[i]); return eval(lf->body, &c); } } }
    return mk_func(fn, args, n->nelems);       /* unknown -> stays symbolic */
}

static Expr *eval(Node *n, VEnv *env)
{
    switch (n->kind) {
        case N_INT: return e_int(n->ival);
        case N_SYM: { Expr *v = venv_find(env, n->name); return v ? v : e_sym(n->name); }
        case N_UNARY:
            if (n->op == T_MINUS) return s_neg(eval(n->a, env));
            if (n->op == T_NOT) { Expr *x = eval(n->a, env); if (x->kind == E_NUM) return e_int(x->num == 0); die("'not' needs a numeric value"); }
            die("bad unary operator"); return 0;
        case N_BIN: {
            int t = n->op; Expr *a = eval(n->a, env), *b = eval(n->b, env);
            switch (t) {
                case T_PLUS:  return s_add(a, b);
                case T_MINUS: return s_sub(a, b);
                case T_STAR:  return s_mul(a, b);
                case T_SLASH: return s_mul(a, s_pow(b, e_int(-1)));
                case T_CARET: return s_pow(a, b);
                case T_EQ: case T_HASH: {              /* = / # : structural equality */
                    int eq = (is_num(a) && is_num(b)) ? (num_cmp(a, b) == 0) : e_equal(a, b);
                    return e_int(t == T_EQ ? eq : !eq);
                }
                case T_LT: case T_GT: case T_LE: case T_GE: {
                    if (is_num(a) && is_num(b)) { int c = num_cmp(a, b), r = 0;
                        switch (t) { case T_LT: r = c<0; break; case T_GT: r = c>0; break;
                                     case T_LE: r = c<=0; break; case T_GE: r = c>=0; break; }
                        return e_int(r); }
                    const char *op = t == T_LT ? "<" : t == T_GT ? ">" : t == T_LE ? "<=" : ">=";  /* symbolic relation */
                    Expr **ar = e_vec(2); ar[0] = a; ar[1] = b; return mk_func(op, ar, 2);
                }
                case T_AND: case T_OR: {
                    if (a->kind != E_NUM || b->kind != E_NUM) die("logical operator needs numeric operands");
                    int av = a->num != 0, bv = b->num != 0; return e_int(t == T_AND ? (av && bv) : (av || bv));
                }
                case T_DOT:
                    if (is_matrix(a) && is_matrix(b)) return mat_mul(a, b);
                    die("'.' (matrix product) needs matrix operands");
            }
            die("bad binary operator"); return 0;
        }
        case N_IF: { Expr *c = eval(n->a, env); if (c->kind != E_NUM) die("if-condition must evaluate to a number");
                     if (c->num != 0) return eval(n->b, env); return n->c ? eval(n->c, env) : e_int(0); }
        case N_CALL: return eval_call(n, env);
        case N_MPROGN: { Expr *last = e_int(0); for (int i = 0; i < n->nelems; i++) last = eval(n->elems[i], env); return last; }
        case N_ASSIGN: { if (n->a->kind != N_SYM) die("left side of ':' must be a name"); Expr *v = eval(n->b, env); venv_assign(env, n->a->name, v); return v; }
        case N_LIST: { Expr **a = e_vec(n->nelems ? n->nelems : 1); for (int i = 0; i < n->nelems; i++) a[i] = eval(n->elems[i], env); return e_list(a, n->nelems); }
        case N_SUBSCRIPT: { Expr *l = eval(n->a, env);       /* l[i] / m[i,j] / m[i][j] */
            int nidx = n->nelems ? n->nelems : 1;
            for (int k = 0; k < nidx; k++) {
                Expr *ix = eval(n->nelems ? n->elems[k] : n->b, env);
                if (ix->kind != E_NUM || ix->den != 1) die("index must be an integer");
                if (is_matrix(l)) { if (ix->num < 1 || ix->num > l->n) die("matrix row index out of range"); l = l->a[ix->num - 1]; }
                else if (l->kind == E_LIST) { if (ix->num < 1 || ix->num > l->n) die("list index out of range"); l = l->a[ix->num - 1]; }
                else die("subscript applied to a non-list");
            }
            return l; }
        case N_FOR: {
            VEnv child; child.parent = env; child.n = 0; venv_bind(&child, n->name, e_int(0));
            if (n->op == FOR_IN) {
                Expr *lst = eval(n->a, env); if (lst->kind != E_LIST) die("for..in needs a list");
                for (int i = 0; i < lst->n; i++) { venv_assign(&child, n->name, lst->a[i]); eval(n->elems[0], &child);
                    if (hax_returning) { hax_returning = 0; return hax_retval; } }
            } else {
                Expr *iv = eval(n->a, env), *sv = eval(n->b, env);
                if (iv->kind != E_NUM || iv->den != 1 || sv->kind != E_NUM || sv->den != 1) die("for-loop needs integer start/step");
                long i = iv->num, step = sv->num, guard = 0;
                for (;;) {
                    if (++guard > 100000000L) die("for-loop exceeded 1e8 iterations");
                    venv_assign(&child, n->name, e_int(i));
                    int go = 1;
                    if (n->op == FOR_THRU) { Expr *L = eval(n->c, &child); if (L->kind != E_NUM) die("thru limit must be numeric"); long lhs = i * L->den, rhs = L->num; go = step >= 0 ? lhs <= rhs : lhs >= rhs; }
                    else if (n->op == FOR_WHILE)  { Expr *c = eval(n->c, &child); if (c->kind != E_NUM) die("while condition must be numeric"); go = c->num != 0; }
                    else if (n->op == FOR_UNLESS) { Expr *c = eval(n->c, &child); if (c->kind != E_NUM) die("unless condition must be numeric"); go = c->num == 0; }
                    if (!go) break;
                    eval(n->elems[0], &child);
                    if (hax_returning) { hax_returning = 0; return hax_retval; }
                    i += step;
                }
            }
            return e_sym("done");
        }
        case N_FLOAT:     return e_flt(n->fval);
        case N_STR:       die("strings are not evaluable yet");
        case N_POSTFIX:
            if (n->op == T_BANG) { Expr *x = eval(n->a, env);
                if (x->kind == E_NUM && x->den == 1 && x->num >= 0) { long r = 1; for (long i = 2; i <= x->num; i++) r *= i; return e_int(r); }
                Expr **a = e_vec(1); a[0] = x; return mk_func("factorial", a, 1); }
            die("'!!' (double factorial) not supported yet");
        case N_QUOTE:     return eval_quote(n->a);
        case N_DEF:       die("function definition is only allowed as a top-level statement");
    }
    die("internal: bad AST node"); return 0;
}

/* -------------------------------------------------- statements + load() ------ */

/* collected top-level display items: either a precomputed string, or an AST node
 * (+ its compile-time value) to be LOWERED to HANGMAN and computed at runtime. */
typedef struct { Node *node; Expr *result; int is_str; char *str; } TLItem;
static TLItem tl[8192]; static int ntl;
static void tl_str(const char *s) { if (ntl < 8192) { tl[ntl].is_str = 1; tl[ntl].str = strdup(s); ntl++; } }
static void tl_val(Node *n, Expr *r) { if (ntl < 8192) { tl[ntl].is_str = 0; tl[ntl].node = n; tl[ntl].result = r; ntl++; } }

static char *slurp(const char *path)
{
    FILE *f = fopen(path, "rb"); if (!f) return 0;
    fseek(f, 0, SEEK_END); long n = ftell(f); fseek(f, 0, SEEK_SET);
    char *b = (char *)malloc(n + 1); if (!b) { perror("malloc"); exit(1); }
    if (fread(b, 1, n, f) != (size_t)n) { fclose(f); return 0; }
    b[n] = 0; fclose(f); return b;
}

#if defined(__unix__)
/* recursively search `dir` for a file named `target`; fill `out` and return 1 if found.
 * This mirrors Maxima's file_search over its share/ tree, so a package loads by its
 * real name (e.g. load("gcdex") finds share/algebra/gcdex.mac). */
static int search_dir(const char *dir, const char *target, char *out, int outsz)
{
    DIR *d = opendir(dir); if (!d) return 0;
    struct dirent *e;
    while ((e = readdir(d))) {
        if (e->d_name[0] == '.') continue;
        char path[2048]; snprintf(path, sizeof path, "%s/%s", dir, e->d_name);
        struct stat st; if (stat(path, &st)) continue;
        if (S_ISDIR(st.st_mode)) { if (search_dir(path, target, out, outsz)) { closedir(d); return 1; } }
        else if (!strcmp(e->d_name, target)) { snprintf(out, outsz, "%s", path); closedir(d); return 1; }
    }
    closedir(d); return 0;
}
#endif

/* mxpm-compatible search: cwd, then ~/.maxima/, then RECURSIVELY through the real
 * Maxima share/ tree in ~/.maxima/share/ (preserving Maxima's package names). */
static char *resolve_load(const char *name)
{
    static char b[8][2048]; const char *home = getenv("HOME"); int nc = 0; const char *c[8];
    snprintf(b[0], 2048, "%s", name);      c[nc++] = b[0];
    snprintf(b[1], 2048, "%s.mac", name);  c[nc++] = b[1];
    if (home) {
        snprintf(b[2], 2048, "%s/.maxima/%s", home, name);              c[nc++] = b[2];
        snprintf(b[3], 2048, "%s/.maxima/%s.mac", home, name);          c[nc++] = b[3];
        snprintf(b[4], 2048, "%s/.maxima/%s/%s.mac", home, name, name); c[nc++] = b[4];
    }
    for (int i = 0; i < nc; i++) { FILE *f = fopen(c[i], "rb"); if (f) { fclose(f); return (char *)c[i]; } }
#if defined(__unix__)
    if (home) {                              /* recursive search of the stdlib tree */
        static char found[2048]; char shdir[1200], tgt[300];
        snprintf(shdir, sizeof shdir, "%s/.maxima/share", home);
        snprintf(tgt, sizeof tgt, "%s.mac", name);
        if (search_dir(shdir, tgt, found, sizeof found)) return found;
    }
#endif
    return 0;
}

static void run_source(const char *source, const char *name);

static void register_func(Node *n)
{
    Node *sig = n->a;
    if (sig->kind != N_CALL || sig->a->kind != N_SYM) die("bad function definition (expected name(args) := ...)");
    if (sig->nelems > 8) die("functions limited to 8 parameters");
    FuncDef *f = &funcs[nfuncs < 1024 ? nfuncs++ : 1023];
    strncpy(f->name, sig->a->name, 63);
    f->nparams = sig->nelems;
    for (int i = 0; i < sig->nelems; i++) { if (sig->elems[i]->kind != N_SYM) die("parameters must be plain names"); strncpy(f->params[i], sig->elems[i]->name, 63); }
    f->body = n->b;
    f->is_float = node_has_float(n->b);
}

static void run_statement(Node *n, int display)
{
    if (n->kind == N_LISP) {
#ifdef HAXMAC_LISP
        const char *r = hax_lisp_call(n->sval);
        if (display) tl_str(r);
#else
        die(":lisp requires haxMac built with Lisp support (-DHAXMAC_LISP + sbcl.o)");
#endif
        return;
    }
    if (n->kind == N_DEF) { register_func(n); if (display) tl_str(n->a->a->name); return; }

    if (n->kind == N_CALL && n->a->kind == N_SYM && !strcmp(n->a->name, "load") &&
        n->nelems == 1 && (n->elems[0]->kind == N_STR || n->elems[0]->kind == N_SYM)) {
        const char *nm = n->elems[0]->name;
        char *path = resolve_load(nm);
        if (!path) { char m[300]; snprintf(m, sizeof m, "load: cannot find '%s' (searched . and ~/.maxima/)", nm); die(m); }
        char *content = slurp(path); if (!content) die("load: read error");
        run_source(content, path);
        if (display) { char q[1100]; snprintf(q, sizeof q, "\"%s\"", path); tl_str(q); }
        return;
    }

    /* Evaluate at compile time (binds globals, does symbolic algebra) AND remember
     * the node, so codegen can LOWER numeric results to HANGMAN.  If compile-time
     * eval isn't possible (a runtime numeric computation), result stays NULL and
     * codegen lowers the node as numeric. */
    Expr *r = 0;
    { jmp_buf jb, *save = hax_catch; hax_catch = &jb; if (!setjmp(jb)) r = eval(n, &genv); hax_catch = save; }
    if (display) tl_val(n, r);
}

static void run_source(const char *source, const char *name)
{
    const char *o_src = src; size_t o_pos = srcpos; int o_line = line; const char *o_name = srcname;
    int o_tok = tok, o_tl = tok_line; long o_ti = tok_int; double o_tf = tok_flt; char o_txt[256]; memcpy(o_txt, tok_txt, sizeof o_txt);

    src = source; srcpos = 0; line = 1; srcname = name;
    lex_next();
    while (tok != T_EOF) {
        Node *nd = parse_expr(0);
        if (nd->kind == N_LISP) { run_statement(nd, 1); continue; }   /* :lisp self-terminates */
        int display = (tok == T_SEMI);                  /* ; displays, $ silent */
        if (tok == T_SEMI || tok == T_DOLLAR) lex_next();
        else if (tok != T_EOF) die("expected ';' or '$' after a statement");
        run_statement(nd, display);
    }

    src = o_src; srcpos = o_pos; line = o_line; srcname = o_name;
    tok = o_tok; tok_line = o_tl; tok_int = o_ti; tok_flt = o_tf; memcpy(tok_txt, o_txt, sizeof tok_txt);
}

/* ------------------------------------------------- native print program ------ */

static struct hofos_api *H;

/* ================= HANGMAN lowering: emit WIR so the binary computes natively ====
 * The symbolic engine simplifies at COMPILE TIME; its (numeric/polynomial) results
 * -- and imperative bodies (if/for/recursion) -- are LOWERED to HANGMAN here so the
 * native executable does the work fast.  Locals live in stack slots (IR_ADDR +
 * LOAD/STORE) so loop variables and reassignment behave like real variables. */

static int L_ty;   /* type of the last lowered value: 0 = integer, 1 = float (double bits) */

typedef struct LEnv { struct LEnv *parent; char names[128][64]; hword addr[128]; char ty[128]; int n; } LEnv;
static hword lenv_find(LEnv *e, const char *nm, int *found, int *ty)
{ for (; e; e = e->parent) for (int i = 0; i < e->n; i++) if (!strcmp(e->names[i], nm)) { if (found) *found = 1; if (ty) *ty = e->ty[i]; return e->addr[i]; }
  if (found) *found = 0; return 0; }
static void lenv_add(LEnv *e, const char *nm, hword addr, int ty)
{ if (e->n >= 128) die("too many locals in a compiled function"); strncpy(e->names[e->n], nm, 63); e->ty[e->n] = (char)ty; e->addr[e->n++] = addr; }

/* allocate a mutable local slot (of type ty) initialised to `val`; returns its address temp */
static hword low_newlocal(LEnv *le, const char *nm, hword val, int ty)
{ hword v = H->new_temp(), addr = H->new_temp(); H->emit(IR_ADDR, addr, v, 0, 0); H->emit(IR_STORE, 0, addr, val, 0); lenv_add(le, nm, addr, ty); return addr; }
static hword low_read(hword addr)  { hword d = H->new_temp(); H->emit(IR_LOAD, d, addr, 0, 0); return d; }
static void  low_write(hword addr, hword val) { H->emit(IR_STORE, 0, addr, val, 0); }
static hword low_promote(hword t, int ty) { if (ty) return t; hword d = H->new_temp(); H->emit(IR_ITOF, d, t, 0, 0); return d; }  /* int -> float */

static hword lower_fconst(double v) { union { double d; long l; } u; u.d = v; L_ty = 1; return h_const(H, u.l); }

/* Value types tracked in L_ty / LEnv.ty.  Lists and matrices are STACK-ALLOCATED
 * arrays (IR_VECALLOC): word0 = length, words 1..N = elements (1-based, like Maxima).
 * A matrix is a length-prefixed vector of row-pointers (a list of lists). */
enum { TY_INT = 0, TY_FLT = 1, TY_ILIST = 2, TY_FLIST = 3, TY_IMAT = 4, TY_FMAT = 5 };
#define TY_IS_LIST(t) ((t) >= TY_ILIST)

/* Heap-allocate a vector with room for `count` elements + the length word0.  getvec(n)
 * returns n+1 usable words from the BSS heap (bump + freevec free-list reuse).  Heap (not
 * the stack) so lists OUTLIVE the frame (functions can return them), don't grow the frame
 * inside loops, and take a RUNTIME count (non-constant sizes).  `count` is any temp/const. */
static hword low_getvec(hword count) { hword a[1] = { count }; return h_call(H, "getvec", a, 1); }
static hword low_vecalloc(int n_elems) { return low_getvec(h_const(H, n_elems)); }   /* constant-size convenience */
/* store `val` at word `i` of vector `base` (i is a compile-time constant) */
static void low_vput(hword base, int i, hword val) { H->emit(IR_STORE, 0, h_bin(H, IR_ADD, base, h_const(H, (long)i * 8)), val, 0); }
/* address of word `idx` (a runtime temp) within `base`:  base + idx*8 */
static hword low_vaddr(hword base, hword idx) { return h_bin(H, IR_ADD, base, h_bin(H, IR_SHL, idx, h_const(H, 3))); }

static int expr_has_float(Expr *e) { if (e->kind == E_FLT) return 1; for (int i = 0; i < e->n; i++) if (expr_has_float(e->a[i])) return 1; return 0; }
/* is this a constant number, or a list/matrix of constant numbers (materializable as native data)? */
static int expr_all_numeric(Expr *e)
{
    if (e->kind == E_NUM || e->kind == E_FLT) return 1;
    if (e->kind == E_LIST || is_matrix(e)) { for (int i = 0; i < e->n; i++) if (!expr_all_numeric(e->a[i])) return 0; return 1; }
    return 0;
}

/* Infer how a parameter `p` is used in a function body: 0 = scalar, 1 = list, 2 = matrix.
 * (`p[i,j]` or `p[i][j]` => matrix; `p[i]`, length/first/last(p) => list.)  This lets a
 * function take a list/matrix argument even though params carry no declared type. */
static int param_shape(Node *n, const char *p)
{
    if (!n) return 0;
    int s = 0, c;
    if (n->kind == N_SUBSCRIPT) {
        if (n->a && n->a->kind == N_SYM && !strcmp(n->a->name, p)) s = (n->nelems >= 2) ? 2 : 1;
        if (n->a && n->a->kind == N_SUBSCRIPT && n->a->a && n->a->a->kind == N_SYM && !strcmp(n->a->a->name, p)) s = 2;
    }
    if (n->kind == N_CALL && n->a && n->a->kind == N_SYM) {
        const char *fn = n->a->name;
        if ((!strcmp(fn, "length") || !strcmp(fn, "first") || !strcmp(fn, "last")) &&
            n->nelems >= 1 && n->elems[0]->kind == N_SYM && !strcmp(n->elems[0]->name, p) && s < 1) s = 1;
    }
    c = param_shape(n->a, p); if (c > s) s = c;
    c = param_shape(n->b, p); if (c > s) s = c;
    c = param_shape(n->c, p); if (c > s) s = c;
    for (int i = 0; i < n->nelems; i++) { c = param_shape(n->elems[i], p); if (c > s) s = c; }
    return s;
}
/* map an inferred shape (0/1/2) + float-ness to a TY_* code */
static int shape_ty(int shape, int isf)
{ return shape == 2 ? (isf ? TY_FMAT : TY_IMAT) : shape == 1 ? (isf ? TY_FLIST : TY_ILIST) : (isf ? TY_FLT : TY_INT); }

/* Infer the SHAPE (0 scalar / 1 list / 2 matrix) of the value a body produces, so a
 * function that RETURNS a list/matrix is typed correctly at its call sites.  Locals are
 * tracked in a small name->shape env (block locals, assignments, params). */
typedef struct { char names[64][64]; int shape[64]; int n; } ShEnv;
static int shenv_get(ShEnv *e, const char *nm) { for (int i = e->n - 1; i >= 0; i--) if (!strcmp(e->names[i], nm)) return e->shape[i]; return 0; }
static void shenv_set(ShEnv *e, const char *nm, int sh) { for (int i = 0; i < e->n; i++) if (!strcmp(e->names[i], nm)) { e->shape[i] = sh; return; } if (e->n < 64) { strncpy(e->names[e->n], nm, 63); e->shape[e->n++] = sh; } }
static int body_shape(Node *n, ShEnv *env)
{
    if (!n) return 0;
    switch (n->kind) {
        case N_LIST: return 1;
        case N_SYM: return shenv_get(env, n->name);
        case N_SUBSCRIPT: { int s = body_shape(n->a, env); int nidx = n->nelems ? n->nelems : 1;
            for (int k = 0; k < nidx; k++) s = (s == 2) ? 1 : 0;   /* matrix->row(list), list->scalar */
            return s; }
        case N_IF: { int s = body_shape(n->b, env); if (!s) s = body_shape(n->c, env); return s; }
        case N_MPROGN: { int s = 0; for (int i = 0; i < n->nelems; i++) s = body_shape(n->elems[i], env); return s; }
        case N_ASSIGN: { int s = body_shape(n->b, env); if (n->a->kind == N_SYM) shenv_set(env, n->a->name, s); return s; }
        case N_CALL: {
            const char *fn = n->a->kind == N_SYM ? n->a->name : "";
            if (!strcmp(fn, "block")) { ShEnv ch = *env; int start = 0;
                if (n->nelems > 0 && n->elems[0]->kind == N_LIST) { Node *loc = n->elems[0];
                    for (int i = 0; i < loc->nelems; i++) { Node *d = loc->elems[i];
                        if (d->kind == N_SYM) shenv_set(&ch, d->name, 0);
                        else if (d->kind == N_ASSIGN && d->a->kind == N_SYM) shenv_set(&ch, d->a->name, body_shape(d->b, &ch)); }
                    start = 1; }
                int s = 0; for (int i = start; i < n->nelems; i++) s = body_shape(n->elems[i], &ch); return s; }
            if (!strcmp(fn, "matrix")) return 2;
            if (!strcmp(fn, "makelist")) return 1;
            if ((!strcmp(fn, "first") || !strcmp(fn, "last")) && n->nelems >= 1) return body_shape(n->elems[0], env) == 2 ? 1 : 0;
            { FuncDef *f = func_find(fn); if (f) return f->ret_shape; }
            return 0;
        }
        default: return 0;
    }
}
/* compute f->ret_shape from its body, seeding the env with the params' inferred shapes */
static void infer_ret_shape(FuncDef *f)
{
    ShEnv env; env.n = 0;
    for (int k = 0; k < f->nparams; k++) shenv_set(&env, f->params[k], param_shape(f->body, f->params[k]));
    f->ret_shape = body_shape(f->body, &env);
}

/* materialize a compile-time-constant Expr (number / list / matrix) as native data:
 * scalars become CONST temps, lists/matrices become stack arrays.  This lets a
 * top-level list VARIABLE (bound in genv as an E_LIST) be re-emitted where used. */
static hword lower_list_expr(Expr *e);
static hword lower_scalar_expr_val(Expr *e)
{
    if (e->kind == E_NUM && e->den == 1) { L_ty = TY_INT; return h_const(H, e->num); }
    if (e->kind == E_NUM) return lower_fconst((double)e->num / e->den);
    if (e->kind == E_FLT) return lower_fconst(e->fval);
    if (e->kind == E_LIST || is_matrix(e)) return lower_list_expr(e);
    die("cannot materialize this value as native data"); return 0;
}
static hword lower_list_expr(Expr *e)
{
    if (is_matrix(e)) {                                    /* matrix(row1, row2, ..): each arg is a row E_LIST */
        int R = e->n, isf = expr_has_float(e);
        hword outer = low_vecalloc(R); low_vput(outer, 0, h_const(H, R));
        for (int r = 0; r < R; r++) { Expr *row = e->a[r]; int C = row->n;
            hword rb = low_vecalloc(C); low_vput(rb, 0, h_const(H, C));
            for (int c = 0; c < C; c++) { hword v = lower_scalar_expr_val(row->a[c]); if (isf) v = low_promote(v, L_ty); low_vput(rb, c + 1, v); }
            low_vput(outer, r + 1, rb); }
        L_ty = isf ? TY_FMAT : TY_IMAT; return outer;
    }
    int nn = e->n, anyflt = 0, anylist = 0, anyflist = 0;  /* E_LIST */
    hword *vals = (hword *)malloc(sizeof(hword) * (nn > 0 ? nn : 1)); char *tys = (char *)malloc(nn > 0 ? nn : 1);
    for (int i = 0; i < nn; i++) { vals[i] = lower_scalar_expr_val(e->a[i]); tys[i] = (char)L_ty;
        if (L_ty == TY_FLT) anyflt = 1; if (TY_IS_LIST(L_ty)) { anylist = 1; if (L_ty == TY_FLIST || L_ty == TY_FMAT) anyflist = 1; } }
    hword base = low_vecalloc(nn); low_vput(base, 0, h_const(H, nn));
    if (anylist) { for (int i = 0; i < nn; i++) low_vput(base, i + 1, vals[i]); L_ty = anyflist ? TY_FMAT : TY_IMAT; }
    else { for (int i = 0; i < nn; i++) { hword v = vals[i]; if (anyflt && tys[i] == TY_INT) v = low_promote(v, 0); low_vput(base, i + 1, v); } L_ty = anyflt ? TY_FLIST : TY_ILIST; }
    free(vals); free(tys); return base;
}

static int is_lowerable(Expr *e)   /* can this simplified Expr become numeric HANGMAN? */
{
    switch (e->kind) {
        case E_NUM: case E_FLT: case E_SYM: return 1;
        case E_ADD: case E_MUL: { for (int i = 0; i < e->n; i++) if (!is_lowerable(e->a[i])) return 0; return 1; }
        case E_POW: return e->a[1]->kind == E_NUM && e->a[1]->den == 1 && e->a[1]->num >= 0 && is_lowerable(e->a[0]);
        default: return 0;                            /* E_FUNC(sin..), lists, matrices */
    }
}
static hword lower_expr(Expr *e, LEnv *le)
{
    switch (e->kind) {
        case E_NUM: if (e->den == 1) { L_ty = 0; return h_const(H, e->num); } return lower_fconst((double)e->num / e->den);
        case E_FLT: return lower_fconst(e->fval);
        case E_SYM: { int f, ty; hword a = lenv_find(le, e->name, &f, &ty); if (!f) die("cannot compile a free symbolic variable"); L_ty = ty; return low_read(a); }
        case E_ADD: { hword acc = lower_expr(e->a[0], le); int at = L_ty;
            for (int i = 1; i < e->n; i++) { hword b = lower_expr(e->a[i], le); int bt = L_ty;
                if (at || bt) { acc = h_bin(H, IR_FADD, low_promote(acc, at), low_promote(b, bt)); at = 1; } else acc = h_bin(H, IR_ADD, acc, b); }
            L_ty = at; return acc; }
        case E_MUL: { hword acc = lower_expr(e->a[0], le); int at = L_ty;
            for (int i = 1; i < e->n; i++) { hword b = lower_expr(e->a[i], le); int bt = L_ty;
                if (at || bt) { acc = h_bin(H, IR_FMUL, low_promote(acc, at), low_promote(b, bt)); at = 1; } else acc = h_bin(H, IR_MUL, acc, b); }
            L_ty = at; return acc; }
        case E_POW: { long ex = e->a[1]->num; hword b = lower_expr(e->a[0], le); int bt = L_ty;
            if (ex == 0) { L_ty = 0; return h_const(H, 1); }
            hword acc = b; for (long k = 1; k < ex; k++) acc = h_bin(H, bt ? IR_FMUL : IR_MUL, acc, b); L_ty = bt; return acc; }
        default: die("cannot compile this expression to numeric code"); return 0;
    }
}

static hword lower(Node *n, LEnv *le);

/* symbolically evaluate a subtree with its free variables kept symbolic; returns the
 * Expr, or NULL if evaluation isn't possible (imperative / runtime-conditional). */
static Expr *try_symbolic(Node *n)
{
    Expr *e = 0; jmp_buf jb, *save = hax_catch; hax_catch = &jb;
    VEnv sv; sv.parent = 0; sv.n = 0;
    if (!setjmp(jb)) e = eval(n, &sv);
    hax_catch = save;
    return e;
}

static hword lower(Node *n, LEnv *le)
{
    switch (n->kind) {
        case N_INT: L_ty = 0; return h_const(H, n->ival);
        case N_FLOAT: return lower_fconst(n->fval);
        case N_SYM: { int f, ty; hword a = lenv_find(le, n->name, &f, &ty); if (f) { L_ty = ty; return low_read(a); }
            Expr *v = venv_find(&genv, n->name);
            if (v && v->kind == E_NUM && v->den == 1) { L_ty = 0; return h_const(H, v->num); }
            if (v && v->kind == E_NUM) return lower_fconst((double)v->num / v->den);
            if (v && v->kind == E_FLT) return lower_fconst(v->fval);
            if (v && (v->kind == E_LIST || is_matrix(v))) return lower_list_expr(v);   /* global list/matrix var */
            die("cannot compile a reference to a symbolic/free variable"); return 0; }
        case N_UNARY:
            if (n->op == T_MINUS) { hword a = lower(n->a, le); int at = L_ty; if (at) { hword z = lower_fconst(0); L_ty = 1; return h_bin(H, IR_FSUB, z, a); } L_ty = 0; return h_neg(H, a); }
            if (n->op == T_NOT)   { hword a = lower(n->a, le); L_ty = 0; return h_bin(H, IR_CMP_EQ, a, h_const(H, 0)); }
            die("bad unary in compiled code"); return 0;
        case N_BIN: {
            int t = n->op;
            if (t == T_CARET) { if (n->b->kind != N_INT || n->b->ival < 0) die("compiled '^' needs a constant non-negative integer exponent");
                long ex = n->b->ival; hword b = lower(n->a, le); int bt = L_ty;
                if (ex == 0) { L_ty = 0; return h_const(H, 1); }
                hword acc = b; for (long k = 1; k < ex; k++) acc = h_bin(H, bt ? IR_FMUL : IR_MUL, acc, b); L_ty = bt; return acc; }
            hword a = lower(n->a, le); int at = L_ty; hword b = lower(n->b, le); int bt = L_ty;
            if (TY_IS_LIST(at) || TY_IS_LIST(bt)) die("cannot do arithmetic on a list/matrix");
            int fl = at || bt; hword fa = fl ? low_promote(a, at) : a, fb = fl ? low_promote(b, bt) : b;
            switch (t) {
                case T_PLUS:  L_ty = fl; return h_bin(H, fl ? IR_FADD : IR_ADD, fa, fb);
                case T_MINUS: L_ty = fl; return h_bin(H, fl ? IR_FSUB : IR_SUB, fa, fb);
                case T_STAR:  L_ty = fl; return h_bin(H, fl ? IR_FMUL : IR_MUL, fa, fb);
                case T_SLASH: L_ty = fl; return h_bin(H, fl ? IR_FDIV : IR_DIV, fa, fb);
                case T_EQ:    L_ty = 0; return h_bin(H, fl ? IR_FCMP_EQ : IR_CMP_EQ, fa, fb);
                case T_HASH:  L_ty = 0; return h_bin(H, fl ? IR_FCMP_NE : IR_CMP_NE, fa, fb);
                case T_LT:    L_ty = 0; return h_bin(H, fl ? IR_FCMP_LT : IR_CMP_LT, fa, fb);
                case T_GT:    L_ty = 0; return h_bin(H, fl ? IR_FCMP_GT : IR_CMP_GT, fa, fb);
                case T_LE:    L_ty = 0; return h_bin(H, fl ? IR_FCMP_LE : IR_CMP_LE, fa, fb);
                case T_GE:    L_ty = 0; return h_bin(H, fl ? IR_FCMP_GE : IR_CMP_GE, fa, fb);
                case T_AND:   L_ty = 0; return h_bin(H, IR_AND, a, b);
                case T_OR:    L_ty = 0; return h_bin(H, IR_OR, a, b);
                default: die("operator not compilable to numeric code"); return 0;
            }
        }
        case N_IF: {
            hword cond = lower(n->a, le), res = H->new_temp();
            hword lt = H->new_label(), lf = H->new_label(), lend = H->new_label();
            H->emit_br(cond, lt, lf);
            H->emit_labelop(lt); hword tv = lower(n->b, le); int tt = L_ty; h_mov(H, res, tv); H->emit_jmp(lend);
            H->emit_labelop(lf); h_mov(H, res, n->c ? lower(n->c, le) : h_const(H, 0)); H->emit_labelop(lend);
            L_ty = tt; return res;                            /* assumes both arms same type */
        }
        case N_FOR: {
            if (n->op == FOR_IN) die("for..in is not compilable to numeric code yet");
            LEnv ch; ch.parent = le; ch.n = 0;
            hword iv = lower(n->a, le); int it = L_ty;
            hword va = low_newlocal(&ch, n->name, iv, it);
            hword step = lower(n->b, le); int st = L_ty;
            hword ltop = H->new_label(), lbody = H->new_label(), lend = H->new_label();
            H->emit_labelop(ltop);
            hword cond;
            if (n->op == FOR_THRU) { hword cv = low_read(va), lim = lower(n->c, &ch); int lt2 = L_ty;
                cond = (it || lt2) ? h_bin(H, IR_FCMP_LE, low_promote(cv, it), low_promote(lim, lt2)) : h_bin(H, IR_CMP_LE, cv, lim); }
            else if (n->op == FOR_WHILE) cond = lower(n->c, &ch);
            else cond = h_bin(H, IR_CMP_EQ, lower(n->c, &ch), h_const(H, 0));
            H->emit_br(cond, lbody, lend);
            H->emit_labelop(lbody);
            lower(n->elems[0], &ch);
            hword cur = low_read(va);
            low_write(va, (it || st) ? h_bin(H, IR_FADD, low_promote(cur, it), low_promote(step, st)) : h_bin(H, IR_ADD, cur, step));
            H->emit_jmp(ltop); H->emit_labelop(lend);
            L_ty = 0; return h_const(H, 0);
        }
        case N_ASSIGN: { if (n->a->kind != N_SYM) die("compiled assignment target must be a name");
            hword val = lower(n->b, le); int vt = L_ty; int f, ty; hword a = lenv_find(le, n->a->name, &f, &ty);
            if (f) low_write(a, val); else low_newlocal(le, n->a->name, val, vt); L_ty = vt; return val; }
        case N_MPROGN: { hword last = h_const(H, 0); L_ty = 0; for (int i = 0; i < n->nelems; i++) last = lower(n->elems[i], le); return last; }
        case N_LIST: {                                        /* [e1,..,eN] -> stack array, word0 = N */
            int nn = n->nelems;
            hword *vals = (hword *)malloc(sizeof(hword) * (nn > 0 ? nn : 1));
            char  *tys  = (char  *)malloc(nn > 0 ? nn : 1);
            int anyflt = 0, anylist = 0, anyflist = 0;
            for (int i = 0; i < nn; i++) { vals[i] = lower(n->elems[i], le); tys[i] = (char)L_ty;
                if (L_ty == TY_FLT) anyflt = 1;
                if (TY_IS_LIST(L_ty)) { anylist = 1; if (L_ty == TY_FLIST || L_ty == TY_FMAT) anyflist = 1; } }
            hword base = low_vecalloc(nn); low_vput(base, 0, h_const(H, nn));
            if (anylist) {                                    /* list of lists -> matrix */
                for (int i = 0; i < nn; i++) low_vput(base, i + 1, vals[i]);
                L_ty = anyflist ? TY_FMAT : TY_IMAT;
            } else {                                          /* scalar list; unify to float if any float */
                for (int i = 0; i < nn; i++) { hword v = vals[i]; if (anyflt && tys[i] == TY_INT) v = low_promote(v, 0); low_vput(base, i + 1, v); }
                L_ty = anyflt ? TY_FLIST : TY_ILIST;
            }
            free(vals); free(tys); return base;
        }
        case N_SUBSCRIPT: {                                   /* l[i] / m[i,j] / m[i][j] -> native indexed load */
            hword base = lower(n->a, le); int bt = L_ty;
            int nidx = n->nelems ? n->nelems : 1;
            for (int k = 0; k < nidx; k++) {
                if (!TY_IS_LIST(bt)) die("subscript of a non-list value");
                Node *ixn = n->nelems ? n->elems[k] : n->b;
                hword idx = lower(ixn, le);
                base = low_read(low_vaddr(base, idx));
                bt = (bt == TY_IMAT) ? TY_ILIST : (bt == TY_FMAT) ? TY_FLIST : (bt == TY_ILIST) ? TY_INT : TY_FLT;
            }
            L_ty = bt; return base;
        }
        case N_CALL: {
            const char *fn = n->a->kind == N_SYM ? n->a->name : "";
            if (!strcmp(fn, "block")) {
                LEnv ch; ch.parent = le; ch.n = 0; int start = 0;
                if (n->nelems > 0 && n->elems[0]->kind == N_LIST) {
                    Node *loc = n->elems[0];
                    for (int i = 0; i < loc->nelems; i++) { Node *d = loc->elems[i];
                        if (d->kind == N_SYM) low_newlocal(&ch, d->name, h_const(H, 0), 0);
                        else if (d->kind == N_ASSIGN && d->a->kind == N_SYM) { hword iv = lower(d->b, &ch); low_newlocal(&ch, d->a->name, iv, L_ty); }
                        else die("block: locals must be names or name:init"); }
                    start = 1;
                }
                hword last = h_const(H, 0); L_ty = 0;
                for (int i = start; i < n->nelems; i++) last = lower(n->elems[i], &ch);
                return last;
            }
            if (!strcmp(fn, "mod") && n->nelems == 2) { hword x = lower(n->elems[0], le), y = lower(n->elems[1], le); L_ty = 0; return h_bin(H, IR_MOD, x, y); }
            if (!strcmp(fn, "matrix")) {                       /* matrix(row1, row2, ..) -> vector of row-pointers */
                int R = n->nelems, isf = node_has_float(n);
                hword outer = low_vecalloc(R); low_vput(outer, 0, h_const(H, R));
                for (int r = 0; r < R; r++) { Node *row = n->elems[r];
                    if (row->kind != N_LIST) die("matrix: each row must be a list [ .. ]");
                    int C = row->nelems; hword rb = low_vecalloc(C); low_vput(rb, 0, h_const(H, C));
                    for (int c = 0; c < C; c++) { hword v = lower(row->elems[c], le); if (isf) v = low_promote(v, L_ty); low_vput(rb, c + 1, v); }
                    low_vput(outer, r + 1, rb); }
                L_ty = isf ? TY_FMAT : TY_IMAT; return outer;
            }
            if (!strcmp(fn, "length") && n->nelems == 1) { hword b = lower(n->elems[0], le); if (!TY_IS_LIST(L_ty)) die("length: argument is not a list"); L_ty = TY_INT; return low_read(b); }
            if (!strcmp(fn, "first") && n->nelems == 1) { hword b = lower(n->elems[0], le); int bt = L_ty; if (!TY_IS_LIST(bt)) die("first: not a list");
                hword v = low_read(h_bin(H, IR_ADD, b, h_const(H, 8)));
                L_ty = (bt == TY_IMAT) ? TY_ILIST : (bt == TY_FMAT) ? TY_FLIST : (bt == TY_ILIST) ? TY_INT : TY_FLT; return v; }
            if (!strcmp(fn, "last") && n->nelems == 1) { hword b = lower(n->elems[0], le); int bt = L_ty; if (!TY_IS_LIST(bt)) die("last: not a list");
                hword v = low_read(low_vaddr(b, low_read(b)));
                L_ty = (bt == TY_IMAT) ? TY_ILIST : (bt == TY_FMAT) ? TY_FLIST : (bt == TY_ILIST) ? TY_INT : TY_FLT; return v; }
            if (!strcmp(fn, "makelist") && n->nelems == 4) {   /* makelist(expr,i,lo,hi) -> heap array + fill loop (RUNTIME bounds) */
                if (n->elems[1]->kind != N_SYM) die("makelist: second arg must be a variable name");
                hword lo = lower(n->elems[2], le); if (L_ty) { hword d = H->new_temp(); H->emit(IR_FTOI, d, lo, 0, 0); lo = d; }
                hword hi = lower(n->elems[3], le); if (L_ty) { hword d = H->new_temp(); H->emit(IR_FTOI, d, hi, 0, 0); hi = d; }
                hword cnt = h_bin(H, IR_ADD, h_bin(H, IR_SUB, hi, lo), h_const(H, 1));   /* hi - lo + 1 (runtime) */
                int isf = node_has_float(n->elems[0]);
                LEnv ch; ch.parent = le; ch.n = 0;
                hword ba = low_newlocal(&ch, "__base", low_getvec(cnt), TY_INT);         /* keep base in a slot across the loop */
                low_vput(low_read(ba), 0, cnt);                                          /* word0 = length */
                hword ia = low_newlocal(&ch, n->elems[1]->name, lo, TY_INT);             /* loop var = lo */
                hword ka = low_newlocal(&ch, "__k", h_const(H, 1), TY_INT);              /* dest index 1..cnt */
                hword ltop = H->new_label(), lbody = H->new_label(), lend = H->new_label();
                H->emit_labelop(ltop);
                H->emit_br(h_bin(H, IR_CMP_LE, low_read(ka), low_read(low_read(ba))), lbody, lend);   /* __k <= base[0] */
                H->emit_labelop(lbody);
                hword v = lower(n->elems[0], &ch); if (isf) v = low_promote(v, L_ty);
                H->emit(IR_STORE, 0, low_vaddr(low_read(ba), low_read(ka)), v, 0);
                low_write(ia, h_bin(H, IR_ADD, low_read(ia), h_const(H, 1)));
                low_write(ka, h_bin(H, IR_ADD, low_read(ka), h_const(H, 1)));
                H->emit_jmp(ltop); H->emit_labelop(lend);
                L_ty = isf ? TY_FLIST : TY_ILIST; return low_read(ba);
            }
            FuncDef *f = func_find(fn);
            if (f) {                                           /* user function -> native call */
                hword args[8]; if (n->nelems > 5) die("compiled calls limited to 5 args");
                for (int i = 0; i < n->nelems; i++) { hword av = lower(n->elems[i], le); int at = L_ty;
                    int psh = i < f->nparams ? param_shape(f->body, f->params[i]) : 0;
                    if (psh == 0) {                                /* scalar param: promote/demote int<->float */
                        if (f->is_float && !at) av = low_promote(av, 0);
                        else if (!f->is_float && at) { hword d = H->new_temp(); H->emit(IR_FTOI, d, av, 0, 0); av = d; }
                    }                                              /* list/matrix param: pass the pointer as-is */
                    args[i] = av; }
                hword r = h_call(H, fn, args, n->nelems); L_ty = shape_ty(f->ret_shape, f->is_float); return r;
            }
            Expr *e = try_symbolic(n); if (e && is_lowerable(e)) return lower_expr(e, le);
            die("cannot compile this call to numeric code"); return 0;
        }
        default: die("this construct is not compilable to numeric code yet"); return 0;
    }
}

/* does this body contain a loop/block? (those must NOT be symbolically evaluated --
 * the interpreter would RUN the loop, and a numeric iteration on symbolic inputs
 * explodes.  Only pure algebraic bodies get symbolic-simplify-then-lower.) */
static int has_loop_or_block(Node *n)
{
    if (!n) return 0;
    if (n->kind == N_FOR) return 1;
    if (n->kind == N_CALL && n->a && n->a->kind == N_SYM && !strcmp(n->a->name, "block")) return 1;
    if (has_loop_or_block(n->a) || has_loop_or_block(n->b) || has_loop_or_block(n->c)) return 1;
    for (int i = 0; i < n->nelems; i++) if (has_loop_or_block(n->elems[i])) return 1;
    return 0;
}

/* lower a function/expression body: prefer symbolic-simplify-then-lower (so diff/
 * expand/algebra fold at compile time -> native code); fall back to direct AST
 * lowering for imperative bodies (conditionals/loops). */
static hword lower_body(Node *body, LEnv *le)
{
    if (!has_loop_or_block(body)) {
        Expr *e = try_symbolic(body);
        if (e && is_lowerable(e)) return lower_expr(e, le);
    }
    return lower(body, le);
}

/* emit a runtime signed-integer printer __hax_puti(n) (recursive; uses wrch). */
static void emit_puti(void)
{
    h_funcdef(H, "__hax_puti", 1);
    hword np = h_param(H, 0);
    hword nv = H->new_temp(), na = H->new_temp(); H->emit(IR_ADDR, na, nv, 0, 0); H->emit(IR_STORE, 0, na, np, 0);
    /* if n < 0 { wrch('-'); n = -n } */
    { hword c = h_bin(H, IR_CMP_LT, low_read(na), h_const(H, 0));
      hword lt = H->new_label(), lend = H->new_label(); H->emit_br(c, lt, lend); H->emit_labelop(lt);
      hword w[1] = { h_const(H, '-') }; h_call(H, "wrch", w, 1);
      low_write(na, h_bin(H, IR_SUB, h_const(H, 0), low_read(na))); H->emit_labelop(lend); }
    /* if n >= 10 { __hax_puti(n / 10) } */
    { hword c = h_bin(H, IR_CMP_GE, low_read(na), h_const(H, 10));
      hword lt = H->new_label(), lend = H->new_label(); H->emit_br(c, lt, lend); H->emit_labelop(lt);
      hword a[1] = { h_bin(H, IR_DIV, low_read(na), h_const(H, 10)) }; h_call(H, "__hax_puti", a, 1); H->emit_labelop(lend); }
    /* wrch('0' + n mod 10) */
    { hword d = h_bin(H, IR_ADD, h_const(H, '0'), h_bin(H, IR_MOD, low_read(na), h_const(H, 10)));
      hword w[1] = { d }; h_call(H, "wrch", w, 1); }
    h_return(H, h_const(H, 0));
    h_funcend(H);
}

/* emit a runtime double printer __hax_putf(x): "<int>.<6 decimals>" */
static void emit_putf(void)
{
    h_funcdef(H, "__hax_putf", 1);
    hword xp = h_param(H, 0);
    LEnv le; le.parent = 0; le.n = 0;
    hword xa = low_newlocal(&le, "x", xp, 1);
    /* if x < 0 { wrch('-'); x = -x } */
    { hword c = h_bin(H, IR_FCMP_LT, low_read(xa), lower_fconst(0));
      hword lt = H->new_label(), lend = H->new_label(); H->emit_br(c, lt, lend); H->emit_labelop(lt);
      hword w[1] = { h_const(H, '-') }; h_call(H, "wrch", w, 1);
      low_write(xa, h_bin(H, IR_FSUB, lower_fconst(0), low_read(xa))); H->emit_labelop(lend); }
    /* integer part */
    hword ip = H->new_temp(); H->emit(IR_FTOI, ip, low_read(xa), 0, 0);
    { hword a[1] = { ip }; h_call(H, "__hax_puti", a, 1); }
    { hword w[1] = { h_const(H, '.') }; h_call(H, "wrch", w, 1); }
    /* fractional part: 6 digits */
    hword ipf = H->new_temp(); H->emit(IR_ITOF, ipf, ip, 0, 0);
    hword fa = low_newlocal(&le, "frac", h_bin(H, IR_FSUB, low_read(xa), ipf), 1);
    for (int k = 0; k < 6; k++) {
        low_write(fa, h_bin(H, IR_FMUL, low_read(fa), lower_fconst(10)));
        hword d = H->new_temp(); H->emit(IR_FTOI, d, low_read(fa), 0, 0);
        { hword w[1] = { h_bin(H, IR_ADD, h_const(H, '0'), d) }; h_call(H, "wrch", w, 1); }
        hword df = H->new_temp(); H->emit(IR_ITOF, df, d, 0, 0);
        low_write(fa, h_bin(H, IR_FSUB, low_read(fa), df));
    }
    h_return(H, h_const(H, 0));
    h_funcend(H);
}

/* emit code to write string `s` to stdout (chunked to fit BCPL's 255-byte cap) */
static void emit_write_str(const char *s)
{
    size_t len = strlen(s), off = 0;
    do {
        size_t chunk = len - off; if (chunk > 240) chunk = 240;
        char buf[256]; memcpy(buf, s + off, chunk); buf[chunk] = 0;
        hword tstr  = h_strlit(H, buf);
        hword taddr = h_bin(H, IR_ADD, tstr, h_const(H, 1));    /* skip BCPL length byte */
        hword args[3] = { h_const(H, 1), taddr, h_const(H, (long)chunk) };
        h_call(H, "__write", args, 3);
        off += chunk;
    } while (off < len);
}

/* native list printer:  name(base) writes  [e1, e2, ..]  using eltfn per element.
 * base points at a stack vector whose word0 = length, words 1..N = elements. */
static void emit_putlist(const char *name, const char *eltfn)
{
    h_funcdef(H, name, 1);
    LEnv le; le.parent = 0; le.n = 0;
    hword base = h_param(H, 0);
    hword nlen = low_read(base);                            /* length = word0 */
    emit_write_str("[");
    hword ia = low_newlocal(&le, "i", h_const(H, 1), TY_INT);
    hword ltop = H->new_label(), lbody = H->new_label(), lend = H->new_label();
    H->emit_labelop(ltop);
    H->emit_br(h_bin(H, IR_CMP_LE, low_read(ia), nlen), lbody, lend);
    H->emit_labelop(lbody);
    { hword lsep = H->new_label(), lno = H->new_label();     /* separator ", " before every element but the first */
      H->emit_br(h_bin(H, IR_CMP_GT, low_read(ia), h_const(H, 1)), lsep, lno);
      H->emit_labelop(lsep); emit_write_str(", "); H->emit_jmp(lno); H->emit_labelop(lno); }
    { hword v = low_read(low_vaddr(base, low_read(ia))); hword a[1] = { v }; h_call(H, eltfn, a, 1); }
    low_write(ia, h_bin(H, IR_ADD, low_read(ia), h_const(H, 1)));
    H->emit_jmp(ltop); H->emit_labelop(lend);
    emit_write_str("]");
    h_return(H, h_const(H, 0)); h_funcend(H);
}
/* native matrix printer:  name(base) writes  matrix([..],[..])  (base = vector of row pointers) */
static void emit_putmat(const char *name, const char *rowfn)
{
    h_funcdef(H, name, 1);
    LEnv le; le.parent = 0; le.n = 0;
    hword base = h_param(H, 0);
    hword R = low_read(base);
    emit_write_str("matrix(");
    hword ia = low_newlocal(&le, "i", h_const(H, 1), TY_INT);
    hword ltop = H->new_label(), lbody = H->new_label(), lend = H->new_label();
    H->emit_labelop(ltop);
    H->emit_br(h_bin(H, IR_CMP_LE, low_read(ia), R), lbody, lend);
    H->emit_labelop(lbody);
    { hword lsep = H->new_label(), lno = H->new_label();
      H->emit_br(h_bin(H, IR_CMP_GT, low_read(ia), h_const(H, 1)), lsep, lno);
      H->emit_labelop(lsep); emit_write_str(","); H->emit_jmp(lno); H->emit_labelop(lno); }
    { hword rp = low_read(low_vaddr(base, low_read(ia))); hword a[1] = { rp }; h_call(H, rowfn, a, 1); }
    low_write(ia, h_bin(H, IR_ADD, low_read(ia), h_const(H, 1)));
    H->emit_jmp(ltop); H->emit_labelop(lend);
    emit_write_str(")");
    h_return(H, h_const(H, 0)); h_funcend(H);
}

static void codegen_program(void)
{
    /* 0. infer each function's return shape (scalar/list/matrix) so callers type the
     *    result correctly -- a function may RETURN a heap list/matrix.  Definition order
     *    means a call to an earlier function already has its ret_shape resolved. */
    for (int i = 0; i < nfuncs; i++) infer_ret_shape(&funcs[i]);
    /* 1. compile every user function to a native HANGMAN function */
    for (int i = 0; i < nfuncs; i++) {
        FuncDef *f = &funcs[i];
        h_funcdef(H, f->name, f->nparams);
        LEnv le; le.parent = 0; le.n = 0;
        for (int k = 0; k < f->nparams; k++)
            low_newlocal(&le, f->params[k], h_param(H, k), shape_ty(param_shape(f->body, f->params[k]), f->is_float));
        h_return(H, lower_body(f->body, &le));
        h_funcend(H);
    }
    /* 2. runtime number + list/matrix printers */
    emit_puti(); emit_putf();
    emit_putlist("__hax_putlist_i", "__hax_puti");
    emit_putlist("__hax_putlist_f", "__hax_putf");
    emit_putmat("__hax_putmat_i", "__hax_putlist_i");
    emit_putmat("__hax_putmat_f", "__hax_putlist_f");
    /* 3. start(): run the top level -- lower numeric results to HANGMAN (computed at
     *    runtime, printed via __hax_puti/__hax_putf); print symbolic results as strings. */
    h_funcdef(H, "start", 0);
    LEnv se; se.parent = 0; se.n = 0;
    for (int i = 0; i < ntl; i++) {
        if (tl[i].is_str) { emit_write_str(tl[i].str); emit_write_str("\n"); continue; }
        Expr *r = tl[i].result;
        if (!r || is_num(r) || ((r->kind == E_LIST || is_matrix(r)) && expr_all_numeric(r))) {
            /* number / list / matrix / runtime value -> lower to native, then pick the
             * printer from the ACTUAL lowered type (L_ty), so it always matches. */
            hword t = lower(tl[i].node, &se);
            const char *pf = (L_ty == TY_FMAT) ? "__hax_putmat_f" : (L_ty == TY_IMAT) ? "__hax_putmat_i"
                           : (L_ty == TY_FLIST) ? "__hax_putlist_f" : (L_ty == TY_ILIST) ? "__hax_putlist_i"
                           : (L_ty == TY_FLT) ? "__hax_putf" : "__hax_puti";
            hword a[1] = { t }; h_call(H, pf, a, 1);
            emit_write_str("\n");
        } else {                                              /* genuinely symbolic -> string */
            emit_write_str(e_str(r)); emit_write_str("\n");
        }
    }
    h_return(H, h_const(H, 0));
    h_funcend(H);
}

/* ------------------------------------------------------------------ driver -- */

int main(int argc, char **argv)
{
    const char *inpath = 0, *outpath = 0, *libpath = HOFOS_DEFAULT_LIB;
    int optlevel = 2; char autoout[512];

    for (int i = 1; i < argc; i++) {
        if (!strcmp(argv[i], "-o") && i + 1 < argc) outpath = argv[++i];
        else if (!strcmp(argv[i], "-L") && i + 1 < argc) libpath = argv[++i];
        else if (!strncmp(argv[i], "-O", 2)) optlevel = atoi(argv[i] + 2);
        else if (argv[i][0] == '-') { fprintf(stderr, "haxMac: unknown flag %s\n", argv[i]); return 1; }
        else inpath = argv[i];
    }
    if (!inpath) { fprintf(stderr, "usage: haxMac SRC.mac [-o OUT] [-L libhofos] [-O<n>]\n"); return 1; }
    if (!outpath) {
        size_t n = strlen(inpath); snprintf(autoout, sizeof autoout, "%s", inpath);
        if (n > 4 && !strcmp(inpath + n - 4, ".mac")) autoout[n - 4] = 0;
        else strncat(autoout, ".elf", sizeof autoout - strlen(autoout) - 1);
        outpath = autoout;
    }

    char *content = slurp(inpath);
    if (!content) { fprintf(stderr, "haxMac: cannot open %s\n", inpath); return 1; }

    genv.parent = 0; genv.n = 0;
    run_source(content, inpath);                 /* parse + symbolically evaluate */

    struct hofos_api api;
    if (hofos_open(&api, libpath)) return 1;
    H = &api;
    api.begin();
    codegen_program();
    if (getenv("MXDUMP")) api.dump();
    api.optimize(optlevel);
    api.emit_elf(hofos_bcpl(outpath));
    fprintf(stderr, "haxMac: compiled %s -> %s (%d displayed result(s))\n", inpath, outpath, ntl);
    return 0;
}
