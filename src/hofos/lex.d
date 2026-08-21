// Generated from BCPL by cg-d.b, split into modules by split.d.
module hofos.lex;

import hofos.all;

long diag_pre(long p1 = 0, long p2 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long col = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long v6 = 0;
    long v7 = 0;
    long v8 = 0;
    long tag = 0;
    long v9 = 0;
    long v10 = 0;
    long i = 0;
    long v11 = 0;
    long v12 = 0;
    long v13 = 0;
    long v14 = 0;
    long v15 = 0;
    long v16 = 0;
    long sev = p1;
    long line = p2;
    if (sev == 1L)
    {
        v0 = 35L;
    }
    else
    {
        if (sev == 4L)
        {
            v1 = 36L;
        }
        else
        {
            v1 = 31L;
        }
        v0 = v1;
    }
    col = v0;
    if (sev == 1L)
    {
        v3 = cast(long)__s2047.ptr;
    }
    else
    {
        if (sev == 3L)
        {
            v5 = cast(long)__s2051.ptr;
        }
        else
        {
            if (sev == 4L)
            {
                v7 = cast(long)__s2055.ptr;
            }
            else
            {
                v7 = cast(long)__s2056.ptr;
            }
            v5 = v7;
        }
        v3 = v5;
    }
    tag = v3;
    v10 = writes(cast(long)__s2059.ptr);
    if (diag_srcname != 0L)
    {
        i = 1L;
        while (i <= cast(long)*cast(ubyte*)(diag_srcname + 0L))
        {
            v11 = wrch(cast(long)*cast(ubyte*)(diag_srcname + i));
            i = (i + 1L);
        }
        v12 = wrch(58L);
    }
    if (line > 0L)
    {
        v14 = writef(cast(long)__s2083.ptr, line);
    }
    v16 = writef(cast(long)__s2086.ptr, col, tag);
    return 0;
}
long is_digit(long p1 = 0)
{
    long c = p1;
    return (cast(long)(c >= 48L) & cast(long)(c <= 57L));
}
long is_hex_digit(long p1 = 0)
{
    long c = p1;
    return (((cast(long)(c >= 48L) & cast(long)(c <= 57L)) | (cast(long)(c >= 97L) & cast(long)(c <= 102L))) | (cast(long)(c >= 65L) & cast(long)(c <= 70L)));
}
long is_alpha(long p1 = 0)
{
    long c = p1;
    return (((cast(long)(c >= 97L) & cast(long)(c <= 122L)) | (cast(long)(c >= 65L) & cast(long)(c <= 90L))) | cast(long)(c == 95L));
}
long is_alnum(long p1 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long c = p1;
    v0 = is_alpha(c);
    return (v0 | is_digit(c));
}
long to_upper(long p1 = 0)
{
    long v0 = 0;
    long c = p1;
    if (c >= 97L)
    {
        if (c <= 122L) goto L441; else goto L442;
L441:
        v0 = (c - 32L);
    goto L443;
    }
L442:
    v0 = c;
L443:
    return v0;
}
long lex_buf_reset()
{
    lex_buflen = 0L;
    *cast(ubyte*)(lex_buf + 0L) = cast(ubyte)0L;
    return 0;
}
long lex_buf_push(long p1 = 0)
{
    long c = p1;
    if (lex_buflen >= (256L - 1L))
    {
        return 0;
    }
    lex_buflen = (lex_buflen + 1L);
    *cast(ubyte*)(lex_buf + lex_buflen) = cast(ubyte)c;
    *cast(ubyte*)(lex_buf + 0L) = cast(ubyte)lex_buflen;
    return 0;
}
long lex_rawget()
{
    long v0 = 0;
    if (lex_pushed_valid != 0)
    {
        lex_pushed_valid = 0L;
        return lex_pushed;
    }
    return rdch();
}
long lex_peek()
{
    long v0 = 0;
    if (lex_pushed_valid != 0) goto L450; else goto L449;
L449:
    lex_pushed = rdch();
    lex_pushed_valid = 1L;
L450:
    return lex_pushed;
}
long lex_advance()
{
    long v0 = 0;
    if (lex_ch == 10L)
    {
        lex_line = (lex_line + 1L);
        lex_col = 1L;
    }
    else
    {
        lex_col = (lex_col + 1L);
    }
    lex_ch = lex_rawget();
    if (lex_ch == -1L) goto L454; else goto L457;
L457:
    if (lex_ch < 0L) goto L454; else goto L456;
L456:
    if (lex_ch == 255L) goto L454; else goto L455;
L454:
    lex_eof_seen = 1L;
L455:
    return 0;
}
long lex_skip_line_comment()
{
    long v0 = 0;
L458:
    if (lex_ch == 10L) goto L460; else goto L461;
L461:
    if (lex_ch == -1L) goto L460; else goto L459;
L459:
    v0 = lex_advance();
    goto L458;
L460:
    return 0;
}
long lex_skip_block_comment()
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
L462:
    if (lex_ch != -1L)
    {
        if (lex_ch == 42L)
        {
            v0 = lex_advance();
            if (lex_ch == 47L)
            {
                v1 = lex_advance();
                return 0;
            }
    goto L462;
        }
        v2 = lex_advance();
    goto L462;
    }
    return 0;
}
long lex_skip_ws_and_comments()
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
L469:
    if (1L != 0)
    {
        if (lex_ch == 47L)
        {
            v0 = lex_advance();
            if (lex_ch == 47L)
            {
                v1 = lex_skip_line_comment();
    goto L469;
            }
            if (lex_ch == 42L)
            {
                v2 = lex_advance();
                v3 = lex_skip_block_comment();
    goto L469;
            }
            v4 = unrdch(lex_ch);
            lex_ch = 47L;
    goto L471;
        }
        if (lex_ch == 32L) goto L478; else goto L482;
L482:
        if (lex_ch == 9L) goto L478; else goto L481;
L481:
        if (lex_ch == 10L) goto L478; else goto L480;
L480:
        if (lex_ch == 13L) goto L478; else goto L479;
L478:
        v5 = lex_advance();
    goto L469;
L479:
    goto L471;
    }
