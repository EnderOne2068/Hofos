/* sbcl_embed.c -- minimal proof that a C program (with its own main) can embed
 * SBCL by linking the Debian runtime object /usr/lib/sbcl/sbcl.o.  SBCL is a
 * native-code Lisp compiler, so the symbolic engine (Maxima) it will host runs at
 * native speed -- the reason we embed SBCL rather than a bytecode Lisp like ECL.
 *
 * The runtime object exposes initialize_lisp() and funcallN() and defines no main(),
 * so we supply main and drive it.  initialize_lisp() parses argv exactly like the
 * `sbcl` binary (which is just `return initialize_lisp(argc,argv,envp)`), then runs
 * the Lisp toplevel and exits -- so passing --eval/--quit boots SBCL, evaluates a
 * form, and quits.  This is the "hello world" of SBCL embedding.
 *
 * Build (link recipe from /usr/lib/sbcl/sbcl.mk):
 *   cc sbcl_embed.c /usr/lib/sbcl/sbcl.o -ldl -lpthread -lzstd -lm \
 *      -Wl,--export-dynamic -o sbcl_embed
 * Run: ./sbcl_embed
 */

#include <stddef.h>
#include <stdio.h>

/* Declared here because the Debian package ships no sbcl.h.  Signature matches
 * SBCL's runtime.c: initialize_lisp(int argc, char *argv[], char *envp[]). */
extern int initialize_lisp(int argc, char **argv, char **envp);

int main(void)
{
    char *args[] = {
        "maxima-embed",
        "--core", "/usr/lib/sbcl/sbcl.core",
        "--noinform",
        "--disable-ldb",
        "--end-runtime-options",
        "--no-sysinit", "--no-userinit",
        "--disable-debugger",
        "--eval", "(format t \"lisp says: ~a~%\" (+ 6 7))",
        "--eval", "(finish-output)",
        "--quit",
        NULL
    };
    int argc = 0;
    while (args[argc]) argc++;

    fprintf(stderr, "[embed] booting SBCL runtime...\n");
    return initialize_lisp(argc, args, NULL);
}
