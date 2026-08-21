#include "wry.h"

/* The driver: read the source, run the compiler, drive libhofos. */
/* ---- driver -------------------------------------------------------------- */
static char g_src[MAXSRC];

/* One help screen, in the shape the Hofos drivers use. */
static void usage()
{
    fprintf(stderr,
"wry - the Rust frontend for Hofos\n"
"\n"
"usage: wry [options] FILE.rs\n"
"\n"
"  -o, -out FILE     write the output here (default a.out)\n"
"  -L FILE           libhofos to load\n"
"  -S                emit assembly instead of a linked image\n"
"  -Opt0..-Opt4      optimisation level (default 2)\n"
"  -Optfast, -Os     maximum optimisation\n"
"  -fcore/-fno-core  include the core:: prelude (default: on)\n"
"  -v                report what the compiler is doing\n"
"  --help, -h        this screen\n"
"\n"
"fn, let, i32/i64/bool/&str, if/else, while/loop/for, closures, structs,\n"
"enums with payloads, match, impl/traits, generics, macro_rules!,\n"
"println!/print!/panic!, and core:: (Option, Result).\n");
}

int main(int argc, char **argv)
{
    struct hofos_api api;
    Compiler cc;
    char *inpath = 0;
    char *outpath = "a.out";
    char *libpath = WRY_DEFAULT_LIB;
    int   usecore = 1;
    int   preludeln = 0;
    int   optlevel = 2;                /* hofos.b's default */
    int   emitasm = 0;
    int   verbose = 0;
    FILE *fp;
    int n;
    int i = 1;

    while (i < argc) {
        if (strcmp(argv[i], "-o") == 0 && i + 1 < argc) { outpath = argv[i + 1]; i = i + 2; continue; }
        if (strcmp(argv[i], "-L") == 0 && i + 1 < argc) { libpath = argv[i + 1]; i = i + 2; continue; }
        if (strcmp(argv[i], "-out") == 0 && i + 1 < argc) { outpath = argv[i + 1]; i = i + 2; continue; }
        if (strcmp(argv[i], "-fno-core") == 0) { usecore = 0; i = i + 1; continue; }
        if (strcmp(argv[i], "-fcore") == 0)    { usecore = 1; i = i + 1; continue; }
        if (strcmp(argv[i], "-S") == 0)        { emitasm = 1; i = i + 1; continue; }
        if (strcmp(argv[i], "-v") == 0)        { verbose = 1; i = i + 1; continue; }
        if (strcmp(argv[i], "--help") == 0 || strcmp(argv[i], "-h") == 0) { usage(); return 0; }
        /* -Opt0..-Opt4 / -Optfast / -Os, handed to libhofos rather than
         * reimplemented — the optimizer lives there, and a second flag table
         * here would be a second thing to keep in sync. */
        if (strncmp(argv[i], "-Opt", 4) == 0) {
            if (strcmp(argv[i], "-Optfast") == 0) optlevel = 4;
            else if (argv[i][4] >= '0' && argv[i][4] <= '4') optlevel = argv[i][4] - '0';
            else { fprintf(stderr, "wry: unknown optimisation level %s\n", argv[i]); return 2; }
            i = i + 1; continue;
        }
        if (strcmp(argv[i], "-Os") == 0) { optlevel = 4; i = i + 1; continue; }
        /* An unknown -flag is an ERROR, not a filename.  Treating it as a source
         * path is how a typo becomes "cannot open -fwhatevr" instead of a
         * diagnostic that names the real mistake. */
        if (argv[i][0] == '-' && argv[i][1] != 0) {
            fprintf(stderr, "wry: unknown option %s  (try --help)\n", argv[i]);
            return 2;
        }
        inpath = argv[i];
        i = i + 1;
    }
    if (inpath == 0) { usage(); return 2; }

    /* THE CORE PRELUDE GOES IN FRONT OF THE USER'S SOURCE, compiled by the same
     * parser.  Option/Result are therefore ordinary Wry declarations rather than
     * compiler intrinsics -- both a real test of generic enums, payload
     * variants, match and impl, and a guarantee that anything the prelude can
     * express, user code can too.
     *
     * `-fno-core` skips it: for testing the language bare, and so a program that
     * declares its own Option still compiles. */
    if (usecore) {
        int pn = wry_core_prelude_len();
        memcpy(g_src, wry_core_prelude(), pn);
        n = pn;
        {   /* Count the prelude's lines now; assigned AFTER cc.init(), which
             * resets the field. */
            int i = 0;
            while (i < pn) { if (g_src[i] == 10) preludeln = preludeln + 1; i = i + 1; }
        }
    } else n = 0;

    fp = fopen(inpath, "rb");
    if (fp == 0) { fprintf(stderr, "wry: cannot open %s\n", inpath); return 2; }
    n = n + (int)fread(g_src + n, 1, MAXSRC - 1 - n, fp);
    fclose(fp);
    g_src[n] = 0;

    if (hofos_open(&api, libpath) != 0) return 2;

    api.begin();
    cc.init(&api);
    cc.prelude_lines = preludeln;   /* diagnostics report USER line numbers */
    cc.lx.init(g_src, n);
    cc.program();

    /* ★ COMPILE THE LIFTED CLOSURES.  Their bodies were captured as source text
     * (a FUNCDEF cannot nest inside another function's IR), so they are parsed
     * now as ordinary top-level functions.  Looped because compiling a closure
     * can lift further ones — a closure inside a closure. */
    while (cc.lambn > 0 && cc.nerr == 0) {
        static char lam[LAMBUF];
        int n2 = cc.lambn;
        memcpy(lam, cc.lambuf, n2);
        lam[n2] = 0;
        cc.lambn = 0;
        cc.prelude_lines = 0;          /* these lines are generated, not the user's */
        cc.lx.init(lam, n2);
        cc.program();
    }

    if (cc.nerr > 0) {
        fprintf(stderr, "wry: %d error(s) — no output\n", cc.nerr);
        return 1;
    }

    if (verbose)
        fprintf(stderr, "wry: %s -> %s  (-Opt%d, core:: %s)\n",
                inpath, outpath, optlevel, usecore ? "on" : "off");
    api.optimize(optlevel);
    /* `-S` stops at assembly.  libhofos decides by EXTENSION (hofos_emit_elf
     * checks for ".s"), so the flag renames the target rather than calling a
     * different entry point — one code path, and the same rule the Hofos
     * drivers already follow. */
    if (emitasm) {
        static char asmout[512];
        int k = 0;
        while (outpath[k] != 0 && k < 500) { asmout[k] = outpath[k]; k = k + 1; }
        /* strip an existing extension so `-S -o foo.elf` gives foo.s, not
         * foo.elf.s */
        { int d = k;
          while (d > 0 && asmout[d - 1] != '.' && asmout[d - 1] != '/') d = d - 1;
          if (d > 0 && asmout[d - 1] == '.') k = d - 1; }
        asmout[k] = '.'; asmout[k + 1] = 's'; asmout[k + 2] = 0;
        api.emit_elf(hofos_bcpl(asmout));
        return 0;
    }
    api.emit_elf(hofos_bcpl(outpath));
    return 0;
}