L471:
    return 0;
}
long lex_buf_eq(long p1 = 0, long p2 = 0)
{
    long i = 0;
    long v0 = 0;
    long kw = p1;
    long n = p2;
    if (lex_buflen != n)
    {
        return 0L;
    }
    i = 1L;
    while (i <= n)
    {
        if (to_upper(cast(long)*cast(ubyte*)(lex_buf + i)) != cast(long)*cast(ubyte*)(kw + i))
        {
            return 0L;
        }
        i = (i + 1L);
    }
    return 1L;
}
long lex_keyword_token()
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
    long v111 = 0;
    long v112 = 0;
    long v113 = 0;
    long v114 = 0;
    long v115 = 0;
    long v116 = 0;
    long v117 = 0;
    long v118 = 0;
    long v119 = 0;
    if (lex_buf_eq(cast(long)__s2288.ptr, 3L) != 0)
    {
        return 247L;
    }
    if (lex_buf_eq(cast(long)__s2293.ptr, 3L) != 0)
    {
        return 200L;
    }
    if (lex_buf_eq(cast(long)__s2298.ptr, 5L) != 0)
    {
        return 245L;
    }
    if (lex_buf_eq(cast(long)__s2303.ptr, 5L) != 0)
    {
        return 268L;
    }
    if (lex_buf_eq(cast(long)__s2308.ptr, 8L) != 0)
    {
        return 246L;
    }
    if (lex_buf_eq(cast(long)__s2313.ptr, 4L) != 0)
    {
        return 266L;
    }
    if (lex_buf_eq(cast(long)__s2318.ptr, 4L) != 0)
    {
        return 267L;
    }
    if (lex_buf_eq(cast(long)__s2323.ptr, 2L) != 0)
    {
        return 201L;
    }
    if (lex_buf_eq(cast(long)__s2328.ptr, 5L) != 0)
    {
        return 202L;
    }
    if (lex_buf_eq(cast(long)__s2333.ptr, 2L) != 0)
    {
        return 203L;
    }
    if (lex_buf_eq(cast(long)__s2338.ptr, 4L) != 0)
    {
        return 204L;
    }
    if (lex_buf_eq(cast(long)__s2343.ptr, 7L) != 0)
    {
        return 205L;
    }
    if (lex_buf_eq(cast(long)__s2348.ptr, 2L) != 0)
    {
        return 206L;
    }
    if (lex_buf_eq(cast(long)__s2353.ptr, 4L) != 0)
    {
        return 207L;
    }
    if (lex_buf_eq(cast(long)__s2358.ptr, 7L) != 0)
    {
        return 208L;
    }
    if (lex_buf_eq(cast(long)__s2363.ptr, 3L) != 0)
    {
        return 138L;
    }
    if (lex_buf_eq(cast(long)__s2368.ptr, 8L) != 0)
    {
        return 209L;
    }
    if (lex_buf_eq(cast(long)__s2373.ptr, 5L) != 0)
    {
        return 210L;
    }
    if (lex_buf_eq(cast(long)__s2378.ptr, 6L) != 0)
    {
        return 211L;
    }
    if (lex_buf_eq(cast(long)__s2383.ptr, 3L) != 0)
    {
        return 212L;
    }
    if (lex_buf_eq(cast(long)__s2388.ptr, 3L) != 0)
    {
        return 213L;
    }
    if (lex_buf_eq(cast(long)__s2393.ptr, 6L) != 0)
    {
        return 214L;
    }
    if (lex_buf_eq(cast(long)__s2398.ptr, 4L) != 0)
    {
        return 215L;
    }
    if (lex_buf_eq(cast(long)__s2403.ptr, 2L) != 0)
    {
        return 216L;
    }
    if (lex_buf_eq(cast(long)__s2408.ptr, 4L) != 0)
    {
        return 217L;
    }
    if (lex_buf_eq(cast(long)__s2413.ptr, 3L) != 0)
    {
        return 218L;
    }
    if (lex_buf_eq(cast(long)__s2418.ptr, 4L) != 0)
    {
        return 219L;
    }
    if (lex_buf_eq(cast(long)__s2423.ptr, 6L) != 0)
    {
        return 140L;
    }
    if (lex_buf_eq(cast(long)__s2428.ptr, 8L) != 0)
    {
        return 220L;
    }
    if (lex_buf_eq(cast(long)__s2433.ptr, 3L) != 0)
    {
        return 225L;
    }
    if (lex_buf_eq(cast(long)__s2438.ptr, 5L) != 0)
    {
        return 221L;
    }
    if (lex_buf_eq(cast(long)__s2443.ptr, 4L) != 0)
    {
        return 139L;
    }
    if (lex_buf_eq(cast(long)__s2448.ptr, 3L) != 0)
    {
        return 222L;
    }
    if (lex_buf_eq(cast(long)__s2453.ptr, 2L) != 0)
    {
        return 223L;
    }
    if (lex_buf_eq(cast(long)__s2458.ptr, 4L) != 0)
    {
        return 248L;
    }
    if (lex_buf_eq(cast(long)__s2463.ptr, 5L) != 0)
    {
        return 250L;
    }
    if (lex_buf_eq(cast(long)__s2468.ptr, 3L) != 0)
    {
        return 251L;
    }
    if (lex_buf_eq(cast(long)__s2473.ptr, 2L) != 0)
    {
        return 224L;
    }
    if (lex_buf_eq(cast(long)__s2478.ptr, 3L) != 0)
    {
        return 225L;
    }
    if (lex_buf_eq(cast(long)__s2483.ptr, 6L) != 0)
    {
        return 226L;
    }
    if (lex_buf_eq(cast(long)__s2488.ptr, 11L) != 0)
    {
        return 227L;
    }
    if (lex_buf_eq(cast(long)__s2493.ptr, 11L) != 0)
    {
        return 228L;
    }
    if (lex_buf_eq(cast(long)__s2498.ptr, 8L) != 0)
    {
        return 229L;
    }
    if (lex_buf_eq(cast(long)__s2503.ptr, 6L) != 0)
    {
        return 230L;
    }
    if (lex_buf_eq(cast(long)__s2508.ptr, 6L) != 0)
    {
        return 141L;
    }
    if (lex_buf_eq(cast(long)__s2513.ptr, 7L) != 0)
    {
        return 231L;
    }
    if (lex_buf_eq(cast(long)__s2518.ptr, 6L) != 0)
    {
        return 232L;
    }
    if (lex_buf_eq(cast(long)__s2523.ptr, 6L) != 0)
    {
        return 233L;
    }
    if (lex_buf_eq(cast(long)__s2528.ptr, 8L) != 0)
    {
        return 234L;
    }
    if (lex_buf_eq(cast(long)__s2533.ptr, 5L) != 0)
    {
        return 235L;
    }
    if (lex_buf_eq(cast(long)__s2538.ptr, 4L) != 0)
    {
        return 236L;
    }
    if (lex_buf_eq(cast(long)__s2543.ptr, 4L) != 0)
    {
        return 237L;
    }
    if (lex_buf_eq(cast(long)__s2548.ptr, 2L) != 0)
    {
        return 238L;
    }
    if (lex_buf_eq(cast(long)__s2553.ptr, 4L) != 0)
    {
        return 239L;
    }
    if (lex_buf_eq(cast(long)__s2558.ptr, 6L) != 0)
    {
        return 240L;
    }
    if (lex_buf_eq(cast(long)__s2563.ptr, 5L) != 0)
    {
        return 241L;
    }
    if (lex_buf_eq(cast(long)__s2568.ptr, 5L) != 0)
    {
        return 242L;
    }
    if (lex_buf_eq(cast(long)__s2573.ptr, 3L) != 0)
    {
        return 244L;
    }
    if (lex_buf_eq(cast(long)__s2578.ptr, 5L) != 0)
    {
        return 243L;
    }
    if (lex_buf_eq(cast(long)__s2583.ptr, 3L) != 0)
    {
        return 139L;
    }
    return 4L;
}
long lex_read_ident()
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    v0 = lex_buf_reset();
L611:
    if (is_alnum(lex_ch) != 0)
    {
        v2 = lex_buf_push(lex_ch);
        v3 = lex_advance();
    goto L611;
    }
    lex_token = lex_keyword_token();
    return 0;
}
long lex_read_number()
{
    long v = 0;
    long base = 0;
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long v6 = 0;
    long ok = 0;
    long d = 0;
    long v7 = 0;
    long v8 = 0;
    long v9 = 0;
    long v10 = 0;
    long v11 = 0;
    long v12 = 0;
    long v13 = 0;
    long v14 = 0;
    long esign = 0;
    long ev = 0;
    long v15 = 0;
    long v16 = 0;
    long v17 = 0;
    long v18 = 0;
    long v19 = 0;
    v = 0L;
    base = 10L;
    lex_numtype = 0L;
    if (lex_ch == 120L) goto L614; else goto L617;
L617:
    if (lex_ch == 88L) goto L614; else goto L615;
L614:
    base = 16L;
    v0 = lex_advance();
    goto L616;
L615:
    if (lex_ch == 98L) goto L618; else goto L621;
L621:
    if (lex_ch == 66L) goto L618; else goto L619;
L618:
    base = 2L;
    v1 = lex_advance();
    goto L620;
L619:
    if (lex_ch == 111L) goto L622; else goto L625;
L625:
    if (lex_ch == 79L) goto L622; else goto L623;
L622:
    base = 8L;
    v2 = lex_advance();
    goto L624;
L623:
    if (lex_ch == 48L)
    {
        v3 = lex_advance();
        if (lex_ch == 120L) goto L628; else goto L631;
L631:
        if (lex_ch == 88L) goto L628; else goto L629;
L628:
        base = 16L;
        v4 = lex_advance();
    goto L630;
L629:
        if (lex_ch == 98L) goto L632; else goto L635;
L635:
        if (lex_ch == 66L) goto L632; else goto L633;
L632:
        base = 2L;
        v5 = lex_advance();
    goto L634;
L633:
        if (lex_ch == 111L) goto L636; else goto L638;
L638:
        if (lex_ch == 79L) goto L636; else goto L637;
L636:
        base = 8L;
        v6 = lex_advance();
L637:
L634:
L630:
    }
L624:
L620:
L616:
L639:
    if (1L != 0)
    {
        ok = 0L;
        d = 0L;
        if (base == 10L)
        {
            if (is_digit(lex_ch) != 0) goto L642; else goto L643;
L642:
            ok = 1L;
        }
L643:
        if (base == 16L)
        {
            if (is_hex_digit(lex_ch) != 0) goto L645; else goto L646;
L645:
            ok = 1L;
        }
L646:
        if (base == 2L)
        {
            if (lex_ch == 48L) goto L648; else goto L651;
L651:
            if (lex_ch == 49L) goto L648; else goto L649;
L648:
            ok = 1L;
        }
L649:
        if (base == 8L)
        {
            if (lex_ch >= 48L) goto L654; else goto L653;
L654:
            if (lex_ch <= 55L) goto L652; else goto L653;
L652:
            ok = 1L;
        }
L653:
        if (ok != 0) goto L657; else goto L656;
L656:
    goto L641;
L657:
        d = (lex_ch - 48L);
        if (base == 16L)
        {
            if (lex_ch >= 97L) goto L660; else goto L659;
L660:
            if (lex_ch <= 102L) goto L658; else goto L659;
L658:
            d = ((lex_ch - 97L) + 10L);
        }
L659:
        if (base == 16L)
        {
            if (lex_ch >= 65L) goto L664; else goto L663;
L664:
            if (lex_ch <= 70L) goto L662; else goto L663;
L662:
            d = ((lex_ch - 65L) + 10L);
        }
L663:
        v = ((v * base) + d);
        v9 = lex_advance();
    goto L639;
    }
L641:
    lex_fexp = 0L;
    if (base == 10L)
    {
        if (lex_ch == 46L) goto L668; else goto L667;
L668:
        if (is_digit(lex_peek()) != 0) goto L666; else goto L667;
L666:
        v12 = lex_advance();
L670:
        if (is_digit(lex_ch) != 0)
        {
            v = ((v * 10L) + (lex_ch - 48L));
            lex_fexp = (lex_fexp - 1L);
            v14 = lex_advance();
    goto L670;
        }
        lex_numtype = 1L;
        if (lex_ch == 101L) goto L673; else goto L675;
L675:
        if (lex_ch == 69L) goto L673; else goto L674;
L673:
        esign = 1L;
        ev = 0L;
        v15 = lex_advance();
        if (lex_ch == 43L)
        {
            v16 = lex_advance();
        }
        if (lex_ch == 45L)
        {
            esign = (-1L);
            v17 = lex_advance();
        }
L680:
        if (is_digit(lex_ch) != 0)
        {
            ev = ((ev * 10L) + (lex_ch - 48L));
            v19 = lex_advance();
    goto L680;
        }
        lex_fexp = (lex_fexp + (esign * ev));
L674:
    }
L667:
    lex_value = v;
    lex_token = 1L;
    return 0;
}
long lex_read_fop()
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
    v0 = lex_ch;
    if (v0 == 43L) goto L685; else goto L693;
