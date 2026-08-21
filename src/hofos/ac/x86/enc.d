// Generated from BCPL by cg-d.b, split into modules by split.d.
module hofos.ac.x86.enc;

import hofos.all;

long ac_shndx(long p1 = 0)
{
    long sec = p1;
    if (sec == 0L)
    {
        return 1L;
    }
    if (sec == 1L)
    {
        return 2L;
    }
    if (sec == 3L)
    {
        return 3L;
    }
    return 4L;
}
long ac_b(long p1 = 0)
{
    long v = p1;
    if (ac_cursec == 1L)
    {
        *cast(ubyte*)(ac_rodata + ac_rodlen) = cast(ubyte)(v & 255L);
        ac_rodlen = (ac_rodlen + 1L);
    }
    else
    {
        if (ac_cursec == 3L)
        {
            *cast(ubyte*)(ac_data + ac_datalen) = cast(ubyte)(v & 255L);
            ac_datalen = (ac_datalen + 1L);
        }
        else
        {
            if (ac_cursec == 4L)
            {
                *cast(ubyte*)(ac_edata + ac_edatalen) = cast(ubyte)(v & 255L);
                ac_edatalen = (ac_edatalen + 1L);
            }
            else
            {
                if (ac_cursec == 5L)
                {
                    *cast(ubyte*)(ac_idata + ac_idatalen) = cast(ubyte)(v & 255L);
                    ac_idatalen = (ac_idatalen + 1L);
                }
                else
                {
                    *cast(ubyte*)(ac_code + ac_len) = cast(ubyte)(v & 255L);
                    ac_len = (ac_len + 1L);
                }
            }
        }
    }
    return 0;
}
long ac_w32(long p1 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v = p1;
    v0 = ac_b(v);
    v1 = ac_b((v >> 8L));
    v2 = ac_b((v >> 16L));
    v3 = ac_b((v >> 24L));
    return 0;
}
long ac_w64(long p1 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v = p1;
    v0 = ac_w32(v);
    v1 = ac_w32((v >> 32L));
    return 0;
}
long ac_patch32(long p1 = 0, long p2 = 0)
{
    long off = p1;
    long v = p2;
    *cast(ubyte*)(ac_code + (off + 0L)) = cast(ubyte)(v & 255L);
    *cast(ubyte*)(ac_code + (off + 1L)) = cast(ubyte)((v >> 8L) & 255L);
    *cast(ubyte*)(ac_code + (off + 2L)) = cast(ubyte)((v >> 16L) & 255L);
    *cast(ubyte*)(ac_code + (off + 3L)) = cast(ubyte)((v >> 24L) & 255L);
    return 0;
}
long ac_streq(long p1 = 0, long p2 = 0)
{
    long i = 0;
    long a = p1;
    long b = p2;
    if (a == 0L) goto L5131; else goto L5133;
L5133:
    if (b == 0L) goto L5131; else goto L5132;
L5131:
    return 0L;
L5132:
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
long ac_dup(long p1 = 0, long p2 = 0, long p3 = 0)
{
    long n = 0;
    long s = 0;
    long v0 = 0;
    long i = 0;
    long src = p1;
    long lo = p2;
    long hi = p3;
    n = ((hi - lo) + 1L);
    s = 0L;
    if (n < 0L)
    {
        n = 0L;
    }
    s = getvec(((n / 8L) + 2L));
    *cast(ubyte*)(s + 0L) = cast(ubyte)n;
    i = 1L;
    while (i <= n)
    {
        *cast(ubyte*)(s + i) = cast(ubyte)cast(long)*cast(ubyte*)(src + ((lo + i) - 1L));
        i = (i + 1L);
    }
    return s;
}
long ac_rnum(long p1 = 0)
{
    long n = 0;
    long v = 0;
    long i = 0;
    long c = 0;
    long c_2 = 0;
    long s = p1;
    n = cast(long)*cast(ubyte*)(s + 0L);
    v = 0L;
    i = 2L;
    if (n < 2L)
    {
        return (-1L);
    }
    if (cast(long)*cast(ubyte*)(s + 1L) != 114L)
    {
        return (-1L);
    }
    if (cast(long)*cast(ubyte*)(s + 2L) >= 48L)
    {
        if (cast(long)*cast(ubyte*)(s + 2L) <= 57L) goto L5153; else goto L5152;
    }
L5152:
    return (-1L);
L5153:
L5155:
    if (i <= n)
    {
        c = cast(long)*cast(ubyte*)(s + i);
        if (c >= 48L)
        {
            if (c <= 57L) goto L5159; else goto L5158;
        }
L5158:
    goto L5157;
L5159:
        v = ((v * 10L) + (c - 48L));
        i = (i + 1L);
    goto L5155;
    }
L5157:
    if (i == n)
    {
        c_2 = cast(long)*cast(ubyte*)(s + n);
        if (c_2 == 98L) goto L5164; else goto L5166;
L5166:
        if (c_2 == 119L) goto L5164; else goto L5165;
L5165:
        if (c_2 == 100L) goto L5164; else goto L5163;
L5163:
        return (-1L);
L5164:
        i = (i + 1L);
    }
    if (i > n) goto L5168; else goto L5167;
L5167:
    return (-1L);
L5168:
    if (v < 8L) goto L5169; else goto L5171;
L5171:
    if (v > 15L) goto L5169; else goto L5170;
L5169:
    return (-1L);
L5170:
    return v;
}
long ac_reg(long p1 = 0)
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
    long v72 = 0;
    long v73 = 0;
    long v74 = 0;
    long v75 = 0;
    long v76 = 0;
    long v77 = 0;
    long v78 = 0;
    long v79 = 0;
    long v80 = 0;
    long s = p1;
    if (ac_streq(s, cast(long)__s22863.ptr) != 0)
    {
        return 0L;
    }
    if (ac_streq(s, cast(long)__s22867.ptr) != 0)
    {
        return 1L;
    }
    if (ac_streq(s, cast(long)__s22871.ptr) != 0)
    {
        return 2L;
    }
    if (ac_streq(s, cast(long)__s22875.ptr) != 0)
    {
        return 3L;
    }
    if (ac_streq(s, cast(long)__s22879.ptr) != 0)
    {
        return 4L;
    }
    if (ac_streq(s, cast(long)__s22883.ptr) != 0)
    {
        return 5L;
    }
    if (ac_streq(s, cast(long)__s22887.ptr) != 0)
    {
        return 6L;
    }
    if (ac_streq(s, cast(long)__s22891.ptr) != 0)
    {
        return 7L;
    }
    if (ac_streq(s, cast(long)__s22895.ptr) != 0)
    {
        return 8L;
    }
    if (ac_streq(s, cast(long)__s22899.ptr) != 0)
    {
        return 9L;
    }
    if (ac_streq(s, cast(long)__s22903.ptr) != 0)
    {
        return 10L;
    }
    if (ac_streq(s, cast(long)__s22907.ptr) != 0)
    {
        return 11L;
    }
    if (ac_streq(s, cast(long)__s22911.ptr) != 0)
    {
        return 12L;
    }
    if (ac_streq(s, cast(long)__s22915.ptr) != 0)
    {
        return 13L;
    }
    if (ac_streq(s, cast(long)__s22919.ptr) != 0)
    {
        return 14L;
    }
    if (ac_streq(s, cast(long)__s22923.ptr) != 0)
    {
        return 15L;
    }
    if (ac_streq(s, cast(long)__s22927.ptr) != 0) goto L5204; else goto L5207;
L5207:
    if (ac_streq(s, cast(long)__s22930.ptr) != 0) goto L5204; else goto L5206;
L5206:
    if (ac_streq(s, cast(long)__s22933.ptr) != 0) goto L5204; else goto L5205;
L5204:
    return 0L;
L5205:
    if (ac_streq(s, cast(long)__s22937.ptr) != 0) goto L5208; else goto L5211;
L5211:
    if (ac_streq(s, cast(long)__s22940.ptr) != 0) goto L5208; else goto L5210;
L5210:
    if (ac_streq(s, cast(long)__s22943.ptr) != 0) goto L5208; else goto L5209;
L5208:
    return 1L;
L5209:
    if (ac_streq(s, cast(long)__s22947.ptr) != 0) goto L5212; else goto L5215;
L5215:
    if (ac_streq(s, cast(long)__s22950.ptr) != 0) goto L5212; else goto L5214;
L5214:
    if (ac_streq(s, cast(long)__s22953.ptr) != 0) goto L5212; else goto L5213;
L5212:
    return 2L;
L5213:
    if (ac_streq(s, cast(long)__s22957.ptr) != 0) goto L5216; else goto L5219;
L5219:
    if (ac_streq(s, cast(long)__s22960.ptr) != 0) goto L5216; else goto L5218;
L5218:
    if (ac_streq(s, cast(long)__s22963.ptr) != 0) goto L5216; else goto L5217;
L5216:
    return 3L;
L5217:
    if (ac_streq(s, cast(long)__s22967.ptr) != 0) goto L5220; else goto L5223;
L5223:
    if (ac_streq(s, cast(long)__s22970.ptr) != 0) goto L5220; else goto L5222;
L5222:
    if (ac_streq(s, cast(long)__s22973.ptr) != 0) goto L5220; else goto L5221;
L5220:
    return 4L;
L5221:
    if (ac_streq(s, cast(long)__s22977.ptr) != 0) goto L5224; else goto L5227;
L5227:
    if (ac_streq(s, cast(long)__s22980.ptr) != 0) goto L5224; else goto L5226;
L5226:
    if (ac_streq(s, cast(long)__s22983.ptr) != 0) goto L5224; else goto L5225;
L5224:
    return 5L;
L5225:
    if (ac_streq(s, cast(long)__s22987.ptr) != 0) goto L5228; else goto L5231;
L5231:
    if (ac_streq(s, cast(long)__s22990.ptr) != 0) goto L5228; else goto L5230;
L5230:
    if (ac_streq(s, cast(long)__s22993.ptr) != 0) goto L5228; else goto L5229;
L5228:
    return 6L;
L5229:
    if (ac_streq(s, cast(long)__s22997.ptr) != 0) goto L5232; else goto L5235;
L5235:
    if (ac_streq(s, cast(long)__s23000.ptr) != 0) goto L5232; else goto L5234;
L5234:
    if (ac_streq(s, cast(long)__s23003.ptr) != 0) goto L5232; else goto L5233;
L5232:
    return 7L;
L5233:
    return ac_rnum(s);
}
long ac_rexr(long p1 = 0)
{
    long r = p1;
    if ((r & 8L) != 0L)
    {
        return 4L;
    }
    return 0L;
}
long ac_rexb(long p1 = 0)
{
    long r = p1;
    if ((r & 8L) != 0L)
    {
        return 1L;
    }
    return 0L;
}
long ac_mem_rexb(long p1 = 0)
{
    long v0 = 0;
    long b = 0;
    long j = p1;
    b = ac_reg(*cast(long*)(ac_tok + ((j + 1L) << 3L)));
    if (b >= 8L)
    {
        return 1L;
    }
    return 0L;
}
long ac_isnum(long p1 = 0)
{
    long c = 0;
    long s = p1;
    c = cast(long)*cast(ubyte*)(s + 1L);
    return (cast(long)(c == 45L) | (cast(long)(c >= 48L) & cast(long)(c <= 57L)));
}
long ac_num(long p1 = 0)
{
    long n = 0;
    long j = 0;
    long neg = 0;
    long j_2 = 0;
    long c = 0;
    long dv = 0;
    long v0 = 0;
    long s = p1;
    n = 0L;
    j = 1L;
    neg = 0L;
    if (cast(long)*cast(ubyte*)(s + 1L) == 45L)
    {
        neg = 1L;
        j = 2L;
    }
    if (j < cast(long)*cast(ubyte*)(s + 0L))
    {
        if (cast(long)*cast(ubyte*)(s + j) == 48L) goto L5247; else goto L5245;
L5247:
        if (cast(long)*cast(ubyte*)(s + (j + 1L)) == 120L) goto L5244; else goto L5249;
L5249:
        if (cast(long)*cast(ubyte*)(s + (j + 1L)) == 88L) goto L5244; else goto L5245;
L5244:
        j_2 = (j + 2L);
        while (j_2 <= cast(long)*cast(ubyte*)(s + 0L))
        {
            c = cast(long)*cast(ubyte*)(s + j_2);
            dv = 0L;
            if (c >= 48L)
            {
                if (c <= 57L) goto L5254; else goto L5255;
L5254:
                dv = (c - 48L);
    goto L5256;
            }
L5255:
            if (c >= 97L)
            {
                if (c <= 102L) goto L5258; else goto L5259;
L5258:
                dv = ((c - 97L) + 10L);
    goto L5260;
            }
L5259:
            dv = ((c - 65L) + 10L);
L5260:
L5256:
            n = ((n << 4L) | dv);
            j_2 = (j_2 + 1L);
        }
    goto L5246;
    }
L5245:
    while (j <= cast(long)*cast(ubyte*)(s + 0L))
    {
        n = ((n * 10L) + (cast(long)*cast(ubyte*)(s + j) - 48L));
        j = (j + 1L);
    }
L5246:
    if (neg != 0)
    {
        v0 = (-n);
    }
    else
    {
        v0 = n;
    }
    return v0;
}
long ac_cur_off()
{
    long v0 = 0;
    v0 = ac_cursec;
    if (v0 == 1L) goto L5271; else goto L5276;
L5276:
    if (v0 == 2L) goto L5272; else goto L5277;
L5277:
    if (v0 == 3L) goto L5273; else goto L5278;
L5278:
    if (v0 == 4L) goto L5274; else goto L5279;
L5279:
    if (v0 == 5L) goto L5275; else goto L5280;
L5280:
    goto L5270;
L5271:
    return ac_rodlen;
L5272:
    return ac_bsslen;
L5273:
    return ac_datalen;
L5274:
    return ac_edatalen;
L5275:
    return ac_idatalen;
L5270:
    return ac_len;
L5269:
    return 0;
}
long ac_add_label(long p1 = 0)
{
    long v0 = 0;
    long name = p1;
    *cast(long*)(ac_lname + (ac_ln << 3L)) = name;
    *cast(long*)(ac_lsec + (ac_ln << 3L)) = ac_cursec;
    *cast(long*)(ac_loff + (ac_ln << 3L)) = ac_cur_off();
    ac_ln = (ac_ln + 1L);
    return 0;
}
long ac_find_label(long p1 = 0)
{
    long i = 0;
    long v0 = 0;
    long name = p1;
    i = 0L;
    while (i <= (ac_ln - 1L))
    {
        if (ac_streq(*cast(long*)(ac_lname + (i << 3L)), name) != 0)
        {
            return *cast(long*)(ac_loff + (i << 3L));
        }
        i = (i + 1L);
    }
    return (-1L);
}
long ac_areloc(long p1 = 0)
{
    long name = p1;
    *cast(long*)(ac_arsite + (ac_arn << 3L)) = ac_len;
    *cast(long*)(ac_arsym + (ac_arn << 3L)) = name;
    ac_arn = (ac_arn + 1L);
    return 0;
}
long ac_fixup(long p1 = 0)
{
    long v0 = 0;
    long name = p1;
    *cast(long*)(ac_fsite + (ac_fn << 3L)) = ac_len;
    *cast(long*)(ac_ftgt + (ac_fn << 3L)) = name;
    ac_fn = (ac_fn + 1L);
    v0 = ac_w32(0L);
    return 0;
}
long ac_is_local(long p1 = 0)
{
    long nm = p1;
    return ((cast(long)(cast(long)*cast(ubyte*)(nm + 0L) >= 2L) & cast(long)(cast(long)*cast(ubyte*)(nm + 1L) == 46L)) & cast(long)(cast(long)*cast(ubyte*)(nm + 2L) == 76L));
}
long ac_needs_sib(long p1 = 0)
{
    long base = p1;
    return cast(long)((base & 7L) == 4L);
}
long ac_mem_operand(long p1 = 0, long p2 = 0)
{
    long v0 = 0;
    long base = 0;
    long sgn = 0;
    long v1 = 0;
    long v2 = 0;
    long neg = 0;
    long v3 = 0;
    long v4 = 0;
    long pos = 0;
    long v5 = 0;
    long mag = 0;
    long v6 = 0;
    long disp = 0;
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
    long regbits = p1;
    long j = p2;
    base = ac_reg(*cast(long*)(ac_tok + ((j + 1L) << 3L)));
    sgn = *cast(long*)(ac_tok + ((j + 2L) << 3L));
    neg = ac_streq(sgn, cast(long)__s23318.ptr);
    pos = ac_streq(sgn, cast(long)__s23322.ptr);
    if (neg != 0) goto L5291; else goto L5294;
L5294:
    if (pos != 0) goto L5291; else goto L5292;
L5291:
    mag = ac_num(*cast(long*)(ac_tok + ((j + 3L) << 3L)));
    if (neg != 0)
    {
        v6 = (-mag);
    }
    else
    {
        v6 = mag;
    }
    disp = v6;
    if (disp >= (-128L))
    {
        if (disp <= 127L) goto L5298; else goto L5299;
L5298:
        v7 = ac_b(((64L | ((regbits & 7L) << 3L)) | (base & 7L)));
        if (ac_needs_sib(base) != 0)
        {
            v9 = ac_b(36L);
        }
        v10 = ac_b((disp & 255L));
    goto L5300;
    }
L5299:
    v11 = ac_b(((128L | ((regbits & 7L) << 3L)) | (base & 7L)));
    if (ac_needs_sib(base) != 0)
    {
        v13 = ac_b(36L);
    }
    v14 = ac_w32(disp);
L5300:
    goto L5293;
L5292:
    v15 = ac_b((((regbits & 7L) << 3L) | (base & 7L)));
    if (ac_needs_sib(base) != 0)
    {
        v17 = ac_b(36L);
    }
L5293:
    return 0;
}
long ac_after_mem(long p1 = 0)
{
    long k = 0;
    long v0 = 0;
    long v1 = 0;
    long j = p1;
    k = (j + 1L);
L5308:
    if (k >= ac_ntok) goto L5310; else goto L5309;
L5309:
    if (ac_streq(*cast(long*)(ac_tok + (k << 3L)), cast(long)__s23408.ptr) != 0)
    {
        return (k + 1L);
    }
    k = (k + 1L);
    goto L5308;
L5310:
    return ac_ntok;
}
long ac_tokenize(long p1 = 0)
{
    long n = 0;
    long i = 0;
    long c = 0;
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long fr = 0;
    long d = 0;
    long v3 = 0;
    long k = 0;
    long v4 = 0;
    long ln = p1;
    n = cast(long)*cast(ubyte*)(ln + 0L);
    i = 1L;
    ac_ntok = 0L;
L5313:
    if (i > n) goto L5315; else goto L5314;
L5314:
    c = cast(long)*cast(ubyte*)(ln + i);
    if (c == 32L) goto L5316; else goto L5320;
L5320:
    if (c == 9L) goto L5316; else goto L5319;
L5319:
    if (c == 44L) goto L5316; else goto L5317;
L5316:
    i = (i + 1L);
    goto L5318;
L5317:
    if (c == 59L)
    {
    goto L5315;
    }
    else
    {
        if (c == 91L) goto L5324; else goto L5327;
L5327:
        if (c == 93L) goto L5324; else goto L5325;
L5324:
        if (ac_ntok < 16L)
        {
            if (c == 91L)
            {
                v1 = cast(long)__s23448.ptr;
            }
            else
            {
                v1 = cast(long)__s23449.ptr;
            }
            *cast(long*)(ac_tok + (ac_ntok << 3L)) = v1;
            ac_ntok = (ac_ntok + 1L);
        }
        i = (i + 1L);
    goto L5326;
L5325:
        fr = i;
L5333:
        if (i > n) goto L5335; else goto L5334;
L5334:
        d = cast(long)*cast(ubyte*)(ln + i);
        if (d == 32L) goto L5336; else goto L5342;
L5342:
        if (d == 9L) goto L5336; else goto L5341;
L5341:
        if (d == 44L) goto L5336; else goto L5340;
L5340:
        if (d == 91L) goto L5336; else goto L5339;
L5339:
        if (d == 93L) goto L5336; else goto L5338;
L5338:
        if (d == 59L) goto L5336; else goto L5337;
L5336:
    goto L5335;
L5337:
        i = (i + 1L);
    goto L5333;
L5335:
        if (ac_ntok < 16L)
        {
            *cast(long*)(ac_tok + (ac_ntok << 3L)) = ac_dup(ln, fr, (i - 1L));
            ac_ntok = (ac_ntok + 1L);
        }
L5326:
    }
L5318:
    goto L5313;
L5315:
    k = ac_ntok;
    while (k <= 15L)
    {
        *cast(long*)(ac_tok + (k << 3L)) = cast(long)__s23498.ptr;
        k = (k + 1L);
    }
    return 0;
}
long ac_tok_is_mem(long p1 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long j = p1;
    return ac_streq(*cast(long*)(ac_tok + (j << 3L)), cast(long)__s23512.ptr);
}
long ac_setcc_op(long p1 = 0)
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
    long m = p1;
    if (ac_streq(m, cast(long)__s23552.ptr) != 0)
    {
        return 148L;
    }
    if (ac_streq(m, cast(long)__s23556.ptr) != 0)
    {
        return 149L;
    }
    if (ac_streq(m, cast(long)__s23560.ptr) != 0)
    {
        return 156L;
    }
    if (ac_streq(m, cast(long)__s23564.ptr) != 0)
    {
        return 158L;
    }
    if (ac_streq(m, cast(long)__s23568.ptr) != 0)
    {
        return 159L;
    }
    if (ac_streq(m, cast(long)__s23572.ptr) != 0)
    {
        return 157L;
    }
    if (ac_streq(m, cast(long)__s23576.ptr) != 0)
    {
        return 146L;
    }
    if (ac_streq(m, cast(long)__s23580.ptr) != 0)
    {
        return 150L;
    }
    if (ac_streq(m, cast(long)__s23584.ptr) != 0)
    {
        return 151L;
    }
    if (ac_streq(m, cast(long)__s23588.ptr) != 0)
    {
        return 147L;
    }
    return (-1L);
}
long ac_xmm(long p1 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long s = p1;
    if (ac_streq(s, cast(long)__s23596.ptr) != 0)
    {
        return 0L;
    }
    if (ac_streq(s, cast(long)__s23600.ptr) != 0)
    {
        return 1L;
    }
    if (ac_streq(s, cast(long)__s23604.ptr) != 0)
    {
        return 2L;
    }
    return (-1L);
}
long ac_isxmm(long p1 = 0)
{
    long v0 = 0;
    long s = p1;
    return cast(long)(ac_xmm(s) >= 0L);
}
long ac_sdop(long p1 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long m = p1;
    if (ac_streq(m, cast(long)__s23618.ptr) != 0)
    {
        return 88L;
    }
    if (ac_streq(m, cast(long)__s23622.ptr) != 0)
    {
        return 92L;
    }
    if (ac_streq(m, cast(long)__s23626.ptr) != 0)
    {
        return 89L;
    }
    return 94L;
}
long ac_cc_from(long p1 = 0, long p2 = 0)
{
    long n = 0;
    long[5] __v23640;
    long v0 = 0;
    long c = 0;
    long i = 0;
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
    long m = p1;
    long from = p2;
    n = ((cast(long)*cast(ubyte*)(m + 0L) - from) + 1L);
    v0 = cast(long)__v23640.ptr;
    c = v0;
    if (n < 1L) goto L5384; else goto L5386;
L5386:
    if (n > 3L) goto L5384; else goto L5385;
L5384:
    return (-1L);
L5385:
    i = 1L;
    while (i <= n)
    {
        *cast(ubyte*)(c + i) = cast(ubyte)cast(long)*cast(ubyte*)(m + ((from + i) - 1L));
        i = (i + 1L);
    }
    *cast(ubyte*)(c + 0L) = cast(ubyte)n;
    if (ac_streq(c, cast(long)__s23661.ptr) != 0)
    {
        return 0L;
    }
    if (ac_streq(c, cast(long)__s23665.ptr) != 0)
    {
        return 1L;
    }
    if (ac_streq(c, cast(long)__s23669.ptr) != 0) goto L5395; else goto L5398;
L5398:
    if (ac_streq(c, cast(long)__s23672.ptr) != 0) goto L5395; else goto L5397;
L5397:
    if (ac_streq(c, cast(long)__s23675.ptr) != 0) goto L5395; else goto L5396;
L5395:
    return 2L;
L5396:
    if (ac_streq(c, cast(long)__s23679.ptr) != 0) goto L5399; else goto L5402;
L5402:
    if (ac_streq(c, cast(long)__s23682.ptr) != 0) goto L5399; else goto L5401;
L5401:
    if (ac_streq(c, cast(long)__s23685.ptr) != 0) goto L5399; else goto L5400;
L5399:
    return 3L;
L5400:
    if (ac_streq(c, cast(long)__s23689.ptr) != 0) goto L5403; else goto L5405;
L5405:
    if (ac_streq(c, cast(long)__s23692.ptr) != 0) goto L5403; else goto L5404;
L5403:
    return 4L;
L5404:
    if (ac_streq(c, cast(long)__s23696.ptr) != 0) goto L5406; else goto L5408;
L5408:
    if (ac_streq(c, cast(long)__s23699.ptr) != 0) goto L5406; else goto L5407;
L5406:
    return 5L;
L5407:
    if (ac_streq(c, cast(long)__s23703.ptr) != 0) goto L5409; else goto L5411;
L5411:
    if (ac_streq(c, cast(long)__s23706.ptr) != 0) goto L5409; else goto L5410;
L5409:
    return 6L;
L5410:
    if (ac_streq(c, cast(long)__s23710.ptr) != 0) goto L5412; else goto L5414;
L5414:
    if (ac_streq(c, cast(long)__s23713.ptr) != 0) goto L5412; else goto L5413;
L5412:
    return 7L;
L5413:
    if (ac_streq(c, cast(long)__s23717.ptr) != 0)
    {
        return 8L;
    }
    if (ac_streq(c, cast(long)__s23721.ptr) != 0)
    {
        return 9L;
    }
    if (ac_streq(c, cast(long)__s23725.ptr) != 0) goto L5419; else goto L5421;
L5421:
    if (ac_streq(c, cast(long)__s23728.ptr) != 0) goto L5419; else goto L5420;
L5419:
    return 10L;
L5420:
    if (ac_streq(c, cast(long)__s23732.ptr) != 0) goto L5422; else goto L5424;
L5424:
    if (ac_streq(c, cast(long)__s23735.ptr) != 0) goto L5422; else goto L5423;
L5422:
    return 11L;
L5423:
    if (ac_streq(c, cast(long)__s23739.ptr) != 0) goto L5425; else goto L5427;
L5427:
    if (ac_streq(c, cast(long)__s23742.ptr) != 0) goto L5425; else goto L5426;
L5425:
    return 12L;
L5426:
    if (ac_streq(c, cast(long)__s23746.ptr) != 0) goto L5428; else goto L5430;
L5430:
    if (ac_streq(c, cast(long)__s23749.ptr) != 0) goto L5428; else goto L5429;
L5428:
    return 13L;
L5429:
    if (ac_streq(c, cast(long)__s23753.ptr) != 0) goto L5431; else goto L5433;
L5433:
    if (ac_streq(c, cast(long)__s23756.ptr) != 0) goto L5431; else goto L5432;
L5431:
    return 14L;
L5432:
    if (ac_streq(c, cast(long)__s23760.ptr) != 0) goto L5434; else goto L5436;
L5436:
    if (ac_streq(c, cast(long)__s23763.ptr) != 0) goto L5434; else goto L5435;
L5434:
    return 15L;
L5435:
    return (-1L);
}
long ac_has_pfx(long p1 = 0, long p2 = 0)
{
    long n = 0;
    long i = 0;
    long m = p1;
    long p = p2;
    n = cast(long)*cast(ubyte*)(p + 0L);
    if (cast(long)*cast(ubyte*)(m + 0L) < n)
    {
        return 0L;
    }
    i = 1L;
    while (i <= n)
    {
        if (cast(long)*cast(ubyte*)(m + i) != cast(long)*cast(ubyte*)(p + i))
        {
            return 0L;
        }
        i = (i + 1L);
    }
    return 1L;
}
long ac_alu_op(long p1 = 0)
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
    long m = p1;
    if (ac_streq(m, cast(long)__s23794.ptr) != 0)
    {
        return 3L;
    }
    if (ac_streq(m, cast(long)__s23798.ptr) != 0)
    {
        return 43L;
    }
    if (ac_streq(m, cast(long)__s23802.ptr) != 0)
    {
        return 35L;
    }
    if (ac_streq(m, cast(long)__s23806.ptr) != 0)
    {
        return 11L;
    }
    if (ac_streq(m, cast(long)__s23810.ptr) != 0)
    {
        return 51L;
    }
    if (ac_streq(m, cast(long)__s23814.ptr) != 0)
    {
        return 59L;
    }
    return (-1L);
}
long ac_alu_pri(long p1 = 0)
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
    long m = p1;
    if (ac_streq(m, cast(long)__s23822.ptr) != 0)
    {
        return 1L;
    }
    if (ac_streq(m, cast(long)__s23826.ptr) != 0)
    {
        return 41L;
    }
    if (ac_streq(m, cast(long)__s23830.ptr) != 0)
    {
        return 33L;
    }
    if (ac_streq(m, cast(long)__s23834.ptr) != 0)
    {
        return 9L;
    }
    if (ac_streq(m, cast(long)__s23838.ptr) != 0)
    {
        return 49L;
    }
    return 57L;
}
long ac_alu_sub(long p1 = 0)
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
    long m = p1;
    if (ac_streq(m, cast(long)__s23845.ptr) != 0)
    {
        return 0L;
    }
    if (ac_streq(m, cast(long)__s23849.ptr) != 0)
    {
        return 1L;
    }
    if (ac_streq(m, cast(long)__s23853.ptr) != 0)
    {
        return 4L;
    }
    if (ac_streq(m, cast(long)__s23857.ptr) != 0)
    {
        return 5L;
    }
    if (ac_streq(m, cast(long)__s23861.ptr) != 0)
    {
        return 6L;
    }
    return 7L;
}
long ac_do_insn()
{
    long m = 0;
    long v0 = 0;
    long setc = 0;
    long v1 = 0;
    long alu = 0;
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
    long v72 = 0;
    long v73 = 0;
    long v74 = 0;
    long v75 = 0;
    long v76 = 0;
    long v77 = 0;
    long v78 = 0;
    long v79 = 0;
    long v80 = 0;
    long v81 = 0;
    long v82 = 0;
    long v83 = 0;
    long v84 = 0;
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
    long dr = 0;
    long v101 = 0;
    long v102 = 0;
    long v103 = 0;
    long v104 = 0;
    long v105 = 0;
    long v106 = 0;
    long v107 = 0;
    long v108 = 0;
    long v109 = 0;
    long v110 = 0;
    long t1 = 0;
    long v111 = 0;
    long v112 = 0;
    long v113 = 0;
    long v114 = 0;
    long v115 = 0;
    long v116 = 0;
    long v117 = 0;
    long v118 = 0;
    long v119 = 0;
    long v120 = 0;
    long v121 = 0;
    long v122 = 0;
    long v123 = 0;
    long v124 = 0;
    long v125 = 0;
    long v126 = 0;
    long v127 = 0;
    long v128 = 0;
    long v129 = 0;
    long v130 = 0;
    long v131 = 0;
    long v132 = 0;
    long v133 = 0;
    long v134 = 0;
    long src = 0;
    long v135 = 0;
    long v136 = 0;
    long v137 = 0;
    long v138 = 0;
    long v139 = 0;
    long v140 = 0;
    long v141 = 0;
    long v142 = 0;
    long v143 = 0;
    long v144 = 0;
    long v145 = 0;
    long v146 = 0;
    long v147 = 0;
    long v148 = 0;
    long v149 = 0;
    long v150 = 0;
    long v151 = 0;
    long v152 = 0;
    long v153 = 0;
    long v154 = 0;
    long src_2 = 0;
    long v155 = 0;
    long v156 = 0;
    long v157 = 0;
    long v158 = 0;
    long v159 = 0;
    long dr_2 = 0;
    long v160 = 0;
    long v161 = 0;
    long v162 = 0;
    long v163 = 0;
    long v164 = 0;
    long v165 = 0;
    long v166 = 0;
    long sr = 0;
    long v167 = 0;
    long v168 = 0;
    long v169 = 0;
    long v170 = 0;
    long v171 = 0;
    long v172 = 0;
    long v173 = 0;
    long v174 = 0;
    long v175 = 0;
    long v176 = 0;
    long v177 = 0;
    long v178 = 0;
    long v179 = 0;
    long v180 = 0;
    long v181 = 0;
    long v182 = 0;
    long v183 = 0;
    long v184 = 0;
    long k = 0;
    long v185 = 0;
    long v186 = 0;
    long v187 = 0;
    long v188 = 0;
    long v189 = 0;
    long v190 = 0;
    long v191 = 0;
    long nm = 0;
    long fd = 0;
    long buf = 0;
    long n = 0;
    long v192 = 0;
    long s = 0;
    long k_2 = 0;
    long i = 0;
    long v193 = 0;
    long v194 = 0;
    long v195 = 0;
    long v196 = 0;
    long v197 = 0;
    long v198 = 0;
    long i_2 = 0;
    long v199 = 0;
    long v200 = 0;
    long v201 = 0;
    long v202 = 0;
    long dr_3 = 0;
    long v203 = 0;
    long v204 = 0;
    long v205 = 0;
    long v206 = 0;
    long v207 = 0;
    long v208 = 0;
    long v209 = 0;
    long v210 = 0;
    long v211 = 0;
    long v212 = 0;
    long v213 = 0;
    long v214 = 0;
    long v215 = 0;
    long v216 = 0;
    long v217 = 0;
    long v218 = 0;
    long v219 = 0;
    long r = 0;
    long v220 = 0;
    long imm = 0;
    long v221 = 0;
    long sub = 0;
    long v222 = 0;
    long v223 = 0;
    long v224 = 0;
    long v225 = 0;
    long v226 = 0;
    long v227 = 0;
    long v228 = 0;
    long v229 = 0;
    long v230 = 0;
    long dr_4 = 0;
    long v231 = 0;
    long sr_2 = 0;
    long v232 = 0;
    long v233 = 0;
    long v234 = 0;
    long v235 = 0;
    long v236 = 0;
    long v237 = 0;
    long v238 = 0;
    long v239 = 0;
    long v240 = 0;
    long r_2 = 0;
    long v241 = 0;
    long v242 = 0;
    long v243 = 0;
    long v244 = 0;
    long v245 = 0;
    long v246 = 0;
    long v247 = 0;
    long v248 = 0;
    long v249 = 0;
    long v250 = 0;
    long dr_5 = 0;
    long v251 = 0;
    long sr_3 = 0;
    long v252 = 0;
    long v253 = 0;
    long v254 = 0;
    long v255 = 0;
    long v256 = 0;
    long v257 = 0;
    long v258 = 0;
    long v259 = 0;
    long v260 = 0;
    long v261 = 0;
    long r_3 = 0;
    long v262 = 0;
    long v263 = 0;
    long v264 = 0;
    long v265 = 0;
    long v266 = 0;
    long v267 = 0;
    long j = 0;
    long v268 = 0;
    long v269 = 0;
    long v270 = 0;
    long v271 = 0;
    long v272 = 0;
    long v273 = 0;
    long r_4 = 0;
    long v274 = 0;
    long v275 = 0;
    long v276 = 0;
    long v277 = 0;
    long v278 = 0;
    long v279 = 0;
    long v280 = 0;
    long v281 = 0;
    long v282 = 0;
    long v283 = 0;
    long v284 = 0;
    long v285 = 0;
    long v286 = 0;
    long v287 = 0;
    long r_5 = 0;
    long v288 = 0;
    long v289 = 0;
    long v290 = 0;
    long v291 = 0;
    long v292 = 0;
    long v293 = 0;
    long v294 = 0;
    long v295 = 0;
    long v296 = 0;
    long v297 = 0;
    long v298 = 0;
    long v299 = 0;
    long v300 = 0;
    long v301 = 0;
    long r_6 = 0;
    long v302 = 0;
    long v303 = 0;
    long v304 = 0;
    long v305 = 0;
    long v306 = 0;
    long v307 = 0;
    long v308 = 0;
    long v309 = 0;
    long v310 = 0;
    long v311 = 0;
    long v312 = 0;
    long v313 = 0;
    long v314 = 0;
    long v315 = 0;
    long r_7 = 0;
    long v316 = 0;
    long v317 = 0;
    long v318 = 0;
    long v319 = 0;
    long v320 = 0;
    long v321 = 0;
    long v322 = 0;
    long r_8 = 0;
    long v323 = 0;
    long v324 = 0;
    long v325 = 0;
    long v326 = 0;
    long v327 = 0;
    long v328 = 0;
    long v329 = 0;
    long r_9 = 0;
    long v330 = 0;
    long v331 = 0;
    long v332 = 0;
    long v333 = 0;
    long v334 = 0;
    long v335 = 0;
    long v336 = 0;
    long r_10 = 0;
    long v337 = 0;
    long v338 = 0;
    long v339 = 0;
    long v340 = 0;
    long v341 = 0;
    long v342 = 0;
    long v343 = 0;
    long ra = 0;
    long v344 = 0;
    long rb = 0;
    long v345 = 0;
    long v346 = 0;
    long v347 = 0;
    long v348 = 0;
    long v349 = 0;
    long v350 = 0;
    long v351 = 0;
    long v352 = 0;
    long dr_6 = 0;
    long v353 = 0;
    long v354 = 0;
    long v355 = 0;
    long v356 = 0;
    long v357 = 0;
    long v358 = 0;
    long v359 = 0;
    long v360 = 0;
    long v361 = 0;
    long v362 = 0;
    long v363 = 0;
    long v364 = 0;
    long v365 = 0;
    long v366 = 0;
    long v367 = 0;
    long dr_7 = 0;
    long v368 = 0;
    long v369 = 0;
    long v370 = 0;
    long v371 = 0;
    long v372 = 0;
    long v373 = 0;
    long v374 = 0;
    long v375 = 0;
    long dr_8 = 0;
    long v376 = 0;
    long v377 = 0;
    long v378 = 0;
    long v379 = 0;
    long v380 = 0;
    long v381 = 0;
    long v382 = 0;
    long v383 = 0;
    long v384 = 0;
    long v385 = 0;
    long v386 = 0;
    long r_11 = 0;
    long v387 = 0;
    long v388 = 0;
    long v389 = 0;
    long v390 = 0;
    long v391 = 0;
    long v392 = 0;
    long v393 = 0;
    long v394 = 0;
    long v395 = 0;
    long v396 = 0;
    long v397 = 0;
    long v398 = 0;
    long v399 = 0;
    long v400 = 0;
    long v401 = 0;
    long v402 = 0;
    long v403 = 0;
    long v404 = 0;
    long v405 = 0;
    long v406 = 0;
    long v407 = 0;
    long v408 = 0;
    long v409 = 0;
    long v410 = 0;
    long v411 = 0;
    long v412 = 0;
    long v413 = 0;
    long v414 = 0;
    long v415 = 0;
    long v416 = 0;
    long v417 = 0;
    long v418 = 0;
    long v419 = 0;
    long v420 = 0;
    long v421 = 0;
    long v422 = 0;
    long v423 = 0;
    long v424 = 0;
    long v425 = 0;
    long v426 = 0;
    long v427 = 0;
    long v428 = 0;
    long v429 = 0;
    long v430 = 0;
    long v431 = 0;
    long v432 = 0;
    long cc = 0;
    long v433 = 0;
    long v434 = 0;
    long v435 = 0;
    long v436 = 0;
    long dr_9 = 0;
    long v437 = 0;
    long sr_4 = 0;
    long v438 = 0;
    long v439 = 0;
    long v440 = 0;
    long v441 = 0;
    long v442 = 0;
    long v443 = 0;
    long v444 = 0;
    long v445 = 0;
    long v446 = 0;
    long v447 = 0;
    long r_12 = 0;
    long v448 = 0;
    long v449 = 0;
    long v450 = 0;
    long v451 = 0;
    long v452 = 0;
    long v453 = 0;
    long v454 = 0;
    long v455 = 0;
    long v456 = 0;
    long v457 = 0;
    long v458 = 0;
    long v459 = 0;
    long v460 = 0;
    long v461 = 0;
    long v462 = 0;
    long v463 = 0;
    long v464 = 0;
    long v465 = 0;
    long v466 = 0;
    long v467 = 0;
    long v468 = 0;
    long v469 = 0;
    long v470 = 0;
    long v471 = 0;
    long v472 = 0;
    long v473 = 0;
    long v474 = 0;
    long v475 = 0;
    long v476 = 0;
    long v477 = 0;
    long v478 = 0;
    long v479 = 0;
    long v480 = 0;
    long v481 = 0;
    long v482 = 0;
    long v483 = 0;
    long v484 = 0;
    long v485 = 0;
    long v486 = 0;
    long v487 = 0;
    long v488 = 0;
    long v489 = 0;
    long v490 = 0;
    long v491 = 0;
    long v492 = 0;
    long v493 = 0;
    long v494 = 0;
    long v495 = 0;
    long v496 = 0;
    long v497 = 0;
    long v498 = 0;
    long v499 = 0;
    long v500 = 0;
    long v501 = 0;
    long v502 = 0;
    long v503 = 0;
    long v504 = 0;
    long v505 = 0;
    long v506 = 0;
    long v507 = 0;
    long v508 = 0;
    long v509 = 0;
    long v510 = 0;
    long v511 = 0;
    long v512 = 0;
    long v513 = 0;
    long v514 = 0;
    long v515 = 0;
    long v516 = 0;
    long v517 = 0;
    long v518 = 0;
    long v519 = 0;
    long r_13 = 0;
    long v520 = 0;
    long v521 = 0;
    long v522 = 0;
    long v523 = 0;
    long v524 = 0;
    long v525 = 0;
    long v526 = 0;
    long r_14 = 0;
    long v527 = 0;
    long v528 = 0;
    long v529 = 0;
    long v530 = 0;
    long v531 = 0;
    long v532 = 0;
    long v533 = 0;
    long r_15 = 0;
    long v534 = 0;
    long v535 = 0;
    long v536 = 0;
    long v537 = 0;
    long v538 = 0;
    long v539 = 0;
    long v540 = 0;
    long dr_10 = 0;
    long v541 = 0;
    long sr_5 = 0;
    long v542 = 0;
    long v543 = 0;
    long v544 = 0;
    long v545 = 0;
    long v546 = 0;
    long v547 = 0;
    long v548 = 0;
    long v549 = 0;
    long v550 = 0;
    long v551 = 0;
    long dr_11 = 0;
    long v552 = 0;
    long sr_6 = 0;
    long v553 = 0;
    long v554 = 0;
    long v555 = 0;
    long op = 0;
    long v556 = 0;
    long v557 = 0;
    long v558 = 0;
    long v559 = 0;
    long v560 = 0;
    long cc_2 = 0;
    long v561 = 0;
    long v562 = 0;
    long v563 = 0;
    long v564 = 0;
    long v565 = 0;
    long v566 = 0;
    long v567 = 0;
    long v568 = 0;
    long v569 = 0;
    long v570 = 0;
    long v571 = 0;
    long v572 = 0;
    long v573 = 0;
    long v574 = 0;
    long v575 = 0;
    long v576 = 0;
    long v577 = 0;
    long v578 = 0;
    long v579 = 0;
    long v580 = 0;
    long v581 = 0;
    long v582 = 0;
    long v583 = 0;
    long v584 = 0;
    long v585 = 0;
    long v586 = 0;
    long v587 = 0;
    long v588 = 0;
    long v589 = 0;
    long dr_12 = 0;
    long v590 = 0;
    long sr_7 = 0;
    long v591 = 0;
    long v592 = 0;
    long v593 = 0;
    long v594 = 0;
    long v595 = 0;
    long v596 = 0;
    long v597 = 0;
    long v598 = 0;
    long v599 = 0;
    long v600 = 0;
    long v601 = 0;
    long v602 = 0;
    long v603 = 0;
    long v604 = 0;
    long v605 = 0;
    long v606 = 0;
    long v607 = 0;
    long v608 = 0;
    long v609 = 0;
    long v610 = 0;
    long v611 = 0;
    long v612 = 0;
    long v613 = 0;
    long s_2 = 0;
    long v614 = 0;
    long v615 = 0;
    long v616 = 0;
    long v617 = 0;
    long v618 = 0;
    long v619 = 0;
    long v620 = 0;
    long v621 = 0;
    long v622 = 0;
    long v623 = 0;
    long v624 = 0;
    long v625 = 0;
    long v626 = 0;
    long v627 = 0;
    long v628 = 0;
    long v629 = 0;
    long v630 = 0;
    long v631 = 0;
    long v632 = 0;
    long v633 = 0;
    long v634 = 0;
    long v635 = 0;
    long v636 = 0;
    long v637 = 0;
    long v638 = 0;
    long v639 = 0;
    long v640 = 0;
    long v641 = 0;
    long v642 = 0;
    long v643 = 0;
    long v644 = 0;
    long v645 = 0;
    long v646 = 0;
    long v647 = 0;
    long v648 = 0;
    long v649 = 0;
    long v650 = 0;
    long v651 = 0;
    long v652 = 0;
    long v653 = 0;
    long v654 = 0;
    long v655 = 0;
    long v656 = 0;
    long v657 = 0;
    long v658 = 0;
    long v659 = 0;
    long v660 = 0;
    long v661 = 0;
    long v662 = 0;
    m = *cast(long*)(ac_tok + (0L << 3L));
    setc = ac_setcc_op(m);
    alu = ac_alu_op(m);
    if (ac_streq(m, cast(long)__s23880.ptr) != 0)
    {
        v5 = ac_b((80L + (ac_reg(*cast(long*)(ac_tok + (1L << 3L))) & 7L)));
        return 0;
    }
    if (ac_streq(m, cast(long)__s23897.ptr) != 0)
    {
        v9 = ac_b((88L + (ac_reg(*cast(long*)(ac_tok + (1L << 3L))) & 7L)));
        return 0;
    }
    if (ac_streq(m, cast(long)__s23914.ptr) != 0)
    {
        v12 = ac_b(201L);
        return 0;
    }
    if (ac_streq(m, cast(long)__s23920.ptr) != 0)
    {
        v15 = ac_b(195L);
        return 0;
    }
    if (ac_streq(m, cast(long)__s23926.ptr) != 0)
    {
        v18 = ac_b(15L);
        v19 = ac_b(5L);
        return 0;
    }
    if (ac_streq(m, cast(long)__s23935.ptr) != 0)
    {
        v22 = ac_b(72L);
        v23 = ac_b(153L);
        return 0;
    }
    if (ac_streq(m, cast(long)__s23944.ptr) != 0)
    {
        if (ac_streq(*cast(long*)(ac_tok + (1L << 3L)), cast(long)__s23953.ptr) != 0)
        {
            v28 = ac_b(243L);
            v29 = ac_b(72L);
            v30 = ac_b(171L);
            return 0;
        }
    }
    if (ac_streq(m, cast(long)__s23965.ptr) != 0)
    {
        if (ac_isxmm(*cast(long*)(ac_tok + (1L << 3L))) != 0)
        {
            v34 = ac_b(102L);
            v35 = ac_b(72L);
            v36 = ac_b(15L);
            v37 = ac_b(110L);
            v40 = ac_b(((192L | (ac_xmm(*cast(long*)(ac_tok + (1L << 3L))) << 3L)) | ac_reg(*cast(long*)(ac_tok + (2L << 3L)))));
            return 0;
        }
        else
        {
            v41 = ac_b(102L);
            v42 = ac_b(72L);
            v43 = ac_b(15L);
            v44 = ac_b(126L);
            v47 = ac_b(((192L | (ac_xmm(*cast(long*)(ac_tok + (2L << 3L))) << 3L)) | ac_reg(*cast(long*)(ac_tok + (1L << 3L)))));
            return 0;
        }
    }
    if (ac_streq(m, cast(long)__s24046.ptr) != 0) goto L5498; else goto L5502;
L5502:
    if (ac_streq(m, cast(long)__s24049.ptr) != 0) goto L5498; else goto L5501;
L5501:
    if (ac_streq(m, cast(long)__s24052.ptr) != 0) goto L5498; else goto L5500;
L5500:
    if (ac_streq(m, cast(long)__s24055.ptr) != 0) goto L5498; else goto L5499;
L5498:
    v56 = ac_b(242L);
    v57 = ac_b(15L);
    v59 = ac_b(ac_sdop(m));
    v62 = ac_b(((192L | (ac_xmm(*cast(long*)(ac_tok + (1L << 3L))) << 3L)) | ac_xmm(*cast(long*)(ac_tok + (2L << 3L)))));
    return 0;
L5499:
    if (ac_streq(m, cast(long)__s24091.ptr) != 0)
    {
        v65 = ac_b(102L);
        v66 = ac_b(15L);
        v67 = ac_b(47L);
        v70 = ac_b(((192L | (ac_xmm(*cast(long*)(ac_tok + (1L << 3L))) << 3L)) | ac_xmm(*cast(long*)(ac_tok + (2L << 3L)))));
        return 0;
    }
    if (ac_streq(m, cast(long)__s24126.ptr) != 0)
    {
        v73 = ac_b(242L);
        v74 = ac_b(72L);
        v75 = ac_b(15L);
        v76 = ac_b(42L);
        v79 = ac_b(((192L | (ac_xmm(*cast(long*)(ac_tok + (1L << 3L))) << 3L)) | ac_reg(*cast(long*)(ac_tok + (2L << 3L)))));
        return 0;
    }
    if (ac_streq(m, cast(long)__s24164.ptr) != 0)
    {
        v82 = ac_b(242L);
        v83 = ac_b(72L);
        v84 = ac_b(15L);
        v85 = ac_b(44L);
        v88 = ac_b(((192L | (ac_reg(*cast(long*)(ac_tok + (1L << 3L))) << 3L)) | ac_xmm(*cast(long*)(ac_tok + (2L << 3L)))));
        return 0;
    }
    if (ac_streq(m, cast(long)__s24202.ptr) != 0)
    {
        if (ac_streq(*cast(long*)(ac_tok + (1L << 3L)), cast(long)__s24211.ptr) != 0) goto L5509; else goto L5510;
L5509:
        v93 = ac_b(72L);
        v94 = ac_b(129L);
        v95 = ac_b(236L);
        v97 = ac_w32(ac_num(*cast(long*)(ac_tok + (2L << 3L))));
        return 0;
    }
L5510:
    if (ac_streq(m, cast(long)__s24233.ptr) != 0)
    {
        dr = ac_reg(*cast(long*)(ac_tok + (1L << 3L)));
        v102 = ac_b((72L | ac_rexb(dr)));
        v103 = ac_b((184L + (dr & 7L)));
        if (ac_isnum(*cast(long*)(ac_tok + (2L << 3L))) != 0)
        {
            v106 = ac_w64(ac_num(*cast(long*)(ac_tok + (2L << 3L))));
        }
        else
        {
            v107 = ac_areloc(*cast(long*)(ac_tok + (2L << 3L)));
            v108 = ac_w64(0L);
        }
        return 0;
    }
    if (ac_streq(m, cast(long)__s24286.ptr) != 0)
    {
        t1 = *cast(long*)(ac_tok + (1L << 3L));
        if (ac_streq(t1, cast(long)__s24296.ptr) != 0) goto L5519; else goto L5521;
L5521:
        if (ac_streq(t1, cast(long)__s24299.ptr) != 0) goto L5519; else goto L5520;
L5519:
        if (ac_isnum(*cast(long*)(ac_tok + (ac_after_mem(2L) << 3L))) != 0)
        {
            if (ac_streq(t1, cast(long)__s24312.ptr) != 0)
            {
                v119 = ac_b(72L);
            }
            v120 = ac_b(199L);
            v121 = ac_mem_operand(0L, 2L);
            v124 = ac_w32(ac_num(*cast(long*)(ac_tok + (ac_after_mem(2L) << 3L))));
            return 0;
        }
L5520:
        if (ac_streq(t1, cast(long)__s24337.ptr) != 0) goto L5526; else goto L5531;
L5531:
        if (ac_streq(t1, cast(long)__s24340.ptr) != 0) goto L5526; else goto L5530;
L5530:
        if (ac_streq(t1, cast(long)__s24343.ptr) != 0) goto L5526; else goto L5529;
L5529:
        if (ac_streq(t1, cast(long)__s24346.ptr) != 0) goto L5526; else goto L5527;
L5526:
        src = ac_reg(*cast(long*)(ac_tok + (ac_after_mem(2L) << 3L)));
        if (ac_streq(t1, cast(long)__s24360.ptr) != 0)
        {
            v137 = ac_b(136L);
            v138 = ac_mem_operand(src, 2L);
            return 0;
        }
        if (ac_streq(t1, cast(long)__s24369.ptr) != 0)
        {
            v141 = ac_b(102L);
            v142 = ac_b(137L);
            v143 = ac_mem_operand(src, 2L);
            return 0;
        }
        if (ac_streq(t1, cast(long)__s24381.ptr) != 0)
        {
            v146 = ac_b(137L);
            v147 = ac_mem_operand(src, 2L);
            return 0;
        }
        v149 = ac_b((72L | ac_rexr(src)));
        v150 = ac_b(137L);
        v151 = ac_mem_operand(src, 2L);
        return 0;
L5527:
        if (ac_tok_is_mem(1L) != 0)
        {
            src_2 = ac_reg(*cast(long*)(ac_tok + (ac_after_mem(1L) << 3L)));
            v156 = ac_b((72L | ac_rexr(src_2)));
            v157 = ac_b(137L);
            v158 = ac_mem_operand(src_2, 1L);
            return 0;
        }
        else
        {
            dr_2 = ac_reg(t1);
            if (ac_tok_is_mem(2L) != 0)
            {
                v162 = ac_b((72L | ac_rexr(dr_2)));
                v163 = ac_b(139L);
                v164 = ac_mem_operand(dr_2, 2L);
                return 0;
            }
            else
            {
                if (ac_reg(*cast(long*)(ac_tok + (2L << 3L))) >= 0L)
                {
                    sr = ac_reg(*cast(long*)(ac_tok + (2L << 3L)));
                    v169 = ac_b(((72L | ac_rexr(sr)) | ac_rexb(dr_2)));
                    v170 = ac_b(137L);
                    v171 = ac_b(((192L | ((sr & 7L) << 3L)) | (dr_2 & 7L)));
                    return 0;
                }
                else
                {
                    if (ac_isnum(*cast(long*)(ac_tok + (2L << 3L))) != 0)
                    {
                        v174 = ac_b((72L | ac_rexb(dr_2)));
                        v175 = ac_b((184L + (dr_2 & 7L)));
                        v177 = ac_w64(ac_num(*cast(long*)(ac_tok + (2L << 3L))));
                        return 0;
                    }
                    else
                    {
                        v179 = ac_b((72L | ac_rexb(dr_2)));
                        v180 = ac_b((184L + (dr_2 & 7L)));
                        v181 = ac_areloc(*cast(long*)(ac_tok + (2L << 3L)));
                        v182 = ac_w64(0L);
                        return 0;
                    }
                }
            }
        }
L5528:
    }
    if (ac_streq(m, cast(long)__s24541.ptr) != 0)
    {
        k = 1L;
        while (k <= (ac_ntok - 1L))
        {
            v186 = ac_b(ac_num(*cast(long*)(ac_tok + (k << 3L))));
            k = (k + 1L);
        }
        return 0;
    }
    if (ac_streq(m, cast(long)__s24560.ptr) != 0)
    {
        ac_bsslen = (ac_bsslen + ac_num(*cast(long*)(ac_tok + (1L << 3L))));
        return 0;
    }
    if (ac_streq(m, cast(long)__s24573.ptr) != 0)
    {
        nm = *cast(long*)(ac_tok + (1L << 3L));
        fd = 0L;
        buf = 0L;
        n = 0L;
        if (cast(long)*cast(ubyte*)(nm + 0L) >= 2L)
        {
            if (cast(long)*cast(ubyte*)(nm + 1L) == 34L) goto L5560; else goto L5561;
L5560:
            s = getvec(((cast(long)*cast(ubyte*)(nm + 0L) / 8L) + 2L));
            k_2 = 0L;
            i = 2L;
            while (i <= (cast(long)*cast(ubyte*)(nm + 0L) - 1L))
            {
                k_2 = (k_2 + 1L);
                *cast(ubyte*)(s + k_2) = cast(ubyte)cast(long)*cast(ubyte*)(nm + i);
                i = (i + 1L);
            }
            *cast(ubyte*)(s + 0L) = cast(ubyte)k_2;
            nm = s;
        }
L5561:
        fd = findinput(nm);
        if (fd <= 0L)
        {
            v195 = writef(cast(long)__s24631.ptr, nm);
            ac_errs = (ac_errs + 1L);
            return 0;
        }
        buf = getvec((1L << 20L));
        n = __read(fd, buf, (1L << 23L));
        v198 = __close(fd);
        if (n < 0L)
        {
            n = 0L;
        }
        i_2 = 0L;
        while (i_2 <= (n - 1L))
        {
            v199 = ac_b(cast(long)*cast(ubyte*)(buf + i_2));
            i_2 = (i_2 + 1L);
        }
        return 0;
    }
    if (ac_streq(m, cast(long)__s24662.ptr) != 0)
    {
        dr_3 = ac_reg(*cast(long*)(ac_tok + (1L << 3L)));
        v205 = ac_b(((72L | ac_rexr(dr_3)) | ac_mem_rexb(2L)));
        v206 = ac_b(141L);
        if (ac_streq(*cast(long*)(ac_tok + (2L << 3L)), cast(long)__s24693.ptr) != 0)
        {
            if (ac_streq(*cast(long*)(ac_tok + (3L << 3L)), cast(long)__s24702.ptr) != 0) goto L5577; else goto L5578;
L5577:
            v211 = ac_b((5L | ((dr_3 & 7L) << 3L)));
            v212 = ac_fixup(*cast(long*)(ac_tok + (4L << 3L)));
    goto L5579;
        }
L5578:
        v213 = ac_mem_operand(dr_3, 2L);
L5579:
        return 0;
    }
    if (alu >= 0L)
    {
        if (ac_tok_is_mem(2L) != 0)
        {
            v215 = ac_b(72L);
            v216 = ac_b(alu);
            v217 = ac_mem_operand(0L, 2L);
            return 0;
        }
        else
        {
            if (ac_isnum(*cast(long*)(ac_tok + (2L << 3L))) != 0)
            {
                r = ac_reg(*cast(long*)(ac_tok + (1L << 3L)));
                imm = ac_num(*cast(long*)(ac_tok + (2L << 3L)));
                sub = ac_alu_sub(m);
                if (imm >= (-128L))
                {
                    if (imm <= 127L) goto L5589; else goto L5590;
L5589:
                    v222 = ac_b(72L);
                    v223 = ac_b(131L);
                    v224 = ac_b(((192L | (sub << 3L)) | (r & 7L)));
                    v225 = ac_b((imm & 255L));
    goto L5591;
                }
L5590:
                v226 = ac_b(72L);
                v227 = ac_b(129L);
                v228 = ac_b(((192L | (sub << 3L)) | (r & 7L)));
                v229 = ac_w32(imm);
L5591:
                return 0;
            }
            else
            {
                dr_4 = ac_reg(*cast(long*)(ac_tok + (1L << 3L)));
                sr_2 = ac_reg(*cast(long*)(ac_tok + (2L << 3L)));
                v234 = ac_b(((72L | ac_rexr(sr_2)) | ac_rexb(dr_4)));
                v236 = ac_b(ac_alu_pri(m));
                v237 = ac_b(((192L | ((sr_2 & 7L) << 3L)) | (dr_4 & 7L)));
                return 0;
            }
        }
    }
    if (ac_streq(m, cast(long)__s24850.ptr) != 0)
    {
        if (ac_ntok == 2L)
        {
            r_2 = ac_reg(*cast(long*)(ac_tok + (1L << 3L)));
            v242 = ac_b((72L | ac_rexb(r_2)));
            v243 = ac_b(247L);
            v244 = ac_b((232L | (r_2 & 7L)));
            return 0;
        }
        else
        {
            if (ac_tok_is_mem(2L) != 0)
            {
                v246 = ac_b(72L);
                v247 = ac_b(15L);
                v248 = ac_b(175L);
                v249 = ac_mem_operand(0L, 2L);
                return 0;
            }
            else
            {
                dr_5 = ac_reg(*cast(long*)(ac_tok + (1L << 3L)));
                sr_3 = ac_reg(*cast(long*)(ac_tok + (2L << 3L)));
                v254 = ac_b(((72L | ac_rexr(dr_5)) | ac_rexb(sr_3)));
                v255 = ac_b(15L);
                v256 = ac_b(175L);
                v257 = ac_b(((192L | ((dr_5 & 7L) << 3L)) | (sr_3 & 7L)));
                return 0;
            }
        }
    }
    if (ac_streq(m, cast(long)__s24940.ptr) != 0)
    {
        if (ac_reg(*cast(long*)(ac_tok + (1L << 3L))) >= 0L)
        {
            r_3 = ac_reg(*cast(long*)(ac_tok + (1L << 3L)));
            v263 = ac_b((72L | ac_rexb(r_3)));
            v264 = ac_b(247L);
            v265 = ac_b((248L | (r_3 & 7L)));
            return 0;
        }
        else
        {
            if (ac_tok_is_mem(2L) != 0)
            {
                v267 = 2L;
            }
            else
            {
                v267 = 3L;
            }
            j = v267;
            v268 = ac_b(72L);
            v269 = ac_b(247L);
            v270 = ac_mem_operand(7L, j);
            return 0;
        }
    }
    if (ac_streq(m, cast(long)__s24993.ptr) != 0)
    {
        r_4 = ac_reg(*cast(long*)(ac_tok + (1L << 3L)));
        if (ac_isnum(*cast(long*)(ac_tok + (2L << 3L))) != 0)
        {
            v276 = ac_b((72L | ac_rexb(r_4)));
            v277 = ac_b(193L);
            v278 = ac_b((224L | (r_4 & 7L)));
            v280 = ac_b((ac_num(*cast(long*)(ac_tok + (2L << 3L))) & 255L));
        }
        else
        {
            v282 = ac_b((72L | ac_rexb(r_4)));
            v283 = ac_b(211L);
            v284 = ac_b((224L | (r_4 & 7L)));
        }
        return 0;
    }
    if (ac_streq(m, cast(long)__s25055.ptr) != 0)
    {
        r_5 = ac_reg(*cast(long*)(ac_tok + (1L << 3L)));
        if (ac_isnum(*cast(long*)(ac_tok + (2L << 3L))) != 0)
        {
            v290 = ac_b((72L | ac_rexb(r_5)));
            v291 = ac_b(193L);
            v292 = ac_b((248L | (r_5 & 7L)));
            v294 = ac_b((ac_num(*cast(long*)(ac_tok + (2L << 3L))) & 255L));
        }
        else
        {
            v296 = ac_b((72L | ac_rexb(r_5)));
            v297 = ac_b(211L);
            v298 = ac_b((248L | (r_5 & 7L)));
        }
        return 0;
    }
    if (ac_streq(m, cast(long)__s25117.ptr) != 0)
    {
        r_6 = ac_reg(*cast(long*)(ac_tok + (1L << 3L)));
        if (ac_isnum(*cast(long*)(ac_tok + (2L << 3L))) != 0)
        {
            v304 = ac_b((72L | ac_rexb(r_6)));
            v305 = ac_b(193L);
            v306 = ac_b((232L | (r_6 & 7L)));
            v308 = ac_b((ac_num(*cast(long*)(ac_tok + (2L << 3L))) & 255L));
        }
        else
        {
            v310 = ac_b((72L | ac_rexb(r_6)));
            v311 = ac_b(211L);
            v312 = ac_b((232L | (r_6 & 7L)));
        }
        return 0;
    }
    if (ac_streq(m, cast(long)__s25179.ptr) != 0)
    {
        r_7 = ac_reg(*cast(long*)(ac_tok + (1L << 3L)));
        v317 = ac_b((72L | ac_rexb(r_7)));
        v318 = ac_b(247L);
        v319 = ac_b((216L | (r_7 & 7L)));
        return 0;
    }
    if (ac_streq(m, cast(long)__s25206.ptr) != 0)
    {
        r_8 = ac_reg(*cast(long*)(ac_tok + (1L << 3L)));
        v324 = ac_b((72L | ac_rexb(r_8)));
        v325 = ac_b(247L);
        v326 = ac_b((208L | (r_8 & 7L)));
        return 0;
    }
    if (ac_streq(m, cast(long)__s25233.ptr) != 0)
    {
        r_9 = ac_reg(*cast(long*)(ac_tok + (1L << 3L)));
        v331 = ac_b((72L | ac_rexb(r_9)));
        v332 = ac_b(247L);
        v333 = ac_b((224L | (r_9 & 7L)));
        return 0;
    }
    if (ac_streq(m, cast(long)__s25260.ptr) != 0)
    {
        r_10 = ac_reg(*cast(long*)(ac_tok + (1L << 3L)));
        v338 = ac_b((72L | ac_rexb(r_10)));
        v339 = ac_b(247L);
        v340 = ac_b((240L | (r_10 & 7L)));
        return 0;
    }
    if (ac_streq(m, cast(long)__s25287.ptr) != 0)
    {
        ra = ac_reg(*cast(long*)(ac_tok + (1L << 3L)));
        rb = ac_reg(*cast(long*)(ac_tok + (2L << 3L)));
        v347 = ac_b(((72L | ac_rexr(rb)) | ac_rexb(ra)));
        v348 = ac_b(133L);
        v349 = ac_b(((192L | ((rb & 7L) << 3L)) | (ra & 7L)));
        return 0;
    }
    if (ac_streq(m, cast(long)__s25331.ptr) != 0)
    {
        dr_6 = ac_reg(*cast(long*)(ac_tok + (1L << 3L)));
        if (ac_streq(*cast(long*)(ac_tok + (2L << 3L)), cast(long)__s25349.ptr) != 0)
        {
            v356 = ac_b((72L | ac_rexr(dr_6)));
            v357 = ac_b(15L);
            v358 = ac_b(182L);
            v359 = ac_b((192L | ((dr_6 & 7L) << 3L)));
            return 0;
        }
        else
        {
            v361 = ac_b((72L | ac_rexr(dr_6)));
            v362 = ac_b(15L);
            v363 = ac_b(182L);
            v364 = ac_mem_operand(dr_6, 3L);
            return 0;
        }
    }
    if (ac_streq(m, cast(long)__s25387.ptr) != 0)
    {
        dr_7 = ac_reg(*cast(long*)(ac_tok + (1L << 3L)));
        v369 = ac_b((72L | ac_rexr(dr_7)));
        v370 = ac_b(15L);
        v371 = ac_b(191L);
        v372 = ac_mem_operand(dr_7, 3L);
        return 0;
    }
    if (ac_streq(m, cast(long)__s25414.ptr) != 0)
    {
        dr_8 = ac_reg(*cast(long*)(ac_tok + (1L << 3L)));
        v377 = ac_b((72L | ac_rexr(dr_8)));
        v378 = ac_b(99L);
        v379 = ac_mem_operand(dr_8, 3L);
        return 0;
    }
    if (ac_streq(m, cast(long)__s25438.ptr) != 0)
    {
        if (ac_tok_is_mem(1L) != 0)
        {
            v383 = ac_b(255L);
            v384 = ac_mem_operand(4L, 1L);
            return 0;
        }
        else
        {
            if (ac_reg(*cast(long*)(ac_tok + (1L << 3L))) >= 0L)
            {
                r_11 = ac_reg(*cast(long*)(ac_tok + (1L << 3L)));
                if (ac_rexb(r_11) != 0L)
                {
                    v388 = ac_b(65L);
                }
                v389 = ac_b(255L);
                v390 = ac_b((224L | (r_11 & 7L)));
                return 0;
            }
            else
            {
                v391 = ac_b(233L);
                v392 = ac_fixup(*cast(long*)(ac_tok + (1L << 3L)));
                return 0;
            }
        }
    }
    if (ac_streq(m, cast(long)__s25497.ptr) != 0)
    {
        v395 = ac_b(15L);
        v396 = ac_b(133L);
        v397 = ac_fixup(*cast(long*)(ac_tok + (1L << 3L)));
        return 0;
    }
    if (ac_streq(m, cast(long)__s25514.ptr) != 0)
    {
        v400 = ac_b(15L);
        v401 = ac_b(132L);
        v402 = ac_fixup(*cast(long*)(ac_tok + (1L << 3L)));
        return 0;
    }
    if (ac_streq(m, cast(long)__s25531.ptr) != 0)
    {
        v405 = ac_b(15L);
        v406 = ac_b(140L);
        v407 = ac_fixup(*cast(long*)(ac_tok + (1L << 3L)));
        return 0;
    }
    if (ac_streq(m, cast(long)__s25548.ptr) != 0)
    {
        v410 = ac_b(15L);
        v411 = ac_b(142L);
        v412 = ac_fixup(*cast(long*)(ac_tok + (1L << 3L)));
        return 0;
    }
    if (ac_streq(m, cast(long)__s25565.ptr) != 0)
    {
        v415 = ac_b(15L);
        v416 = ac_b(143L);
        v417 = ac_fixup(*cast(long*)(ac_tok + (1L << 3L)));
        return 0;
    }
    if (ac_streq(m, cast(long)__s25582.ptr) != 0)
    {
        v420 = ac_b(15L);
        v421 = ac_b(141L);
        v422 = ac_fixup(*cast(long*)(ac_tok + (1L << 3L)));
        return 0;
    }
    if (ac_streq(m, cast(long)__s25599.ptr) != 0)
    {
        v425 = ac_b(15L);
        v426 = ac_b(134L);
        v427 = ac_fixup(*cast(long*)(ac_tok + (1L << 3L)));
        return 0;
    }
    if (ac_streq(m, cast(long)__s25616.ptr) != 0)
    {
        v430 = ac_b(15L);
        v431 = ac_b(131L);
        v432 = ac_fixup(*cast(long*)(ac_tok + (1L << 3L)));
        return 0;
    }
    cc = (-1L);
    if (ac_has_pfx(m, cast(long)__s25636.ptr) != 0)
    {
        cc = ac_cc_from(m, 5L);
    }
    if (cc >= 0L)
    {
        dr_9 = ac_reg(*cast(long*)(ac_tok + (1L << 3L)));
        sr_4 = ac_reg(*cast(long*)(ac_tok + (2L << 3L)));
        v440 = ac_b(((72L | ac_rexr(dr_9)) | ac_rexb(sr_4)));
        v441 = ac_b(15L);
        v442 = ac_b((64L + cc));
        v443 = ac_b(((192L | ((dr_9 & 7L) << 3L)) | (sr_4 & 7L)));
        return 0;
    }
    cc = (-1L);
    if (ac_has_pfx(m, cast(long)__s25691.ptr) != 0)
    {
        cc = ac_cc_from(m, 4L);
    }
    if (cc >= 0L)
    {
        r_12 = ac_reg(*cast(long*)(ac_tok + (1L << 3L)));
        if (r_12 < 0L)
        {
            v449 = writef(cast(long)__s25710.ptr, *cast(long*)(ac_tok + (1L << 3L)));
            ac_errs = (ac_errs + 1L);
            return 0;
        }
        v451 = ac_b((64L | ac_rexb(r_12)));
        v452 = ac_b(15L);
        v453 = ac_b((144L + cc));
        v454 = ac_b((192L | (r_12 & 7L)));
        return 0;
    }
    cc = (-1L);
    if (ac_has_pfx(m, cast(long)__s25743.ptr) != 0)
    {
        cc = ac_cc_from(m, 2L);
    }
    if (cc >= 0L)
    {
        v458 = ac_b(15L);
        v459 = ac_b((128L + cc));
        v460 = ac_fixup(*cast(long*)(ac_tok + (1L << 3L)));
        return 0;
    }
    if (ac_streq(m, cast(long)__s25766.ptr) != 0)
    {
        v463 = ac_b(144L);
        return 0;
    }
    if (ac_streq(m, cast(long)__s25772.ptr) != 0)
    {
        v466 = ac_b(204L);
        return 0;
    }
    if (ac_streq(m, cast(long)__s25778.ptr) != 0)
    {
        v469 = ac_b(250L);
        return 0;
    }
    if (ac_streq(m, cast(long)__s25784.ptr) != 0)
    {
        v472 = ac_b(251L);
        return 0;
    }
    if (ac_streq(m, cast(long)__s25790.ptr) != 0)
    {
        v475 = ac_b(244L);
        return 0;
    }
    if (ac_streq(m, cast(long)__s25796.ptr) != 0)
    {
        v478 = ac_b(15L);
        v479 = ac_b(11L);
        return 0;
    }
    if (ac_streq(m, cast(long)__s25805.ptr) != 0)
    {
        v482 = ac_b(72L);
        v483 = ac_b(207L);
        return 0;
    }
    if (ac_streq(m, cast(long)__s25814.ptr) != 0)
    {
        v486 = ac_b(207L);
        return 0;
    }
    if (ac_streq(m, cast(long)__s25820.ptr) != 0)
    {
        v489 = ac_b(205L);
        v491 = ac_b((ac_num(*cast(long*)(ac_tok + (1L << 3L))) & 255L));
        return 0;
    }
    if (ac_streq(m, cast(long)__s25838.ptr) != 0)
    {
        v494 = ac_b(15L);
        v495 = ac_b(52L);
        return 0;
    }
    if (ac_streq(m, cast(long)__s25847.ptr) != 0)
    {
        v498 = ac_b(15L);
        v499 = ac_b(53L);
        return 0;
    }
    if (ac_streq(m, cast(long)__s25856.ptr) != 0)
    {
        v502 = ac_b(15L);
        v503 = ac_b(7L);
        return 0;
    }
    if (ac_streq(m, cast(long)__s25865.ptr) != 0)
    {
        v506 = ac_b(153L);
        return 0;
    }
    if (ac_streq(m, cast(long)__s25871.ptr) != 0)
    {
        v509 = ac_b(15L);
        v510 = ac_b(136L);
        v511 = ac_fixup(*cast(long*)(ac_tok + (1L << 3L)));
        return 0;
    }
    if (ac_streq(m, cast(long)__s25888.ptr) != 0)
    {
        v514 = ac_b(15L);
        v515 = ac_b(137L);
        v516 = ac_fixup(*cast(long*)(ac_tok + (1L << 3L)));
        return 0;
    }
    if (ac_streq(m, cast(long)__s25905.ptr) != 0)
    {
        r_13 = ac_reg(*cast(long*)(ac_tok + (1L << 3L)));
        v521 = ac_b((72L | ac_rexb(r_13)));
        v522 = ac_b(255L);
        v523 = ac_b((192L | (r_13 & 7L)));
        return 0;
    }
    if (ac_streq(m, cast(long)__s25932.ptr) != 0)
    {
        r_14 = ac_reg(*cast(long*)(ac_tok + (1L << 3L)));
        v528 = ac_b((72L | ac_rexb(r_14)));
        v529 = ac_b(255L);
        v530 = ac_b((200L | (r_14 & 7L)));
        return 0;
    }
    if (ac_streq(m, cast(long)__s25959.ptr) != 0)
    {
        r_15 = ac_reg(*cast(long*)(ac_tok + (1L << 3L)));
        v535 = ac_b((72L | ac_rexb(r_15)));
        v536 = ac_b(15L);
        v537 = ac_b((200L | (r_15 & 7L)));
        return 0;
    }
    if (ac_streq(m, cast(long)__s25986.ptr) != 0)
    {
        dr_10 = ac_reg(*cast(long*)(ac_tok + (1L << 3L)));
        sr_5 = ac_reg(*cast(long*)(ac_tok + (2L << 3L)));
        v544 = ac_b(((72L | ac_rexr(sr_5)) | ac_rexb(dr_10)));
        v545 = ac_b(135L);
        v546 = ac_b(((192L | ((sr_5 & 7L) << 3L)) | (dr_10 & 7L)));
        return 0;
    }
    if (ac_streq(m, cast(long)__s26030.ptr) != 0) goto L5721; else goto L5723;
L5723:
    if (ac_streq(m, cast(long)__s26033.ptr) != 0) goto L5721; else goto L5722;
L5721:
    dr_11 = ac_reg(*cast(long*)(ac_tok + (1L << 3L)));
    sr_6 = ac_reg(*cast(long*)(ac_tok + (2L << 3L)));
    if (ac_streq(m, cast(long)__s26055.ptr) != 0)
    {
        v555 = 19L;
    }
    else
    {
        v555 = 27L;
    }
    op = v555;
    v558 = ac_b(((72L | ac_rexr(dr_11)) | ac_rexb(sr_6)));
    v559 = ac_b(op);
    v560 = ac_b(((192L | ((dr_11 & 7L) << 3L)) | (sr_6 & 7L)));
    return 0;
L5722:
    cc_2 = (-1L);
    if (ac_streq(m, cast(long)__s26086.ptr) != 0) goto L5727; else goto L5729;
L5729:
    if (ac_streq(m, cast(long)__s26089.ptr) != 0) goto L5727; else goto L5728;
L5727:
    cc_2 = 68L;
L5728:
    if (ac_streq(m, cast(long)__s26093.ptr) != 0) goto L5730; else goto L5732;
L5732:
    if (ac_streq(m, cast(long)__s26096.ptr) != 0) goto L5730; else goto L5731;
L5730:
    cc_2 = 69L;
L5731:
    if (ac_streq(m, cast(long)__s26100.ptr) != 0)
    {
        cc_2 = 66L;
    }
    if (ac_streq(m, cast(long)__s26104.ptr) != 0)
    {
        cc_2 = 67L;
    }
    if (ac_streq(m, cast(long)__s26108.ptr) != 0)
    {
        cc_2 = 70L;
    }
    if (ac_streq(m, cast(long)__s26112.ptr) != 0)
    {
        cc_2 = 71L;
    }
    if (ac_streq(m, cast(long)__s26116.ptr) != 0)
    {
        cc_2 = 76L;
    }
    if (ac_streq(m, cast(long)__s26120.ptr) != 0)
    {
        cc_2 = 77L;
    }
    if (ac_streq(m, cast(long)__s26124.ptr) != 0)
    {
        cc_2 = 78L;
    }
    if (ac_streq(m, cast(long)__s26128.ptr) != 0)
    {
        cc_2 = 79L;
    }
    if (ac_streq(m, cast(long)__s26132.ptr) != 0)
    {
        cc_2 = 72L;
    }
    if (ac_streq(m, cast(long)__s26136.ptr) != 0)
    {
        cc_2 = 73L;
    }
    if (cc_2 >= 0L)
    {
        dr_12 = ac_reg(*cast(long*)(ac_tok + (1L << 3L)));
        sr_7 = ac_reg(*cast(long*)(ac_tok + (2L << 3L)));
        v593 = ac_b(((72L | ac_rexr(dr_12)) | ac_rexb(sr_7)));
        v594 = ac_b(15L);
        v595 = ac_b(cc_2);
        v596 = ac_b(((192L | ((dr_12 & 7L) << 3L)) | (sr_7 & 7L)));
        return 0;
    }
    if (ac_streq(m, cast(long)__s26185.ptr) != 0)
    {
        v599 = ac_b(15L);
        v600 = ac_b(130L);
        v601 = ac_fixup(*cast(long*)(ac_tok + (1L << 3L)));
        return 0;
    }
    if (ac_streq(m, cast(long)__s26202.ptr) != 0)
    {
        v604 = ac_b(15L);
        v605 = ac_b(135L);
        v606 = ac_fixup(*cast(long*)(ac_tok + (1L << 3L)));
        return 0;
    }
    if (ac_streq(m, cast(long)__s26219.ptr) != 0)
    {
        if (ac_streq(*cast(long*)(ac_tok + (1L << 3L)), cast(long)__s26228.ptr) != 0)
        {
            if (ac_streq(*cast(long*)(ac_tok + (2L << 3L)), cast(long)__s26238.ptr) != 0)
            {
                v613 = *cast(long*)(ac_tok + (3L << 3L));
            }
            else
            {
                v613 = *cast(long*)(ac_tok + (2L << 3L));
            }
            s_2 = v613;
            v614 = ac_b(255L);
            v615 = ac_b(21L);
            v616 = ac_fixup(s_2);
            return 0;
        }
        else
        {
            if (ac_reg(*cast(long*)(ac_tok + (1L << 3L))) >= 0L)
            {
                v618 = ac_b(255L);
                v620 = ac_b((208L | (ac_reg(*cast(long*)(ac_tok + (1L << 3L))) & 7L)));
                return 0;
            }
            else
            {
                v621 = ac_b(232L);
                v622 = ac_fixup(*cast(long*)(ac_tok + (1L << 3L)));
                return 0;
            }
        }
    }
    if (ac_streq(m, cast(long)__s26300.ptr) != 0)
    {
        if (ac_isxmm(*cast(long*)(ac_tok + (1L << 3L))) != 0)
        {
            v626 = ac_b(243L);
            v627 = ac_b(15L);
            v628 = ac_b(111L);
            v630 = ac_mem_operand(ac_xmm(*cast(long*)(ac_tok + (1L << 3L))), 2L);
            return 0;
        }
        else
        {
            v631 = ac_b(243L);
            v632 = ac_b(15L);
            v633 = ac_b(127L);
            v636 = ac_mem_operand(ac_xmm(*cast(long*)(ac_tok + (ac_after_mem(1L) << 3L))), 1L);
            return 0;
        }
    }
    if (ac_streq(m, cast(long)__s26353.ptr) != 0)
    {
        v639 = ac_b(102L);
        v640 = ac_b(15L);
        v641 = ac_b(108L);
        v644 = ac_b(((192L | (ac_xmm(*cast(long*)(ac_tok + (1L << 3L))) << 3L)) | ac_xmm(*cast(long*)(ac_tok + (2L << 3L)))));
        return 0;
    }
    if (ac_streq(m, cast(long)__s26388.ptr) != 0)
    {
        v647 = ac_b(102L);
        v648 = ac_b(15L);
        v649 = ac_b(212L);
        v652 = ac_b(((192L | (ac_xmm(*cast(long*)(ac_tok + (1L << 3L))) << 3L)) | ac_xmm(*cast(long*)(ac_tok + (2L << 3L)))));
        return 0;
    }
    if (ac_streq(m, cast(long)__s26423.ptr) != 0)
    {
        v655 = ac_b(102L);
        v656 = ac_b(15L);
        v657 = ac_b(251L);
        v660 = ac_b(((192L | (ac_xmm(*cast(long*)(ac_tok + (1L << 3L))) << 3L)) | ac_xmm(*cast(long*)(ac_tok + (2L << 3L)))));
        return 0;
    }
    v662 = writef(cast(long)__s26458.ptr, m);
    ac_errs = (ac_errs + 1L);
    return 0;
}
long ac_readline(long p1 = 0)
{
    long n = 0;
    long v0 = 0;
    long c = 0;
    long v1 = 0;
    long buf = p1;
    n = 0L;
    c = rdch();
    if (c == -1L)
    {
        return 0L;
    }
L5783:
    if (c == 10L) goto L5785; else goto L5786;
L5786:
    if (c == -1L) goto L5785; else goto L5784;
L5784:
    if (c != 13L)
    {
        if (n < 250L) goto L5787; else goto L5788;
L5787:
        n = (n + 1L);
        *cast(ubyte*)(buf + n) = cast(ubyte)c;
    }
L5788:
    c = rdch();
    goto L5783;
L5785:
    *cast(ubyte*)(buf + 0L) = cast(ubyte)n;
    return 1L;
}
long ac_assemble(long p1 = 0)
{
    long v0 = 0;
    long st = 0;
    long prev = 0;
    long v1 = 0;
    long line = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long v6 = 0;
    long v7 = 0;
    long t0 = 0;
    long l = 0;
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
    long i = 0;
    long nm = 0;
    long v35 = 0;
    long v36 = 0;
    long tgt = 0;
    long v37 = 0;
    long v38 = 0;
    long v39 = 0;
    long inname = p1;
    st = findinput(inname);
    prev = 0L;
    line = getvec(64L);
    if (st != 0) goto L5791; else goto L5790;
L5790:
    v3 = writef(cast(long)__s26501.ptr, inname);
    return 0L;
L5791:
    prev = input();
    v5 = selectinput(st);
L5792:
    if (ac_readline(line) != 0)
    {
        v7 = ac_tokenize(line);
        if (ac_ntok == 0L)
        {
    goto L5792;
        }
        t0 = *cast(long*)(ac_tok + (0L << 3L));
        l = cast(long)*cast(ubyte*)(t0 + 0L);
        if (cast(long)*cast(ubyte*)(t0 + l) == 58L)
        {
            v9 = ac_add_label(ac_dup(t0, 1L, (l - 1L)));
        }
        else
        {
            if (ac_streq(t0, cast(long)__s26538.ptr) != 0)
            {
                if (ac_streq(*cast(long*)(ac_tok + (1L << 3L)), cast(long)__s26547.ptr) != 0)
                {
                    ac_cursec = 0L;
                }
                if (ac_streq(*cast(long*)(ac_tok + (1L << 3L)), cast(long)__s26557.ptr) != 0)
                {
                    ac_cursec = 1L;
                }
                if (ac_streq(*cast(long*)(ac_tok + (1L << 3L)), cast(long)__s26567.ptr) != 0)
                {
                    ac_cursec = 1L;
                }
                if (ac_streq(*cast(long*)(ac_tok + (1L << 3L)), cast(long)__s26577.ptr) != 0)
                {
                    ac_cursec = 2L;
                }
                if (ac_streq(*cast(long*)(ac_tok + (1L << 3L)), cast(long)__s26587.ptr) != 0)
                {
                    ac_cursec = 3L;
                }
                if (ac_streq(*cast(long*)(ac_tok + (1L << 3L)), cast(long)__s26597.ptr) != 0)
                {
                    ac_cursec = 4L;
                }
                if (ac_streq(*cast(long*)(ac_tok + (1L << 3L)), cast(long)__s26607.ptr) != 0)
                {
                    ac_cursec = 5L;
                }
            }
            else
            {
                if (ac_streq(t0, cast(long)__s26611.ptr) != 0) goto L5817; else goto L5821;
L5821:
                if (ac_streq(t0, cast(long)__s26614.ptr) != 0) goto L5817; else goto L5820;
L5820:
                if (ac_streq(t0, cast(long)__s26617.ptr) != 0) goto L5817; else goto L5818;
L5817:
    goto L5819;
L5818:
                v32 = ac_do_insn();
L5819:
            }
        }
    goto L5792;
    }
    v33 = endread();
    v34 = selectinput(prev);
    i = 0L;
    while (i <= (ac_fn - 1L))
    {
        nm = *cast(long*)(ac_ftgt + (i << 3L));
        if (ac_is_local(nm) != 0)
        {
            tgt = ac_find_label(nm);
            if (tgt < 0L)
            {
                v38 = writef(cast(long)__s26645.ptr);
                ac_errs = (ac_errs + 1L);
            }
            else
            {
                v39 = ac_patch32(*cast(long*)(ac_fsite + (i << 3L)), (tgt - (*cast(long*)(ac_fsite + (i << 3L)) + 4L)));
            }
        }
        else
        {
            *cast(long*)(ac_rsite + (ac_rn << 3L)) = *cast(long*)(ac_fsite + (i << 3L));
            *cast(long*)(ac_rsym + (ac_rn << 3L)) = nm;
            ac_rn = (ac_rn + 1L);
        }
        i = (i + 1L);
    }
    return cast(long)(ac_errs == 0L);
}
long ac_put(long p1 = 0)
{
    long v0 = 0;
    long v = p1;
    return binwrch((v & 255L));
}
long ac_put16(long p1 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v = p1;
    v0 = ac_put(v);
    v1 = ac_put((v >> 8L));
    return 0;
}
long ac_put32(long p1 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v = p1;
    v0 = ac_put(v);
    v1 = ac_put((v >> 8L));
    v2 = ac_put((v >> 16L));
    v3 = ac_put((v >> 24L));
    return 0;
}
long ac_put64(long p1 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v = p1;
    v0 = ac_put32(v);
    v1 = ac_put32((v >> 32L));
    return 0;
}
long ac_align8(long p1 = 0)
{
    long x = p1;
    return ((x + 7L) & (~7L));
}
long ac_init()
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
    ac_code = getvec((1L << 19L));
    ac_len = 0L;
    ac_lname = getvec((1L << 15L));
    ac_loff = getvec((1L << 15L));
    ac_ln = 0L;
    ac_fsite = getvec((1L << 17L));
    ac_ftgt = getvec((1L << 17L));
    ac_fn = 0L;
    ac_rsite = getvec((1L << 16L));
    ac_rsym = getvec((1L << 16L));
    ac_rn = 0L;
    ac_rodata = getvec((1L << 16L));
    ac_rodlen = 0L;
    ac_cursec = 0L;
    ac_bsslen = 0L;
    ac_data = getvec((1L << 15L));
    ac_datalen = 0L;
    ac_edata = getvec((1L << 13L));
    ac_edatalen = 0L;
    ac_idata = getvec((1L << 13L));
    ac_idatalen = 0L;
    ac_lsec = getvec((1L << 15L));
    ac_arsite = getvec((1L << 17L));
    ac_arsym = getvec((1L << 17L));
    ac_arn = 0L;
    ac_tok = getvec(20L);
    ac_errs = 0L;
    return 0;
}
