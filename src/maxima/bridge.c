/* bridge.c -- libhofos host-bridge for the Maxima frontend (first slice).
 *
 * The Maxima frontend is a HOST-SIDE C tool (like NAL, which is D): it embeds a
 * Common Lisp for :lisp / CL interop, compiles the Maxima language, and drives the
 * whole Hofos pipeline -- HANGMAN construction, optimization, native codegen, JIT --
 * by loading libhofos as a shared library.  This file is that platform shim, proven
 * end to end before any Lisp or Maxima grammar is layered on top.
 *
 * Hofos entry points use the System V integer ABI (args rdi/rsi/rdx/rcx/r8/r9,
 * return rax), which is the C ABI for word/pointer args, so every export is called
 * directly.  Strings are BCPL: byte 0 = length, bytes 1.. = the characters.
 *
 *   Unix   : dlopen("libhofos.so")  + dlsym    (native SysV; called directly)
 *   Windows: LoadLibrary("libhofos.dll") + GetProcAddress (NAL emits MS-x64->SysV
 *            thunks, so a Windows C compiler calls them with its own ABI)
 *
 * Build (Unix): cc bridge.c -ldl -o bridge
 * Run        : ./bridge [path-to-libhofos]   # expects jit42.wir in cwd
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if defined(_WIN32)
  #include <windows.h>
  typedef HMODULE hofos_lib_t;
  static hofos_lib_t hofos_dlopen(const char *p) { return LoadLibraryA(p); }
  static void *hofos_dlsym(hofos_lib_t h, const char *n) { return (void *)GetProcAddress(h, n); }
  #define HOFOS_DEFAULT_LIB "libhofos.dll"
#elif defined(__unix__)
  #include <dlfcn.h>
  typedef void *hofos_lib_t;
  static hofos_lib_t hofos_dlopen(const char *p) { return dlopen(p, RTLD_NOW | RTLD_GLOBAL); }
  static void *hofos_dlsym(hofos_lib_t h, const char *n) { return dlsym(h, n); }
  #define HOFOS_DEFAULT_LIB "libhofos.so"
#else
  #error "unsupported platform for the libhofos bridge"
#endif

typedef long hword;                         /* one Hofos machine word */

/* HANGMAN opcodes (from src/hofoshdr.h) needed to build WIR programmatically. */
enum {
    IR_CONST = 1, IR_ADD = 4, IR_SUB = 5, IR_MUL = 6, IR_DIV = 7, IR_MOD = 8,
    IR_RETURN = 34, IR_FUNCDEF = 36, IR_FUNCEND = 37
};

/* The subset of the libhofos facade the bridge needs.  BCPL string args are
 * passed as (const void *) pointing at the length byte. */
typedef void  (*fn_begin)(void);
typedef void  (*fn_optimize)(hword level);
typedef void  (*fn_emit_elf)(const void *bcpl_out);
typedef void  (*fn_load_wir)(const void *bcpl_path);
typedef hword (*fn_run_wir)(const void *bcpl_path, const void *bcpl_entry);
typedef hword (*fn_jit_run)(const void *bcpl_entry);
typedef hword (*fn_jit)(const void *bcpl_entry);
typedef void  (*fn_dump)(void);
typedef hword (*fn_new_temp)(void);
typedef hword (*fn_emit)(hword op, hword dst, hword a1, hword a2, hword a3);

struct hofos_api {
    hofos_lib_t lib;
    fn_begin    begin;
    fn_optimize optimize;
    fn_emit_elf emit_elf;
    fn_load_wir load_wir;
    fn_run_wir  run_wir;
    fn_jit_run  jit_run;
    fn_jit      jit;
    fn_dump     dump;
    fn_new_temp new_temp;
    fn_emit     emit;
};

/* C string -> BCPL string (byte 0 = length).  Caller frees. */
static unsigned char *bcpl(const char *s)
{
    size_t n = strlen(s);
    unsigned char *b = (unsigned char *)malloc(n + 1);
    if (!b) { perror("malloc"); exit(1); }
    if (n > 255) { fprintf(stderr, "bridge: string too long for BCPL: %s\n", s); exit(1); }
    b[0] = (unsigned char)n;
    memcpy(b + 1, s, n);
    return b;
}

static void *must(struct hofos_api *a, const char *name)
{
    void *p = hofos_dlsym(a->lib, name);
    if (!p) { fprintf(stderr, "bridge: symbol '%s' not found in libhofos\n", name); exit(1); }
    return p;
}

