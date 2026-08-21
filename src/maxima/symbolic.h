/* symbolic.h -- haxMac's own symbolic-algebra engine (a small CAS).
 *
 * Expressions are canonicalised n-ary trees over exact rationals:
 *   E_NUM  num/den            E_SYM  name            E_FUNC name(args...)
 *   E_ADD  a0 + a1 + ...       E_MUL  a0 * a1 * ...   E_POW  base ^ exp
 * The smart operations (simplify, s_add/s_mul/s_pow, diff, expand, subst) keep
 * results in a canonical form: flattened, like-terms combined, factors gathered,
 * numeric parts folded, operands sorted by a total order so equal expressions are
 * structurally identical.  This is haxMac's engine -- it does NOT call Maxima.
 * Header-only, single-TU (static).
 */
#ifndef SYMBOLIC_H
#define SYMBOLIC_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

enum { E_NUM, E_FLT, E_SYM, E_ADD, E_MUL, E_POW, E_FUNC, E_LIST };

typedef struct Expr {
    int  kind;
    long num, den;              /* E_NUM: reduced rational num/den (den>0)     */
    double fval;                /* E_FLT: floating-point value                 */
    char name[64];              /* E_SYM / E_FUNC name                         */
    struct Expr **a; int n;     /* operands: ADD/MUL args; POW a[0]^a[1]; FUNC */
} Expr;

static void sym_die(const char *m) { fprintf(stderr, "haxMac(symbolic): %s\n", m); exit(1); }

static long sym_gcd(long a, long b) { if (a < 0) a = -a; if (b < 0) b = -b; while (b) { long t = a % b; a = b; b = t; } return a ? a : 1; }

static Expr *e_alloc(int kind)
{ Expr *e = (Expr *)calloc(1, sizeof *e); if (!e) sym_die("oom"); e->kind = kind; return e; }

static Expr *e_num(long num, long den)
{
    if (den == 0) sym_die("division by zero");
    if (den < 0) { num = -num; den = -den; }
    long g = sym_gcd(num, den); num /= g; den /= g;
    Expr *e = e_alloc(E_NUM); e->num = num; e->den = den; return e;
}
static Expr *e_int(long v) { return e_num(v, 1); }
static Expr *e_flt(double v) { Expr *e = e_alloc(E_FLT); e->fval = v; return e; }
static Expr *e_sym(const char *s) { Expr *e = e_alloc(E_SYM); strncpy(e->name, s, sizeof e->name - 1); return e; }
static double to_dbl(Expr *e) { return e->kind == E_FLT ? e->fval : (double)e->num / (double)e->den; }
static int    is_num(Expr *e) { return e->kind == E_NUM || e->kind == E_FLT; }

static Expr **e_vec(int n) { Expr **v = (Expr **)calloc(n ? n : 1, sizeof(Expr *)); if (!v) sym_die("oom"); return v; }

static int e_is_num(Expr *e, long num, long den) { return e->kind == E_NUM && e->num == num && e->den == den; }
static int e_is_zero(Expr *e) { return e_is_num(e, 0, 1); }
static int e_is_one(Expr *e)  { return e_is_num(e, 1, 1); }

/* total order for canonical sorting / equality: NUM < SYM < FUNC < POW < MUL < ADD,
 * then structural. */
static int e_cmp(Expr *x, Expr *y)
{
    if (x->kind != y->kind) return x->kind - y->kind;
    switch (x->kind) {
        case E_NUM: { long l = x->num * y->den, r = y->num * x->den; return l < r ? -1 : l > r ? 1 : 0; }
        case E_FLT: return x->fval < y->fval ? -1 : x->fval > y->fval ? 1 : 0;
        case E_SYM: return strcmp(x->name, y->name);
        case E_FUNC: { int c = strcmp(x->name, y->name); if (c) return c; }
        /* fallthrough: compare arg vectors */
        case E_ADD: case E_MUL: case E_POW: case E_LIST: {
            int i, m = x->n < y->n ? x->n : y->n;
            for (i = 0; i < m; i++) { int c = e_cmp(x->a[i], y->a[i]); if (c) return c; }
            return x->n - y->n;
        }
    }
    return 0;
}
static int e_equal(Expr *x, Expr *y) { return e_cmp(x, y) == 0; }

