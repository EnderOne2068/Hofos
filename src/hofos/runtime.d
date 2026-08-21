// Generated from BCPL by cg-d.b, split into modules by split.d.
module hofos.runtime;

import hofos.all;

// Support code for the port, of two kinds:
//   * primitives with NO BCPL source at all -- the backend emits them
//     (wrch, __alloc, __fval, the file syscalls);
//   * translations of the libhdr.h routines the compiler happens to call
//     (writef, rdch, findinput, ...).
// libhdr ITSELF stays BCPL -- include/libhdr.h is the runtime header
// every compiled BCPL program GETs, and it is never ported to D.  These
// are the port's own copies of what it calls, not a D libhdr.
import core.stdc.stdio : putchar;
import core.stdc.stdlib : malloc, exit;

long wrch(long c) { putchar(cast(int)c); return 0; }
long writes(long s)
{
    ubyte* p = cast(ubyte*)s;
    long n = p[0];
    for (long k = 1; k <= n; k++) putchar(p[k]);
    return 0;
}
long __alloc(long nwords)
{
    return cast(long)malloc(cast(size_t)(nwords * 8));
}
double __fval(long b) { return *cast(double*)&b; }  // bits -> double
long __fbits(double d) { return *cast(long*)&d; }   // double -> bits
version (Windows)
{
    extern(C) int _open(const(char)*, int, ...);
    extern(C) int _close(int);
    extern(C) int _read(int, void*, uint);
    extern(C) int _write(int, const(void)*, uint);
    alias os_open = _open;   alias os_close = _close;
    alias os_read = _read;   alias os_write = _write;
    enum : int { O_RDONLY = 0, O_WRONLY = 1, O_CREAT = 0x0100,
                 O_TRUNC = 0x0200, O_BINARY = 0x8000 }
}
else
{
    extern(C) int open(const(char)*, int, ...);
    extern(C) int close(int);
    extern(C) long read(int, void*, size_t);
    extern(C) long write(int, const(void)*, size_t);
    alias os_open = open;    alias os_close = close;
    alias os_read = read;    alias os_write = write;
    enum : int { O_RDONLY = 0, O_WRONLY = 1, O_CREAT = 0x40,
                 O_TRUNC = 0x200, O_BINARY = 0 }
}
long __write(long fd = 0, long buf = 0, long len = 0)
{
    if (fd == 1 || fd == 2)
    {
        ubyte* p = cast(ubyte*)buf;
        for (long k = 0; k < len; k++) putchar(p[k]);
        return len;
    }
    return os_write(cast(int)fd, cast(void*)buf, cast(uint)len);
}
long __read(long fd = 0, long buf = 0, long len = 0)
{ return os_read(cast(int)fd, cast(void*)buf, cast(uint)len); }
long __open(long name)
{ return os_open(cast(const(char)*)name, O_RDONLY | O_BINARY); }
long __create(long name)
{ return os_open(cast(const(char)*)name,
                 O_WRONLY | O_CREAT | O_TRUNC | O_BINARY, 493); }  // 0755
