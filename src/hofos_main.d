// The entry point lives OUTSIDE the package so that `import hofos;`
// does not drag a main() into someone else's program.
module hofos_main;

import hofos;
import core.stdc.stdlib : malloc;

int main(string[] args)
{
    long* av = cast(long*)malloc((args.length + 1) * 8);
    foreach (k, a; args)
    {
        char* c = cast(char*)malloc(a.length + 1);
        c[0 .. a.length] = a[];
        c[a.length] = 0;
        av[k] = cast(long)c;
    }
    av[args.length] = 0;
    __argc = cast(long)args.length;
    __argv = cast(long)av;
    return cast(int)start();
}
