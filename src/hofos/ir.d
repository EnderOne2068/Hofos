// Generated from BCPL by cg-d.b, split into modules by split.d.
module hofos.ir;

import hofos.all;

long ir_init()
{
    long v0 = 0;
    long v1 = 0;
    long i = 0;
    long v2 = 0;
    long i_2 = 0;
    ir_arena = getvec(((8L * 262144L) + 4L));
    ir_next = 1L;
    ir_nextemp = 1L;
    ir_nextlabel = 1L;
    ir_tname = getvec((65536L + 2L));
    i = 0L;
    while (i <= 65536L)
    {
        *cast(long*)(ir_tname + (i << 3L)) = 0L;
        i = (i + 1L);
    }
    ir_gname = getvec((4096L + 2L));
    i_2 = 0L;
    while (i_2 <= 4096L)
    {
        *cast(long*)(ir_gname + (i_2 << 3L)) = 0L;
        i_2 = (i_2 + 1L);
    }
    return 0;
}
long ir_new_temp()
{
    long t = 0;
    t = ir_nextemp;
    ir_nextemp = (t + 1L);
    return t;
}
long ir_new_label()
{
    long l = 0;
    l = ir_nextlabel;
    ir_nextlabel = (l + 1L);
    return l;
}
long ir_emit(long p1 = 0, long p2 = 0, long p3 = 0, long p4 = 0, long p5 = 0)
{
    long n = 0;
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long op = p1;
    long dst = p2;
    long a1 = p3;
    long a2 = p4;
    long a3 = p5;
    n = ir_next;
    ir_next = (ir_next + 8L);
    if (ir_next >= (8L * 262144L))
    {
        v1 = writes(cast(long)__s7852.ptr);
        v2 = __finish();
    }
    *cast(long*)(ir_arena + (n << 3L)) = op;
    *cast(long*)(ir_arena + ((n + 1L) << 3L)) = dst;
    *cast(long*)(ir_arena + ((n + 2L) << 3L)) = a1;
    *cast(long*)(ir_arena + ((n + 3L) << 3L)) = a2;
    *cast(long*)(ir_arena + ((n + 4L) << 3L)) = a3;
    *cast(long*)(ir_arena + ((n + 5L) << 3L)) = 0L;
    *cast(long*)(ir_arena + ((n + 6L) << 3L)) = 0L;
    *cast(long*)(ir_arena + ((n + 7L) << 3L)) = 0L;
    return n;
}
long ir_emit_br(long p1 = 0, long p2 = 0, long p3 = 0)
{
    long v0 = 0;
    long n = 0;
    long cond = p1;
    long ltrue = p2;
    long lfalse = p3;
    n = ir_emit(31L, 0L, cond, 0L, 0L);
    *cast(long*)(ir_arena + ((n + 5L) << 3L)) = ltrue;
    *cast(long*)(ir_arena + ((n + 6L) << 3L)) = lfalse;
    return n;
}
long ir_emit_jmp(long p1 = 0)
{
    long v0 = 0;
    long n = 0;
    long label = p1;
    n = ir_emit(30L, 0L, 0L, 0L, 0L);
    *cast(long*)(ir_arena + ((n + 5L) << 3L)) = label;
    return n;
}
long ir_emit_label(long p1 = 0)
{
    long v0 = 0;
    long label = p1;
    return ir_emit(32L, 0L, label, 0L, 0L);
}
long ir_emit_call(long p1 = 0, long p2 = 0, long p3 = 0, long p4 = 0, long p5 = 0)
{
    long v0 = 0;
    long n = 0;
    long dst = p1;
    long callee = p2;
    long argc = p3;
    long a1 = p4;
    long a2 = p5;
    n = ir_emit(33L, dst, callee, argc, a1);
    *cast(long*)(ir_arena + ((n + 5L) << 3L)) = a2;
    return n;
}
long ir_set_arg3(long p1 = 0, long p2 = 0)
{
    long n = p1;
    long a3 = p2;
    *cast(long*)(ir_arena + ((n + 6L) << 3L)) = a3;
    return 0;
}
long ir_op_name(long p1 = 0)
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
    long v31 = 0;
    long v32 = 0;
    long v33 = 0;
    long op = p1;
    if (op == 4L) goto L1970; else goto L2003;
L2003:
    if (op == 5L) goto L1971; else goto L2004;
L2004:
    if (op == 6L) goto L1972; else goto L2005;
L2005:
    if (op == 7L) goto L1973; else goto L2006;
L2006:
    if (op == 8L) goto L1974; else goto L2007;
L2007:
    if (op == 9L) goto L1975; else goto L2008;
