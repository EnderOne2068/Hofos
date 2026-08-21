/* sbcl_interop.c -- prove two-way C<->Lisp interop with embedded SBCL.
 *
 * With :callable-exports, initialize_lisp() reinitializes the runtime, fills the
 * named global symbols below with the Lisp callables' addresses, and RETURNS to C
 * (no Lisp toplevel takes over).  We then call the callables like ordinary C
 * function pointers.  The Maxima frontend uses exactly this to hand expressions to
 * the embedded Maxima and get simplified results back.
 *
 * Build: cc sbcl_interop.c /usr/lib/sbcl/sbcl.o -ldl -lpthread -lzstd -lm \
 *           -Wl,--export-dynamic -o sbcl_interop
 * Run  : ./sbcl_interop           (needs test.core in cwd)
 */

#include <stdio.h>

extern int initialize_lisp(int argc, char **argv, char **envp);

/* SBCL fills these during initialize_lisp (the ("c_name" ...) forms in the core).
 * They are data symbols; --export-dynamic makes them visible to the runtime's
 * foreign-symbol lookup so it can write the callable addresses in. */
void *lisp_addone = 0;
void *lisp_echo   = 0;

typedef int   (*addone_fn)(int);
typedef char *(*echo_fn)(const char *);

int main(void)
{
    char *args[] = {
        "maxima", "--core", "test.core",
        "--noinform", "--disable-ldb", "--end-runtime-options",
        "--no-sysinit", "--no-userinit",
        NULL
    };
    int argc = 0;
    while (args[argc]) argc++;

    fprintf(stderr, "[interop] initialize_lisp...\n");
    initialize_lisp(argc, args, NULL);
    fprintf(stderr, "[interop] returned to C; addone=%p echo=%p\n", lisp_addone, lisp_echo);

    if (!lisp_addone || !lisp_echo) {
        fprintf(stderr, "[interop] FAIL: callable-export symbols were not filled\n");
        return 1;
    }

    addone_fn addone = (addone_fn)lisp_addone;
    echo_fn   echo   = (echo_fn)lisp_echo;

    printf("addone(41)         = %d   (expect 42)\n", addone(41));
    printf("echo(\"hi from C\") = %s\n", echo("hi from C"));
    return 0;
}
