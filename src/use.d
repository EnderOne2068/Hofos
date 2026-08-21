// Using one Hofos backend directly from D.
import hofos.cg.x86.linux;   // just the x86-64 Linux backend
import std.stdio;

void main()
{
    // Granlund-Montgomery magic for division by a constant, straight out of
    // the backend: x/10 == MULHI(x, M) >>arith s, plus the sign bit.
    long[1] M, s;
    foreach (d; [3L, 5L, 10L, 100L])
    {
        ax_magic(d, cast(long)M.ptr, cast(long)s.ptr);
        writefln("  /%-4d  M = 0x%016x  shift = %d", d, M[0], s[0]);
    }
}