L693:
    if (v0 == 45L) goto L686; else goto L694;
L694:
    if (v0 == 42L) goto L687; else goto L695;
L695:
    if (v0 == 47L) goto L688; else goto L696;
L696:
    if (v0 == 61L) goto L689; else goto L697;
L697:
    if (v0 == 126L) goto L690; else goto L698;
L698:
    if (v0 == 60L) goto L691; else goto L699;
L699:
    if (v0 == 62L) goto L692; else goto L700;
L700:
    goto L684;
L685:
    v1 = lex_advance();
    lex_token = 252L;
    goto L683;
L686:
    v2 = lex_advance();
    lex_token = 253L;
    goto L683;
L687:
    v3 = lex_advance();
    lex_token = 254L;
    goto L683;
L688:
    v4 = lex_advance();
    lex_token = 255L;
    goto L683;
L689:
    v5 = lex_advance();
    lex_token = 256L;
    goto L683;
L690:
    v6 = lex_advance();
    if (lex_ch == 61L)
    {
        v7 = lex_advance();
    }
    lex_token = 257L;
    goto L683;
L691:
    v8 = lex_advance();
    if (lex_ch == 61L)
    {
        v9 = lex_advance();
        lex_token = 259L;
    }
    else
    {
        lex_token = 258L;
    }
    goto L683;