static int cmp_ptr(const void *p, const void *q) { return e_cmp(*(Expr *const *)p, *(Expr *const *)q); }

static Expr *simplify(Expr *e);

/* raw builders (operands already simplified); simplify() does the real work */
static Expr *mk_add(Expr **a, int n) { Expr *e = e_alloc(E_ADD); e->a = a; e->n = n; return simplify(e); }
static Expr *mk_mul(Expr **a, int n) { Expr *e = e_alloc(E_MUL); e->a = a; e->n = n; return simplify(e); }
static Expr *mk_pow(Expr *b, Expr *x) { Expr *e = e_alloc(E_POW); e->a = e_vec(2); e->a[0] = b; e->a[1] = x; e->n = 2; return simplify(e); }
static Expr *mk_func(const char *nm, Expr **a, int n) { Expr *e = e_alloc(E_FUNC); strncpy(e->name, nm, sizeof e->name - 1); e->a = a; e->n = n; return simplify(e); }
static Expr *e_list(Expr **a, int n) { Expr *e = e_alloc(E_LIST); e->a = a; e->n = n; return e; }

static Expr *s_add(Expr *x, Expr *y) { Expr **a = e_vec(2); a[0] = x; a[1] = y; return mk_add(a, 2); }
static Expr *s_mul(Expr *x, Expr *y) { Expr **a = e_vec(2); a[0] = x; a[1] = y; return mk_mul(a, 2); }
static Expr *s_pow(Expr *b, Expr *x) { return mk_pow(b, x); }
static Expr *s_neg(Expr *x) { return s_mul(e_int(-1), x); }
static Expr *s_sub(Expr *x, Expr *y) { return s_add(x, s_neg(y)); }

/* split a product term into (coeff rational, rest-expr) for like-term collection */
static void split_coeff(Expr *t, long *cn, long *cd, Expr **rest)
{
    if (t->kind == E_NUM) { *cn = t->num; *cd = t->den; *rest = e_int(1); return; }
    if (t->kind == E_MUL && t->n > 0 && t->a[0]->kind == E_NUM) {
        *cn = t->a[0]->num; *cd = t->a[0]->den;
        if (t->n == 2) { *rest = t->a[1]; return; }
        Expr **r = e_vec(t->n - 1); for (int i = 1; i < t->n; i++) r[i - 1] = t->a[i];
        Expr *m = e_alloc(E_MUL); m->a = r; m->n = t->n - 1; *rest = m; return;
    }
    *cn = 1; *cd = 1; *rest = t;
}
/* split a factor into (base, exponent-expr) for power gathering */
static void split_pow(Expr *f, Expr **base, Expr **ex)
{
    if (f->kind == E_POW) { *base = f->a[0]; *ex = f->a[1]; return; }
    *base = f; *ex = e_int(1);
}

