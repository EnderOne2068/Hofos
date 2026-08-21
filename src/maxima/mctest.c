/* multi-compile stress test: drive libhofos's compile pipeline many times in one
 * process.  Pre-fix, the bump heap never frees, so this exhausts the 64 MB .bss heap
 * and crashes after a handful of compiles.  Post-fix (hofos_begin -> heap_reclaim),
 * each compile reclaims the previous one's arenas, so it runs indefinitely. */
#include "hofos.h"
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv)
{
    struct hofos_api a;
    const char *lib = argc > 1 ? argv[1] : "./libhofos.so";
    int N = argc > 2 ? atoi(argv[2]) : 300;
    if (hofos_open(&a, lib)) { fprintf(stderr, "open %s failed\n", lib); return 2; }

    for (int i = 0; i < N; i++) {
        a.begin();
        h_funcdef(&a, "start", 0);
        /* a small but non-trivial body so cg/dce actually allocate scratch each time */
        hword acc = h_const(&a, i);
        for (int k = 0; k < 8; k++) acc = h_bin(&a, IR_ADD, acc, h_const(&a, k * 3 + 1));
        h_return(&a, acc);
        h_funcend(&a);
        a.optimize(2);
        a.emit_elf((void *)hofos_bcpl("/tmp/mc_out.elf"));
        if (i % 25 == 0) { fprintf(stderr, "  compile %d ok\n", i); fflush(stderr); }
    }
    printf("ALL %d COMPILES OK (no heap exhaustion)\n", N);
    return 0;
}