L692:
    v10 = lex_advance();
    if (lex_ch == 61L)
    {
        v11 = lex_advance();
        lex_token = 261L;
    }
    else
    {
        lex_token = 260L;
    }
    goto L683;
L684:
    lex_token = 252L;
L683:
    return 0;
}
long lex_read_fkeyword()
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
    v0 = lex_buf_reset();
L709:
    if (is_alnum(lex_ch) != 0)
    {
        v2 = lex_buf_push(lex_ch);
        v3 = lex_advance();
    goto L709;
    }
    if (lex_buf_eq(cast(long)__s2872.ptr, 3L) != 0)
    {
        lex_token = 262L;
    }
    else
    {
        if (lex_buf_eq(cast(long)__s2877.ptr, 3L) != 0)
        {
            lex_token = 263L;
        }
        else
        {
            diag_nerr = (diag_nerr + 1L);
            v8 = diag_pre(2L, lex_line);
            v10 = writef(cast(long)__s2889.ptr);
            lex_token = 262L;
        }
    }
    return 0;
}
long lex_read_string()
{
    long v0 = 0;
    long c = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    v0 = lex_buf_reset();
L718:
    if (lex_ch != 34L)
    {
        if (lex_ch != -1L) goto L719; else goto L720;
L719:
        c = lex_ch;
        if (c == 42L)
        {
            v1 = lex_advance();
            v2 = lex_ch;
            if (v2 == 110L) goto L726; else goto L742;
L742:
            if (v2 == 78L) goto L727; else goto L743;
L743:
            if (v2 == 116L) goto L728; else goto L744;
L744:
            if (v2 == 84L) goto L729; else goto L745;
L745:
            if (v2 == 115L) goto L730; else goto L746;
L746:
            if (v2 == 83L) goto L731; else goto L747;
L747:
            if (v2 == 99L) goto L732; else goto L748;
L748:
            if (v2 == 67L) goto L733; else goto L749;
L749:
            if (v2 == 101L) goto L734; else goto L750;
L750:
            if (v2 == 69L) goto L735; else goto L751;
L751:
            if (v2 == 98L) goto L736; else goto L752;
L752:
            if (v2 == 66L) goto L737; else goto L753;
L753:
            if (v2 == 112L) goto L738; else goto L754;
L754:
            if (v2 == 80L) goto L739; else goto L755;
L755:
            if (v2 == 42L) goto L740; else goto L756;
L756:
            if (v2 == 34L) goto L741; else goto L757;
L757:
    goto L725;
L726:
            c = 10L;
    goto L724;
L727:
            c = 10L;
    goto L724;
L728:
            c = 9L;
    goto L724;
L729:
            c = 9L;
    goto L724;
L730:
            c = 32L;
    goto L724;
L731:
            c = 32L;
    goto L724;
L732:
            c = 13L;
    goto L724;
L733:
            c = 13L;
    goto L724;
L734:
            c = 27L;
    goto L724;
L735:
            c = 27L;
    goto L724;
L736:
            c = 8L;
    goto L724;
L737:
            c = 8L;
    goto L724;
L738:
            c = 12L;
    goto L724;
L739:
            c = 12L;
    goto L724;
L740:
            c = 42L;
    goto L724;
L741:
            c = 34L;
    goto L724;
L725:
            c = lex_ch;
L724:
        }
        v3 = lex_buf_push(c);
        v4 = lex_advance();
    goto L718;
    }
L720:
    if (lex_ch == 34L)
    {
        v5 = lex_advance();
    }
    lex_token = 2L;
    return 0;
}
long lex_read_char()
{
    long c = 0;
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    c = lex_ch;
    v0 = lex_advance();
    if (c == 42L)
    {
        v1 = lex_ch;
        if (v1 == 110L) goto L764; else goto L778;
L778:
        if (v1 == 78L) goto L765; else goto L779;
L779:
        if (v1 == 116L) goto L766; else goto L780;
L780:
        if (v1 == 84L) goto L767; else goto L781;
L781:
        if (v1 == 115L) goto L768; else goto L782;
L782:
        if (v1 == 83L) goto L769; else goto L783;
L783:
        if (v1 == 99L) goto L770; else goto L784;
L784:
        if (v1 == 67L) goto L771; else goto L785;
L785:
        if (v1 == 101L) goto L772; else goto L786;
L786:
        if (v1 == 69L) goto L773; else goto L787;
L787:
        if (v1 == 98L) goto L774; else goto L788;
L788:
        if (v1 == 66L) goto L775; else goto L789;
L789:
        if (v1 == 112L) goto L776; else goto L790;
L790:
        if (v1 == 80L) goto L777; else goto L791;
L791:
    goto L763;
L764:
        c = 10L;
    goto L762;
L765:
        c = 10L;
    goto L762;
L766:
        c = 9L;
    goto L762;
L767:
        c = 9L;
    goto L762;
L768:
        c = 32L;
    goto L762;
L769:
        c = 32L;
    goto L762;
L770:
        c = 13L;
    goto L762;
L771:
        c = 13L;
    goto L762;
L772:
        c = 27L;
    goto L762;
L773:
        c = 27L;
    goto L762;
L774:
        c = 8L;
    goto L762;
L775:
        c = 8L;
    goto L762;
L776:
        c = 12L;
    goto L762;
L777:
        c = 12L;
    goto L762;
L763:
        c = lex_ch;
L762:
        v2 = lex_advance();
    }
    if (lex_ch == 39L)
    {
        v3 = lex_advance();
    }
    lex_value = c;
    lex_token = 1L;
    lex_numtype = 0L;
    return 0;
}
long lex_read_operator()
{
    long c = 0;
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
    c = lex_ch;
    v0 = lex_advance();
    if (c == 40L) goto L796; else goto L821;
L821:
    if (c == 41L) goto L797; else goto L822;
L822:
    if (c == 91L) goto L798; else goto L823;
L823:
    if (c == 93L) goto L799; else goto L824;
L824:
    if (c == 123L) goto L800; else goto L825;
L825:
    if (c == 125L) goto L801; else goto L826;
L826:
    if (c == 44L) goto L802; else goto L827;
L827:
    if (c == 59L) goto L803; else goto L828;
L828:
    if (c == 46L) goto L804; else goto L829;
L829:
    if (c == 64L) goto L805; else goto L830;
L830:
    if (c == 33L) goto L806; else goto L831;
L831:
    if (c == 63L) goto L807; else goto L832;
L832:
    if (c == 37L) goto L808; else goto L833;
L833:
    if (c == 43L) goto L809; else goto L834;
L834:
    if (c == 42L) goto L810; else goto L835;
L835:
    if (c == 47L) goto L811; else goto L836;
L836:
    if (c == 38L) goto L812; else goto L837;
L837:
    if (c == 124L) goto L813; else goto L838;
L838:
    if (c == 36L) goto L814; else goto L839;
L839:
    if (c == 45L) goto L815; else goto L840;
L840:
    if (c == 58L) goto L816; else goto L841;
L841:
    if (c == 61L) goto L817; else goto L842;
L842:
    if (c == 126L) goto L818; else goto L843;
L843:
    if (c == 60L) goto L819; else goto L844;
L844:
    if (c == 62L) goto L820; else goto L845;
L845:
    goto L795;
L796:
    lex_token = 100L;
    goto L794;
L797:
    lex_token = 101L;
    goto L794;
L798:
    lex_token = 102L;
    goto L794;
L799:
    lex_token = 103L;
    goto L794;
L800:
    lex_token = 104L;
    goto L794;
L801:
    lex_token = 105L;
    goto L794;
L802:
    lex_token = 106L;
    goto L794;
L803:
    lex_token = 107L;
    goto L794;
L804:
    if (lex_ch == 46L)
    {
        v1 = lex_advance();
        lex_token = 264L;
    }
    else
    {
        lex_token = 109L;
    }
    goto L794;
L805:
    lex_token = 110L;
    goto L794;
L806:
    lex_token = 111L;
    goto L794;
L807:
    lex_token = 112L;
    goto L794;
L808:
    lex_token = 113L;
    goto L794;
L809:
    lex_token = 130L;
    goto L794;
L810:
    lex_token = 132L;
    goto L794;
L811:
    lex_token = 133L;
    goto L794;
L812:
    lex_token = 135L;
    goto L794;
L813:
    lex_token = 136L;
    goto L794;
L814:
    if (lex_ch == 40L)
    {
        v2 = lex_advance();
        lex_token = 104L;
    }
    else
    {
        if (lex_ch == 41L)
        {
            v3 = lex_advance();
            lex_token = 105L;
        }
        else
        {
            lex_token = 114L;
        }
    }
    goto L794;
L815:
    if (lex_ch == 62L)
    {
        v4 = lex_advance();
        lex_token = 116L;
    }
    else
    {
        lex_token = 131L;
    }
    goto L794;
L816:
    if (lex_ch == 61L)
    {
        v5 = lex_advance();
        lex_token = 115L;
    }
    else
    {
        if (lex_ch == 58L)
        {
            v6 = lex_advance();
            lex_token = 249L;
        }
        else
        {
            lex_token = 108L;
        }
    }
    goto L794;
L817:
    if (lex_ch == 62L)
    {
        v7 = lex_advance();
        lex_token = 117L;
    }
    else
    {
        lex_token = 120L;
    }
    goto L794;
L818:
    if (lex_ch == 61L)
    {
        v8 = lex_advance();
        lex_token = 121L;
    }
    else
    {
        lex_token = 137L;
    }
    goto L794;
L819:
    if (lex_ch == 61L)
    {
        v9 = lex_advance();
        lex_token = 123L;
    }
    else
    {
        if (lex_ch == 60L)
        {
            v10 = lex_advance();
            lex_token = 140L;
        }
        else
        {
            lex_token = 122L;
        }
    }
    goto L794;
L820:
    if (lex_ch == 61L)
    {
        v11 = lex_advance();
        lex_token = 125L;
    }
    else
    {
        if (lex_ch == 62L)
        {
            v12 = lex_advance();
            lex_token = 141L;
        }
        else
        {
            lex_token = 124L;
        }
    }
    goto L794;
L795:
    diag_nerr = (diag_nerr + 1L);
    v13 = diag_pre(2L, lex_line);
    v15 = writef(cast(long)__s3187.ptr, c, c);
    lex_token = 0L;
L794:
    return 0;
}
long lex_init()
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    lex_ch = 32L;
    lex_line = 1L;
    lex_col = 0L;
    lex_lastline = 1L;
    lex_prevline = 1L;
    lex_eof_seen = 0L;
    lex_pushed_valid = 0L;
    lex_buf = getvec(((256L / 8L) + 4L));
    v1 = lex_buf_reset();
    v2 = lex_advance();
    return 0;
}
long lex_rawbyte()
{
    long[2] __v3210;
    long v0 = 0;
    long buf = 0;
    long v1 = 0;
    long n = 0;
    v0 = cast(long)__v3210.ptr;
    buf = v0;
    n = __read(__rdfd, buf, 1L);
    if (n <= 0L)
    {
        return (-1L);
    }
    return (cast(long)*cast(ubyte*)(buf + 0L) & 255L);
}
long lex_rdvarint()
{
    long v = 0;
    long sh = 0;
    long b = 0;
    long v0 = 0;
    v = 0L;
    sh = 0L;
    b = 0L;
L884:
    if (1L != 0)
    {
        b = lex_rawbyte();
        if (b < 0L)
        {
            return v;
        }
        v = (v | ((b & 127L) << sh));
        sh = (sh + 7L);
        if ((b & 128L) == 0L)
        {
    goto L886;
        }
    goto L884;
    }
L886:
    return v;
}
long lex_decode_token()
{
    long v0 = 0;
    long delta = 0;
    long v1 = 0;
    long kind = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long len = 0;
    long v5 = 0;
    long i = 0;
    long v6 = 0;
    delta = lex_rdvarint();
    kind = lex_rawbyte();
    lex_prevline = lex_lastline;
    lex_line = (lex_line + delta);
    lex_lastline = lex_line;
    if (kind < 0L)
    {
        lex_token = 0L;
        return 0;
    }
    lex_token = kind;
    if (kind == 1L)
    {
        lex_numtype = lex_rawbyte();
        lex_value = lex_rdvarint();
    }
    else
    {
        if (kind == 4L) goto L896; else goto L898;
L898:
        if (kind == 2L) goto L896; else goto L897;
L896:
        len = lex_rdvarint();
        v5 = lex_buf_reset();
        i = 1L;
        while (i <= len)
        {
            *cast(ubyte*)(lex_buf + i) = cast(ubyte)lex_rawbyte();
            i = (i + 1L);
        }
        *cast(ubyte*)(lex_buf + 0L) = cast(ubyte)len;
        lex_buflen = len;
        *cast(ubyte*)(lex_buf + (len + 1L)) = cast(ubyte)0L;
L897:
    }
    return 0;
}
long lex_is_opassign_op(long p1 = 0)
{
    long t = p1;
    if (t == 111L) goto L905; else goto L917;
L917:
    if (t == 132L) goto L906; else goto L918;
L918:
    if (t == 133L) goto L907; else goto L919;
L919:
    if (t == 225L) goto L908; else goto L920;
L920:
    if (t == 130L) goto L909; else goto L921;
L921:
    if (t == 131L) goto L910; else goto L922;
L922:
    if (t == 140L) goto L911; else goto L923;
L923:
    if (t == 141L) goto L912; else goto L924;
L924:
    if (t == 135L) goto L913; else goto L925;
L925:
    if (t == 136L) goto L914; else goto L926;
L926:
    if (t == 138L) goto L915; else goto L927;
L927:
    if (t == 139L) goto L916; else goto L928;
L928:
    goto L904;
L905:
    return 1L;
L906:
    return 1L;
L907:
    return 1L;
L908:
    return 1L;
L909:
    return 1L;
L910:
    return 1L;
L911:
    return 1L;
L912:
    return 1L;
L913:
    return 1L;
L914:
    return 1L;
L915:
    return 1L;
L916:
    return 1L;
L904:
    return 0L;
L903:
    return 0;
}
long lex_next()
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
    if (lex_replay != 0L)
    {
        v0 = lex_decode_token();
        return 0;
    }
    v1 = lex_skip_ws_and_comments();
    lex_prevline = lex_lastline;
    lex_lastline = lex_line;
    if (lex_eof_seen != 0) goto L931; else goto L934;