static Expr *simplify(Expr *e)
{
    switch (e->kind) {
        case E_NUM: case E_SYM: return e;
        case E_LIST: { Expr **a = e_vec(e->n); for (int i = 0; i < e->n; i++) a[i] = simplify(e->a[i]); return e_list(a, e->n); }
        case E_FUNC: {
            Expr **a = e_vec(e->n); for (int i = 0; i < e->n; i++) a[i] = simplify(e->a[i]);
            /* numeric folds for a few functions */
            if (e->n == 1 && a[0]->kind == E_NUM && a[0]->den == 1) {
                long v = a[0]->num;
                if (!strcmp(e->name, "abs")) return e_int(v < 0 ? -v : v);
            }
            if (e->n == 1 && a[0]->kind == E_FLT) {
                double v = a[0]->fval;
                if (!strcmp(e->name, "sin")) return e_flt(sin(v));
                if (!strcmp(e->name, "cos")) return e_flt(cos(v));
                if (!strcmp(e->name, "tan")) return e_flt(tan(v));
                if (!strcmp(e->name, "exp")) return e_flt(exp(v));
                if (!strcmp(e->name, "log")) return e_flt(log(v));
                if (!strcmp(e->name, "abs")) return e_flt(fabs(v));
            }
            Expr *r = e_alloc(E_FUNC); strncpy(r->name, e->name, sizeof r->name - 1); r->a = a; r->n = e->n; return r;
        }
        case E_ADD: {
            /* flatten */
            int cap = 8, k = 0; Expr **flat = e_vec(cap);
            for (int i = 0; i < e->n; i++) {
                Expr *s = simplify(e->a[i]);
                if (s->kind == E_ADD) for (int j = 0; j < s->n; j++) { if (k >= cap) { cap *= 2; flat = (Expr **)realloc(flat, cap * sizeof *flat); } flat[k++] = s->a[j]; }
                else { if (k >= cap) { cap *= 2; flat = (Expr **)realloc(flat, cap * sizeof *flat); } flat[k++] = s; }
            }
            /* collect like terms */
            long constn = 0, constd = 1; int cflt = 0; double cf = 0;
            Expr **rests = e_vec(k); long *cn = (long *)calloc(k ? k : 1, sizeof(long)), *cd = (long *)calloc(k ? k : 1, sizeof(long));
            int nt = 0;
            for (int i = 0; i < k; i++) {
                if (flat[i]->kind == E_NUM) { if (cflt) cf += (double)flat[i]->num / flat[i]->den;
                    else { constn = constn * flat[i]->den + flat[i]->num * constd; constd *= flat[i]->den; long g = sym_gcd(constn, constd); constn /= g; constd /= g; } continue; }
                if (flat[i]->kind == E_FLT) { if (!cflt) { cflt = 1; cf = (double)constn / constd; } cf += flat[i]->fval; continue; }
                long tn, td; Expr *rest; split_coeff(flat[i], &tn, &td, &rest);
                int f = -1; for (int j = 0; j < nt; j++) if (e_equal(rests[j], rest)) { f = j; break; }
                if (f < 0) { rests[nt] = rest; cn[nt] = tn; cd[nt] = td; nt++; }
                else { cn[f] = cn[f] * td + tn * cd[f]; cd[f] *= td; long g = sym_gcd(cn[f], cd[f]); cn[f] /= g; cd[f] /= g; }
            }
            /* rebuild */
            Expr **out = e_vec(nt + 1); int no = 0;
            for (int j = 0; j < nt; j++) {
                if (cn[j] == 0) continue;
                if (cn[j] == 1 && cd[j] == 1) out[no++] = rests[j];
                else if (e_is_one(rests[j])) out[no++] = e_num(cn[j], cd[j]);
                else out[no++] = s_mul(e_num(cn[j], cd[j]), rests[j]);   /* re-simplify: folds nested float coeffs */
            }
            if (cflt) { if (cf != 0.0) out[no++] = e_flt(cf); }
            else if (!(constn == 0 && constd == 1)) out[no++] = e_num(constn, constd);
            if (no == 0) return e_int(0);
            if (no == 1) return out[0];
            qsort(out, no, sizeof *out, cmp_ptr);
            Expr *r = e_alloc(E_ADD); r->a = out; r->n = no; return r;
        }
        case E_MUL: {
            int cap = 8, k = 0; Expr **flat = e_vec(cap);
            for (int i = 0; i < e->n; i++) {
                Expr *s = simplify(e->a[i]);
                if (s->kind == E_MUL) for (int j = 0; j < s->n; j++) { if (k >= cap) { cap *= 2; flat = (Expr **)realloc(flat, cap * sizeof *flat); } flat[k++] = s->a[j]; }
                else { if (k >= cap) { cap *= 2; flat = (Expr **)realloc(flat, cap * sizeof *flat); } flat[k++] = s; }
            }
            long coefn = 1, coefd = 1; int cflt = 0; double cf = 1;
            Expr **bases = e_vec(k); Expr **exps = e_vec(k); int nf = 0;
            for (int i = 0; i < k; i++) {
                if (flat[i]->kind == E_NUM) { if (cflt) cf *= (double)flat[i]->num / flat[i]->den;
                    else { coefn *= flat[i]->num; coefd *= flat[i]->den; long g = sym_gcd(coefn, coefd); coefn /= g; coefd /= g; } continue; }
                if (flat[i]->kind == E_FLT) { if (!cflt) { cflt = 1; cf = (double)coefn / coefd; } cf *= flat[i]->fval; continue; }
                Expr *base, *ex; split_pow(flat[i], &base, &ex);
                int f = -1; for (int j = 0; j < nf; j++) if (e_equal(bases[j], base)) { f = j; break; }
                if (f < 0) { bases[nf] = base; exps[nf] = ex; nf++; }
                else exps[f] = s_add(exps[f], ex);
            }
            if (cflt ? cf == 0.0 : coefn == 0) return e_int(0);
            Expr **out = e_vec(nf + 1); int no = 0;
            for (int j = 0; j < nf; j++) {
                Expr *p = s_pow(bases[j], exps[j]);
                if (e_is_one(p)) continue;
                out[no++] = p;
            }
            qsort(out, no, sizeof *out, cmp_ptr);
            if (cflt) { if (cf != 1.0) { Expr **o2 = e_vec(no + 1); o2[0] = e_flt(cf); for (int j = 0; j < no; j++) o2[j + 1] = out[j]; out = o2; no++; } }
            else if (!(coefn == 1 && coefd == 1)) {
                Expr **o2 = e_vec(no + 1); o2[0] = e_num(coefn, coefd); for (int j = 0; j < no; j++) o2[j + 1] = out[j]; out = o2; no++;
            }
            if (no == 0) return e_int(1);
            if (no == 1) return out[0];
            Expr *r = e_alloc(E_MUL); r->a = out; r->n = no; return r;
        }
        case E_POW: {
            Expr *b = simplify(e->a[0]), *x = simplify(e->a[1]);
            if (e_is_zero(x)) return e_int(1);
            if (e_is_one(x)) return b;
            if (e_is_zero(b)) return e_int(0);
            if (e_is_one(b)) return e_int(1);
            if (is_num(b) && is_num(x) && (b->kind == E_FLT || x->kind == E_FLT)) return e_flt(pow(to_dbl(b), to_dbl(x)));
            if (b->kind == E_NUM && x->kind == E_NUM && x->den == 1) {
                long ex = x->num; long n = 1, d = 1;
                if (ex >= 0) { for (long i = 0; i < ex; i++) { n *= b->num; d *= b->den; } }
                else { for (long i = 0; i < -ex; i++) { n *= b->den; d *= b->num; } }
                return e_num(n, d);
            }
            if (b->kind == E_POW) return s_pow(b->a[0], s_mul(b->a[1], x));   /* (u^a)^x = u^(a*x) */
            Expr *r = e_alloc(E_POW); r->a = e_vec(2); r->a[0] = b; r->a[1] = x; r->n = 2; return r;
        }
    }
    return e;
}

