/* hofosc.h -- reusable C interface to libhofos (the Hofos compiler as a shared
 * library).  Header-only, single-TU (functions are static).  Loads libhofos.so /
 * libhofos.dll, resolves the System V ABI entry points, and offers small WIR
 * builder helpers so a C frontend can construct a HANGMAN program and emit native
 * code.  Proven end to end by src/maxima/bridge.c (jit42->42, C-built->45).
 *
 * Hofos ABI: SysV integer regs; strings are BCPL (byte 0 = length).  A BCPL string
 * handed to a WIR node (a function/string name) MUST outlive emit_elf -- the arena
 * keeps the pointer and codegen/DCE dereference it.  One compile per process
 * (getvec never frees), so leaking these strings is correct.
 */
#ifndef HOFOSC_H
#define HOFOSC_H

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
  #error "unsupported platform for libhofos"
#endif

typedef long hword;                         /* one Hofos machine word */

/* HANGMAN opcodes (src/hofoshdr.h). */
enum {
    IR_CONST = 1, IR_LOAD = 2, IR_STORE = 3,
    IR_ADD = 4, IR_SUB = 5, IR_MUL = 6, IR_DIV = 7, IR_MOD = 8,
    IR_AND = 9, IR_OR = 10, IR_XOR = 11, IR_NOT = 12, IR_SHL = 13, IR_SHR = 14,
    IR_CMP_EQ = 20, IR_CMP_NE = 21, IR_CMP_LT = 22, IR_CMP_LE = 23,
    IR_CMP_GT = 24, IR_CMP_GE = 25, IR_NEG = 26,
    IR_JMP = 30, IR_BR = 31, IR_LABEL = 32, IR_CALL = 33, IR_RETURN = 34,
    IR_PARAM = 35, IR_FUNCDEF = 36, IR_FUNCEND = 37, IR_STRLIT = 38, IR_MOV = 39,
    IR_VECALLOC = 42,                 /* tN = base of a stack vector of (a1+1) zeroed words */
    IR_ADDR = 45, IR_SETARG = 47,
    /* tN = the ADDRESS of the function named a2.  A host that lifts closures
     * needs this: the resulting temp is a callee with no name, which cg lowers
     * to an indirect `call rax`. */
    IR_FUNCADDR = 50,
    IR_FADD = 51, IR_FSUB = 52, IR_FMUL = 53, IR_FDIV = 54,
    IR_FCMP_LT = 55, IR_FCMP_LE = 56, IR_FCMP_GT = 57, IR_FCMP_GE = 58, IR_FCMP_EQ = 59, IR_FCMP_NE = 60,
    IR_ITOF = 61, IR_FTOI = 62
};

typedef void  (*fn_v_void)(void);
typedef void  (*fn_v_word)(hword);
typedef void  (*fn_v_ptr)(const void *);
typedef hword (*fn_w_void)(void);
typedef hword (*fn_emit)(hword op, hword dst, hword a1, hword a2, hword a3);
typedef hword (*fn_emit_call)(hword dst, hword callee, hword argc, hword a1, hword a2);
typedef void  (*fn_set_arg3)(hword n, hword a3);
typedef hword (*fn_new_label)(void);
typedef hword (*fn_emit_br)(hword cond, hword ltrue, hword lfalse);
typedef hword (*fn_emit_jmp)(hword label);
typedef hword (*fn_emit_label)(hword label);

struct hofos_api {
    hofos_lib_t lib;
    fn_v_void begin;        /* hofos_begin    = ir_init                      */
    fn_v_word optimize;     /* hofos_optimize(level) = opt_compose+dce_run   */
    fn_v_ptr  emit_elf;     /* hofos_emit_elf(bcpl_path)                     */
    fn_v_ptr  load_wir;     /* hofos_load_wir(bcpl_path)                     */
    fn_v_void dump;         /* hofos_dump()                                  */
    fn_w_void new_temp;     /* ir_new_temp()                                 */
    fn_emit   emit;         /* ir_emit(op,dst,a1,a2,a3)                      */
    fn_emit_call emit_call; /* ir_emit_call(dst,callee,argc,a1,a2) -> node   */
    fn_set_arg3  set_arg3;  /* ir_set_arg3(node, a3)                         */
    fn_new_label  new_label;   /* ir_new_label()                            */
    fn_emit_br    emit_br;     /* ir_emit_br(cond, ltrue, lfalse)           */
    fn_emit_jmp   emit_jmp;    /* ir_emit_jmp(label)                        */
    fn_emit_label emit_labelop;/* ir_emit_label(label)                      */
};

/* C string -> BCPL string (byte 0 = length).  Deliberately never freed: WIR
 * nodes keep the pointer through codegen (see header note). */
static unsigned char *hofos_bcpl(const char *s)
{
    size_t n = strlen(s);
    unsigned char *b = (unsigned char *)malloc(n + 1);
    if (!b) { perror("malloc"); exit(1); }
    if (n > 255) { fprintf(stderr, "hofosc: string too long: %s\n", s); exit(1); }
    b[0] = (unsigned char)n;
    memcpy(b + 1, s, n);
    return b;
}

static void *hofos_sym(struct hofos_api *a, const char *name)
{
    void *p = hofos_dlsym(a->lib, name);
    if (!p) { fprintf(stderr, "hofosc: symbol '%s' not found in libhofos\n", name); exit(1); }
    return p;
}