L934:
    if (lex_ch < 0L) goto L931; else goto L933;
L933:
    if (lex_ch == -1L) goto L931; else goto L932;
L931:
    lex_token = 0L;
    return 0;
L932:
    if (is_alpha(lex_ch) != 0)
    {
        v3 = lex_read_ident();
    }
    else
    {
        if (is_digit(lex_ch) != 0)
        {
            v5 = lex_read_number();
        }
        else
        {
            if (lex_ch == 34L)
            {
                v6 = lex_advance();
                v7 = lex_read_string();
            }
            else
            {
                if (lex_ch == 39L)
                {
                    v8 = lex_advance();
                    v9 = lex_read_char();
                }
                else
                {
                    if (lex_ch == 35L)
                    {
                        v10 = lex_advance();
                        if (lex_ch == 43L) goto L950; else goto L959;
L959:
                        if (lex_ch == 45L) goto L950; else goto L958;
L958:
                        if (lex_ch == 42L) goto L950; else goto L957;
L957:
                        if (lex_ch == 47L) goto L950; else goto L956;
L956:
                        if (lex_ch == 61L) goto L950; else goto L955;
L955:
                        if (lex_ch == 126L) goto L950; else goto L954;
L954:
                        if (lex_ch == 60L) goto L950; else goto L953;
L953:
                        if (lex_ch == 62L) goto L950; else goto L951;
L950:
                        v11 = lex_read_fop();
    goto L952;
L951:
                        if (is_alpha(lex_ch) != 0)
                        {
                            if (lex_ch != 120L) goto L967; else goto L961;
L967:
                            if (lex_ch != 88L) goto L966; else goto L961;
L966:
                            if (lex_ch != 98L) goto L965; else goto L961;
L965:
                            if (lex_ch != 66L) goto L964; else goto L961;
L964:
                            if (lex_ch != 111L) goto L963; else goto L961;
L963:
                            if (lex_ch != 79L) goto L960; else goto L961;
L960:
                            v13 = lex_read_fkeyword();
    goto L962;
                        }
L961:
                        v14 = lex_read_number();
L962:
L952:
                    }
                    else
                    {
                        v15 = lex_read_operator();
                    }
                }
            }
        }
    }
    if (lex_is_opassign_op(lex_token) != 0)
    {
        if (lex_ch == 58L) goto L969; else goto L970;
L969:
        if (lex_peek() == 61L)
        {
            v18 = lex_advance();
            v19 = lex_advance();
            lex_opassign_op = lex_token;
            lex_token = 118L;
        }
    }