/* substitute: replace symbol `var` with `val` throughout, then simplify */
static Expr *e_copy(Expr *e);
static Expr *subst(Expr *e, const char *var, Expr *val)
{
    switch (e->kind) {
        case E_NUM: return e;
        case E_SYM: return strcmp(e->name, var) == 0 ? val : e;
        default: {
            Expr **a = e_vec(e->n); for (int i = 0; i < e->n; i++) a[i] = subst(e->a[i], var, val);
            Expr *r = e_alloc(e->kind); strncpy(r->name, e->name, sizeof r->name - 1); r->a = a; r->n = e->n;
            return simplify(r);
        }
    }
}

/* symbolic differentiation d(e)/d(var) */
static Expr *diff(Expr *e, const char *var)
{
    switch (e->kind) {
        case E_NUM: return e_int(0);
        case E_SYM: return e_int(strcmp(e->name, var) == 0 ? 1 : 0);
        case E_ADD: { Expr **a = e_vec(e->n); for (int i = 0; i < e->n; i++) a[i] = diff(e->a[i], var); return mk_add(a, e->n); }
        case E_MUL: {                                /* product rule */
            Expr **terms = e_vec(e->n);
            for (int i = 0; i < e->n; i++) {
                Expr **fac = e_vec(e->n);
                for (int j = 0; j < e->n; j++) fac[j] = (i == j) ? diff(e->a[j], var) : e->a[j];
                terms[i] = mk_mul(fac, e->n);
            }
            return mk_add(terms, e->n);
        }
        case E_POW: {
            Expr *b = e->a[0], *x = e->a[1];
            if (x->kind == E_NUM) {                  /* power rule: d(u^n)=n*u^(n-1)*u' */
                Expr *nm1 = s_sub(x, e_int(1));
                return s_mul(s_mul(x, s_pow(b, nm1)), diff(b, var));
            }
            if (b->kind == E_NUM) {                  /* exp rule: d(a^v)=a^v*ln(a)*v' */
                Expr **la = e_vec(1); la[0] = b; Expr *lna = mk_func("log", la, 1);
                return s_mul(s_mul(e, lna), diff(x, var));
            }
            /* general u^v = e^{v ln u}: d = u^v (v' ln u + v u'/u) */
            Expr **la = e_vec(1); la[0] = b; Expr *lnu = mk_func("log", la, 1);
            Expr *t1 = s_mul(diff(x, var), lnu);
            Expr *t2 = s_mul(x, s_mul(diff(b, var), s_pow(b, e_int(-1))));
            return s_mul(e, s_add(t1, t2));
        }
        case E_FUNC: {
            if (e->n != 1) sym_die("diff: only single-argument functions supported");
            Expr *u = e->a[0], *du = diff(u, var), *outer = 0;
            Expr **ua = e_vec(1); ua[0] = u;
            if      (!strcmp(e->name, "sin"))  outer = mk_func("cos", ua, 1);
            else if (!strcmp(e->name, "cos"))  outer = s_neg(mk_func("sin", ua, 1));
            else if (!strcmp(e->name, "exp"))  outer = mk_func("exp", ua, 1);
            else if (!strcmp(e->name, "log"))  outer = s_pow(u, e_int(-1));
            else if (!strcmp(e->name, "tan"))  { Expr **t = e_vec(1); t[0] = u; outer = s_add(e_int(1), s_pow(mk_func("tan", t, 1), e_int(2))); }
            else if (!strcmp(e->name, "sqrt")) outer = s_mul(e_num(1,2), s_pow(u, e_num(-1,2)));
            else { char m[96]; snprintf(m, sizeof m, "diff: unknown function '%s'", e->name); sym_die(m); }
            return s_mul(outer, du);
        }
    }
    return e_int(0);
}