static int hofos_open(struct hofos_api *a, const char *path)
{
    memset(a, 0, sizeof *a);
    a->lib = hofos_dlopen(path);
    if (!a->lib) {
#if defined(__unix__)
        fprintf(stderr, "bridge: cannot load %s: %s\n", path, dlerror());
#else
        fprintf(stderr, "bridge: cannot load %s (error %lu)\n", path, (unsigned long)GetLastError());
#endif
        return -1;
    }
    a->begin    = (fn_begin)    must(a, "hofos_begin");
    a->optimize = (fn_optimize) must(a, "hofos_optimize");
    a->emit_elf = (fn_emit_elf) must(a, "hofos_emit_elf");
    a->load_wir = (fn_load_wir) must(a, "hofos_load_wir");
    a->run_wir  = (fn_run_wir)  must(a, "hofos_run_wir");
    a->jit_run  = (fn_jit_run)  must(a, "hofos_jit_run");
    a->jit      = (fn_jit)      must(a, "hofos_jit");
    a->dump     = (fn_dump)     must(a, "hofos_dump");
    a->new_temp = (fn_new_temp) must(a, "ir_new_temp");
    a->emit     = (fn_emit)     must(a, "ir_emit");
    return 0;
}

/* Build a HANGMAN program in C via the ir_* API (no text file): a single
 * function `start` returning (6*7) + (40/5) - 5 = 45.  This is the shape the
 * Maxima front will use -- construct WIR as it compiles, then emit native code.
 * Mirrors hmread.b's emit patterns: FUNCDEF(t,argc,name), CONST(d,v), binop(d,a,b),
 * RETURN(0,a), FUNCEND.  Temps come from ir_new_temp() and are used by id. */
static void build_demo(struct hofos_api *H)
{
    hword f, t1, t2, t3, t4, t5, t6, t7, t8, t9;
    unsigned char *name = bcpl("start");

    H->begin();                                          /* ir_init */
    f = H->new_temp();
    H->emit(IR_FUNCDEF, f, 0, (hword)(long)name, 0);     /* argc = 0 */

    t1 = H->new_temp(); H->emit(IR_CONST, t1, 6, 0, 0);
    t2 = H->new_temp(); H->emit(IR_CONST, t2, 7, 0, 0);
    t3 = H->new_temp(); H->emit(IR_MUL,   t3, t1, t2, 0);   /* 42 */

    t4 = H->new_temp(); H->emit(IR_CONST, t4, 40, 0, 0);
    t5 = H->new_temp(); H->emit(IR_CONST, t5, 5,  0, 0);
    t6 = H->new_temp(); H->emit(IR_DIV,   t6, t4, t5, 0);   /* 8 */

    t7 = H->new_temp(); H->emit(IR_ADD,   t7, t3, t6, 0);   /* 50 */
    t8 = H->new_temp(); H->emit(IR_CONST, t8, 5,  0, 0);
    t9 = H->new_temp(); H->emit(IR_SUB,   t9, t7, t8, 0);   /* 45 */

    H->emit(IR_RETURN, 0, t9, 0, 0);
    H->emit(IR_FUNCEND, 0, 0, 0, 0);
    /* NB: do NOT free(name) -- the FUNCDEF node holds this pointer, and the
     * optimizer/codegen (incl. whole-fn DCE's "is this the 'start' root?" check)
     * dereferences it until emit_elf.  A frontend's WIR strings must outlive
     * codegen; with one compile per process, letting them live is correct. */
}

int main(int argc, char **argv)
{
    const char *libpath = (argc > 1) ? argv[1] : HOFOS_DEFAULT_LIB;
    const char *wirpath = (argc > 2) ? argv[2] : "jit42.wir";
    const char *outpath = (argc > 3) ? argv[3] : "bridge_out.elf";
    struct hofos_api H;
    unsigned char *wir, *out;

    setvbuf(stdout, NULL, _IONBF, 0);              /* markers survive a crash */

    if (hofos_open(&H, libpath)) return 1;
    fprintf(stderr, "[bridge] libhofos loaded from %s.\n", libpath);

    wir = bcpl(wirpath);
    out = bcpl(outpath);

    /* ONE codegen pass per process: irr_load reads the HANGMAN text into the
     * arena, then cg_compile_to_elf64 emits a standalone native ELF.  (getvec
     * is a bump allocator that never frees, so cg_init must run only once per
     * process -- the Maxima frontend compiles one source to one binary and
     * exits, matching this.) */
    if (strcmp(wirpath, "-build") == 0) {
        fprintf(stderr, "[bridge] building WIR in C via ir_* (expect exit 45)...\n");
        build_demo(&H);
    } else {
        fprintf(stderr, "[bridge] hofos_load_wir(%s)...\n", wirpath);
        H.load_wir(wir);
    }
    fprintf(stderr, "[bridge] hofos_optimize(2)...\n");
    H.optimize(2);            /* opt_compose_level + dce_run (register allocation) */
    fprintf(stderr, "[bridge] hofos_emit_elf(%s)...\n", outpath);
    H.emit_elf(out);
    fprintf(stderr, "[bridge] done -- %s written.\n", outpath);

    free(wir); free(out);
    return 0;
}