L2008:
    if (op == 10L) goto L1976; else goto L2009;
L2009:
    if (op == 11L) goto L1977; else goto L2010;
L2010:
    if (op == 13L) goto L1978; else goto L2011;
L2011:
    if (op == 14L) goto L1979; else goto L2012;
L2012:
    if (op == 20L) goto L1980; else goto L2013;
L2013:
    if (op == 21L) goto L1981; else goto L2014;
L2014:
    if (op == 22L) goto L1982; else goto L2015;
L2015:
    if (op == 23L) goto L1983; else goto L2016;
L2016:
    if (op == 24L) goto L1984; else goto L2017;
L2017:
    if (op == 25L) goto L1985; else goto L2018;
L2018:
    if (op == 51L) goto L1986; else goto L2019;
L2019:
    if (op == 52L) goto L1987; else goto L2020;
L2020:
    if (op == 53L) goto L1988; else goto L2021;
L2021:
    if (op == 54L) goto L1989; else goto L2022;
L2022:
    if (op == 59L) goto L1990; else goto L2023;
L2023:
    if (op == 60L) goto L1991; else goto L2024;
L2024:
    if (op == 55L) goto L1992; else goto L2025;
L2025:
    if (op == 56L) goto L1993; else goto L2026;
L2026:
    if (op == 57L) goto L1994; else goto L2027;
L2027:
    if (op == 58L) goto L1995; else goto L2028;
L2028:
    if (op == 12L) goto L1996; else goto L2029;
L2029:
    if (op == 26L) goto L1997; else goto L2030;
L2030:
    if (op == 39L) goto L1998; else goto L2031;
L2031:
    if (op == 2L) goto L1999; else goto L2032;
L2032:
    if (op == 43L) goto L2000; else goto L2033;
L2033:
    if (op == 61L) goto L2001; else goto L2034;
L2034:
    if (op == 62L) goto L2002; else goto L2035;
L2035:
    goto L1969;
L1970:
    return cast(long)__s8045.ptr;
L1971:
    return cast(long)__s8046.ptr;
L1972:
    return cast(long)__s8047.ptr;
L1973:
    return cast(long)__s8048.ptr;
L1974:
    return cast(long)__s8049.ptr;
L1975:
    return cast(long)__s8050.ptr;
L1976:
    return cast(long)__s8051.ptr;
L1977:
    return cast(long)__s8052.ptr;
L1978:
    return cast(long)__s8053.ptr;
L1979:
    return cast(long)__s8054.ptr;
L1980:
    return cast(long)__s8055.ptr;
L1981:
    return cast(long)__s8056.ptr;
L1982:
    return cast(long)__s8057.ptr;
L1983:
    return cast(long)__s8058.ptr;
L1984:
    return cast(long)__s8059.ptr;
L1985:
    return cast(long)__s8060.ptr;
L1986:
    return cast(long)__s8061.ptr;
L1987:
    return cast(long)__s8062.ptr;
L1988:
    return cast(long)__s8063.ptr;
L1989:
    return cast(long)__s8064.ptr;
L1990:
    return cast(long)__s8065.ptr;
L1991:
    return cast(long)__s8066.ptr;
L1992:
    return cast(long)__s8067.ptr;
L1993:
    return cast(long)__s8068.ptr;
L1994:
    return cast(long)__s8069.ptr;
L1995:
    return cast(long)__s8070.ptr;
L1996:
    return cast(long)__s8071.ptr;
L1997:
    return cast(long)__s8072.ptr;
L1998:
    return cast(long)__s8073.ptr;
L1999:
    return cast(long)__s8074.ptr;
L2000:
    return cast(long)__s8075.ptr;
L2001:
    return cast(long)__s8076.ptr;
L2002:
    return cast(long)__s8077.ptr;
L1969:
    return cast(long)__s8078.ptr;