/* multiply two expressions distributing over sums, term by term.  Each term-times-
 * term is a monomial (safe for s_mul -- it won't re-form the outer sum into a power,
 * which is what caused runaway recursion when expanding (x+1)^n). */
static Expr *expand_mul(Expr *a, Expr *b)
{
    int an = a->kind == E_ADD ? a->n : 1, bn = b->kind == E_ADD ? b->n : 1;
    Expr **terms = e_vec(an * bn); int k = 0;
    for (int i = 0; i < an; i++) for (int j = 0; j < bn; j++) {
        Expr *ai = a->kind == E_ADD ? a->a[i] : a;
        Expr *bj = b->kind == E_ADD ? b->a[j] : b;
        terms[k++] = s_mul(ai, bj);
    }
    return mk_add(terms, k);
}

/* expand: distribute products over sums, and integer powers of sums */
static Expr *expand(Expr *e)
{
    switch (e->kind) {
        case E_NUM: case E_SYM: return e;
        case E_FUNC: { Expr **a = e_vec(e->n); for (int i = 0; i < e->n; i++) a[i] = expand(e->a[i]); return mk_func(e->name, a, e->n); }
        case E_ADD: { Expr **a = e_vec(e->n); for (int i = 0; i < e->n; i++) a[i] = expand(e->a[i]); return mk_add(a, e->n); }
        case E_POW: {
            Expr *b = expand(e->a[0]), *x = e->a[1];
            if (b->kind == E_ADD && x->kind == E_NUM && x->den == 1 && x->num >= 1 && x->num <= 20) {
                Expr *acc = b; for (long i = 1; i < x->num; i++) acc = expand_mul(acc, b);
                return acc;
            }
            return s_pow(b, x);
        }
        case E_MUL: {
            Expr *acc = e_int(1);
            for (int i = 0; i < e->n; i++) acc = expand_mul(acc, expand(e->a[i]));
            return acc;
        }
    }
    return e;
}