static int hofos_open(struct hofos_api *a, const char *path)
{
    memset(a, 0, sizeof *a);
    a->lib = hofos_dlopen(path);
    if (!a->lib) {
#if defined(__unix__)
        fprintf(stderr, "hofosc: cannot load %s: %s\n", path, dlerror());
#else
        fprintf(stderr, "hofosc: cannot load %s (error %lu)\n", path, (unsigned long)GetLastError());
#endif
        return -1;
    }
    a->begin    = (fn_v_void) hofos_sym(a, "hofos_begin");
    a->optimize = (fn_v_word) hofos_sym(a, "hofos_optimize");
    a->emit_elf = (fn_v_ptr)  hofos_sym(a, "hofos_emit_elf");
    a->load_wir = (fn_v_ptr)  hofos_sym(a, "hofos_load_wir");
    a->dump     = (fn_v_void) hofos_sym(a, "hofos_dump");
    a->new_temp  = (fn_w_void)    hofos_sym(a, "ir_new_temp");
    a->emit      = (fn_emit)      hofos_sym(a, "ir_emit");
    a->emit_call = (fn_emit_call) hofos_sym(a, "ir_emit_call");
    a->set_arg3  = (fn_set_arg3)  hofos_sym(a, "ir_set_arg3");
    a->new_label   = (fn_new_label)  hofos_sym(a, "ir_new_label");
    a->emit_br     = (fn_emit_br)    hofos_sym(a, "ir_emit_br");
    a->emit_jmp    = (fn_emit_jmp)   hofos_sym(a, "ir_emit_jmp");
    a->emit_labelop= (fn_emit_label) hofos_sym(a, "ir_emit_label");
    return 0;
}

/* ---- WIR builder conveniences ---- */

/* Open function `name` (a C string) with `argc` params; returns nothing.
 * Emits FUNCDEF with a fresh temp and a persistent BCPL name. */
static void h_funcdef(struct hofos_api *a, const char *name, int argc)
{
    hword f = a->new_temp();
    a->emit(IR_FUNCDEF, f, argc, (hword)(long)hofos_bcpl(name), 0);
}
static void h_funcend(struct hofos_api *a) { a->emit(IR_FUNCEND, 0, 0, 0, 0); }

/* tN = const v ; returns tN. */
static hword h_const(struct hofos_api *a, long v)
{
    hword t = a->new_temp();
    a->emit(IR_CONST, t, v, 0, 0);
    return t;
}
/* tN = a <op> b ; returns tN.  op is one of IR_ADD..IR_MOD etc. */
static hword h_bin(struct hofos_api *a, int op, hword x, hword y)
{
    hword t = a->new_temp();
    a->emit(op, t, x, y, 0);
    return t;
}
/* tN = -x ; returns tN. */
static hword h_neg(struct hofos_api *a, hword x)
{
    hword t = a->new_temp();
    a->emit(IR_NEG, t, x, 0, 0);
    return t;
}
static void h_return(struct hofos_api *a, hword x) { a->emit(IR_RETURN, 0, x, 0, 0); }

/* dst := src  (used to merge branch results into a stable "variable" temp). */
static void h_mov(struct hofos_api *a, hword dst, hword src) { a->emit(IR_MOV, dst, src, 0, 0); }

/* tN = address of an interned string literal `s` (BCPL layout: byte0 = length,
 * chars at +1).  So the char data starts at (tN + 1), length = strlen(s) (<=255). */
static hword h_strlit(struct hofos_api *a, const char *s)
{
    hword t = a->new_temp();
    a->emit(IR_STRLIT, t, (hword)(long)hofos_bcpl(s), 0, 0);
    return t;
}

/* Declare formal parameter #k (0-based) of the current function; returns the temp
 * holding it.  cg's IR_PARAM expects 1-BASED indices (index 1 = first arg in rdi,
 * mapped to arg-spill slot 7-index) -- matching lower.b's `FOR i = 1 TO argc` -- so
 * emit k+1.  (Passing 0-based left param 0 unmapped and shifted the rest.) */
static hword h_param(struct hofos_api *a, int k)
{
    hword t = a->new_temp();
    a->emit(IR_PARAM, t, k + 1, 0, 0);
    return t;
}

/* tN = name(args[0..argc-1]) ; returns tN (the result temp).  Callee is a CONST of
 * the name pointer with the a2=1 "func-name pointer" marker (so codegen resolves it
 * by name and whole-fn DCE keeps it).  Up to 3 args in a1..a3; args 4,5 via SETARG. */
static hword h_call(struct hofos_api *a, const char *name, hword *args, int argc)
{
    hword callee = a->new_temp();
    a->emit(IR_CONST, callee, (hword)(long)hofos_bcpl(name), 1, 0);   /* marker a2=1 */
    hword dst = a->new_temp();
    hword a1 = argc > 0 ? args[0] : 0;
    hword a2 = argc > 1 ? args[1] : 0;
    hword a3 = argc > 2 ? args[2] : 0;
    if (argc > 3) a->emit(IR_SETARG, 0, args[3], 4, 0);
    if (argc > 4) a->emit(IR_SETARG, 0, args[4], 5, 0);
    hword n = a->emit_call(dst, callee, argc, a1, a2);
    if (argc > 2) a->set_arg3(n, a3);
    return dst;
}

#endif /* HOFOSC_H */