L970:
    return 0;
}
long lex_tok_name(long p1 = 0)
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
    long t = p1;
    if (t == 0L) goto L976; else goto L1037;
L1037:
    if (t == 1L) goto L977; else goto L1038;
L1038:
    if (t == 2L) goto L978; else goto L1039;
L1039:
    if (t == 3L) goto L979; else goto L1040;
L1040:
    if (t == 4L) goto L980; else goto L1041;
L1041:
    if (t == 100L) goto L981; else goto L1042;
L1042:
    if (t == 101L) goto L982; else goto L1043;
L1043:
    if (t == 102L) goto L983; else goto L1044;
L1044:
    if (t == 103L) goto L984; else goto L1045;
L1045:
    if (t == 104L) goto L985; else goto L1046;
L1046:
    if (t == 105L) goto L986; else goto L1047;
L1047:
    if (t == 106L) goto L987; else goto L1048;
L1048:
    if (t == 107L) goto L988; else goto L1049;
L1049:
    if (t == 108L) goto L989; else goto L1050;
L1050:
    if (t == 109L) goto L990; else goto L1051;
L1051:
    if (t == 110L) goto L991; else goto L1052;
L1052:
    if (t == 111L) goto L992; else goto L1053;
L1053:
    if (t == 113L) goto L993; else goto L1054;