/* ---- factoring ---- */
/* raw (non-simplifying) builders so a factored form like 2^2*3 or (x-1)*(x-2)
 * DISPLAYS factored instead of folding back to the number/expanded polynomial. */
static Expr *raw_pow(Expr *b, Expr *ex) { Expr *p = e_alloc(E_POW); p->a = e_vec(2); p->a[0] = b; p->a[1] = ex; p->n = 2; return p; }
static Expr *raw_mul(Expr **a, int n) { if (n == 1) return a[0]; Expr *m = e_alloc(E_MUL); m->a = a; m->n = n; return m; }

static Expr *factor_int(long n)
{
    if (n == 0) return e_int(0); if (n == 1 || n == -1) return e_int(n);
    Expr **f = e_vec(80); int nf = 0;
    if (n < 0) { f[nf++] = e_int(-1); n = -n; }
    for (long p = 2; p * p <= n; p++) if (n % p == 0) { int e = 0; while (n % p == 0) { n /= p; e++; } f[nf++] = e == 1 ? e_int(p) : raw_pow(e_int(p), e_int(e)); }
    if (n > 1) f[nf++] = e_int(n);
    return nf == 0 ? e_int(1) : raw_mul(f, nf);
}

/* integer coefficients of a univariate polynomial in `var`; returns degree or -1 */
static int poly_get(Expr *e, const char *var, long *c, int maxd)
{
    for (int i = 0; i <= maxd; i++) c[i] = 0;
    Expr *one = e; Expr **terms = (e->kind == E_ADD) ? e->a : &one; int nt = (e->kind == E_ADD) ? e->n : 1;
    int deg = 0;
    for (int i = 0; i < nt; i++) {
        Expr *t = terms[i]; long coeff = 1; int power = 0;
        Expr *t1 = t; Expr **facs = (t->kind == E_MUL) ? t->a : &t1; int nf = (t->kind == E_MUL) ? t->n : 1;
        for (int j = 0; j < nf; j++) { Expr *f = facs[j];
            if (f->kind == E_NUM) { if (f->den != 1) return -1; coeff *= f->num; }
            else if (f->kind == E_SYM && !strcmp(f->name, var)) power += 1;
            else if (f->kind == E_POW && f->a[0]->kind == E_SYM && !strcmp(f->a[0]->name, var) && f->a[1]->kind == E_NUM && f->a[1]->den == 1 && f->a[1]->num >= 0) power += (int)f->a[1]->num;
            else return -1; }
        if (power > maxd) return -1;
        c[power] += coeff; if (power > deg) deg = power;
    }
    return deg;
}
static long poly_eval_c(long *c, int deg, long x) { long v = 0; for (int i = deg; i >= 0; i--) v = v * x + c[i]; return v; }

/* factor a univariate integer polynomial by peeling off integer roots (synthetic
 * division).  Returns a raw product, or NULL if not a univariate integer poly. */
