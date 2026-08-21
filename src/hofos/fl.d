// Generated from BCPL by cg-d.b, split into modules by split.d.
module hofos.fl;

import hofos.all;

long rd8(long p1 = 0, long p2 = 0)
{
    long b = p1;
    long o = p2;
    return cast(long)*cast(ubyte*)(b + o);
}
long rd16(long p1 = 0, long p2 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long b = p1;
    long o = p2;
    v0 = rd8(b, o);
    return (v0 | (rd8(b, (o + 1L)) << 8L));
}
long rd32(long p1 = 0, long p2 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long b = p1;
    long o = p2;
    v0 = rd16(b, o);
    return (v0 | (rd16(b, (o + 2L)) << 16L));
}
long rd64(long p1 = 0, long p2 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long b = p1;
    long o = p2;
    v0 = rd32(b, o);
    return (v0 | (rd32(b, (o + 4L)) << 32L));
}
long fl_put(long p1 = 0)
{
    long v0 = 0;
    long v = p1;
    return binwrch((v & 255L));
}
long fl_put16(long p1 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v = p1;
    v0 = fl_put(v);
    v1 = fl_put((v >> 8L));
    return 0;
}
long fl_put32(long p1 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v = p1;
    v0 = fl_put(v);
    v1 = fl_put((v >> 8L));
    v2 = fl_put((v >> 16L));
    v3 = fl_put((v >> 24L));
    return 0;
}
long fl_put64(long p1 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v = p1;
    v0 = fl_put32(v);
    v1 = fl_put32((v >> 32L));
    return 0;
}
long fl_patch32(long p1 = 0, long p2 = 0)
{
    long o = p1;
    long v = p2;
    *cast(ubyte*)(fl_code + (o + 0L)) = cast(ubyte)(v & 255L);
    *cast(ubyte*)(fl_code + (o + 1L)) = cast(ubyte)((v >> 8L) & 255L);
    *cast(ubyte*)(fl_code + (o + 2L)) = cast(ubyte)((v >> 16L) & 255L);
    *cast(ubyte*)(fl_code + (o + 3L)) = cast(ubyte)((v >> 24L) & 255L);
    return 0;
}
long fl_patch64(long p1 = 0, long p2 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long o = p1;
    long v = p2;
    v0 = fl_patch32(o, v);
    v1 = fl_patch32((o + 4L), (v >> 32L));
    return 0;
}
long fl_ends_with(long p1 = 0, long p2 = 0)
{
    long ns = 0;
    long nt = 0;
    long off = 0;
    long i = 0;
    long s = p1;
    long suffix = p2;
    ns = cast(long)*cast(ubyte*)(s + 0L);
    nt = cast(long)*cast(ubyte*)(suffix + 0L);
    off = (ns - nt);
    if (ns < nt)
    {
        return 0L;
    }
    i = 1L;
    while (i <= nt)
    {
        if (cast(long)*cast(ubyte*)(s + (off + i)) != cast(long)*cast(ubyte*)(suffix + i))
        {
            return 0L;
        }
        i = (i + 1L);
    }
    return 1L;
}
long fl_note_undef(long p1 = 0)
{
    long i = 0;
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long nm = p1;
    i = 0L;
    while (i <= (fl_undefn - 1L))
    {
        if (fl_streq(*cast(long*)(fl_undef_nm + (i << 3L)), nm) != 0)
        {
            return 0;
        }
        i = (i + 1L);
    }
    if (fl_undefn < 1024L)
    {
        *cast(long*)(fl_undef_nm + (fl_undefn << 3L)) = nm;
        fl_undefn = (fl_undefn + 1L);
    }
    v2 = writef(cast(long)__s27943.ptr, nm);
    return 0;
}
long fl_reloc_symname(long p1 = 0, long p2 = 0)
{
    long buf = 0;
    long v0 = 0;
    long off = 0;
    long v1 = 0;
    long v2 = 0;
    long k = p1;
    long sb = p2;
    buf = *cast(long*)(fl_obuf + (k << 3L));
    off = rd32(buf, sb);
    if (off == 0L)
    {
        return cast(long)__s27959.ptr;
    }
    return fl_str_dup(buf, (*cast(long*)(fl_ostroff + (k << 3L)) + off));
}
long fl_note_abs_in_so(long p1 = 0)
{
    long i = 0;
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long nm = p1;
    i = 0L;
    while (i <= (fl_absn - 1L))
    {
        if (fl_streq(*cast(long*)(fl_abs_nm + (i << 3L)), nm) != 0)
        {
            return 0;
        }
        i = (i + 1L);
    }
    if (fl_absn < 256L)
    {
        *cast(long*)(fl_abs_nm + (fl_absn << 3L)) = nm;
        fl_absn = (fl_absn + 1L);
    }
    v2 = writef(cast(long)__s27996.ptr, nm);
    return 0;
}
long fl_streq(long p1 = 0, long p2 = 0)
{
    long i = 0;
    long a = p1;
    long b = p2;
    if (a == 0L) goto L5969; else goto L5971;
L5971:
    if (b == 0L) goto L5969; else goto L5970;
L5969:
    return 0L;
L5970:
    if (cast(long)*cast(ubyte*)(a + 0L) != cast(long)*cast(ubyte*)(b + 0L))
    {
        return 0L;
    }
    i = 1L;
    while (i <= cast(long)*cast(ubyte*)(a + 0L))
    {
        if (cast(long)*cast(ubyte*)(a + i) != cast(long)*cast(ubyte*)(b + i))
        {
            return 0L;
        }
        i = (i + 1L);
    }
    return 1L;
}
long fl_align8(long p1 = 0)
{
    long x = p1;
    return ((x + 7L) & (~7L));
}
long fl_align16(long p1 = 0)
{
    long x = p1;
    return ((x + 15L) & (~15L));
}
long fl_str_dup(long p1 = 0, long p2 = 0)
{
    long n = 0;
    long s = 0;
    long v0 = 0;
    long i = 0;
    long buf = p1;
    long off = p2;
    n = 0L;
    s = 0L;
L5980:
    if (cast(long)*cast(ubyte*)(buf + (off + n)) == 0L) goto L5982; else goto L5981;
L5981:
    n = (n + 1L);
    goto L5980;
L5982:
    s = getvec(((n / 8L) + 2L));
    *cast(ubyte*)(s + 0L) = cast(ubyte)n;
    i = 1L;
    while (i <= n)
    {
        *cast(ubyte*)(s + i) = cast(ubyte)cast(long)*cast(ubyte*)(buf + ((off + i) - 1L));
        i = (i + 1L);
    }
    return s;
}
long fl_load1(long p1 = 0, long p2 = 0)
{
    long v0 = 0;
    long fd = 0;
    long v1 = 0;
    long buf = 0;
    long n = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long name = p1;
    long k = p2;
    fd = findinput(name);
    buf = getvec((1L << 20L));
    n = 0L;
    if (fd <= 0L)
    {
        v3 = writef(cast(long)__s28091.ptr, name);
        return 0L;
    }
    n = __read(fd, buf, (1L << 23L));
    v5 = __close(fd);
    if (n < 0L)
    {
        n = 0L;
    }
    *cast(long*)(fl_obuf + (k << 3L)) = buf;
    *cast(long*)(fl_osize + (k << 3L)) = n;
    return 1L;
}
long fl_detect1(long p1 = 0)
{
    long b = 0;
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long k = p1;
    b = *cast(long*)(fl_obuf + (k << 3L));
    if (*cast(long*)(fl_osize + (k << 3L)) >= 4L)
    {
        if (rd8(b, 0L) == 127L) goto L5995; else goto L5992;
L5995:
        if (rd8(b, 1L) == 69L) goto L5994; else goto L5992;
L5994:
        if (rd8(b, 2L) == 76L) goto L5993; else goto L5992;
L5993:
        if (rd8(b, 3L) == 70L) goto L5991; else goto L5992;
L5991:
        return 1L;
    }
L5992:
    if (*cast(long*)(fl_osize + (k << 3L)) >= 20L)
    {
        if (rd16(b, 0L) == 34404L) goto L5997; else goto L5998;
L5997:
        return 2L;
    }
L5998:
    return 0L;
}
long fl_coff_name(long p1 = 0, long p2 = 0, long p3 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long s = 0;
    long n = 0;
    long j = 0;
    long v4 = 0;
    long c = 0;
    long buf = p1;
    long off = p2;
    long strbase = p3;
    if (rd32(buf, off) == 0L)
    {
        return fl_str_dup(buf, (strbase + rd32(buf, (off + 4L))));
    }
    s = getvec(2L);
    n = 0L;
    j = 0L;
L6002:
    if (j <= 7L)
    {
        c = rd8(buf, (off + j));
        if (c == 0L)
        {
    goto L6005;
        }
        *cast(ubyte*)(s + (j + 1L)) = cast(ubyte)c;
        n = (n + 1L);
        j = (j + 1L);
    goto L6002;
    }
L6005:
    *cast(ubyte*)(s + 0L) = cast(ubyte)n;
    return s;
}
long fl_parse_elf(long p1 = 0)
{
    long buf = 0;
    long v0 = 0;
    long shoff = 0;
    long v1 = 0;
    long shentsize = 0;
    long v2 = 0;
    long shnum = 0;
    long i = 0;
    long b = 0;
    long v3 = 0;
    long typ = 0;
    long v4 = 0;
    long flag = 0;
    long v5 = 0;
    long off = 0;
    long v6 = 0;
    long size = 0;
    long v7 = 0;
    long link = 0;
    long v8 = 0;
    long k = p1;
    buf = *cast(long*)(fl_obuf + (k << 3L));
    shoff = rd64(buf, 40L);
    shentsize = rd16(buf, 58L);
    shnum = rd16(buf, 60L);
    *cast(long*)(fl_otoff + (k << 3L)) = 0L;
    *cast(long*)(fl_otsize + (k << 3L)) = 0L;
    *cast(long*)(fl_oroff + (k << 3L)) = 0L;
    *cast(long*)(fl_orsize + (k << 3L)) = 0L;
    *cast(long*)(fl_odoff + (k << 3L)) = 0L;
    *cast(long*)(fl_odsize + (k << 3L)) = 0L;
    *cast(long*)(fl_obsize + (k << 3L)) = 0L;
    *cast(long*)(fl_osymoff + (k << 3L)) = 0L;
    *cast(long*)(fl_osymsz + (k << 3L)) = 0L;
    *cast(long*)(fl_ostroff + (k << 3L)) = 0L;
    *cast(long*)(fl_oreloff + (k << 3L)) = 0L;
    *cast(long*)(fl_orelsz + (k << 3L)) = 0L;
    i = 0L;
    while (i <= (shnum - 1L))
    {
        b = (shoff + (i * shentsize));
        typ = rd32(buf, (b + 4L));
        flag = rd64(buf, (b + 8L));
        off = rd64(buf, (b + 24L));
        size = rd64(buf, (b + 32L));
        link = rd32(buf, (b + 40L));
        if (typ == 1L)
        {
            if ((flag & 4L) != 0L)
            {
                *cast(long*)(fl_otoff + (k << 3L)) = off;
                *cast(long*)(fl_otsize + (k << 3L)) = size;
            }
            else
            {
                if ((flag & 1L) != 0L)
                {
                    *cast(long*)(fl_odoff + (k << 3L)) = off;
                    *cast(long*)(fl_odsize + (k << 3L)) = size;
                }
                else
                {
                    *cast(long*)(fl_oroff + (k << 3L)) = off;
                    *cast(long*)(fl_orsize + (k << 3L)) = size;
                }
            }
        }
        if (typ == 8L)
        {
            *cast(long*)(fl_obsize + (k << 3L)) = size;
        }
        if (typ == 2L)
        {
            *cast(long*)(fl_osymoff + (k << 3L)) = off;
            *cast(long*)(fl_osymsz + (k << 3L)) = size;
            *cast(long*)(fl_ostroff + (k << 3L)) = rd64(buf, ((shoff + (link * shentsize)) + 24L));
        }
        if (typ == 4L)
        {
            *cast(long*)(fl_oreloff + (k << 3L)) = off;
            *cast(long*)(fl_orelsz + (k << 3L)) = size;
        }
        i = (i + 1L);
    }
    return 0;
}
long fl_parse_coff(long p1 = 0)
{
    long buf = 0;
    long v0 = 0;
    long nsects = 0;
    long v1 = 0;
    long symoff = 0;
    long v2 = 0;
    long nsyms = 0;
    long v3 = 0;
    long optsz = 0;
    long shoff = 0;
    long i = 0;
    long b = 0;
    long v4 = 0;
    long c1 = 0;
    long v5 = 0;
    long size = 0;
    long v6 = 0;
    long praw = 0;
    long v7 = 0;
    long prel = 0;
    long v8 = 0;
    long nrel = 0;
    long k = p1;
    buf = *cast(long*)(fl_obuf + (k << 3L));
    nsects = rd16(buf, 2L);
    symoff = rd32(buf, 8L);
    nsyms = rd32(buf, 12L);
    optsz = rd16(buf, 16L);
    shoff = (20L + optsz);
    *cast(long*)(fl_otoff + (k << 3L)) = 0L;
    *cast(long*)(fl_otsize + (k << 3L)) = 0L;
    *cast(long*)(fl_oroff + (k << 3L)) = 0L;
    *cast(long*)(fl_orsize + (k << 3L)) = 0L;
    *cast(long*)(fl_odoff + (k << 3L)) = 0L;
    *cast(long*)(fl_odsize + (k << 3L)) = 0L;
    *cast(long*)(fl_obsize + (k << 3L)) = 0L;
    *cast(long*)(fl_oreloff + (k << 3L)) = 0L;
    *cast(long*)(fl_orelsz + (k << 3L)) = 0L;
    i = 0L;
    while (i <= (nsects - 1L))
    {
        b = (shoff + (i * 40L));
        c1 = rd8(buf, (b + 1L));
        size = rd32(buf, (b + 16L));
        praw = rd32(buf, (b + 20L));
        prel = rd32(buf, (b + 24L));
        nrel = rd16(buf, (b + 32L));
        if (c1 == 116L)
        {
            *cast(long*)(fl_otoff + (k << 3L)) = praw;
            *cast(long*)(fl_otsize + (k << 3L)) = size;
            *cast(long*)(fl_oreloff + (k << 3L)) = prel;
            *cast(long*)(fl_orelsz + (k << 3L)) = (nrel * 10L);
        }
        if (c1 == 114L)
        {
            *cast(long*)(fl_oroff + (k << 3L)) = praw;
            *cast(long*)(fl_orsize + (k << 3L)) = size;
        }
        if (c1 == 100L)
        {
            *cast(long*)(fl_odoff + (k << 3L)) = praw;
            *cast(long*)(fl_odsize + (k << 3L)) = size;
        }
        if (c1 == 98L)
        {
            *cast(long*)(fl_obsize + (k << 3L)) = size;
        }
        i = (i + 1L);
    }
    *cast(long*)(fl_osymoff + (k << 3L)) = symoff;
    *cast(long*)(fl_osymsz + (k << 3L)) = nsyms;
    *cast(long*)(fl_ostroff + (k << 3L)) = (symoff + (nsyms * 18L));
    return 0;
}
long fl_parse1(long p1 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long k = p1;
    if (fl_fmt == 2L)
    {
        v0 = fl_parse_coff(k);
    }
    else
    {
        v1 = fl_parse_elf(k);
    }
    return 0;
}
long fl_is_import(long p1 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long v6 = 0;
    long v7 = 0;
    long v8 = 0;
    long v9 = 0;
    long v10 = 0;
    long v11 = 0;
    long v12 = 0;
    long v13 = 0;
    long v14 = 0;
    long v15 = 0;
    long v16 = 0;
    long v17 = 0;
    long v18 = 0;
    long v19 = 0;
    long nm = p1;
    if (fl_streq(nm, cast(long)__s28566.ptr) != 0)
    {
        return 1L;
    }
    if (fl_streq(nm, cast(long)__s28570.ptr) != 0)
    {
        return 1L;
    }
    if (fl_streq(nm, cast(long)__s28574.ptr) != 0)
    {
        return 1L;
    }
    if (fl_streq(nm, cast(long)__s28578.ptr) != 0)
    {
        return 1L;
    }
    if (fl_streq(nm, cast(long)__s28582.ptr) != 0)
    {
        return 1L;
    }
    if (fl_streq(nm, cast(long)__s28586.ptr) != 0)
    {
        return 1L;
    }
    if (fl_streq(nm, cast(long)__s28590.ptr) != 0)
    {
        return 1L;
    }
    if (fl_streq(nm, cast(long)__s28594.ptr) != 0)
    {
        return 1L;
    }
    if (fl_streq(nm, cast(long)__s28598.ptr) != 0)
    {
        return 1L;
    }
    if (fl_streq(nm, cast(long)__s28602.ptr) != 0)
    {
        return 1L;
    }
    return 0L;
}
long fl_import_dll(long p1 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long v6 = 0;
    long v7 = 0;
    long v8 = 0;
    long v9 = 0;
    long v10 = 0;
    long v11 = 0;
    long v12 = 0;
    long v13 = 0;
    long v14 = 0;
    long v15 = 0;
    long v16 = 0;
    long v17 = 0;
    long v18 = 0;
    long nm = p1;
    if (fl_is_import(nm) != 0)
    {
        return 0L;
    }
    if (fl_streq(nm, cast(long)__s28612.ptr) != 0)
    {
        return 1L;
    }
    if (fl_streq(nm, cast(long)__s28616.ptr) != 0)
    {
        return 1L;
    }
    if (fl_streq(nm, cast(long)__s28620.ptr) != 0)
    {
        return 1L;
    }
    if (fl_streq(nm, cast(long)__s28624.ptr) != 0)
    {
        return 1L;
    }
    if (fl_streq(nm, cast(long)__s28628.ptr) != 0)
    {
        return 1L;
    }
    if (fl_streq(nm, cast(long)__s28632.ptr) != 0)
    {
        return 1L;
    }
    if (fl_streq(nm, cast(long)__s28636.ptr) != 0)
    {
        return 1L;
    }
    if (fl_streq(nm, cast(long)__s28640.ptr) != 0)
    {
        return 1L;
    }
    if (fl_streq(nm, cast(long)__s28644.ptr) != 0)
    {
        return 1L;
    }
    return (-1L);
}
long fl_dll_name_of(long p1 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long d = p1;
    if (d == 0L)
    {
        v1 = cast(long)__s28654.ptr;
    }
    else
    {
        v1 = cast(long)__s28655.ptr;
    }
    return v1;
}
long fl_import_index(long p1 = 0)
{
    long i = 0;
    long v0 = 0;
    long nm = p1;
    i = 0L;
    while (i <= (fl_imp_n - 1L))
    {
        if (fl_streq(*cast(long*)(fl_imp_names + (i << 3L)), nm) != 0)
        {
            return i;
        }
        i = (i + 1L);
    }
    return (-1L);
}
long fl_import_vaddr(long p1 = 0)
{
    long v0 = 0;
    long i = 0;
    long d = 0;
    long nm = p1;
    i = fl_import_index(nm);
    if (i < 0L)
    {
        return (-1L);
    }
    d = *cast(long*)(fl_imp_dll + (i << 3L));
    return ((fl_rvaddr + *cast(long*)(fl_dll_iat + (d << 3L))) + ((i - *cast(long*)(fl_dll_lo + (d << 3L))) * 8L));
}
long fl_put_rod32(long p1 = 0, long p2 = 0)
{
    long off = p1;
    long v = p2;
    *cast(ubyte*)(fl_rodata + off) = cast(ubyte)(v & 255L);
    *cast(ubyte*)(fl_rodata + (off + 1L)) = cast(ubyte)((v >> 8L) & 255L);
    *cast(ubyte*)(fl_rodata + (off + 2L)) = cast(ubyte)((v >> 16L) & 255L);
    *cast(ubyte*)(fl_rodata + (off + 3L)) = cast(ubyte)((v >> 24L) & 255L);
    return 0;
}
long fl_plan_imports()
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long v6 = 0;
    long v7 = 0;
    long v8 = 0;
    long k = 0;
    long buf = 0;
    long nsyms = 0;
    long s = 0;
    long sb = 0;
    long v9 = 0;
    long sec = 0;
    long v10 = 0;
    long naux = 0;
    long v11 = 0;
    long nm = 0;
    long v12 = 0;
    long d = 0;
    long v13 = 0;
    long w = 0;
    long d_2 = 0;
    long lo = 0;
    long i = 0;
    long tn = 0;
    long td = 0;
    long v14 = 0;
    long n = 0;
    long v15 = 0;
    long off = 0;
    long d_3 = 0;
    long c = 0;
    long i_2 = 0;
    long nm_2 = 0;
    long d_4 = 0;
    fl_imp_n = 0L;
    fl_imp_names = getvec(64L);
    fl_imp_hnoff = getvec(64L);
    fl_imp_dll = getvec(64L);
    fl_dll_name = getvec(8L);
    fl_dll_lo = getvec(8L);
    fl_dll_cnt = getvec(8L);
    fl_dll_ilt = getvec(8L);
    fl_dll_iat = getvec(8L);
    fl_dll_noff = getvec(8L);
    fl_ndll = 0L;
    k = 0L;
    while (k <= (fl_nobj - 1L))
    {
        buf = *cast(long*)(fl_obuf + (k << 3L));
        nsyms = *cast(long*)(fl_osymsz + (k << 3L));
        s = 0L;
L6096:
        if (s >= nsyms) goto L6098; else goto L6097;
L6097:
        sb = (*cast(long*)(fl_osymoff + (k << 3L)) + (s * 18L));
        sec = rd16(buf, (sb + 12L));
        naux = rd8(buf, (sb + 17L));
        if (sec == 0L)
        {
            nm = fl_coff_name(buf, sb, *cast(long*)(fl_ostroff + (k << 3L)));
            d = fl_import_dll(nm);
            if (d >= 0L)
            {
                if (fl_import_index(nm) < 0L) goto L6101; else goto L6102;
L6101:
                *cast(long*)(fl_imp_names + (fl_imp_n << 3L)) = nm;
                *cast(long*)(fl_imp_dll + (fl_imp_n << 3L)) = d;
                fl_imp_n = (fl_imp_n + 1L);
            }
L6102:
        }
        s = ((s + 1L) + naux);
    goto L6096;
L6098:
        k = (k + 1L);
    }
    w = 0L;
    fl_ndll = 0L;
    d_2 = 0L;
    while (d_2 <= 1L)
    {
        lo = w;
        i = 0L;
L6108:
        if (i >= fl_imp_n) goto L6110; else goto L6109;
L6109:
        if (i >= w)
        {
            if (*cast(long*)(fl_imp_dll + (i << 3L)) == d_2) goto L6111; else goto L6112;
L6111:
            tn = *cast(long*)(fl_imp_names + (w << 3L));
            td = *cast(long*)(fl_imp_dll + (w << 3L));
            *cast(long*)(fl_imp_names + (w << 3L)) = *cast(long*)(fl_imp_names + (i << 3L));
            *cast(long*)(fl_imp_dll + (w << 3L)) = *cast(long*)(fl_imp_dll + (i << 3L));
            *cast(long*)(fl_imp_names + (i << 3L)) = tn;
            *cast(long*)(fl_imp_dll + (i << 3L)) = td;
            w = (w + 1L);
        }
L6112:
        i = (i + 1L);
    goto L6108;
L6110:
        if (w > lo)
        {
            *cast(long*)(fl_dll_name + (fl_ndll << 3L)) = fl_dll_name_of(d_2);
            *cast(long*)(fl_dll_lo + (fl_ndll << 3L)) = lo;
            *cast(long*)(fl_dll_cnt + (fl_ndll << 3L)) = (w - lo);
            fl_ndll = (fl_ndll + 1L);
        }
        d_2 = (d_2 + 1L);
    }
    if (fl_imp_n > 0L)
    {
        n = fl_imp_n;
        off = fl_align8(fl_rodsize);
        fl_imp_base = off;
        off = (off + ((fl_ndll + 1L) * 20L));
        d_3 = 0L;
        while (d_3 <= (fl_ndll - 1L))
        {
            c = *cast(long*)(fl_dll_cnt + (d_3 << 3L));
            *cast(long*)(fl_dll_ilt + (d_3 << 3L)) = off;
            off = (off + ((c + 1L) * 8L));
            *cast(long*)(fl_dll_iat + (d_3 << 3L)) = off;
            off = (off + ((c + 1L) * 8L));
            d_3 = (d_3 + 1L);
        }
        fl_imp_iltoff = *cast(long*)(fl_dll_ilt + (0L << 3L));
        fl_imp_iatoff = *cast(long*)(fl_dll_iat + (0L << 3L));
        i_2 = 0L;
        while (i_2 <= (n - 1L))
        {
            nm_2 = *cast(long*)(fl_imp_names + (i_2 << 3L));
            *cast(long*)(fl_imp_hnoff + (i_2 << 3L)) = off;
            off = (((off + 2L) + cast(long)*cast(ubyte*)(nm_2 + 0L)) + 1L);
            if ((off & 1L) != 0L)
            {
                off = (off + 1L);
            }
            i_2 = (i_2 + 1L);
        }
        d_4 = 0L;
        while (d_4 <= (fl_ndll - 1L))
        {
            *cast(long*)(fl_dll_noff + (d_4 << 3L)) = off;
            off = ((off + cast(long)*cast(ubyte*)(*cast(long*)(fl_dll_name + (d_4 << 3L)) + 0L)) + 1L);
            d_4 = (d_4 + 1L);
        }
        fl_imp_dlloff = *cast(long*)(fl_dll_noff + (0L << 3L));
        fl_rodsize = off;
    }
    return 0;
}
long fl_emit_imports()
{
    long n = 0;
    long rrva = 0;
    long o = 0;
    long d = 0;
    long db = 0;
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long lo = 0;
    long j = 0;
    long hn = 0;
    long v3 = 0;
    long v4 = 0;
    long nm = 0;
    long o_2 = 0;
    long j_2 = 0;
    long i = 0;
    long nm_2 = 0;
    long o_3 = 0;
    long j_3 = 0;
    if (fl_imp_n > 0L)
    {
        n = fl_imp_n;
        rrva = (fl_rvaddr - 4194304L);
        o = fl_imp_base;
        while (o <= (fl_rodsize - 1L))
        {
            *cast(ubyte*)(fl_rodata + o) = cast(ubyte)0L;
            o = (o + 1L);
        }
        d = 0L;
        while (d <= (fl_ndll - 1L))
        {
            db = (fl_imp_base + (d * 20L));
            v0 = fl_put_rod32((db + 0L), (rrva + *cast(long*)(fl_dll_ilt + (d << 3L))));
            v1 = fl_put_rod32((db + 12L), (rrva + *cast(long*)(fl_dll_noff + (d << 3L))));
            v2 = fl_put_rod32((db + 16L), (rrva + *cast(long*)(fl_dll_iat + (d << 3L))));
            lo = *cast(long*)(fl_dll_lo + (d << 3L));
            j = 0L;
            while (j <= (*cast(long*)(fl_dll_cnt + (d << 3L)) - 1L))
            {
                hn = (rrva + *cast(long*)(fl_imp_hnoff + ((lo + j) << 3L)));
                v3 = fl_put_rod32((*cast(long*)(fl_dll_ilt + (d << 3L)) + (j * 8L)), hn);
                v4 = fl_put_rod32((*cast(long*)(fl_dll_iat + (d << 3L)) + (j * 8L)), hn);
                j = (j + 1L);
            }
            nm = *cast(long*)(fl_dll_name + (d << 3L));
            o_2 = *cast(long*)(fl_dll_noff + (d << 3L));
            j_2 = 1L;
            while (j_2 <= cast(long)*cast(ubyte*)(nm + 0L))
            {
                *cast(ubyte*)(fl_rodata + ((o_2 + j_2) - 1L)) = cast(ubyte)cast(long)*cast(ubyte*)(nm + j_2);
                j_2 = (j_2 + 1L);
            }
            d = (d + 1L);
        }
        i = 0L;
        while (i <= (n - 1L))
        {
            nm_2 = *cast(long*)(fl_imp_names + (i << 3L));
            o_3 = *cast(long*)(fl_imp_hnoff + (i << 3L));
            j_3 = 1L;
            while (j_3 <= cast(long)*cast(ubyte*)(nm_2 + 0L))
            {
                *cast(ubyte*)(fl_rodata + ((o_3 + 1L) + j_3)) = cast(ubyte)cast(long)*cast(ubyte*)(nm_2 + j_3);
                j_3 = (j_3 + 1L);
            }
            i = (i + 1L);
        }
    }
    return 0;
}
long fl_strless(long p1 = 0, long p2 = 0)
{
    long na = 0;
    long nb = 0;
    long v0 = 0;
    long n = 0;
    long i = 0;
    long a = p1;
    long b = p2;
    na = cast(long)*cast(ubyte*)(a + 0L);
    nb = cast(long)*cast(ubyte*)(b + 0L);
    if (na < nb)
    {
        v0 = na;
    }
    else
    {
        v0 = nb;
    }
    n = v0;
    i = 1L;
    while (i <= n)
    {
        if (cast(long)*cast(ubyte*)(a + i) < cast(long)*cast(ubyte*)(b + i))
        {
            return 1L;
        }
        if (cast(long)*cast(ubyte*)(a + i) > cast(long)*cast(ubyte*)(b + i))
        {
            return 0L;
        }
        i = (i + 1L);
    }
    return cast(long)(na < nb);
}
long fl_plan_exports()
{
    long n = 0;
    long namebytes = 0;
    long i = 0;
    long v0 = 0;
    if (fl_shared != 0L)
    {
        if (fl_gn > 0L) goto L6169; else goto L6170;
L6169:
        n = fl_gn;
        namebytes = 0L;
        i = 0L;
        while (i <= (n - 1L))
        {
            namebytes = ((namebytes + cast(long)*cast(ubyte*)(*cast(long*)(fl_gname + (i << 3L)) + 0L)) + 1L);
            i = (i + 1L);
        }
        fl_exp_off = fl_align8(fl_rodsize);
        fl_exp_size = (((((40L + (n * 4L)) + (n * 4L)) + (n * 2L)) + namebytes) + 16L);
        fl_rodsize = (fl_exp_off + fl_exp_size);
    }
L6170:
    return 0;
}
long fl_emit_exports()
{
    long n = 0;
    long rrva = 0;
    long eat = 0;
    long npt = 0;
    long ord = 0;
    long strs = 0;
    long v0 = 0;
    long idx = 0;
    long so = 0;
    long o = 0;
    long i = 0;
    long i_2 = 0;
    long v = 0;
    long j = 0;
    long go = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long v6 = 0;
    long v7 = 0;
    long k = 0;
    long i_3 = 0;
    long nm = 0;
    long v8 = 0;
    long v9 = 0;
    long j_2 = 0;
    long v10 = 0;
    long d = 0;
    long j_3 = 0;
    long v11 = 0;
    if (fl_shared != 0L)
    {
        if (fl_gn > 0L) goto L6176; else goto L6177;
L6176:
        n = fl_gn;
        rrva = (fl_rvaddr - 4194304L);
        eat = (fl_exp_off + 40L);
        npt = (eat + (n * 4L));
        ord = (npt + (n * 4L));
        strs = (ord + (n * 2L));
        idx = getvec((fl_gn + 2L));
        so = strs;
        o = fl_exp_off;
        while (o <= (fl_rodsize - 1L))
        {
            *cast(ubyte*)(fl_rodata + o) = cast(ubyte)0L;
            o = (o + 1L);
        }
        i = 0L;
        while (i <= (n - 1L))
        {
            *cast(long*)(idx + (i << 3L)) = i;
            i = (i + 1L);
        }
        i_2 = 1L;
        while (i_2 <= (n - 1L))
        {
            v = *cast(long*)(idx + (i_2 << 3L));
            j = (i_2 - 1L);
            go = 1L;
L6191:
            if (go != 0)
            {
                if (j < 0L) goto L6193; else goto L6192;
L6192:
                if (fl_strless(*cast(long*)(fl_gname + (v << 3L)), *cast(long*)(fl_gname + (*cast(long*)(idx + (j << 3L)) << 3L))) != 0)
                {
                    *cast(long*)(idx + ((j + 1L) << 3L)) = *cast(long*)(idx + (j << 3L));
                    j = (j - 1L);
                }
                else
                {
                    go = 0L;
                }
    goto L6191;
            }
L6193:
            *cast(long*)(idx + ((j + 1L) << 3L)) = v;
            i_2 = (i_2 + 1L);
        }
        v2 = fl_put_rod32((fl_exp_off + 16L), 1L);
        v3 = fl_put_rod32((fl_exp_off + 20L), n);
        v4 = fl_put_rod32((fl_exp_off + 24L), n);
        v5 = fl_put_rod32((fl_exp_off + 28L), (rrva + eat));
        v6 = fl_put_rod32((fl_exp_off + 32L), (rrva + npt));
        v7 = fl_put_rod32((fl_exp_off + 36L), (rrva + ord));
        k = 0L;
        while (k <= (n - 1L))
        {
            i_3 = *cast(long*)(idx + (k << 3L));
            nm = *cast(long*)(fl_gname + (i_3 << 3L));
            v8 = fl_put_rod32((eat + (k * 4L)), (*cast(long*)(fl_gvaddr + (i_3 << 3L)) - 4194304L));
            v9 = fl_put_rod32((npt + (k * 4L)), (rrva + so));
            *cast(ubyte*)(fl_rodata + (ord + (k * 2L))) = cast(ubyte)(k & 255L);
            *cast(ubyte*)(fl_rodata + ((ord + (k * 2L)) + 1L)) = cast(ubyte)((k >> 8L) & 255L);
            j_2 = 1L;
            while (j_2 <= cast(long)*cast(ubyte*)(nm + 0L))
            {
                *cast(ubyte*)(fl_rodata + ((so + j_2) - 1L)) = cast(ubyte)cast(long)*cast(ubyte*)(nm + j_2);
                j_2 = (j_2 + 1L);
            }
            so = ((so + cast(long)*cast(ubyte*)(nm + 0L)) + 1L);
            k = (k + 1L);
        }
        d = cast(long)__s29498.ptr;
        j_3 = 1L;
        while (j_3 <= cast(long)*cast(ubyte*)(d + 0L))
        {
            *cast(ubyte*)(fl_rodata + ((so + j_3) - 1L)) = cast(ubyte)cast(long)*cast(ubyte*)(d + j_3);
            j_3 = (j_3 + 1L);
        }
        v11 = fl_put_rod32((fl_exp_off + 12L), (rrva + so));
    }
L6177:
    return 0;
}
long fl_layout()
{
    long t = 0;
    long r = 0;
    long d = 0;
    long b = 0;
    long k = 0;
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long trva = 0;
    long v6 = 0;
    long csz = 0;
    long v7 = 0;
    long rsz = 0;
    long v8 = 0;
    long dsz = 0;
    long rrva = 0;
    long drva = 0;
    long brva = 0;
    long v9 = 0;
    long strsz = 0;
    long v10 = 0;
    long symsz = 0;
    long hashsz = 0;
    long v11 = 0;
    long v12 = 0;
    long v13 = 0;
    long dend = 0;
    long v14 = 0;
    long so = 0;
    long v15 = 0;
    long ho = 0;
    long v16 = 0;
    long dyo = 0;
    long v17 = 0;
    long v18 = 0;
    long v19 = 0;
    long v20 = 0;
    t = 0L;
    r = 0L;
    d = 0L;
    b = 0L;
    k = 0L;
    while (k <= (fl_nobj - 1L))
    {
        *cast(long*)(fl_otbase + (k << 3L)) = t;
        t = fl_align16((t + *cast(long*)(fl_otsize + (k << 3L))));
        *cast(long*)(fl_orbase + (k << 3L)) = r;
        r = fl_align8((r + *cast(long*)(fl_orsize + (k << 3L))));
        *cast(long*)(fl_odbase + (k << 3L)) = d;
        d = fl_align8((d + *cast(long*)(fl_odsize + (k << 3L))));
        *cast(long*)(fl_obbase + (k << 3L)) = b;
        b = fl_align8((b + *cast(long*)(fl_obsize + (k << 3L))));
        k = (k + 1L);
    }
    fl_clen = t;
    fl_rodsize = r;
    fl_datasize = d;
    fl_bsssize = b;
    if (fl_fmt == 2L)
    {
        v4 = fl_plan_imports();
        v5 = fl_plan_exports();
    }
    if (fl_fmt == 2L)
    {
        trva = 4096L;
        if (fl_clen > 0L)
        {
            v6 = fl_clen;
        }
        else
        {
            v6 = 1L;
        }
        csz = v6;
        if (fl_rodsize > 0L)
        {
            v7 = fl_rodsize;
        }
        else
        {
            v7 = 1L;
        }
        rsz = v7;
        if (fl_datasize > 0L)
        {
            v8 = fl_datasize;
        }
        else
        {
            v8 = 1L;
        }
        dsz = v8;
        rrva = ((((trva + csz) + 4096L) - 1L) & (~(4096L - 1L)));
        drva = ((((rrva + rsz) + 4096L) - 1L) & (~(4096L - 1L)));
        brva = ((((drva + dsz) + 4096L) - 1L) & (~(4096L - 1L)));
        fl_tvaddr = (4194304L + trva);
        fl_rvaddr = (4194304L + rrva);
        fl_dvaddr = (4194304L + drva);
        fl_bvaddr = (4194304L + brva);
    }
    else
    {
        if (fl_shared != 0L)
        {
            strsz = fl_so_strsz();
            symsz = fl_so_symsz();
            hashsz = (((2L + 1L) + (fl_gn + 1L)) * 4L);
            fl_tvaddr = 232L;
            fl_rvaddr = (fl_tvaddr + fl_align8(fl_clen));
            fl_dvaddr = (fl_rvaddr + fl_align8(fl_rodsize));
            dend = (fl_dvaddr + fl_align8(fl_datasize));
            so = fl_align8((dend + strsz));
            ho = fl_align8((so + symsz));
            dyo = fl_align8((ho + hashsz));
            fl_bvaddr = fl_align8((dyo + 112L));
        }
        else
        {
            fl_tvaddr = (4194304L + 200L);
            fl_rvaddr = (fl_tvaddr + fl_align8(fl_clen));
            fl_dvaddr = (fl_rvaddr + fl_align8(fl_rodsize));
            fl_bvaddr = (fl_dvaddr + fl_align8(fl_datasize));
        }
    }
    return 0;
}
long fl_vaddr_of(long p1 = 0, long p2 = 0, long p3 = 0)
{
    long k = p1;
    long shndx = p2;
    long value = p3;
    if (shndx == 1L) goto L6233; else goto L6237;
L6237:
    if (shndx == 2L) goto L6234; else goto L6238;
L6238:
    if (shndx == 3L) goto L6235; else goto L6239;
L6239:
    if (shndx == 4L) goto L6236; else goto L6240;
L6240:
    goto L6232;
L6233:
    return ((fl_tvaddr + *cast(long*)(fl_otbase + (k << 3L))) + value);
L6234:
    return ((fl_rvaddr + *cast(long*)(fl_orbase + (k << 3L))) + value);
L6235:
    return ((fl_dvaddr + *cast(long*)(fl_odbase + (k << 3L))) + value);
L6236:
    return ((fl_bvaddr + *cast(long*)(fl_obbase + (k << 3L))) + value);
L6232:
    return 0L;
L6231:
    return 0;
}
long fl_collect_syms()
{
    long k = 0;
    long buf = 0;
    long nsyms = 0;
    long s = 0;
    long sb = 0;
    long v0 = 0;
    long sec = 0;
    long v1 = 0;
    long naux = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long nsym = 0;
    long s_2 = 0;
    long sb_2 = 0;
    long v5 = 0;
    long shndx = 0;
    long v6 = 0;
    long v7 = 0;
    long v8 = 0;
    long v9 = 0;
    fl_gn = 0L;
    k = 0L;
    while (k <= (fl_nobj - 1L))
    {
        buf = *cast(long*)(fl_obuf + (k << 3L));
        if (fl_fmt == 2L)
        {
            nsyms = *cast(long*)(fl_osymsz + (k << 3L));
            s = 0L;
L6248:
            if (s >= nsyms) goto L6250; else goto L6249;
L6249:
            sb = (*cast(long*)(fl_osymoff + (k << 3L)) + (s * 18L));
            sec = rd16(buf, (sb + 12L));
            naux = rd8(buf, (sb + 17L));
            if (sec >= 1L)
            {
                if (sec <= 4L) goto L6251; else goto L6252;
L6251:
                *cast(long*)(fl_gname + (fl_gn << 3L)) = fl_coff_name(buf, sb, *cast(long*)(fl_ostroff + (k << 3L)));
                *cast(long*)(fl_gvaddr + (fl_gn << 3L)) = fl_vaddr_of(k, sec, rd32(buf, (sb + 8L)));
                fl_gn = (fl_gn + 1L);
            }
L6252:
            s = ((s + 1L) + naux);
    goto L6248;
L6250:
        }
        else
        {
            nsym = (*cast(long*)(fl_osymsz + (k << 3L)) / 24L);
            s_2 = 1L;
            while (s_2 <= (nsym - 1L))
            {
                sb_2 = (*cast(long*)(fl_osymoff + (k << 3L)) + (s_2 * 24L));
                shndx = rd16(buf, (sb_2 + 6L));
                if (shndx != 0L)
                {
                    *cast(long*)(fl_gname + (fl_gn << 3L)) = fl_str_dup(buf, (*cast(long*)(fl_ostroff + (k << 3L)) + rd32(buf, sb_2)));
                    *cast(long*)(fl_gvaddr + (fl_gn << 3L)) = fl_vaddr_of(k, shndx, rd64(buf, (sb_2 + 8L)));
                    fl_gn = (fl_gn + 1L);
                }
                s_2 = (s_2 + 1L);
            }
        }
        k = (k + 1L);
    }
    return 0;
}
long fl_gsym_lookup(long p1 = 0)
{
    long i = 0;
    long v0 = 0;
    long name = p1;
    i = 0L;
    while (i <= (fl_gn - 1L))
    {
        if (fl_streq(*cast(long*)(fl_gname + (i << 3L)), name) != 0)
        {
            return *cast(long*)(fl_gvaddr + (i << 3L));
        }
        i = (i + 1L);
    }
    return (-1L);
}
long fl_copy_sections()
{
    long k = 0;
    long buf = 0;
    long i = 0;
    long i_2 = 0;
    long i_3 = 0;
    k = 0L;
    while (k <= (fl_nobj - 1L))
    {
        buf = *cast(long*)(fl_obuf + (k << 3L));
        i = 0L;
        while (i <= (*cast(long*)(fl_otsize + (k << 3L)) - 1L))
        {
            *cast(ubyte*)(fl_code + (*cast(long*)(fl_otbase + (k << 3L)) + i)) = cast(ubyte)cast(long)*cast(ubyte*)(buf + (*cast(long*)(fl_otoff + (k << 3L)) + i));
            i = (i + 1L);
        }
        i_2 = 0L;
        while (i_2 <= (*cast(long*)(fl_orsize + (k << 3L)) - 1L))
        {
            *cast(ubyte*)(fl_rodata + (*cast(long*)(fl_orbase + (k << 3L)) + i_2)) = cast(ubyte)cast(long)*cast(ubyte*)(buf + (*cast(long*)(fl_oroff + (k << 3L)) + i_2));
            i_2 = (i_2 + 1L);
        }
        i_3 = 0L;
        while (i_3 <= (*cast(long*)(fl_odsize + (k << 3L)) - 1L))
        {
            *cast(ubyte*)(fl_data + (*cast(long*)(fl_odbase + (k << 3L)) + i_3)) = cast(ubyte)cast(long)*cast(ubyte*)(buf + (*cast(long*)(fl_odoff + (k << 3L)) + i_3));
            i_3 = (i_3 + 1L);
        }
        k = (k + 1L);
    }
    return 0;
}
long fl_relocate()
{
    long k = 0;
    long buf = 0;
    long nrel = 0;
    long r = 0;
    long rb = 0;
    long v0 = 0;
    long roff = 0;
    long v1 = 0;
    long si = 0;
    long v2 = 0;
    long rtype = 0;
    long sb = 0;
    long v3 = 0;
    long sec = 0;
    long site = 0;
    long v4 = 0;
    long add = 0;
    long s = 0;
    long v5 = 0;
    long v6 = 0;
    long v7 = 0;
    long nm = 0;
    long v8 = 0;
    long iv = 0;
    long v9 = 0;
    long v10 = 0;
    long v11 = 0;
    long v12 = 0;
    long nrel_2 = 0;
    long r_2 = 0;
    long rb_2 = 0;
    long v13 = 0;
    long roff_2 = 0;
    long v14 = 0;
    long info = 0;
    long v15 = 0;
    long add_2 = 0;
    long si_2 = 0;
    long rtype_2 = 0;
    long sb_2 = 0;
    long v16 = 0;
    long shndx = 0;
    long site_2 = 0;
    long s_2 = 0;
    long v17 = 0;
    long v18 = 0;
    long v19 = 0;
    long v20 = 0;
    long nm_2 = 0;
    long v21 = 0;
    long v22 = 0;
    long v23 = 0;
    long v24 = 0;
    long v25 = 0;
    long v26 = 0;
    k = 0L;
    while (k <= (fl_nobj - 1L))
    {
        buf = *cast(long*)(fl_obuf + (k << 3L));
        if (fl_fmt == 2L)
        {
            nrel = (*cast(long*)(fl_orelsz + (k << 3L)) / 10L);
            r = 0L;
            while (r <= (nrel - 1L))
            {
                rb = (*cast(long*)(fl_oreloff + (k << 3L)) + (r * 10L));
                roff = rd32(buf, rb);
                si = rd32(buf, (rb + 4L));
                rtype = rd16(buf, (rb + 8L));
                sb = (*cast(long*)(fl_osymoff + (k << 3L)) + (si * 18L));
                sec = rd16(buf, (sb + 12L));
                site = (*cast(long*)(fl_otbase + (k << 3L)) + roff);
                add = rd32(buf, (*cast(long*)(fl_otoff + (k << 3L)) + roff));
                s = 0L;
                if (sec >= 1L)
                {
                    if (sec <= 4L) goto L6293; else goto L6294;
L6293:
                    s = fl_vaddr_of(k, sec, rd32(buf, (sb + 8L)));
    goto L6295;
                }
L6294:
                nm = fl_coff_name(buf, sb, *cast(long*)(fl_ostroff + (k << 3L)));
                iv = fl_import_vaddr(nm);
                if (iv >= 0L)
                {
                    s = iv;
                }
                else
                {
                    s = fl_gsym_lookup(nm);
                    if (s == (-1L))
                    {
                        v10 = fl_note_undef(nm);
                        fl_errs = (fl_errs + 1L);
                        s = 0L;
                    }
                }
L6295:
                if (rtype == 1L)
                {
                    v11 = fl_patch64(site, (s + add));
                }
                else
                {
                    v12 = fl_patch32(site, ((s + add) - ((fl_tvaddr + site) + 4L)));
                }
                r = (r + 1L);
            }
        }
        else
        {
            nrel_2 = (*cast(long*)(fl_orelsz + (k << 3L)) / 24L);
            r_2 = 0L;
            while (r_2 <= (nrel_2 - 1L))
            {
                rb_2 = (*cast(long*)(fl_oreloff + (k << 3L)) + (r_2 * 24L));
                roff_2 = rd64(buf, rb_2);
                info = rd64(buf, (rb_2 + 8L));
                add_2 = rd64(buf, (rb_2 + 16L));
                si_2 = (info >> 32L);
                rtype_2 = (info & 255L);
                sb_2 = (*cast(long*)(fl_osymoff + (k << 3L)) + (si_2 * 24L));
                shndx = rd16(buf, (sb_2 + 6L));
                site_2 = (*cast(long*)(fl_otbase + (k << 3L)) + roff_2);
                s_2 = 0L;
                if (shndx != 0L)
                {
                    s_2 = fl_vaddr_of(k, shndx, rd64(buf, (sb_2 + 8L)));
                }
                else
                {
                    nm_2 = fl_str_dup(buf, (*cast(long*)(fl_ostroff + (k << 3L)) + rd32(buf, sb_2)));
                    s_2 = fl_gsym_lookup(nm_2);
                    if (s_2 == (-1L))
                    {
                        v22 = fl_note_undef(nm_2);
                        fl_errs = (fl_errs + 1L);
                        s_2 = 0L;
                    }
                }
                if (rtype_2 == 1L)
                {
                    if (fl_shared != 0L)
                    {
                        v24 = fl_note_abs_in_so(fl_reloc_symname(k, sb_2));
                        fl_errs = (fl_errs + 1L);
                    }
                    v25 = fl_patch64(site_2, (s_2 + add_2));
                }
                else
                {
                    v26 = fl_patch32(site_2, ((s_2 + add_2) - (fl_tvaddr + site_2)));
                }
                r_2 = (r_2 + 1L);
            }
        }
        k = (k + 1L);
    }
    return 0;
}
long fl_write_exe(long p1 = 0)
{
    long v0 = 0;
    long out_ = 0;
    long prev = 0;
    long v1 = 0;
    long rod_fileoff = 0;
    long v2 = 0;
    long data_fileoff = 0;
    long filesz = 0;
    long memsz = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long v6 = 0;
    long v7 = 0;
    long v8 = 0;
    long v9 = 0;
    long v10 = 0;
    long v11 = 0;
    long v12 = 0;
    long v13 = 0;
    long v14 = 0;
    long i = 0;
    long v15 = 0;
    long v16 = 0;
    long v17 = 0;
    long v18 = 0;
    long v19 = 0;
    long v20 = 0;
    long v21 = 0;
    long v22 = 0;
    long v23 = 0;
    long v24 = 0;
    long v25 = 0;
    long v26 = 0;
    long v27 = 0;
    long v28 = 0;
    long v29 = 0;
    long v30 = 0;
    long v31 = 0;
    long v32 = 0;
    long v33 = 0;
    long v34 = 0;
    long v35 = 0;
    long v36 = 0;
    long v37 = 0;
    long v38 = 0;
    long v39 = 0;
    long v40 = 0;
    long v41 = 0;
    long v42 = 0;
    long v43 = 0;
    long v44 = 0;
    long i_2 = 0;
    long v45 = 0;
    long v46 = 0;
    long v47 = 0;
    long v48 = 0;
    long nm = 0;
    long v49 = 0;
    long v50 = 0;
    long v51 = 0;
    long i_3 = 0;
    long v52 = 0;
    long i_4 = 0;
    long v53 = 0;
    long v54 = 0;
    long i_5 = 0;
    long v55 = 0;
    long i_6 = 0;
    long v56 = 0;
    long i_7 = 0;
    long v57 = 0;
    long i_8 = 0;
    long v58 = 0;
    long i_9 = 0;
    long v59 = 0;
    long i_10 = 0;
    long v60 = 0;
    long v61 = 0;
    long v62 = 0;
    long v63 = 0;
    long v64 = 0;
    long v65 = 0;
    long v66 = 0;
    long v67 = 0;
    long v68 = 0;
    long outname = p1;
    out_ = findoutput(outname);
    prev = 0L;
    rod_fileoff = (200L + fl_align8(fl_clen));
    data_fileoff = (rod_fileoff + fl_align8(fl_rodsize));
    filesz = (data_fileoff + fl_datasize);
    memsz = ((fl_bvaddr - 4194304L) + fl_bsssize);
    if (out_ != 0) goto L6320; else goto L6319;
L6319:
    v4 = writef(cast(long)__s30305.ptr, outname);
    return 0;
L6320:
    prev = output();
    v6 = selectoutput(out_);
    v7 = fl_put(127L);
    v8 = fl_put(69L);
    v9 = fl_put(76L);
    v10 = fl_put(70L);
    v11 = fl_put(2L);
    v12 = fl_put(1L);
    v13 = fl_put(1L);
    v14 = fl_put(fl_osabi);
    i = 1L;
    while (i <= 8L)
    {
        v15 = fl_put(0L);
        i = (i + 1L);
    }
    v16 = fl_put16(2L);
    v17 = fl_put16(62L);
    v18 = fl_put32(1L);
    v19 = fl_put64(fl_entry);
    v20 = fl_put64(64L);
    v21 = fl_put64(0L);
    v22 = fl_put32(0L);
    v23 = fl_put16(64L);
    v24 = fl_put16(56L);
    v25 = fl_put16(2L);
    v26 = fl_put16(0L);
    v27 = fl_put16(0L);
    v28 = fl_put16(0L);
    v29 = fl_put32(1L);
    v30 = fl_put32(7L);
    v31 = fl_put64(0L);
    v32 = fl_put64(4194304L);
    v33 = fl_put64(4194304L);
    v34 = fl_put64(filesz);
    v35 = fl_put64(memsz);
    v36 = fl_put64(4096L);
    if (fl_osnote != 0L)
    {
        v37 = fl_put32(4L);
        v38 = fl_put32(4L);
        v39 = fl_put64(176L);
        v40 = fl_put64((4194304L + 176L));
        v41 = fl_put64((4194304L + 176L));
        v42 = fl_put64(24L);
        v43 = fl_put64(24L);
        v44 = fl_put64(4L);
    }
    else
    {
        i_2 = 1L;
        while (i_2 <= 56L)
        {
            v45 = fl_put(0L);
            i_2 = (i_2 + 1L);
        }
    }
    if (fl_osnote != 0L)
    {
        if (fl_osnote == 1L)
        {
            v47 = cast(long)__s30450.ptr;
        }
        else
        {
            v47 = cast(long)__s30451.ptr;
        }
        nm = v47;
        v49 = fl_put32((cast(long)*cast(ubyte*)(nm + 0L) + 1L));
        v50 = fl_put32(4L);
        v51 = fl_put32(1L);
        i_3 = 1L;
        while (i_3 <= cast(long)*cast(ubyte*)(nm + 0L))
        {
            v52 = fl_put(cast(long)*cast(ubyte*)(nm + i_3));
            i_3 = (i_3 + 1L);
        }
        i_4 = (cast(long)*cast(ubyte*)(nm + 0L) + 1L);
        while (i_4 <= 8L)
        {
            v53 = fl_put(0L);
            i_4 = (i_4 + 1L);
        }
        v54 = fl_put32(0L);
    }
    else
    {
        i_5 = 1L;
        while (i_5 <= 24L)
        {
            v55 = fl_put(0L);
            i_5 = (i_5 + 1L);
        }
    }
    i_6 = 0L;
    while (i_6 <= (fl_clen - 1L))
    {
        v56 = fl_put(cast(long)*cast(ubyte*)(fl_code + i_6));
        i_6 = (i_6 + 1L);
    }
    i_7 = (200L + fl_clen);
    while (i_7 <= (rod_fileoff - 1L))
    {
        v57 = fl_put(0L);
        i_7 = (i_7 + 1L);
    }
    i_8 = 0L;
    while (i_8 <= (fl_rodsize - 1L))
    {
        v58 = fl_put(cast(long)*cast(ubyte*)(fl_rodata + i_8));
        i_8 = (i_8 + 1L);
    }
    i_9 = (rod_fileoff + fl_rodsize);
    while (i_9 <= (data_fileoff - 1L))
    {
        v59 = fl_put(0L);
        i_9 = (i_9 + 1L);
    }
    i_10 = 0L;
    while (i_10 <= (fl_datasize - 1L))
    {
        v60 = fl_put(cast(long)*cast(ubyte*)(fl_data + i_10));
        i_10 = (i_10 + 1L);
    }
    v61 = endwrite();
    v62 = selectoutput(prev);
    v64 = writef(cast(long)__s30562.ptr, outname, fl_nobj, fl_clen);
    v66 = writef(cast(long)__s30567.ptr, fl_rodsize, fl_datasize);
    v68 = writef(cast(long)__s30572.ptr, fl_bsssize, fl_entry);
    return 0;
}
long fl_so_symsz()
{
    return ((fl_gn + 1L) * 24L);
}
long fl_so_strsz()
{
    long n = 0;
    long i = 0;
    n = 1L;
    i = 0L;
    while (i <= (fl_gn - 1L))
    {
        n = ((n + cast(long)*cast(ubyte*)(*cast(long*)(fl_gname + (i << 3L)) + 0L)) + 1L);
        i = (i + 1L);
    }
    return n;
}
long fl_write_so(long p1 = 0)
{
    long v0 = 0;
    long out_ = 0;
    long prev = 0;
    long v1 = 0;
    long rod_fileoff = 0;
    long v2 = 0;
    long data_fileoff = 0;
    long v3 = 0;
    long dend = 0;
    long stroff = 0;
    long v4 = 0;
    long strsz = 0;
    long v5 = 0;
    long symoff = 0;
    long v6 = 0;
    long symsz = 0;
    long v7 = 0;
    long hashoff = 0;
    long nsym = 0;
    long hashsz = 0;
    long v8 = 0;
    long dynoff = 0;
    long dynsz = 0;
    long filesz = 0;
    long memsz = 0;
    long v9 = 0;
    long v10 = 0;
    long v11 = 0;
    long v12 = 0;
    long v13 = 0;
    long v14 = 0;
    long v15 = 0;
    long v16 = 0;
    long v17 = 0;
    long v18 = 0;
    long v19 = 0;
    long v20 = 0;
    long i = 0;
    long v21 = 0;
    long v22 = 0;
    long v23 = 0;
    long v24 = 0;
    long v25 = 0;
    long v26 = 0;
    long v27 = 0;
    long v28 = 0;
    long v29 = 0;
    long v30 = 0;
    long v31 = 0;
    long v32 = 0;
    long v33 = 0;
    long v34 = 0;
    long v35 = 0;
    long v36 = 0;
    long v37 = 0;
    long v38 = 0;
    long v39 = 0;
    long v40 = 0;
    long v41 = 0;
    long v42 = 0;
    long v43 = 0;
    long v44 = 0;
    long v45 = 0;
    long v46 = 0;
    long v47 = 0;
    long v48 = 0;
    long v49 = 0;
    long v50 = 0;
    long v51 = 0;
    long v52 = 0;
    long v53 = 0;
    long v54 = 0;
    long v55 = 0;
    long v56 = 0;
    long v57 = 0;
    long v58 = 0;
    long i_2 = 0;
    long v59 = 0;
    long i_3 = 0;
    long v60 = 0;
    long i_4 = 0;
    long v61 = 0;
    long i_5 = 0;
    long v62 = 0;
    long i_6 = 0;
    long v63 = 0;
    long i_7 = 0;
    long v64 = 0;
    long i_8 = 0;
    long v65 = 0;
    long v66 = 0;
    long i_9 = 0;
    long s = 0;
    long j = 0;
    long v67 = 0;
    long v68 = 0;
    long i_10 = 0;
    long v69 = 0;
    long i_11 = 0;
    long v70 = 0;
    long noff = 0;
    long i_12 = 0;
    long v71 = 0;
    long v72 = 0;
    long v73 = 0;
    long v74 = 0;
    long v75 = 0;
    long v76 = 0;
    long i_13 = 0;
    long v77 = 0;
    long v78 = 0;
    long v79 = 0;
    long v80 = 0;
    long v81 = 0;
    long v82 = 0;
    long i_14 = 0;
    long v83 = 0;
    long v84 = 0;
    long i_15 = 0;
    long v85 = 0;
    long v86 = 0;
    long v87 = 0;
    long v88 = 0;
    long v89 = 0;
    long v90 = 0;
    long v91 = 0;
    long v92 = 0;
    long v93 = 0;
    long v94 = 0;
    long v95 = 0;
    long v96 = 0;
    long v97 = 0;
    long v98 = 0;
    long v99 = 0;
    long v100 = 0;
    long v101 = 0;
    long v102 = 0;
    long v103 = 0;
    long outname = p1;
    out_ = findoutput(outname);
    prev = 0L;
    rod_fileoff = (232L + fl_align8(fl_clen));
    data_fileoff = (rod_fileoff + fl_align8(fl_rodsize));
    dend = (data_fileoff + fl_align8(fl_datasize));
    stroff = dend;
    strsz = fl_so_strsz();
    symoff = fl_align8((stroff + strsz));
    symsz = fl_so_symsz();
    hashoff = fl_align8((symoff + symsz));
    nsym = (fl_gn + 1L);
    hashsz = (((2L + 1L) + nsym) * 4L);
    dynoff = fl_align8((hashoff + hashsz));
    dynsz = 112L;
    filesz = (dynoff + dynsz);
    memsz = (fl_bvaddr + fl_bsssize);
    if (out_ != 0) goto L6375; else goto L6374;
L6374:
    v10 = writef(cast(long)__s30665.ptr, outname);
    return 0;
L6375:
    if (memsz < filesz)
    {
        memsz = filesz;
    }
    prev = output();
    v12 = selectoutput(out_);
    v13 = fl_put(127L);
    v14 = fl_put(69L);
    v15 = fl_put(76L);
    v16 = fl_put(70L);
    v17 = fl_put(2L);
    v18 = fl_put(1L);
    v19 = fl_put(1L);
    v20 = fl_put(fl_osabi);
    i = 1L;
    while (i <= 8L)
    {
        v21 = fl_put(0L);
        i = (i + 1L);
    }
    v22 = fl_put16(3L);
    v23 = fl_put16(62L);
    v24 = fl_put32(1L);
    v25 = fl_put64(0L);
    v26 = fl_put64(64L);
    v27 = fl_put64(0L);
    v28 = fl_put32(0L);
    v29 = fl_put16(64L);
    v30 = fl_put16(56L);
    v31 = fl_put16(3L);
    v32 = fl_put16(0L);
    v33 = fl_put16(0L);
    v34 = fl_put16(0L);
    v35 = fl_put32(1L);
    v36 = fl_put32(7L);
    v37 = fl_put64(0L);
    v38 = fl_put64(0L);
    v39 = fl_put64(0L);
    v40 = fl_put64(filesz);
    v41 = fl_put64(memsz);
    v42 = fl_put64(4096L);
    v43 = fl_put32(2L);
    v44 = fl_put32(6L);
    v45 = fl_put64(dynoff);
    v46 = fl_put64(dynoff);
    v47 = fl_put64(dynoff);
    v48 = fl_put64(dynsz);
    v49 = fl_put64(dynsz);
    v50 = fl_put64(8L);
    v51 = fl_put32(1685382481L);
    v52 = fl_put32(6L);
    v53 = fl_put64(0L);
    v54 = fl_put64(0L);
    v55 = fl_put64(0L);
    v56 = fl_put64(0L);
    v57 = fl_put64(0L);
    v58 = fl_put64(16L);
    i_2 = 232L;
    while (i_2 <= (232L - 1L))
    {
        v59 = fl_put(0L);
        i_2 = (i_2 + 1L);
    }
    i_3 = 0L;
    while (i_3 <= (fl_clen - 1L))
    {
        v60 = fl_put(cast(long)*cast(ubyte*)(fl_code + i_3));
        i_3 = (i_3 + 1L);
    }
    i_4 = (232L + fl_clen);
    while (i_4 <= (rod_fileoff - 1L))
    {
        v61 = fl_put(0L);
        i_4 = (i_4 + 1L);
    }
    i_5 = 0L;
    while (i_5 <= (fl_rodsize - 1L))
    {
        v62 = fl_put(cast(long)*cast(ubyte*)(fl_rodata + i_5));
        i_5 = (i_5 + 1L);
    }
    i_6 = (rod_fileoff + fl_rodsize);
    while (i_6 <= (data_fileoff - 1L))
    {
        v63 = fl_put(0L);
        i_6 = (i_6 + 1L);
    }
    i_7 = 0L;
    while (i_7 <= (fl_datasize - 1L))
    {
        v64 = fl_put(cast(long)*cast(ubyte*)(fl_data + i_7));
        i_7 = (i_7 + 1L);
    }
    i_8 = (data_fileoff + fl_datasize);
    while (i_8 <= (stroff - 1L))
    {
        v65 = fl_put(0L);
        i_8 = (i_8 + 1L);
    }
    v66 = fl_put(0L);
    i_9 = 0L;
    while (i_9 <= (fl_gn - 1L))
    {
        s = *cast(long*)(fl_gname + (i_9 << 3L));
        j = 1L;
        while (j <= cast(long)*cast(ubyte*)(s + 0L))
        {
            v67 = fl_put(cast(long)*cast(ubyte*)(s + j));
            j = (j + 1L);
        }
        v68 = fl_put(0L);
        i_9 = (i_9 + 1L);
    }
    i_10 = (stroff + strsz);
    while (i_10 <= (symoff - 1L))
    {
        v69 = fl_put(0L);
        i_10 = (i_10 + 1L);
    }
    i_11 = 1L;
    while (i_11 <= 24L)
    {
        v70 = fl_put(0L);
        i_11 = (i_11 + 1L);
    }
    noff = 1L;
    i_12 = 0L;
    while (i_12 <= (fl_gn - 1L))
    {
        v71 = fl_put32(noff);
        v72 = fl_put(18L);
        v73 = fl_put(0L);
        v74 = fl_put16(1L);
        v75 = fl_put64(*cast(long*)(fl_gvaddr + (i_12 << 3L)));
        v76 = fl_put64(0L);
        noff = ((noff + cast(long)*cast(ubyte*)(*cast(long*)(fl_gname + (i_12 << 3L)) + 0L)) + 1L);
        i_12 = (i_12 + 1L);
    }
    i_13 = (symoff + symsz);
    while (i_13 <= (hashoff - 1L))
    {
        v77 = fl_put(0L);
        i_13 = (i_13 + 1L);
    }
    v78 = fl_put32(1L);
    v79 = fl_put32(nsym);
    if (nsym > 1L)
    {
        v80 = 1L;
    }
    else
    {
        v80 = 0L;
    }
    v81 = fl_put32(v80);
    v82 = fl_put32(0L);
    i_14 = 1L;
    while (i_14 <= (nsym - 1L))
    {
        if ((i_14 + 1L) < nsym)
        {
            v83 = (i_14 + 1L);
        }
        else
        {
            v83 = 0L;
        }
        v84 = fl_put32(v83);
        i_14 = (i_14 + 1L);
    }
    i_15 = (hashoff + hashsz);
    while (i_15 <= (dynoff - 1L))
    {
        v85 = fl_put(0L);
        i_15 = (i_15 + 1L);
    }
    v86 = fl_put64(4L);
    v87 = fl_put64(hashoff);
    v88 = fl_put64(5L);
    v89 = fl_put64(stroff);
    v90 = fl_put64(6L);
    v91 = fl_put64(symoff);
    v92 = fl_put64(10L);
    v93 = fl_put64(strsz);
    v94 = fl_put64(11L);
    v95 = fl_put64(24L);
    v96 = fl_put64(14L);
    v97 = fl_put64(1L);
    v98 = fl_put64(0L);
    v99 = fl_put64(0L);
    v100 = endwrite();
    v101 = selectoutput(prev);
    v103 = writef(cast(long)__s31064.ptr, outname, fl_nobj, fl_clen, fl_gn);
    return 0;
}
long fl_pe_sect(long p1 = 0, long p2 = 0, long p3 = 0, long p4 = 0, long p5 = 0)
{
    long j = 0;
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long v6 = 0;
    long v7 = 0;
    long v8 = 0;
    long v9 = 0;
    long v10 = 0;
    long v11 = 0;
    long name = p1;
    long vsize = p2;
    long rva = p3;
    long rawsize = p4;
    long rawptr = p5;
    j = 1L;
    while (j <= 8L)
    {
        if (j <= cast(long)*cast(ubyte*)(name + 0L))
        {
            v0 = fl_put(cast(long)*cast(ubyte*)(name + j));
        }
        else
        {
            v1 = fl_put(0L);
        }
        j = (j + 1L);
    }
    if (vsize > 0L)
    {
        v2 = vsize;
    }
    else
    {
        v2 = 1L;
    }
    v3 = fl_put32(v2);
    v4 = fl_put32(rva);
    v5 = fl_put32(rawsize);
    v6 = fl_put32(rawptr);
    v7 = fl_put32(0L);
    v8 = fl_put32(0L);
    v9 = fl_put16(0L);
    v10 = fl_put16(0L);
    v11 = fl_put32(fl_secchars);
    return 0;
}
long fl_write_pe(long p1 = 0)
{
    long v0 = 0;
    long out_ = 0;
    long prev = 0;
    long trva = 0;
    long rrva = 0;
    long drva = 0;
    long brva = 0;
    long text_fo = 0;
    long rod_fo = 0;
    long data_fo = 0;
    long textraw = 0;
    long rodraw = 0;
    long dataraw = 0;
    long sizeimg = 0;
    long i = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long v6 = 0;
    long i_2 = 0;
    long v7 = 0;
    long v8 = 0;
    long v9 = 0;
    long v10 = 0;
    long v11 = 0;
    long v12 = 0;
    long v13 = 0;
    long v14 = 0;
    long v15 = 0;
    long v16 = 0;
    long v17 = 0;
    long v18 = 0;
    long v19 = 0;
    long v20 = 0;
    long v21 = 0;
    long v22 = 0;
    long v23 = 0;
    long v24 = 0;
    long v25 = 0;
    long v26 = 0;
    long v27 = 0;
    long v28 = 0;
    long v29 = 0;
    long v30 = 0;
    long v31 = 0;
    long v32 = 0;
    long v33 = 0;
    long v34 = 0;
    long v35 = 0;
    long v36 = 0;
    long v37 = 0;
    long v38 = 0;
    long v39 = 0;
    long v40 = 0;
    long v41 = 0;
    long v42 = 0;
    long v43 = 0;
    long v44 = 0;
    long v45 = 0;
    long v46 = 0;
    long v47 = 0;
    long v48 = 0;
    long v49 = 0;
    long v50 = 0;
    long e = 0;
    long dr = 0;
    long ds = 0;
    long v51 = 0;
    long v52 = 0;
    long v53 = 0;
    long dptr = 0;
    long v54 = 0;
    long v55 = 0;
    long v56 = 0;
    long v57 = 0;
    long v58 = 0;
    long v59 = 0;
    long v60 = 0;
    long v61 = 0;
    long v62 = 0;
    long i_3 = 0;
    long v63 = 0;
    long i_4 = 0;
    long v64 = 0;
    long i_5 = 0;
    long v65 = 0;
    long i_6 = 0;
    long v66 = 0;
    long i_7 = 0;
    long v67 = 0;
    long v68 = 0;
    long v69 = 0;
    long v70 = 0;
    long v71 = 0;
    long v72 = 0;
    long v73 = 0;
    long v74 = 0;
    long v75 = 0;
    long v76 = 0;
    long v77 = 0;
    long v78 = 0;
    long outname = p1;
    out_ = findoutput(outname);
    prev = 0L;
    trva = (fl_tvaddr - 4194304L);
    rrva = (fl_rvaddr - 4194304L);
    drva = (fl_dvaddr - 4194304L);
    brva = (fl_bvaddr - 4194304L);
    text_fo = 1024L;
    rod_fo = ((((text_fo + fl_clen) + 512L) - 1L) & (~(512L - 1L)));
    data_fo = ((((rod_fo + fl_rodsize) + 512L) - 1L) & (~(512L - 1L)));
    textraw = (((fl_clen + 512L) - 1L) & (~(512L - 1L)));
    rodraw = (((fl_rodsize + 512L) - 1L) & (~(512L - 1L)));
    dataraw = (((fl_datasize + 512L) - 1L) & (~(512L - 1L)));
    sizeimg = ((((brva + fl_bsssize) + 4096L) - 1L) & (~(4096L - 1L)));
    i = 0L;
    if (out_ != 0) goto L6459; else goto L6458;
L6458:
    v2 = writef(cast(long)__s31215.ptr, outname);
    return 0;
L6459:
    prev = output();
    v4 = selectoutput(out_);
    v5 = fl_put(77L);
    v6 = fl_put(90L);
    i_2 = 2L;
    while (i_2 <= 59L)
    {
        v7 = fl_put(0L);
        i_2 = (i_2 + 1L);
    }
    v8 = fl_put32(64L);
    v9 = fl_put(80L);
    v10 = fl_put(69L);
    v11 = fl_put(0L);
    v12 = fl_put(0L);
    v13 = fl_put16(34404L);
    v14 = fl_put16(4L);
    v15 = fl_put32(0L);
    v16 = fl_put32(0L);
    v17 = fl_put32(0L);
    v18 = fl_put16(240L);
    if (fl_shared != 0L)
    {
        v19 = 8226L;
    }
    else
    {
        v19 = 34L;
    }
    v20 = fl_put16(v19);
    v21 = fl_put16(523L);
    v22 = fl_put(1L);
    v23 = fl_put(0L);
    v24 = fl_put32(textraw);
    v25 = fl_put32((rodraw + dataraw));
    v26 = fl_put32(fl_bsssize);
    v27 = fl_put32((fl_entry - 4194304L));
    v28 = fl_put32(trva);
    v29 = fl_put64(4194304L);
    v30 = fl_put32(4096L);
    v31 = fl_put32(512L);
    v32 = fl_put16(6L);
    v33 = fl_put16(0L);
    v34 = fl_put16(0L);
    v35 = fl_put16(0L);
    v36 = fl_put16(6L);
    v37 = fl_put16(0L);
    v38 = fl_put32(0L);
    v39 = fl_put32(sizeimg);
    v40 = fl_put32(1024L);
    v41 = fl_put32(0L);
    if (fl_efi != 0L)
    {
        v42 = 10L;
    }
    else
    {
        v42 = 3L;
    }
    v43 = fl_put16(v42);
    v44 = fl_put16(0L);
    v45 = fl_put64(1048576L);
    v46 = fl_put64(4096L);
    v47 = fl_put64(1048576L);
    v48 = fl_put64(4096L);
    v49 = fl_put32(0L);
    v50 = fl_put32(16L);
    e = 0L;
    while (e <= 15L)
    {
        dr = 0L;
        ds = 0L;
        if (fl_shared != 0L)
        {
            if (fl_gn > 0L) goto L6476; else goto L6475;
L6476:
            if (e == 0L) goto L6474; else goto L6475;
L6474:
            dr = ((fl_rvaddr - 4194304L) + fl_exp_off);
            ds = fl_exp_size;
        }
L6475:
        if (fl_imp_n > 0L)
        {
            if (e == 1L) goto L6478; else goto L6479;
L6478:
            dr = ((fl_rvaddr - 4194304L) + fl_imp_base);
            ds = ((fl_ndll + 1L) * 20L);
        }
L6479:
        if (fl_imp_n > 0L)
        {
            if (e == 12L) goto L6481; else goto L6482;
L6481:
            dr = ((fl_rvaddr - 4194304L) + fl_imp_iatoff);
            ds = ((fl_imp_n + 1L) * 8L);
        }
L6482:
        v51 = fl_put32(dr);
        v52 = fl_put32(ds);
        e = (e + 1L);
    }
    if (dataraw > 0L)
    {
        v53 = data_fo;
    }
    else
    {
        v53 = 0L;
    }
    dptr = v53;
    fl_secchars = 1610612768L;
    v55 = fl_pe_sect(cast(long)__s31431.ptr, fl_clen, trva, textraw, text_fo);
    fl_secchars = 1073741888L;
    v57 = fl_pe_sect(cast(long)__s31436.ptr, fl_rodsize, rrva, rodraw, rod_fo);
    fl_secchars = 3221225536L;
    v59 = fl_pe_sect(cast(long)__s31441.ptr, fl_datasize, drva, dataraw, dptr);
    fl_secchars = 3221225600L;
    v61 = fl_pe_sect(cast(long)__s31446.ptr, fl_bsssize, brva, 0L, 0L);
    i = (((64L + 24L) + 240L) + 160L);
    while (i <= (1024L - 1L))
    {
        v62 = fl_put(0L);
        i = (i + 1L);
    }
    i_3 = 0L;
    while (i_3 <= (fl_clen - 1L))
    {
        v63 = fl_put(cast(long)*cast(ubyte*)(fl_code + i_3));
        i_3 = (i_3 + 1L);
    }
    i_4 = (text_fo + fl_clen);
    while (i_4 <= (rod_fo - 1L))
    {
        v64 = fl_put(0L);
        i_4 = (i_4 + 1L);
    }
    i_5 = 0L;
    while (i_5 <= (fl_rodsize - 1L))
    {
        v65 = fl_put(cast(long)*cast(ubyte*)(fl_rodata + i_5));
        i_5 = (i_5 + 1L);
    }
    i_6 = (rod_fo + fl_rodsize);
    while (i_6 <= (data_fo - 1L))
    {
        v66 = fl_put(0L);
        i_6 = (i_6 + 1L);
    }
    i_7 = 0L;
    while (i_7 <= (fl_datasize - 1L))
    {
        v67 = fl_put(cast(long)*cast(ubyte*)(fl_data + i_7));
        i_7 = (i_7 + 1L);
    }
    v68 = endwrite();
    v69 = selectoutput(prev);
    if (fl_shared != 0L)
    {
        v72 = cast(long)__s31533.ptr;
    }
    else
    {
        v72 = cast(long)__s31534.ptr;
    }
    v74 = writef(cast(long)__s31528.ptr, outname, v72, fl_nobj);
    v76 = writef(cast(long)__s31538.ptr, fl_clen, fl_rodsize, fl_datasize);
    v78 = writef(cast(long)__s31544.ptr, fl_bsssize, (fl_entry - 4194304L), 4194304L);
    return 0;
}
long fl_run(long p1 = 0, long p2 = 0, long p3 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long v6 = 0;
    long v7 = 0;
    long v8 = 0;
    long v9 = 0;
    long v10 = 0;
    long v11 = 0;
    long v12 = 0;
    long v13 = 0;
    long v14 = 0;
    long v15 = 0;
    long v16 = 0;
    long v17 = 0;
    long v18 = 0;
    long v19 = 0;
    long v20 = 0;
    long v21 = 0;
    long v22 = 0;
    long v23 = 0;
    long v24 = 0;
    long v25 = 0;
    long v26 = 0;
    long v27 = 0;
    long v28 = 0;
    long v29 = 0;
    long v30 = 0;
    long k = 0;
    long f = 0;
    long v31 = 0;
    long v32 = 0;
    long v33 = 0;
    long v34 = 0;
    long v35 = 0;
    long v36 = 0;
    long v37 = 0;
    long v38 = 0;
    long v39 = 0;
    long v40 = 0;
    long v41 = 0;
    long v42 = 0;
    long v43 = 0;
    long v44 = 0;
    long v45 = 0;
    long v46 = 0;
    long v = 0;
    long v47 = 0;
    long v48 = 0;
    long i = 0;
    long v49 = 0;
    long v50 = 0;
    long v51 = 0;
    long v52 = 0;
    long v53 = 0;
    long v54 = 0;
    long v55 = 0;
    long names = p1;
    long nin = p2;
    long outname = p3;
    fl_nobj = nin;
    fl_code = getvec((1L << 19L));
    fl_rodata = getvec((1L << 16L));
    fl_data = getvec((1L << 16L));
    fl_obuf = getvec(256L);
    fl_osize = getvec(256L);
    fl_otoff = getvec(256L);
    fl_otsize = getvec(256L);
    fl_oroff = getvec(256L);
    fl_orsize = getvec(256L);
    fl_odoff = getvec(256L);
    fl_odsize = getvec(256L);
    fl_obsize = getvec(256L);
    fl_osymoff = getvec(256L);
    fl_osymsz = getvec(256L);
    fl_ostroff = getvec(256L);
    fl_oreloff = getvec(256L);
    fl_orelsz = getvec(256L);
    fl_otbase = getvec(256L);
    fl_orbase = getvec(256L);
    fl_odbase = getvec(256L);
    fl_obbase = getvec(256L);
    fl_gname = getvec((1L << 15L));
    fl_gvaddr = getvec((1L << 15L));
    fl_errs = 0L;
    fl_undef_nm = getvec(1024L);
    fl_undefn = 0L;
    fl_abs_nm = getvec(256L);
    fl_absn = 0L;
    if (fl_ends_with(outname, cast(long)__s31644.ptr) != 0) goto L6514; else goto L6516;
L6516:
    if (fl_ends_with(outname, cast(long)__s31647.ptr) != 0) goto L6514; else goto L6515;
L6514:
    fl_shared = 1L;
L6515:
    if (fl_ends_with(outname, cast(long)__s31651.ptr) != 0)
    {
        fl_efi = 1L;
    }
    fl_fmt = 0L;
    k = 0L;
    while (k <= (nin - 1L))
    {
        f = 0L;
        if (fl_load1(*cast(long*)(names + (k << 3L)), k) != 0) goto L6524; else goto L6523;
L6523:
        return 0L;
L6524:
        f = fl_detect1(k);
        if (f == 0L)
        {
            v34 = writes(cast(long)__s31674.ptr);
            return 0L;
        }
        if (fl_fmt == 0L)
        {
            fl_fmt = f;
        }
        else
        {
            if (f == fl_fmt) goto L6531; else goto L6530;
L6530:
            v36 = writes(cast(long)__s31683.ptr);
            return 0L;
L6531:
        }
        v37 = fl_parse1(k);
        k = (k + 1L);
    }
    fl_imp_n = 0L;
    v38 = fl_collect_syms();
    v39 = fl_layout();
    v40 = fl_collect_syms();
    v41 = fl_copy_sections();
    if (fl_fmt == 2L)
    {
        v42 = fl_emit_imports();
        v43 = fl_emit_exports();
    }
    v44 = fl_relocate();
    fl_entry = fl_tvaddr;
    v = fl_gsym_lookup(cast(long)__s31709.ptr);
    if (v != (-1L))
    {
        fl_entry = v;
    }
    if (fl_errs > 0L)
    {
        if (fl_undefn > 0L)
        {
            v48 = writef(cast(long)__s31722.ptr, fl_undefn, fl_errs);
            i = 0L;
            while (i <= (fl_undefn - 1L))
            {
                v50 = writef(cast(long)__s31733.ptr, *cast(long*)(fl_undef_nm + (i << 3L)));
                i = (i + 1L);
            }
        }
        if (fl_undefn > 0L) goto L6545; else goto L6544;
L6544:
        v52 = writef(cast(long)__s31745.ptr, fl_errs);
L6545:
        return 0L;
    }
    if (fl_fmt == 2L)
    {
        v53 = fl_write_pe(outname);
    }
    else
    {
        if (fl_shared != 0L)
        {
            v54 = fl_write_so(outname);
        }
        else
        {
            v55 = fl_write_exe(outname);
        }
    }
    return 1L;
}