L1054:
    if (t == 115L) goto L994; else goto L1055;
L1055:
    if (t == 116L) goto L995; else goto L1056;
L1056:
    if (t == 120L) goto L996; else goto L1057;
L1057:
    if (t == 121L) goto L997; else goto L1058;
L1058:
    if (t == 122L) goto L998; else goto L1059;
L1059:
    if (t == 123L) goto L999; else goto L1060;
L1060:
    if (t == 124L) goto L1000; else goto L1061;
L1061:
    if (t == 125L) goto L1001; else goto L1062;
L1062:
    if (t == 130L) goto L1002; else goto L1063;
L1063:
    if (t == 131L) goto L1003; else goto L1064;
L1064:
    if (t == 132L) goto L1004; else goto L1065;
L1065:
    if (t == 133L) goto L1005; else goto L1066;
L1066:
    if (t == 135L) goto L1006; else goto L1067;
L1067:
    if (t == 136L) goto L1007; else goto L1068;
L1068:
    if (t == 137L) goto L1008; else goto L1069;
L1069:
    if (t == 140L) goto L1009; else goto L1070;
L1070:
    if (t == 141L) goto L1010; else goto L1071;
L1071:
    if (t == 218L) goto L1011; else goto L1072;
L1072:
    if (t == 201L) goto L1012; else goto L1073;
L1073:
    if (t == 206L) goto L1013; else goto L1074;
L1074:
    if (t == 237L) goto L1014; else goto L1075;
L1075:
    if (t == 207L) goto L1015; else goto L1076;