static Expr *poly_factor(Expr *e, const char *var)
{
    long c[64]; int deg = poly_get(e, var, c, 63);
    if (deg < 1) return 0;
    Expr **facs = e_vec(deg + 2); int nf = 0;
    while (deg >= 1) {
        long c0 = c[0] < 0 ? -c[0] : c[0]; long root = 0; int found = 0;
        if (c[0] == 0) { found = 1; }
        else for (long r = 1; r <= c0 && !found; r++) if (c0 % r == 0) {
            if (poly_eval_c(c, deg, r) == 0) { root = r; found = 1; } else if (poly_eval_c(c, deg, -r) == 0) { root = -r; found = 1; } }
        if (!found) break;
        Expr **lin = e_vec(2); lin[0] = e_sym(var); lin[1] = e_int(-root);
        Expr *l = e_alloc(E_ADD); l->a = lin; l->n = 2; facs[nf++] = l;
        long q[64]; q[deg - 1] = c[deg]; for (int i = deg - 1; i >= 1; i--) q[i - 1] = c[i] + root * q[i];
        for (int i = 0; i < deg; i++) c[i] = q[i]; deg--;
    }
    if (deg >= 1) {                         /* leftover polynomial factor */
        Expr **ts = e_vec(deg + 1); int n2 = 0;
        for (int i = deg; i >= 0; i--) if (c[i] != 0) {
            Expr *term; if (i == 0) term = e_int(c[i]);
            else { Expr *vp = i == 1 ? e_sym(var) : raw_pow(e_sym(var), e_int(i));
                   if (c[i] == 1) term = vp; else { Expr **mm = e_vec(2); mm[0] = e_int(c[i]); mm[1] = vp; term = raw_mul(mm, 2); } }
            ts[n2++] = term; }
        if (n2 == 1) facs[nf++] = ts[0];
        else { Expr *rr = e_alloc(E_ADD); rr->a = ts; rr->n = n2; facs[nf++] = rr; }
    } else if (c[0] != 1) facs[nf++] = e_int(c[0]);
    return nf == 0 ? e_int(1) : raw_mul(facs, nf);
}

/* ---- printing in Maxima infix syntax ---- */
static void e_print(Expr *e, char **p, char *end, int paren_ctx);
static void ap(char **p, char *end, const char *s) { while (*s && *p < end - 1) *(*p)++ = *s++; **p = 0; }
static void apn(char **p, char *end, long v) { char b[32]; snprintf(b, sizeof b, "%ld", v); ap(p, end, b); }

/* precedence for parenthesisation: ADD=1, MUL=2, POW=3, atom/func=4 */
static int e_prec(Expr *e) { switch (e->kind) { case E_ADD: return 1; case E_MUL: return 2; case E_POW: return 3; default: return 4; } }

/* total degree of a term (sum of exponents of its symbolic factors) -- used only
 * to order sum terms for display (high degree first, Maxima-like). */
static int e_degree(Expr *e)
{
    switch (e->kind) {
        case E_SYM: return 1;
        case E_POW: return (e->a[1]->kind == E_NUM && e->a[1]->den == 1) ? (int)e->a[1]->num * e_degree(e->a[0]) : 1;
        case E_MUL: { int d = 0; for (int i = 0; i < e->n; i++) d += e_degree(e->a[i]); return d; }
        case E_FUNC: return 1;
        default: return 0;
    }
}
static int cmp_display(const void *p, const void *q)
{ Expr *a = *(Expr *const *)p, *b = *(Expr *const *)q; int da = e_degree(a), db = e_degree(b);
  if (da != db) return db - da; return e_cmp(a, b); }