long __close(long h) { return os_close(cast(int)h); }
long __syscall6(long n = 0, long a = 0, long b = 0, long c = 0, long d = 0, long e = 0) { return -1; } // no raw syscalls here
long __exitcode(long n) { exit(cast(int)n); return 0; }
long __delay(long ms) { return 0; }                      // TODO: port
long __ticks() { return 0; }                             // TODO: port
long setjump(long env) { return 0; }   // coroutines need a real port
long longjump(long env = 0, long v = 0) { return 0; }
long getvec(long p1 = 0)
{
    long v0 = 0;
    long n = p1;
    return __alloc((n + 1L));
}
long freevec(long p1 = 0)
{
    long v0 = 0;
    long cur = 0;
    long v1 = 0;
    long p = p1;
    cur = __alloc(0L);
    if (p != 0L)
    {
        if (p <= cur) goto L17; else goto L18;
L17:
        v1 = __alloc(((p - cur) / 8L));
    }
L18:
    return 0;
}
long newline()
{
    long v0 = 0;
    return wrch(10L);
}
long writen_pos(long p1 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long n = p1;
    if (n >= 10L)
    {
        v0 = writen_pos((n / 10L));
    }
    v1 = wrch((48L + (n % 10L)));
    return 0;
}
long writen(long p1 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long n = p1;
    if (n < 0L)
    {
        v0 = wrch(45L);
        n = (-n);
    }
    v1 = writen_pos(n);
    return 0;
}
long writes_dyn(long p1 = 0)
{
    long n = 0;
    long i = 0;
    long v0 = 0;
    long s = p1;
    n = cast(long)*cast(ubyte*)(s + 0L);
    i = 1L;
    while (i <= n)
    {
        v0 = wrch(cast(long)*cast(ubyte*)(s + i));
        i = (i + 1L);
    }
    return 0;
}
long writex_pos(long p1 = 0, long p2 = 0)
{
    long v0 = 0;
    long d = 0;
    long v1 = 0;
    long v2 = 0;
    long n = p1;
    long width = p2;
    if (n >= 16L) goto L28; else goto L30;
L30:
    if (width > 1L) goto L28; else goto L29;
L28:
    v0 = writex_pos((n >> 4L), (width - 1L));
L29:
    d = (n & 15L);
    if (d < 10L)
    {
        v1 = (48L + d);
    }
    else
    {
        v1 = ((65L + d) - 10L);
    }
    v2 = wrch(v1);
    return 0;
}
long writex(long p1 = 0)
{
    long v0 = 0;
    long n = p1;
    return writex_pos(n, 1L);
}
long writeo(long p1 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long n = p1;
    if ((n >> 3L) != 0L)
    {
        v0 = writeo((n >> 3L));
    }
    v1 = wrch((48L + (n & 7L)));
    return 0;
}
long writefloat(long p1 = 0)
{
    long ip = 0;
    long frac = 0;
    long scaled = 0;
    long half = 0;
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long d = 0;
    long v3 = 0;
    long x = p1;
    ip = 0L;
    frac = 0L;
    scaled = 0L;
    half = __fbits(__fval(__fbits(cast(double)1L)) / __fval(__fbits(cast(double)2L)));
    if (cast(long)(__fval(x) < __fval(__fbits(cast(double)0L))) != 0)
    {
        v0 = wrch(45L);
        x = __fbits(__fval(__fbits(cast(double)0L)) - __fval(x));
    }
    ip = cast(long)__fval(x);
    frac = __fbits(__fval(x) - __fval(__fbits(cast(double)ip)));
    scaled = cast(long)__fval(__fbits(__fval(__fbits(__fval(frac) * __fval(__fbits(cast(double)1000000L)))) + __fval(half)));
    if (scaled >= 1000000L)
    {
        ip = (ip + 1L);
        scaled = (scaled - 1000000L);
    }
    v1 = writen(ip);
    v2 = wrch(46L);
    d = 100000L;
    while (d > 0L)
    {
        v3 = wrch((48L + ((scaled / d) % 10L)));
        d = (d / 10L);
    }
    return 0;
}
long writef(long p1 = 0, long p2 = 0, long p3 = 0, long p4 = 0, long p5 = 0)
{
    long n = 0;
    long i = 0;
    long arg = 0;
    long ch = 0;
    long[5] __v397;
    long v0 = 0;
    long args = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long v6 = 0;
    long v7 = 0;
    long v8 = 0;
    long fmt = p1;
    long a1 = p2;
    long a2 = p3;
    long a3 = p4;
    long a4 = p5;
    n = cast(long)*cast(ubyte*)(fmt + 0L);
    i = 1L;
    arg = 0L;
    ch = 0L;
    v0 = cast(long)__v397.ptr;
    args = v0;
    *cast(long*)(args + (0L << 3L)) = a1;
    *cast(long*)(args + (1L << 3L)) = a2;
    *cast(long*)(args + (2L << 3L)) = a3;
    *cast(long*)(args + (3L << 3L)) = a4;
L43:
    if (i <= n)
    {
        ch = cast(long)*cast(ubyte*)(fmt + i);
        if (ch == 37L)
        {
            i = (i + 1L);
            if (i > n)
            {
    goto L45;
            }
            ch = cast(long)*cast(ubyte*)(fmt + i);
            if (ch == 110L)
            {
                if (arg < 4L)
                {
                    v1 = writen(*cast(long*)(args + (arg << 3L)));
                }
                arg = (arg + 1L);
            }
            else
            {
                if (ch == 115L)
                {
                    if (arg < 4L)
                    {
                        v2 = writes_dyn(*cast(long*)(args + (arg << 3L)));
                    }
                    arg = (arg + 1L);
                }
                else
                {
                    if (ch == 99L)
                    {
                        if (arg < 4L)
                        {
                            v3 = wrch(*cast(long*)(args + (arg << 3L)));
                        }
                        arg = (arg + 1L);
                    }
                    else
                    {
                        if (ch == 120L)
                        {
                            if (arg < 4L)
                            {
                                v4 = writex(*cast(long*)(args + (arg << 3L)));
                            }
                            arg = (arg + 1L);
                        }
                        else
                        {
                            if (ch == 111L)
                            {
                                if (arg < 4L)
                                {
                                    v5 = writeo(*cast(long*)(args + (arg << 3L)));
                                }
                                arg = (arg + 1L);
                            }
                            else
                            {
                                if (ch == 102L)
                                {
                                    if (arg < 4L)
                                    {
                                        v6 = writefloat(*cast(long*)(args + (arg << 3L)));
                                    }
                                    arg = (arg + 1L);
                                }
                                else
                                {
                                    v7 = wrch(ch);
                                }
                            }
                        }
                    }
                }
            }
            i = (i + 1L);
        }
        else
        {
            v8 = wrch(ch);
            i = (i + 1L);
        }
    goto L43;
    }
L45:
    return 0;
}
long rdch()
{
    long ch = 0;
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    ch = (-1L);
L81:
    if (1L != 0)
    {
        if (__rdpb != 0L)
        {
            ch = (__rdpb - 1L);
            __rdpb = 0L;
        }
        else
        {
            if (__rdbuf == 0L)
            {
                __rdbuf = getvec(513L);
            }
            if (__rdpos >= __rdn)
            {
                if (__unbuf != 0)
                {
                    v1 = 1L;
                }
                else
                {
                    v1 = 4096L;
                }
                __rdn = __read(__rdfd, __rdbuf, v1);
                __rdpos = 0L;
                if (__rdn <= 0L)
                {
                    return (-1L);
                }
            }
            ch = (cast(long)*cast(ubyte*)(__rdbuf + __rdpos) & 255L);
            __rdpos = (__rdpos + 1L);
        }
        if (ch == 13L) goto L97; else goto L96;
L96:
    goto L83;
L97:
    goto L81;
    }
L83:
    return ch;
}
long unrdch(long p1 = 0)
{
    long c = p1;
    __rdpb = (c + 1L);
    return 0;
}
long strcopy_bcpl_to_c(long p1 = 0, long p2 = 0)
{
    long n = 0;
    long i = 0;
    long src = p1;
    long dst = p2;
    n = cast(long)*cast(ubyte*)(src + 0L);
    i = 1L;
    while (i <= n)
    {
        *cast(ubyte*)(dst + (i - 1L)) = cast(ubyte)cast(long)*cast(ubyte*)(src + i);
        i = (i + 1L);
    }
    *cast(ubyte*)(dst + n) = cast(ubyte)0L;
    return n;
}
long findinput(long p1 = 0)
{
    long[129] __v604;
    long v0 = 0;
    long cbuf = 0;
    long fd = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long path_bcpl = p1;
    v0 = cast(long)__v604.ptr;
    cbuf = v0;
    fd = 0L;
    v1 = strcopy_bcpl_to_c(path_bcpl, cbuf);
    fd = __open(cbuf);
    if (fd > 0L)
    {
        v3 = fd;
    }
    else
    {
        v3 = 0L;
    }
    return v3;
}
long selectinput(long p1 = 0)
{
    long fd = p1;
    __rdpos = 0L;
    __rdn = 0L;
    __rdpb = 0L;
    __rdfd = fd;
    return 0;
}
long endread()
{
    long v0 = 0;
    if (__rdfd > 0L)
    {
        v0 = __close(__rdfd);
    }
    __rdpos = 0L;
    __rdn = 0L;
    __rdpb = 0L;
    __rdfd = 0L;
    return 0;
}
long findoutput(long p1 = 0)
{
    long[129] __v674;
    long v0 = 0;
    long cbuf = 0;
    long v1 = 0;
    long v2 = 0;
    long path_bcpl = p1;
    v0 = cast(long)__v674.ptr;
    cbuf = v0;
    v1 = strcopy_bcpl_to_c(path_bcpl, cbuf);
    return __create(cbuf);
}
long __finish()
{
    long v0 = 0;
    v0 = __syscall6(60L, 0L, 0L, 0L, 0L, 0);
    return 0;
}
long selectoutput(long p1 = 0)
{
    long fd = p1;
    __outfd = fd;
    return 0;
}
long output()
{
    long v0 = 0;
    if (__outfd != 0L)
    {
        v0 = __outfd;
    }
    else
    {
        v0 = 1L;
    }
    return v0;
}
long input()
{
    return __rdfd;
}
long endwrite()
{
    long v0 = 0;
    if (__outfd > 1L)
    {
        v0 = __close(__outfd);
    }
    __outfd = 0L;
    return 0;
}
long binwrch(long p1 = 0)
{
    long[2] __v1791;
    long v0 = 0;
    long buf = 0;
    long v1 = 0;
    long fd = 0;
    long v2 = 0;
    long c = p1;
    v0 = cast(long)__v1791.ptr;
    buf = v0;
    if (__outfd != 0L)
    {
        v1 = __outfd;
    }
    else
    {
        v1 = 1L;
    }
    fd = v1;
    *cast(ubyte*)(buf + 0L) = cast(ubyte)(c & 255L);
    v2 = __write(fd, buf, 1L);
    return 0;
}
long c_to_bcpl(long p1 = 0, long p2 = 0)
{
    long n = 0;
    long i = 0;
    long c_str = p1;
    long dst = p2;
    n = 0L;
    if (c_str == 0L)
    {
        *cast(ubyte*)(dst + 0L) = cast(ubyte)0L;
        *cast(ubyte*)(dst + 1L) = cast(ubyte)0L;
        return 0;
    }
L349:
    if (cast(long)*cast(ubyte*)(c_str + n) == 0L) goto L351; else goto L352;
L352:
    if (n >= 254L) goto L351; else goto L350;
L350:
    n = (n + 1L);
    goto L349;
L351:
    *cast(ubyte*)(dst + 0L) = cast(ubyte)n;
    i = 0L;
    while (i <= (n - 1L))
    {
        *cast(ubyte*)(dst + (i + 1L)) = cast(ubyte)cast(long)*cast(ubyte*)(c_str + i);
        i = (i + 1L);
    }
    *cast(ubyte*)(dst + (n + 1L)) = cast(ubyte)0L;
    return 0;
}
long rdargs_cmdline(long p1 = 0, long p2 = 0)
{
    long s = 0;
    long i = 0;
    long out_ = 0;
    long k = 0;
    long start = 0;
    long len = 0;
    long buf = 0;
    long quoted = 0;
    long v0 = 0;
    long j = 0;
    long dst = p1;
    long max = p2;
    s = __argv;
    i = 0L;
    out_ = 0L;
    k = 0L;
    while (k <= (max - 1L))
    {
        *cast(long*)(dst + (k << 3L)) = 0L;
        k = (k + 1L);
    }
    if (cast(long)*cast(ubyte*)(s + 0L) == 34L)
    {
        i = 1L;
L364:
        if (cast(long)*cast(ubyte*)(s + i) != 0L)
        {
            if (cast(long)*cast(ubyte*)(s + i) != 34L) goto L365; else goto L366;
L365:
            i = (i + 1L);
    goto L364;
        }
L366:
        if (cast(long)*cast(ubyte*)(s + i) == 34L)
        {
            i = (i + 1L);
        }
    }
    else
    {
L370:
        if (cast(long)*cast(ubyte*)(s + i) != 0L)
        {
            if (cast(long)*cast(ubyte*)(s + i) != 32L) goto L371; else goto L372;
L371:
            i = (i + 1L);
    goto L370;
        }
L372:
    }
    while (1L != 0)
    {
L377:
        if (cast(long)*cast(ubyte*)(s + i) == 32L)
        {
            i = (i + 1L);
    goto L377;
        }
        if (cast(long)*cast(ubyte*)(s + i) == 0L)
        {
            return out_;
        }
        start = 0L;
        len = 0L;
        buf = 0L;
        quoted = cast(long)(cast(long)*cast(ubyte*)(s + i) == 34L);
        if (quoted != 0)
        {
            i = (i + 1L);
        }
        start = i;
        if (quoted != 0)
        {
L387:
            if (cast(long)*cast(ubyte*)(s + i) != 0L)
            {
                if (cast(long)*cast(ubyte*)(s + i) != 34L) goto L388; else goto L389;
L388:
                i = (i + 1L);
    goto L387;
            }
L389:
        }
        else
        {
L391:
            if (cast(long)*cast(ubyte*)(s + i) != 0L)
            {
                if (cast(long)*cast(ubyte*)(s + i) != 32L) goto L392; else goto L393;
L392:
                i = (i + 1L);
    goto L391;
            }
L393:
        }
        len = (i - start);
        if (quoted != 0)
        {
            if (cast(long)*cast(ubyte*)(s + i) == 34L) goto L395; else goto L396;
L395:
            i = (i + 1L);
        }
L396:
        if (out_ < max)
        {
            buf = getvec(((len / 8L) + 2L));
            *cast(ubyte*)(buf + 0L) = cast(ubyte)len;
            j = 1L;
            while (j <= len)
            {
                *cast(ubyte*)(buf + j) = cast(ubyte)cast(long)*cast(ubyte*)(s + ((start + j) - 1L));
                j = (j + 1L);
            }
            *cast(ubyte*)(buf + (len + 1L)) = cast(ubyte)0L;
            *cast(long*)(dst + (out_ << 3L)) = buf;
            out_ = (out_ + 1L);
        }
    }
    return out_;
}
long rdargs(long p1 = 0, long p2 = 0, long p3 = 0)
{
    long argv_ptr = 0;
    long n = 0;
    long bcpl_buf = 0;
    long v0 = 0;
    long i = 0;
    long i_2 = 0;
    long v1 = 0;
    long v2 = 0;
    long spec = p1;
    long dst = p2;
    long max = p3;
    argv_ptr = __argv;
    n = 0L;
    bcpl_buf = 0L;
    if (__argc == (-1L))
    {
        return rdargs_cmdline(dst, max);
    }
    n = (__argc - 1L);
    if (n < 0L)
    {
        return 0L;
    }
    if (n > max)
    {
        n = max;
    }
    i = 0L;
    while (i <= (max - 1L))
    {
        *cast(long*)(dst + (i << 3L)) = 0L;
        i = (i + 1L);
    }
    i_2 = 0L;
    while (i_2 <= (n - 1L))
    {
        bcpl_buf = getvec(32L);
        v2 = c_to_bcpl(*cast(long*)(argv_ptr + ((i_2 + 1L) << 3L)), bcpl_buf);
        *cast(long*)(dst + (i_2 << 3L)) = bcpl_buf;
        i_2 = (i_2 + 1L);
    }
    return n;
}