L1076:
    if (t == 217L) goto L1016; else goto L1077;
L1077:
    if (t == 223L) goto L1017; else goto L1078;
L1078:
    if (t == 248L) goto L1018; else goto L1079;
L1079:
    if (t == 249L) goto L1019; else goto L1080;
L1080:
    if (t == 250L) goto L1020; else goto L1081;
L1081:
    if (t == 251L) goto L1021; else goto L1082;
L1082:
    if (t == 252L) goto L1022; else goto L1083;
L1083:
    if (t == 253L) goto L1023; else goto L1084;
L1084:
    if (t == 254L) goto L1024; else goto L1085;
L1085:
    if (t == 255L) goto L1025; else goto L1086;
L1086:
    if (t == 256L) goto L1026; else goto L1087;
L1087:
    if (t == 257L) goto L1027; else goto L1088;
L1088:
    if (t == 258L) goto L1028; else goto L1089;
L1089:
    if (t == 259L) goto L1029; else goto L1090;
L1090:
    if (t == 260L) goto L1030; else goto L1091;
L1091:
    if (t == 261L) goto L1031; else goto L1092;
L1092:
    if (t == 238L) goto L1032; else goto L1093;
L1093:
    if (t == 204L) goto L1033; else goto L1094;
L1094:
    if (t == 205L) goto L1034; else goto L1095;
L1095:
    if (t == 208L) goto L1035; else goto L1096;
L1096:
    if (t == 242L) goto L1036; else goto L1097;
L1097:
    goto L975;
L976:
    return cast(long)__s3572.ptr;
L977:
    return cast(long)__s3573.ptr;
L978:
    return cast(long)__s3574.ptr;
L979:
    return cast(long)__s3575.ptr;
L980:
    return cast(long)__s3576.ptr;
L981:
    return cast(long)__s3577.ptr;
L982:
    return cast(long)__s3578.ptr;
L983:
    return cast(long)__s3579.ptr;
L984:
    return cast(long)__s3580.ptr;
L985:
    return cast(long)__s3581.ptr;
L986:
    return cast(long)__s3582.ptr;
L987:
    return cast(long)__s3583.ptr;
L988:
    return cast(long)__s3584.ptr;
L989:
    return cast(long)__s3585.ptr;
L990:
    return cast(long)__s3586.ptr;
L991:
    return cast(long)__s3587.ptr;
L992:
    return cast(long)__s3588.ptr;
L993:
    return cast(long)__s3589.ptr;
L994:
    return cast(long)__s3590.ptr;
L995:
    return cast(long)__s3591.ptr;
L996:
    return cast(long)__s3592.ptr;
L997:
    return cast(long)__s3593.ptr;
L998:
    return cast(long)__s3594.ptr;
L999:
    return cast(long)__s3595.ptr;
L1000:
    return cast(long)__s3596.ptr;
L1001:
    return cast(long)__s3597.ptr;
L1002:
    return cast(long)__s3598.ptr;
L1003:
    return cast(long)__s3599.ptr;
L1004:
    return cast(long)__s3600.ptr;
L1005:
    return cast(long)__s3601.ptr;
L1006:
    return cast(long)__s3602.ptr;
L1007:
    return cast(long)__s3603.ptr;
L1008:
    return cast(long)__s3604.ptr;
L1009:
    return cast(long)__s3605.ptr;
L1010:
    return cast(long)__s3606.ptr;
L1011:
    return cast(long)__s3607.ptr;
L1012:
    return cast(long)__s3608.ptr;
L1013:
    return cast(long)__s3609.ptr;
L1014:
    return cast(long)__s3610.ptr;
L1015:
    return cast(long)__s3611.ptr;
L1016:
    return cast(long)__s3612.ptr;
L1017:
    return cast(long)__s3613.ptr;
L1018:
    return cast(long)__s3614.ptr;
L1019:
    return cast(long)__s3615.ptr;
L1020:
    return cast(long)__s3616.ptr;
L1021:
    return cast(long)__s3617.ptr;
L1022:
    return cast(long)__s3618.ptr;
L1023:
    return cast(long)__s3619.ptr;
L1024:
    return cast(long)__s3620.ptr;
L1025:
    return cast(long)__s3621.ptr;
L1026:
    return cast(long)__s3622.ptr;
L1027:
    return cast(long)__s3623.ptr;
L1028:
    return cast(long)__s3624.ptr;
L1029:
    return cast(long)__s3625.ptr;
L1030:
    return cast(long)__s3626.ptr;
L1031:
    return cast(long)__s3627.ptr;
L1032:
    return cast(long)__s3628.ptr;
L1033:
    return cast(long)__s3629.ptr;
L1034:
    return cast(long)__s3630.ptr;
L1035:
    return cast(long)__s3631.ptr;
L1036:
    return cast(long)__s3632.ptr;
L975:
    if (t >= 200L)
    {
        v62 = cast(long)__s3636.ptr;
    }
    else
    {
        v62 = cast(long)__s3637.ptr;
    }
    return v62;
L974:
    return 0;
}
long lex_print()
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
    v2 = writef(cast(long)__s3640.ptr, lex_lastline, lex_tok_name(lex_token));
    v3 = lex_token;
    if (v3 == 1L) goto L1103; else goto L1106;
L1106:
    if (v3 == 4L) goto L1104; else goto L1107;
L1107:
    if (v3 == 2L) goto L1105; else goto L1108;
L1108:
    goto L1102;
L1103:
    v5 = writef(cast(long)__s3654.ptr, lex_value);
    goto L1101;
L1104:
    v7 = writef(cast(long)__s3658.ptr, lex_buf);
    goto L1101;
L1105:
    v9 = writef(cast(long)__s3662.ptr, lex_buf);
    goto L1101;
L1102:
L1101:
    v10 = newline();
    return 0;
}