/* is a term negative (leading numeric coefficient < 0)? */
static int e_is_neg(Expr *t)
{
    if (t->kind == E_NUM) return t->num < 0;
    if (t->kind == E_FLT) return t->fval < 0;
    if (t->kind == E_MUL && t->n > 0 && t->a[0]->kind == E_NUM) return t->a[0]->num < 0;
    if (t->kind == E_MUL && t->n > 0 && t->a[0]->kind == E_FLT) return t->a[0]->fval < 0;
    return 0;
}
/* return t with its sign flipped (for printing `a - b` instead of `a + -b`) */
static Expr *e_negate(Expr *t)
{
    if (t->kind == E_NUM) return e_num(-t->num, t->den);
    if (t->kind == E_FLT) return e_flt(-t->fval);
    if (t->kind == E_MUL && t->n > 0 && (t->a[0]->kind == E_NUM || t->a[0]->kind == E_FLT)) {
        Expr *c = t->a[0]->kind == E_NUM ? e_num(-t->a[0]->num, t->a[0]->den) : e_flt(-t->a[0]->fval);
        if (e_is_one(c)) { if (t->n == 2) return t->a[1];
            Expr **r = e_vec(t->n - 1); for (int i = 1; i < t->n; i++) r[i - 1] = t->a[i];
            Expr *m = e_alloc(E_MUL); m->a = r; m->n = t->n - 1; return m; }
        Expr **r = e_vec(t->n); r[0] = c; for (int i = 1; i < t->n; i++) r[i] = t->a[i];
        Expr *m = e_alloc(E_MUL); m->a = r; m->n = t->n; return m;
    }
    return t;
}

static void e_print(Expr *e, char **p, char *end, int ctx)
{
    int prec = e_prec(e), par = prec < ctx;
    if (par) ap(p, end, "(");
    switch (e->kind) {
        case E_NUM: apn(p, end, e->num); if (e->den != 1) { ap(p, end, "/"); apn(p, end, e->den); } break;
        case E_FLT: { char b[64]; snprintf(b, sizeof b, "%.12g", e->fval); ap(p, end, b);
                      if (!strpbrk(b, ".eEni")) ap(p, end, ".0"); break; }
        case E_SYM: ap(p, end, e->name); break;
        case E_FUNC:
            /* relational operators print infix: a<b, a>=b, a=b, ... */
            if (e->n == 2 && (!strcmp(e->name, "<") || !strcmp(e->name, ">") || !strcmp(e->name, "<=") ||
                              !strcmp(e->name, ">=") || !strcmp(e->name, "=") || !strcmp(e->name, "#"))) {
                e_print(e->a[0], p, end, 1); ap(p, end, e->name); e_print(e->a[1], p, end, 1); break; }
            ap(p, end, e->name); ap(p, end, "("); for (int i = 0; i < e->n; i++) { if (i) ap(p, end, ","); e_print(e->a[i], p, end, 1); } ap(p, end, ")"); break;
        case E_ADD: {
            /* display terms high-degree first (Maxima-like); `-` for negatives. */
            Expr **ts = e_vec(e->n); for (int i = 0; i < e->n; i++) ts[i] = e->a[i];
            qsort(ts, e->n, sizeof *ts, cmp_display);
            for (int idx = 0; idx < e->n; idx++) {
                Expr *t = ts[idx]; int neg = e_is_neg(t);
                if (idx == 0) { if (neg) ap(p, end, "-"); }
                else            ap(p, end, neg ? "-" : "+");
                e_print(neg ? e_negate(t) : t, p, end, 1);
            }
            break;
        }
        case E_MUL: {
            int start = 0;
            if (e->a[0]->kind == E_NUM && e->a[0]->num == -1 && e->a[0]->den == 1) { ap(p, end, "-"); start = 1; }
            for (int i = start; i < e->n; i++) { if (i > start) ap(p, end, "*"); e_print(e->a[i], p, end, 2); }
            break;
        }
        case E_POW: e_print(e->a[0], p, end, 4); ap(p, end, "^"); e_print(e->a[1], p, end, 4); break;
        case E_LIST: ap(p, end, "["); for (int i = 0; i < e->n; i++) { if (i) ap(p, end, ","); e_print(e->a[i], p, end, 0); } ap(p, end, "]"); break;
    }
    if (par) ap(p, end, ")");
}
static char *e_str(Expr *e) { static char buf[8192]; char *p = buf; e_print(e, &p, buf + sizeof buf, 0); return buf; }

#endif /* SYMBOLIC_H */