L1968:
    return 0;
}
long ir_op_is_binary(long p1 = 0)
{
    long op = p1;
    if (op == 12L) goto L2036; else goto L2039;
L2039:
    if (op == 26L) goto L2036; else goto L2038;
L2038:
    if (op == 39L) goto L2036; else goto L2037;
L2036:
    return 0L;
L2037:
    if (op == 2L) goto L2040; else goto L2042;
L2042:
    if (op == 43L) goto L2040; else goto L2041;
L2040:
    return 0L;
L2041:
    if (op == 61L) goto L2043; else goto L2045;
L2045:
    if (op == 62L) goto L2043; else goto L2044;
L2043:
    return 0L;
L2044:
    return 1L;
}
long hm_wrstr(long p1 = 0)
{
    long n = 0;
    long v0 = 0;
    long i = 0;
    long c = 0;
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
    long s = p1;
    n = cast(long)*cast(ubyte*)(s + 0L);
    v0 = wrch(34L);
    i = 1L;
    while (i <= n)
    {
        c = cast(long)*cast(ubyte*)(s + i);
        if (c == 10L) goto L2052; else goto L2057;
L2057:
        if (c == 9L) goto L2053; else goto L2058;
L2058:
        if (c == 13L) goto L2054; else goto L2059;
L2059:
        if (c == 42L) goto L2055; else goto L2060;
L2060:
        if (c == 34L) goto L2056; else goto L2061;
L2061:
    goto L2051;
L2052:
        v1 = wrch(42L);
        v2 = wrch(110L);
    goto L2050;
L2053:
        v3 = wrch(42L);
        v4 = wrch(116L);
    goto L2050;
L2054:
        v5 = wrch(42L);
        v6 = wrch(99L);
    goto L2050;
L2055:
        v7 = wrch(42L);
        v8 = wrch(42L);
    goto L2050;
L2056:
        v9 = wrch(42L);
        v10 = wrch(34L);
    goto L2050;
L2051:
        v11 = wrch(c);
L2050:
        i = (i + 1L);
    }
    v12 = wrch(34L);
    return 0;
}
long hm_dump()
{
    long p = 0;
    long i = 0;
    long hi = 0;
    long v0 = 0;
    long nmap = 0;
    long pend4 = 0;
    long pend5 = 0;
    long k = 0;
    long op = 0;
    long dst = 0;
    long a1 = 0;
    long a2 = 0;
    long a3 = 0;
    long l1 = 0;
    long l2 = 0;
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
    long nm = 0;
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
    long v59 = 0;
    long v60 = 0;
    long v61 = 0;
    long v62 = 0;
    long v63 = 0;
    long v64 = 0;
    long v65 = 0;
    long v66 = 0;
    long v67 = 0;
    long v68 = 0;
    long v69 = 0;
    long v70 = 0;
    long v71 = 0;
    p = ir_arena;
    i = 1L;
    hi = (ir_nextemp + 4L);
    nmap = getvec(hi);
    pend4 = 0L;
    pend5 = 0L;
    k = 0L;
    while (k <= hi)
    {
        *cast(long*)(nmap + (k << 3L)) = 0L;
        k = (k + 1L);
    }
L2066:
    if (i >= ir_next) goto L2068; else goto L2067;
L2067:
    op = *cast(long*)(p + (i << 3L));
    dst = *cast(long*)(p + ((i + 1L) << 3L));
    a1 = *cast(long*)(p + ((i + 2L) << 3L));
    a2 = *cast(long*)(p + ((i + 3L) << 3L));
    a3 = *cast(long*)(p + ((i + 4L) << 3L));
    l1 = *cast(long*)(p + ((i + 5L) << 3L));
    l2 = *cast(long*)(p + ((i + 6L) << 3L));
    if (op == 36L) goto L2071; else goto L2096;
L2096:
    if (op == 37L) goto L2072; else goto L2097;
L2097:
    if (op == 32L) goto L2073; else goto L2098;
L2098:
    if (op == 30L) goto L2074; else goto L2099;
L2099:
    if (op == 31L) goto L2075; else goto L2100;
L2100:
    if (op == 35L) goto L2076; else goto L2101;
L2101:
    if (op == 34L) goto L2077; else goto L2102;
L2102:
    if (op == 46L) goto L2078; else goto L2103;
L2103:
    if (op == 1L) goto L2079; else goto L2104;
L2104:
    if (op == 38L) goto L2080; else goto L2105;
L2105:
    if (op == 47L) goto L2081; else goto L2106;
L2106:
    if (op == 33L) goto L2082; else goto L2107;
L2107:
    if (op == 3L) goto L2083; else goto L2108;
L2108:
    if (op == 44L) goto L2084; else goto L2109;
L2109:
    if (op == 40L) goto L2085; else goto L2110;
L2110:
    if (op == 41L) goto L2086; else goto L2111;
L2111:
    if (op == 49L) goto L2087; else goto L2112;
L2112:
    if (op == 42L) goto L2088; else goto L2113;
L2113:
    if (op == 48L) goto L2089; else goto L2114;
L2114:
    if (op == 45L) goto L2090; else goto L2115;
L2115:
    if (op == 50L) goto L2091; else goto L2116;
L2116:
    if (op == 63L) goto L2092; else goto L2117;
L2117:
    if (op == 64L) goto L2093; else goto L2118;
L2118:
    if (op == 65L) goto L2094; else goto L2119;
L2119:
    if (op == 66L) goto L2095; else goto L2120;
L2120:
    goto L2070;
L2071:
    v2 = writef(cast(long)__s8284.ptr, a2, a1);
    goto L2069;
L2072:
    v4 = writes(cast(long)__s8287.ptr);
    goto L2069;
L2073:
    v6 = writef(cast(long)__s8290.ptr, a1);
    goto L2069;
L2074:
    v8 = writef(cast(long)__s8293.ptr, l1);
    goto L2069;
L2075:
    v10 = writef(cast(long)__s8296.ptr, a1, l1, l2);
    goto L2069;
L2076:
    v12 = writef(cast(long)__s8299.ptr, dst, a1);
    goto L2069;
L2077:
    v14 = writef(cast(long)__s8302.ptr, a1);
    goto L2069;
L2078:
    v16 = writes(cast(long)__s8305.ptr);
    goto L2069;
L2079:
    if (a2 != 0L)
    {
        if (dst > 0L)
        {
            if (dst <= hi)
            {
                *cast(long*)(nmap + (dst << 3L)) = a1;
            }
        }
    }
    else
    {
        v18 = writef(cast(long)__s8316.ptr, dst, a1);
    }
    goto L2069;
L2080:
    v20 = writef(cast(long)__s8319.ptr, dst);
    v21 = hm_wrstr(a1);
    v22 = newline();
    goto L2069;
L2081:
    if (a2 == 4L)
    {
        pend4 = a1;
    }
    if (a2 == 5L)
    {
        pend5 = a1;
    }
    goto L2069;
L2082:
    nm = 0L;
    if (a1 > 0L)
    {
        if (a1 <= hi)
        {
            nm = *cast(long*)(nmap + (a1 << 3L));
        }
    }
    if (nm != 0L)
    {
        v24 = writef(cast(long)__s8341.ptr, dst, nm);
    }
    else
    {
        v26 = writef(cast(long)__s8344.ptr, dst, a1);
    }
    if (a3 > 0L)
    {
        v28 = writef(cast(long)__s8349.ptr, a3);
    }
    if (l1 > 0L)
    {
        v30 = writef(cast(long)__s8354.ptr, l1);
    }
    if (l2 > 0L)
    {
        v32 = writef(cast(long)__s8359.ptr, l2);
    }
    if (pend4 > 0L)
    {
        v34 = writef(cast(long)__s8364.ptr, pend4);
    }
    if (pend5 > 0L)
    {
        v36 = writef(cast(long)__s8369.ptr, pend5);
    }
    v37 = newline();
    pend4 = 0L;
    pend5 = 0L;
    goto L2069;
L2083:
    v39 = writef(cast(long)__s8376.ptr, a1, a2);
    goto L2069;
L2084:
    v41 = writef(cast(long)__s8379.ptr, a1, a2);
    goto L2069;
L2085:
    v43 = writef(cast(long)__s8382.ptr, dst, a1);
    goto L2069;
L2086:
    v45 = writef(cast(long)__s8385.ptr, a1, a2);
    goto L2069;
L2087:
    v47 = writef(cast(long)__s8388.ptr, dst, a1);
    goto L2069;
L2088:
    v49 = writef(cast(long)__s8391.ptr, dst, a1);
    goto L2069;
L2089:
    v51 = writef(cast(long)__s8394.ptr, dst, a1);
    goto L2069;
L2090:
    v53 = writef(cast(long)__s8397.ptr, dst, a1);
    goto L2069;
L2091:
    v55 = writef(cast(long)__s8400.ptr, dst, a2, a1);
    goto L2069;
L2092:
    v57 = writef(cast(long)__s8403.ptr, a1, a2, a3);
    goto L2069;
L2093:
    v59 = writef(cast(long)__s8406.ptr, a1, a2, a3);
    goto L2069;
L2094:
    v61 = writef(cast(long)__s8409.ptr, dst, a1, a2, a3);
    goto L2069;
L2095:
    v63 = writef(cast(long)__s8412.ptr, dst, a1, a2, a3);
    goto L2069;
L2070:
    if (ir_op_is_binary(op) != 0)
    {
        v67 = writef(cast(long)__s8417.ptr, ir_op_name(op), dst, a1, a2);
    }
    else
    {
        v70 = writef(cast(long)__s8422.ptr, ir_op_name(op), dst, a1);
    }
L2069:
    i = (i + 8L);
    goto L2066;
L2068:
    v71 = freevec(nmap);
    return 0;
}
