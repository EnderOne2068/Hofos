// Generated from BCPL by cg-d.b, split into modules by split.d.
module hofos.cg.x86.linux;

import hofos.all;

long cg_ra_use(long p1 = 0, long p2 = 0)
{
    long t = p1;
    long pos = p2;
    if (t > 0L)
    {
        if (*cast(long*)(cg_ra_lu + (t << 3L)) < pos) goto L4494; else goto L4495;
L4494:
        *cast(long*)(cg_ra_lu + (t << 3L)) = pos;
    }
L4495:
    return 0;
}
long cg_ra_mark_uses(long p1 = 0, long p2 = 0, long p3 = 0)
{
    long op = 0;
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
    long p = p1;
    long i = p2;
    long pos = p3;
    op = *cast(long*)(p + (i << 3L));
    if (op >= 4L)
    {
        if (op <= 11L) goto L4497; else goto L4503;
    }
L4503:
    if (op == 13L) goto L4497; else goto L4502;
L4502:
    if (op == 14L) goto L4497; else goto L4501;
L4501:
    if (op >= 20L)
    {
        if (op <= 25L) goto L4497; else goto L4500;
    }
L4500:
    if (op >= 51L) goto L4506; else goto L4498;
L4506:
    if (op <= 60L) goto L4497; else goto L4498;
L4497:
    v0 = cg_ra_use(*cast(long*)(p + ((i + 2L) << 3L)), pos);
    v1 = cg_ra_use(*cast(long*)(p + ((i + 3L) << 3L)), pos);
    goto L4499;
L4498:
    if (op == 39L) goto L4507; else goto L4518;
L4518:
    if (op == 26L) goto L4507; else goto L4517;
L4517:
    if (op == 12L) goto L4507; else goto L4516;
L4516:
    if (op == 2L) goto L4507; else goto L4515;
L4515:
    if (op == 43L) goto L4507; else goto L4514;
L4514:
    if (op == 45L) goto L4507; else goto L4513;
L4513:
    if (op == 68L) goto L4507; else goto L4512;
L4512:
    if (op == 70L) goto L4507; else goto L4511;
L4511:
    if (op == 61L) goto L4507; else goto L4510;
L4510:
    if (op == 62L) goto L4507; else goto L4508;
L4507:
    v2 = cg_ra_use(*cast(long*)(p + ((i + 2L) << 3L)), pos);
    goto L4509;
L4508:
    if (op == 3L) goto L4519; else goto L4524;
L4524:
    if (op == 44L) goto L4519; else goto L4523;
L4523:
    if (op == 69L) goto L4519; else goto L4522;
L4522:
    if (op == 71L) goto L4519; else goto L4520;
L4519:
    v3 = cg_ra_use(*cast(long*)(p + ((i + 2L) << 3L)), pos);
    v4 = cg_ra_use(*cast(long*)(p + ((i + 3L) << 3L)), pos);
    goto L4521;
L4520:
    if (op == 63L) goto L4525; else goto L4528;
L4528:
    if (op == 64L) goto L4525; else goto L4526;
L4525:
    v5 = cg_ra_use(*cast(long*)(p + ((i + 2L) << 3L)), pos);
    v6 = cg_ra_use(*cast(long*)(p + ((i + 3L) << 3L)), pos);
    v7 = cg_ra_use(*cast(long*)(p + ((i + 4L) << 3L)), pos);
    goto L4527;
L4526:
    if (op == 65L) goto L4529; else goto L4532;
L4532:
    if (op == 66L) goto L4529; else goto L4530;
L4529:
    v8 = cg_ra_use(*cast(long*)(p + ((i + 1L) << 3L)), pos);
    v9 = cg_ra_use(*cast(long*)(p + ((i + 2L) << 3L)), pos);
    v10 = cg_ra_use(*cast(long*)(p + ((i + 3L) << 3L)), pos);
    v11 = cg_ra_use(*cast(long*)(p + ((i + 4L) << 3L)), pos);
    goto L4531;
L4530:
    if (op == 34L) goto L4533; else goto L4537;
L4537:
    if (op == 31L) goto L4533; else goto L4536;
L4536:
    if (op == 47L) goto L4533; else goto L4534;
L4533:
    v12 = cg_ra_use(*cast(long*)(p + ((i + 2L) << 3L)), pos);
    goto L4535;
L4534:
    if (op == 41L)
    {
        v13 = cg_ra_use(*cast(long*)(p + ((i + 3L) << 3L)), pos);
    }
    else
    {
        if (op == 33L)
        {
            v14 = cg_ra_use(*cast(long*)(p + ((i + 2L) << 3L)), pos);
            v15 = cg_ra_use(*cast(long*)(p + ((i + 4L) << 3L)), pos);
            v16 = cg_ra_use(*cast(long*)(p + ((i + 5L) << 3L)), pos);
            v17 = cg_ra_use(*cast(long*)(p + ((i + 6L) << 3L)), pos);
        }
    }
L4535:
L4531:
L4527:
L4521:
L4509:
L4499:
    return 0;
}
long cg_ra_span(long p1 = 0, long p2 = 0, long p3 = 0)
{
    long last = 0;
    long t = 0;
    long pstart = p1;
    long pend = p2;
    long nt = p3;
    last = nt;
    t = 1L;
    while (t <= last)
    {
        if (*cast(long*)(cg_ra_fd + (t << 3L)) > 0L)
        {
            if (*cast(long*)(cg_ra_fd + (t << 3L)) <= pend) goto L4549; else goto L4548;
L4549:
            if (*cast(long*)(cg_ra_lu + (t << 3L)) >= pstart) goto L4547; else goto L4548;
L4547:
            if (*cast(long*)(cg_ra_fd + (t << 3L)) > pstart)
            {
                *cast(long*)(cg_ra_fd + (t << 3L)) = pstart;
            }
            if (*cast(long*)(cg_ra_lu + (t << 3L)) < pend)
            {
                *cast(long*)(cg_ra_lu + (t << 3L)) = pend;
            }
        }
L4548:
        t = (t + 1L);
    }
    return 0;
}
long cg_ra_backedge(long p1 = 0, long p2 = 0, long p3 = 0)
{
    long v0 = 0;
    long target = p1;
    long pos = p2;
    long nt = p3;
    if (*cast(long*)(cg_ra_lpgen + (target << 3L)) == cg_curgen)
    {
        if (*cast(long*)(cg_ra_lp + (target << 3L)) < pos) goto L4555; else goto L4556;
L4555:
        v0 = cg_ra_span(*cast(long*)(cg_ra_lp + (target << 3L)), pos, nt);
    }
L4556:
    return 0;
}
long cg_regalloc(long p1 = 0)
{
    long p = 0;
    long nt = 0;
    long fnend = 0;
    long maxpos = 0;
    long t = 0;
    long i = 0;
    long t_2 = 0;
    long i_2 = 0;
    long pos = 0;
    long op = 0;
    long d = 0;
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long[6] __v18963;
    long v4 = 0;
    long rtmp = 0;
    long[6] __v18965;
    long v5 = 0;
    long rreg = 0;
    long r = 0;
    long z = 0;
    long t_3 = 0;
    long pos_2 = 0;
    long t_4 = 0;
    long done = 0;
    long r_2 = 0;
    long r_3 = 0;
    long from = p1;
    p = ir_arena;
    nt = (ir_nextemp + 3L);
    fnend = from;
    maxpos = 0L;
    cg_ra_used = 0L;
    t = 0L;
    while (t <= nt)
    {
        *cast(long*)(cg_temp_reg + (t << 3L)) = 0L;
        t = (t + 1L);
    }
    if ((opt_flags & 1024L) != 0L) goto L4563; else goto L4562;
L4562:
    return 0;
L4563:
    i = from;
L4564:
    if (i >= ir_next) goto L4566; else goto L4567;
L4567:
    if (*cast(long*)(p + (i << 3L)) == 37L) goto L4566; else goto L4565;
L4565:
    i = (i + 8L);
    goto L4564;
L4566:
    fnend = i;
    t_2 = 0L;
    while (t_2 <= nt)
    {
        *cast(long*)(cg_ra_fd + (t_2 << 3L)) = 0L;
        *cast(long*)(cg_ra_lu + (t_2 << 3L)) = 0L;
        *cast(long*)(cg_ra_bn + (t_2 << 3L)) = 0L;
        t_2 = (t_2 + 1L);
    }
    i_2 = from;
    pos = 1L;
L4572:
    if (i_2 >= fnend) goto L4574; else goto L4573;
L4573:
    op = *cast(long*)(p + (i_2 << 3L));
    d = *cast(long*)(p + ((i_2 + 1L) << 3L));
    if (op == 35L)
    {
        if (d > 0L)
        {
            *cast(long*)(cg_ra_fd + (d << 3L)) = (-1L);
        }
    }
    if (d > 0L)
    {
        if (op != 35L) goto L4579; else goto L4580;
L4579:
        if (*cast(long*)(cg_ra_fd + (d << 3L)) == 0L)
        {
            *cast(long*)(cg_ra_fd + (d << 3L)) = pos;
        }
        if (*cast(long*)(cg_ra_lu + (d << 3L)) < pos)
        {
            *cast(long*)(cg_ra_lu + (d << 3L)) = pos;
        }
    }
L4580:
    v0 = cg_ra_mark_uses(p, i_2, pos);
    if (op == 45L)
    {
        *cast(long*)(cg_ra_fd + (*cast(long*)(p + ((i_2 + 2L) << 3L)) << 3L)) = (-1L);
    }
    if (op == 32L)
    {
        *cast(long*)(cg_ra_lp + (*cast(long*)(p + ((i_2 + 2L) << 3L)) << 3L)) = pos;
        *cast(long*)(cg_ra_lpgen + (*cast(long*)(p + ((i_2 + 2L) << 3L)) << 3L)) = cg_curgen;
    }
    if (op == 30L)
    {
        v1 = cg_ra_backedge(*cast(long*)(p + ((i_2 + 5L) << 3L)), pos, nt);
    }
    if (op == 31L)
    {
        v2 = cg_ra_backedge(*cast(long*)(p + ((i_2 + 5L) << 3L)), pos, nt);
        v3 = cg_ra_backedge(*cast(long*)(p + ((i_2 + 6L) << 3L)), pos, nt);
    }
    maxpos = pos;
    pos = (pos + 1L);
    i_2 = (i_2 + 8L);
    goto L4572;
L4574:
    v4 = cast(long)__v18963.ptr;
    rtmp = v4;
    v5 = cast(long)__v18965.ptr;
    rreg = v5;
    *cast(long*)(rreg + (0L << 3L)) = 3L;
    *cast(long*)(rreg + (1L << 3L)) = 12L;
    *cast(long*)(rreg + (2L << 3L)) = 13L;
    *cast(long*)(rreg + (3L << 3L)) = 14L;
    *cast(long*)(rreg + (4L << 3L)) = 15L;
    r = 0L;
    while (r <= 4L)
    {
        *cast(long*)(rtmp + (r << 3L)) = 0L;
        r = (r + 1L);
    }
    z = 0L;
    while (z <= maxpos)
    {
        *cast(long*)(cg_ra_bk + (z << 3L)) = 0L;
        z = (z + 1L);
    }
    t_3 = 1L;
    while (t_3 <= nt)
    {
        if (*cast(long*)(cg_ra_fd + (t_3 << 3L)) > 0L)
        {
            *cast(long*)(cg_ra_bn + (t_3 << 3L)) = *cast(long*)(cg_ra_bk + (*cast(long*)(cg_ra_fd + (t_3 << 3L)) << 3L));
            *cast(long*)(cg_ra_bk + (*cast(long*)(cg_ra_fd + (t_3 << 3L)) << 3L)) = t_3;
        }
        t_3 = (t_3 + 1L);
    }
    pos_2 = 1L;
    while (pos_2 <= maxpos)
    {
        t_4 = *cast(long*)(cg_ra_bk + (pos_2 << 3L));
L4612:
        if (t_4 == 0L) goto L4614; else goto L4613;
L4613:
        done = 0L;
        r_2 = 0L;
        while (r_2 <= 4L)
        {
            if (*cast(long*)(rtmp + (r_2 << 3L)) != 0L)
            {
                if (*cast(long*)(cg_ra_lu + (*cast(long*)(rtmp + (r_2 << 3L)) << 3L)) < pos_2) goto L4619; else goto L4620;
L4619:
                *cast(long*)(rtmp + (r_2 << 3L)) = 0L;
            }
L4620:
            r_2 = (r_2 + 1L);
        }
        r_3 = 0L;
        while (r_3 <= 4L)
        {
            if (done != 0) goto L4627; else goto L4626;
L4626:
            if (*cast(long*)(rtmp + (r_3 << 3L)) == 0L)
            {
                *cast(long*)(rtmp + (r_3 << 3L)) = t_4;
                *cast(long*)(cg_temp_reg + (t_4 << 3L)) = *cast(long*)(rreg + (r_3 << 3L));
                cg_ra_used = (cg_ra_used | (1L << r_3));
                done = 1L;
            }
L4627:
            r_3 = (r_3 + 1L);
        }
        t_4 = *cast(long*)(cg_ra_bn + (t_4 << 3L));
    goto L4612;
L4614:
        pos_2 = (pos_2 + 1L);
    }
    return 0;
}
long cg_name_is(long p1 = 0, long p2 = 0)
{
    long i = 0;
    long ptr = p1;
    long literal = p2;
    if (ptr == 0L)
    {
        return 0L;
    }
    if (cast(long)*cast(ubyte*)(ptr + 0L) != cast(long)*cast(ubyte*)(literal + 0L))
    {
        return 0L;
    }
    i = 1L;
    while (i <= cast(long)*cast(ubyte*)(ptr + 0L))
    {
        if (cast(long)*cast(ubyte*)(ptr + i) != cast(long)*cast(ubyte*)(literal + i))
        {
            return 0L;
        }
        i = (i + 1L);
    }
    return 1L;
}
long axc(long p1 = 0)
{
    long v0 = 0;
    long c = p1;
    return binwrch(c);
}
long axs(long p1 = 0)
{
    long k = 0;
    long v0 = 0;
    long s = p1;
    k = 1L;
    while (k <= cast(long)*cast(ubyte*)(s + 0L))
    {
        v0 = binwrch(cast(long)*cast(ubyte*)(s + k));
        k = (k + 1L);
    }
    return 0;
}
long axhex(long p1 = 0)
{
    long v0 = 0;
    long dig = 0;
    long v1 = 0;
    long v2 = 0;
    long sh = 0;
    long v3 = 0;
    long n = p1;
    dig = cast(long)__s19661.ptr;
    v2 = axs(cast(long)__s19664.ptr);
    sh = 60L;
    while (sh >= 0L)
    {
        v3 = axc(cast(long)*cast(ubyte*)(dig + (((n >> sh) & 15L) + 1L)));
        sh = (sh + (-4L));
    }
    return 0;
}
long axn(long p1 = 0)
{
    long m = 0;
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long n = p1;
    if (n < 0L)
    {
        m = (-n);
        if (m < 0L)
        {
            v0 = axhex(n);
        }
        else
        {
            v1 = binwrch(45L);
            v2 = axn(m);
        }
    }
    else
    {
        if (n >= 10L)
        {
            v3 = axn((n / 10L));
        }
        v4 = binwrch((48L + (n % 10L)));
    }
    return 0;
}
long axnl()
{
    long v0 = 0;
    return binwrch(10L);
}
long ax_argreg(long p1 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long v6 = 0;
    long i = p1;
    if (i == 1L) goto L4721; else goto L4727;
L4727:
    if (i == 2L) goto L4722; else goto L4728;
L4728:
    if (i == 3L) goto L4723; else goto L4729;
L4729:
    if (i == 4L) goto L4724; else goto L4730;
L4730:
    if (i == 5L) goto L4725; else goto L4731;
L4731:
    if (i == 6L) goto L4726; else goto L4732;
L4732:
    goto L4720;
L4721:
    return cast(long)__s19726.ptr;
L4722:
    return cast(long)__s19727.ptr;
L4723:
    return cast(long)__s19728.ptr;
L4724:
    return cast(long)__s19729.ptr;
L4725:
    return cast(long)__s19730.ptr;
L4726:
    return cast(long)__s19731.ptr;
L4720:
    return cast(long)__s19732.ptr;
L4719:
    return 0;
}
long ax_slot_reset()
{
    ax_curgen = (ax_curgen + 1L);
    ax_slotnext = 12L;
    return 0;
}
long ax_slot_for(long p1 = 0)
{
    long t = p1;
    if (*cast(long*)(ax_slotgen + (t << 3L)) != ax_curgen)
    {
        *cast(long*)(ax_slotgen + (t << 3L)) = ax_curgen;
        *cast(long*)(ax_slotmap + (t << 3L)) = ax_slotnext;
        ax_slotnext = (ax_slotnext + 1L);
    }
    return *cast(long*)(ax_slotmap + (t << 3L));
}
long ax_regname(long p1 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long r = p1;
    if (r == 3L) goto L4737; else goto L4742;
L4742:
    if (r == 12L) goto L4738; else goto L4743;
L4743:
    if (r == 13L) goto L4739; else goto L4744;
L4744:
    if (r == 14L) goto L4740; else goto L4745;
L4745:
    if (r == 15L) goto L4741; else goto L4746;
L4746:
    goto L4736;
L4737:
    return cast(long)__s19777.ptr;
L4738:
    return cast(long)__s19778.ptr;
L4739:
    return cast(long)__s19779.ptr;
L4740:
    return cast(long)__s19780.ptr;
L4741:
    return cast(long)__s19781.ptr;
L4736:
    return cast(long)__s19782.ptr;
L4735:
    return 0;
}
long ax_mem(long p1 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long d = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long v6 = 0;
    long v7 = 0;
    long v8 = 0;
    long v9 = 0;
    long v10 = 0;
    long t = p1;
    if (*cast(long*)(cg_temp_reg + (t << 3L)) != 0L)
    {
        v1 = axs(ax_regname(*cast(long*)(cg_temp_reg + (t << 3L))));
    }
    else
    {
        d = (8L * ax_slot_for(t));
        if (d >= 0L)
        {
            v4 = axs(cast(long)__s19809.ptr);
            v5 = axn(d);
            v6 = axc(93L);
        }
        else
        {
            v8 = axs(cast(long)__s19817.ptr);
            v9 = axn((-d));
            v10 = axc(93L);
        }
    }
    return 0;
}
long ax_ld(long p1 = 0, long p2 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long v6 = 0;
    long reg = p1;
    long t = p2;
    v1 = axs(cast(long)__s19829.ptr);
    v2 = axs(reg);
    v4 = axs(cast(long)__s19834.ptr);
    v5 = ax_mem(t);
    v6 = axnl();
    return 0;
}
long ax_st(long p1 = 0, long p2 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long v6 = 0;
    long t = p1;
    long reg = p2;
    v1 = axs(cast(long)__s19844.ptr);
    v2 = ax_mem(t);
    v4 = axs(cast(long)__s19849.ptr);
    v5 = axs(reg);
    v6 = axnl();
    return 0;
}
long ax_const(long p1 = 0, long p2 = 0, long p3 = 0)
{
    long v0 = 0;
    long r = 0;
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
    long dst = p1;
    long v = p2;
    long marker = p3;
    if (marker == 1L)
    {
        *cast(long*)(ax_nametab + (dst << 3L)) = v;
    }
    else
    {
        *cast(long*)(ax_cis + (dst << 3L)) = 1L;
        *cast(long*)(ax_cval + (dst << 3L)) = v;
        if (*cast(long*)(cg_temp_reg + (dst << 3L)) != 0L)
        {
            r = ax_regname(*cast(long*)(cg_temp_reg + (dst << 3L)));
            if (v == 0L)
            {
                v2 = axs(cast(long)__s19892.ptr);
                v3 = axs(r);
                v5 = axs(cast(long)__s19897.ptr);
                v6 = axs(r);
                v7 = axnl();
            }
            else
            {
                v9 = axs(cast(long)__s19904.ptr);
                v10 = axs(r);
                v12 = axs(cast(long)__s19909.ptr);
                v13 = axn(v);
                v14 = axnl();
            }
        }
        else
        {
            v16 = axs(cast(long)__s19916.ptr);
            v17 = axn(v);
            v18 = axnl();
            v20 = ax_st(dst, cast(long)__s19923.ptr);
        }
    }
    return 0;
}
long ax_mov(long p1 = 0, long p2 = 0)
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
    long dst = p1;
    long a1 = p2;
    if (dst == a1)
    {
    }
    else
    {
        if (*cast(long*)(cg_temp_reg + (dst << 3L)) != 0L) goto L4765; else goto L4768;
L4768:
        if (*cast(long*)(cg_temp_reg + (a1 << 3L)) != 0L) goto L4765; else goto L4766;
L4765:
        v1 = axs(cast(long)__s19944.ptr);
        v2 = ax_mem(dst);
        v4 = axs(cast(long)__s19949.ptr);
        v5 = ax_mem(a1);
        v6 = axnl();
    goto L4767;
L4766:
        v8 = ax_ld(cast(long)__s19956.ptr, a1);
        v10 = ax_st(dst, cast(long)__s19959.ptr);
L4767:
    }
    return 0;
}
long ax_bin(long p1 = 0, long p2 = 0, long p3 = 0, long p4 = 0)
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
    long op = p1;
    long dst = p2;
    long a1 = p3;
    long a2 = p4;
    v1 = ax_ld(cast(long)__s19967.ptr, a1);
    v3 = axs(cast(long)__s19970.ptr);
    v4 = axs(op);
    v6 = axs(cast(long)__s19975.ptr);
    v7 = ax_mem(a2);
    v8 = axnl();
    v10 = ax_st(dst, cast(long)__s19982.ptr);
    return 0;
}
long ax_mul(long p1 = 0, long p2 = 0, long p3 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long v6 = 0;
    long v7 = 0;
    long dst = p1;
    long a1 = p2;
    long a2 = p3;
    v1 = ax_ld(cast(long)__s19989.ptr, a1);
    v3 = axs(cast(long)__s19992.ptr);
    v4 = ax_mem(a2);
    v5 = axnl();
    v7 = ax_st(dst, cast(long)__s19999.ptr);
    return 0;
}
long ax_log2(long p1 = 0)
{
    long k = 0;
    long x = 0;
    long v = p1;
    k = 0L;
    x = v;
    if (x <= 0L)
    {
        return (-1L);
    }
L4771:
    if (x == 1L) goto L4773; else goto L4772;
L4772:
    if ((x & 1L) != 0L)
    {
        return (-1L);
    }
    x = (x >> 1L);
    k = (k + 1L);
    goto L4771;
L4773:
    return k;
}
long ax_ult(long p1 = 0, long p2 = 0)
{
    long sa = 0;
    long sb = 0;
    long a = p1;
    long b = p2;
    sa = cast(long)(a < 0L);
    sb = cast(long)(b < 0L);
    if (sa == sb)
    {
        return cast(long)(a < b);
    }
    return sb;
}
long ax_udivmod(long p1 = 0, long p2 = 0, long p3 = 0)
{
    long q = 0;
    long r = 0;
    long i = 0;
    long v0 = 0;
    long num = p1;
    long den = p2;
    long remp = p3;
    q = 0L;
    r = 0L;
    i = 63L;
    while (i >= 0L)
    {
        r = (r << 1L);
        if (((num >> i) & 1L) != 0L)
        {
            r = (r | 1L);
        }
        if (ax_ult(r, den) != 0) goto L4785; else goto L4784;
L4784:
        r = (r - den);
        q = (q | (1L << i));
L4785:
        i = (i + (-1L));
    }
    *cast(long*)(remp + (0L << 3L)) = r;
    return q;
}
long ax_magic(long p1 = 0, long p2 = 0, long p3 = 0)
{
    long two63 = 0;
    long ad = 0;
    long t = 0;
    long[1] __v20074;
    long v0 = 0;
    long rv = 0;
    long anc = 0;
    long p = 0;
    long q1 = 0;
    long r1 = 0;
    long q2 = 0;
    long r2 = 0;
    long delta = 0;
    long more = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long v6 = 0;
    long d = p1;
    long Mp = p2;
    long sp = p3;
    two63 = long.min;
    ad = d;
    t = two63;
    v0 = cast(long)__v20074.ptr;
    rv = v0;
    anc = 0L;
    p = 63L;
    q1 = 0L;
    r1 = 0L;
    q2 = 0L;
    r2 = 0L;
    delta = 0L;
    more = 1L;
    if (ad < 0L)
    {
        ad = (-ad);
    }
    if (d < 0L)
    {
        t = (t + 1L);
    }
    v1 = ax_udivmod(t, ad, rv);
    anc = ((t - 1L) - *cast(long*)(rv + (0L << 3L)));
    q1 = ax_udivmod(two63, anc, rv);
    r1 = *cast(long*)(rv + (0L << 3L));
    q2 = ax_udivmod(two63, ad, rv);
    r2 = *cast(long*)(rv + (0L << 3L));
    while (more != 0)
    {
        p = (p + 1L);
        q1 = (q1 + q1);
        r1 = (r1 + r1);
        if (ax_ult(r1, anc) != 0) goto L4794; else goto L4793;
L4793:
        q1 = (q1 + 1L);
        r1 = (r1 - anc);
L4794:
        q2 = (q2 + q2);
        r2 = (r2 + r2);
        if (ax_ult(r2, ad) != 0) goto L4796; else goto L4795;
L4795:
        q2 = (q2 + 1L);
        r2 = (r2 - ad);
L4796:
        delta = (ad - r2);
        more = (ax_ult(q1, delta) | (cast(long)(q1 == delta) & cast(long)(r1 == 0L)));
    }
    *cast(long*)(Mp + (0L << 3L)) = (q2 + 1L);
    if (d < 0L)
    {
        *cast(long*)(Mp + (0L << 3L)) = (-*cast(long*)(Mp + (0L << 3L)));
    }
    *cast(long*)(sp + (0L << 3L)) = (p - 64L);
    return 0;
}
long ax_divmod_idiv(long p1 = 0, long p2 = 0, long p3 = 0, long p4 = 0)
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
    long dst = p1;
    long a1 = p2;
    long a2 = p3;
    long wantmod = p4;
    v1 = ax_ld(cast(long)__s20177.ptr, a1);
    v3 = axs(cast(long)__s20180.ptr);
    if (*cast(long*)(cg_temp_reg + (a2 << 3L)) != 0L)
    {
        v5 = axs(cast(long)__s20190.ptr);
        v7 = axs(ax_regname(*cast(long*)(cg_temp_reg + (a2 << 3L))));
        v8 = axnl();
    }
    else
    {
        v10 = axs(cast(long)__s20204.ptr);
        v11 = ax_mem(a2);
        v12 = axnl();
    }
    if (wantmod != 0)
    {
        v14 = cast(long)__s20212.ptr;
    }
    else
    {
        v14 = cast(long)__s20213.ptr;
    }
    v16 = ax_st(dst, v14);
    return 0;
}
long ax_div_pow2(long p1 = 0, long p2 = 0, long p3 = 0, long p4 = 0)
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
    long dst = p1;
    long a1 = p2;
    long k = p3;
    long wantmod = p4;
    v1 = ax_ld(cast(long)__s20221.ptr, a1);
    if (wantmod != 0)
    {
        v3 = ax_ld(cast(long)__s20224.ptr, a1);
    }
    v5 = axs(cast(long)__s20227.ptr);
    v7 = axs(cast(long)__s20230.ptr);
    v8 = axn((64L - k));
    v9 = axnl();
    v11 = axs(cast(long)__s20239.ptr);
    if (wantmod != 0)
    {
        v13 = axs(cast(long)__s20242.ptr);
        v14 = axn((-(1L << k)));
        v15 = axnl();
        v17 = axs(cast(long)__s20252.ptr);
        v19 = ax_st(dst, cast(long)__s20255.ptr);
    }
    else
    {
        v21 = axs(cast(long)__s20258.ptr);
        v22 = axn(k);
        v23 = axnl();
        v25 = ax_st(dst, cast(long)__s20265.ptr);
    }
    return 0;
}
long ax_magic_divmod(long p1 = 0, long p2 = 0, long p3 = 0, long p4 = 0, long p5 = 0)
{
    long[1] __v20273;
    long v0 = 0;
    long Mv = 0;
    long[1] __v20275;
    long v1 = 0;
    long sv = 0;
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
    long dst = p1;
    long a1 = p2;
    long a2 = p3;
    long d = p4;
    long wantmod = p5;
    v0 = cast(long)__v20273.ptr;
    Mv = v0;
    v1 = cast(long)__v20275.ptr;
    sv = v1;
    v2 = ax_magic(d, Mv, sv);
    v4 = ax_ld(cast(long)__s20280.ptr, a1);
    v6 = axs(cast(long)__s20283.ptr);
    v7 = axhex(*cast(long*)(Mv + (0L << 3L)));
    v8 = axnl();
    v10 = axs(cast(long)__s20295.ptr);
    if (d > 0L)
    {
        if (*cast(long*)(Mv + (0L << 3L)) < 0L) goto L4810; else goto L4811;
L4810:
        v12 = axs(cast(long)__s20307.ptr);
    }
L4811:
    if (d < 0L)
    {
        if (*cast(long*)(Mv + (0L << 3L)) > 0L) goto L4813; else goto L4814;
L4813:
        v14 = axs(cast(long)__s20319.ptr);
    }
L4814:
    if (*cast(long*)(sv + (0L << 3L)) > 0L)
    {
        v16 = axs(cast(long)__s20329.ptr);
        v17 = axn(*cast(long*)(sv + (0L << 3L)));
        v18 = axnl();
    }
    v20 = axs(cast(long)__s20341.ptr);
    v22 = axs(cast(long)__s20344.ptr);
    v24 = axs(cast(long)__s20347.ptr);
    if (wantmod != 0)
    {
        v26 = axs(cast(long)__s20350.ptr);
        v27 = ax_mem(a2);
        v28 = axnl();
        v30 = axs(cast(long)__s20357.ptr);
        v32 = axs(cast(long)__s20360.ptr);
        v34 = ax_st(dst, cast(long)__s20363.ptr);
    }
    else
    {
        v36 = ax_st(dst, cast(long)__s20366.ptr);
    }
    return 0;
}
long ax_divmod(long p1 = 0, long p2 = 0, long p3 = 0, long p4 = 0)
{
    long d = 0;
    long v0 = 0;
    long k = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long dst = p1;
    long a1 = p2;
    long a2 = p3;
    long wantmod = p4;
    if (*cast(long*)(ax_cis + (a2 << 3L)) != 0L)
    {
        d = *cast(long*)(ax_cval + (a2 << 3L));
        k = ax_log2(d);
        if (k >= 1L)
        {
            if (k <= 30L) goto L4824; else goto L4825;
L4824:
            v1 = ax_div_pow2(dst, a1, k, wantmod);
    goto L4826;
        }
L4825:
        if (d >= 3L) goto L4828; else goto L4831;
L4831:
        if (d <= (-3L)) goto L4828; else goto L4829;
L4828:
        v2 = ax_magic_divmod(dst, a1, a2, d, wantmod);
    goto L4830;
L4829:
        v3 = ax_divmod_idiv(dst, a1, a2, wantmod);
L4830:
L4826:
    }
    else
    {
        v4 = ax_divmod_idiv(dst, a1, a2, wantmod);
    }
    return 0;
}
long ax_shift(long p1 = 0, long p2 = 0, long p3 = 0, long p4 = 0)
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
    long dst = p1;
    long a1 = p2;
    long a2 = p3;
    long isleft = p4;
    v1 = ax_ld(cast(long)__s20412.ptr, a1);
    v3 = ax_ld(cast(long)__s20415.ptr, a2);
    if (isleft != 0)
    {
        v5 = cast(long)__s20419.ptr;
    }
    else
    {
        v5 = cast(long)__s20420.ptr;
    }
    v7 = axs(v5);
    v9 = ax_st(dst, cast(long)__s20423.ptr);
    return 0;
}
long ax_unary(long p1 = 0, long p2 = 0, long p3 = 0)
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
    long op = p1;
    long dst = p2;
    long a1 = p3;
    v1 = ax_ld(cast(long)__s20430.ptr, a1);
    v3 = axs(cast(long)__s20433.ptr);
    v4 = axs(op);
    v6 = axs(cast(long)__s20438.ptr);
    v8 = ax_st(dst, cast(long)__s20441.ptr);
    return 0;
}
long ax_setcc(long p1 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long kind = p1;
    if (kind == 1L) goto L4837; else goto L4842;
L4842:
    if (kind == 2L) goto L4838; else goto L4843;
L4843:
    if (kind == 3L) goto L4839; else goto L4844;
L4844:
    if (kind == 4L) goto L4840; else goto L4845;
L4845:
    if (kind == 5L) goto L4841; else goto L4846;
L4846:
    goto L4836;
L4837:
    return cast(long)__s20455.ptr;
L4838:
    return cast(long)__s20456.ptr;
L4839:
    return cast(long)__s20457.ptr;
L4840:
    return cast(long)__s20458.ptr;
L4841:
    return cast(long)__s20459.ptr;
L4836:
    return cast(long)__s20460.ptr;
L4835:
    return 0;
}
long ax_cmp(long p1 = 0, long p2 = 0, long p3 = 0, long p4 = 0)
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
    long dst = p1;
    long a1 = p2;
    long a2 = p3;
    long kind = p4;
    v1 = ax_ld(cast(long)__s20467.ptr, a1);
    v3 = axs(cast(long)__s20470.ptr);
    v4 = ax_mem(a2);
    v5 = axnl();
    v7 = axs(cast(long)__s20477.ptr);
    v9 = axs(ax_setcc(kind));
    v11 = axs(cast(long)__s20484.ptr);
    v13 = axs(cast(long)__s20487.ptr);
    v15 = ax_st(dst, cast(long)__s20490.ptr);
    return 0;
}
long ax_label(long p1 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long l = p1;
    v1 = axs(cast(long)__s20495.ptr);
    v2 = axn(l);
    v4 = axs(cast(long)__s20500.ptr);
    return 0;
}
long ax_jmp(long p1 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long l = p1;
    v1 = axs(cast(long)__s20505.ptr);
    v2 = axn(l);
    v3 = axnl();
    return 0;
}
long ax_br(long p1 = 0, long p2 = 0, long p3 = 0)
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
    long cond = p1;
    long lt = p2;
    long lf = p3;
    v1 = ax_ld(cast(long)__s20516.ptr, cond);
    v3 = axs(cast(long)__s20519.ptr);
    v5 = axs(cast(long)__s20522.ptr);
    v6 = axn(lt);
    v7 = axnl();
    v9 = axs(cast(long)__s20529.ptr);
    v10 = axn(lf);
    v11 = axnl();
    return 0;
}
long ax_call(long p1 = 0, long p2 = 0)
{
    long p = 0;
    long callee = 0;
    long argc = 0;
    long arg1 = 0;
    long arg2 = 0;
    long arg3 = 0;
    long name = 0;
    long v0 = 0;
    long wr = 0;
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
    long dst = p1;
    long ipos = p2;
    p = ir_arena;
    callee = *cast(long*)(p + ((ipos + 2L) << 3L));
    argc = *cast(long*)(p + ((ipos + 3L) << 3L));
    arg1 = *cast(long*)(p + ((ipos + 4L) << 3L));
    arg2 = *cast(long*)(p + ((ipos + 5L) << 3L));
    arg3 = *cast(long*)(p + ((ipos + 6L) << 3L));
    name = *cast(long*)(ax_nametab + (callee << 3L));
    wr = cast(long)__s20581.ptr;
    if (name != 0L)
    {
        if (cg_name_is(name, wr) != 0) goto L4850; else goto L4848;
L4850:
        if (arg1 != 0L) goto L4849; else goto L4848;
L4849:
        if (*cast(long*)(ax_strmeta + (arg1 << 3L)) >= 0L) goto L4847; else goto L4848;
L4847:
        v2 = ax_write_intrinsic(*cast(long*)(ax_strmeta + (arg1 << 3L)));
        if (dst > 0L)
        {
            v4 = axs(cast(long)__s20606.ptr);
            v6 = ax_st(dst, cast(long)__s20609.ptr);
        }
        return 0;
    }
L4848:
    if (argc >= 1L)
    {
        if (arg1 != 0L) goto L4854; else goto L4855;
L4854:
        v8 = ax_ld(ax_argreg(1L), arg1);
    }
L4855:
    if (argc >= 2L)
    {
        if (arg2 != 0L) goto L4857; else goto L4858;
L4857:
        v10 = ax_ld(ax_argreg(2L), arg2);
    }
L4858:
    if (argc >= 3L)
    {
        if (arg3 != 0L) goto L4860; else goto L4861;
L4860:
        v12 = ax_ld(ax_argreg(3L), arg3);
    }
L4861:
    if (name != 0L)
    {
        v14 = axs(cast(long)__s20641.ptr);
        v15 = axs(name);
        v16 = axnl();
    }
    else
    {
        v18 = ax_ld(cast(long)__s20648.ptr, callee);
        v20 = axs(cast(long)__s20651.ptr);
    }
    if (dst > 0L)
    {
        v22 = ax_st(dst, cast(long)__s20656.ptr);
    }
    return 0;
}
long ax_frame_bytes(long p1 = 0)
{
    long slots = 0;
    long nops = p1;
    slots = ((nops + 15L) + 12L);
    return (((slots * 8L) + 15L) & (~15L));
}
long ax_save_regs()
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
    if ((cg_ra_used & 1L) != 0L)
    {
        v1 = axs(cast(long)__s20679.ptr);
    }
    if ((cg_ra_used & 2L) != 0L)
    {
        v3 = axs(cast(long)__s20687.ptr);
    }
    if ((cg_ra_used & 4L) != 0L)
    {
        v5 = axs(cast(long)__s20695.ptr);
    }
    if ((cg_ra_used & 8L) != 0L)
    {
        v7 = axs(cast(long)__s20703.ptr);
    }
    if ((cg_ra_used & 16L) != 0L)
    {
        v9 = axs(cast(long)__s20711.ptr);
    }
    return 0;
}
long ax_restore_regs()
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
    if ((cg_ra_used & 1L) != 0L)
    {
        v1 = axs(cast(long)__s20720.ptr);
    }
    if ((cg_ra_used & 2L) != 0L)
    {
        v3 = axs(cast(long)__s20728.ptr);
    }
    if ((cg_ra_used & 4L) != 0L)
    {
        v5 = axs(cast(long)__s20736.ptr);
    }
    if ((cg_ra_used & 8L) != 0L)
    {
        v7 = axs(cast(long)__s20744.ptr);
    }
    if ((cg_ra_used & 16L) != 0L)
    {
        v9 = axs(cast(long)__s20752.ptr);
    }
    return 0;
}
long ax_prologue(long p1 = 0, long p2 = 0, long p3 = 0)
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
    long name = p1;
    long fbytes = p2;
    long nspill = p3;
    v0 = axs(name);
    v2 = axs(cast(long)__s20761.ptr);
    v4 = axs(cast(long)__s20764.ptr);
    v5 = axn(fbytes);
    v6 = axnl();
    if (nspill >= 1L)
    {
        v8 = axs(cast(long)__s20773.ptr);
    }
    if (nspill >= 2L)
    {
        v10 = axs(cast(long)__s20778.ptr);
    }
    if (nspill >= 3L)
    {
        v12 = axs(cast(long)__s20783.ptr);
    }
    if (nspill >= 4L)
    {
        v14 = axs(cast(long)__s20788.ptr);
    }
    if (nspill >= 5L)
    {
        v16 = axs(cast(long)__s20793.ptr);
    }
    if (nspill >= 6L)
    {
        v18 = axs(cast(long)__s20798.ptr);
    }
    v19 = ax_save_regs();
    return 0;
}
long ax_param(long p1 = 0, long p2 = 0)
{
    long v0 = 0;
    long dst = p1;
    long idx = p2;
    *cast(long*)(ax_slotgen + (dst << 3L)) = ax_curgen;
    if (idx <= 6L)
    {
        v0 = (7L - idx);
    }
    else
    {
        v0 = (-(idx - 5L));
    }
    *cast(long*)(ax_slotmap + (dst << 3L)) = v0;
    return 0;
}
long ax_setarg(long p1 = 0, long p2 = 0)
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
    long temp = p1;
    long idx = p2;
    if (idx <= 6L)
    {
        v1 = ax_ld(ax_argreg(idx), temp);
    }
    else
    {
        v3 = ax_ld(cast(long)__s20832.ptr, temp);
        v5 = axs(cast(long)__s20835.ptr);
        v6 = axn(((idx - 7L) * 8L));
        v8 = axs(cast(long)__s20844.ptr);
    }
    return 0;
}
long ax_return(long p1 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long v6 = 0;
    long a1 = p1;
    if (a1 != 0L)
    {
        v1 = ax_ld(cast(long)__s20851.ptr, a1);
    }
    else
    {
        v3 = axs(cast(long)__s20854.ptr);
    }
    v4 = ax_restore_regs();
    v6 = axs(cast(long)__s20859.ptr);
    return 0;
}
long ax_load(long p1 = 0, long p2 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long dst = p1;
    long a1 = p2;
    v1 = ax_ld(cast(long)__s20865.ptr, a1);
    v3 = axs(cast(long)__s20868.ptr);
    v5 = ax_st(dst, cast(long)__s20871.ptr);
    return 0;
}
long ax_store(long p1 = 0, long p2 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long a1 = p1;
    long a2 = p2;
    v1 = ax_ld(cast(long)__s20877.ptr, a2);
    v3 = ax_ld(cast(long)__s20880.ptr, a1);
    v5 = axs(cast(long)__s20883.ptr);
    return 0;
}
long ax_loadb(long p1 = 0, long p2 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long dst = p1;
    long a1 = p2;
    v1 = ax_ld(cast(long)__s20889.ptr, a1);
    v3 = axs(cast(long)__s20892.ptr);
    v5 = ax_st(dst, cast(long)__s20895.ptr);
    return 0;
}
long ax_storeb(long p1 = 0, long p2 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long a1 = p1;
    long a2 = p2;
    v1 = ax_ld(cast(long)__s20901.ptr, a2);
    v3 = ax_ld(cast(long)__s20904.ptr, a1);
    v5 = axs(cast(long)__s20907.ptr);
    return 0;
}
long ax_load2(long p1 = 0, long p2 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long dst = p1;
    long a1 = p2;
    v1 = ax_ld(cast(long)__s20913.ptr, a1);
    v3 = axs(cast(long)__s20916.ptr);
    v5 = ax_st(dst, cast(long)__s20919.ptr);
    return 0;
}
long ax_store2(long p1 = 0, long p2 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long a1 = p1;
    long a2 = p2;
    v1 = ax_ld(cast(long)__s20925.ptr, a2);
    v3 = ax_ld(cast(long)__s20928.ptr, a1);
    v5 = axs(cast(long)__s20931.ptr);
    return 0;
}
long ax_load4(long p1 = 0, long p2 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long dst = p1;
    long a1 = p2;
    v1 = ax_ld(cast(long)__s20937.ptr, a1);
    v3 = axs(cast(long)__s20940.ptr);
    v5 = ax_st(dst, cast(long)__s20943.ptr);
    return 0;
}
long ax_store4(long p1 = 0, long p2 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long a1 = p1;
    long a2 = p2;
    v1 = ax_ld(cast(long)__s20949.ptr, a2);
    v3 = ax_ld(cast(long)__s20952.ptr, a1);
    v5 = axs(cast(long)__s20955.ptr);
    return 0;
}
long ax_addr(long p1 = 0, long p2 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long dst = p1;
    long a1 = p2;
    v1 = axs(cast(long)__s20961.ptr);
    v2 = ax_mem(a1);
    v3 = axnl();
    v5 = ax_st(dst, cast(long)__s20968.ptr);
    return 0;
}
long ax_vecalloc(long p1 = 0, long p2 = 0)
{
    long words = 0;
    long bytes = 0;
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
    long dst = p1;
    long a1 = p2;
    words = (a1 + 1L);
    bytes = (words * 8L);
    if ((bytes & 15L) != 0L)
    {
        bytes = (bytes + 8L);
    }
    v1 = axs(cast(long)__s20986.ptr);
    v2 = axn(bytes);
    v3 = axnl();
    v5 = axs(cast(long)__s20993.ptr);
    v6 = axn((bytes / 8L));
    v7 = axnl();
    v9 = axs(cast(long)__s21002.ptr);
    v11 = axs(cast(long)__s21005.ptr);
    v13 = axs(cast(long)__s21008.ptr);
    v15 = axs(cast(long)__s21011.ptr);
    v17 = ax_st(dst, cast(long)__s21014.ptr);
    return 0;
}
long ax_stkalloc(long p1 = 0, long p2 = 0)
{
    long bytes = 0;
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long v6 = 0;
    long v7 = 0;
    long dst = p1;
    long a1 = p2;
    bytes = (32L + (a1 * 4L));
    if ((bytes & 15L) != 0L)
    {
        bytes = ((bytes + 15L) & (~15L));
    }
    v1 = axs(cast(long)__s21034.ptr);
    v2 = axn(bytes);
    v3 = axnl();
    v5 = axs(cast(long)__s21041.ptr);
    v7 = ax_st(dst, cast(long)__s21044.ptr);
    return 0;
}
long ax_strlit(long p1 = 0, long p2 = 0)
{
    long n = 0;
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
    long dst = p1;
    long a1 = p2;
    n = ax_strn;
    *cast(long*)(ax_strptr + (n << 3L)) = a1;
    ax_strn = (ax_strn + 1L);
    *cast(long*)(ax_strmeta + (dst << 3L)) = n;
    if (ax_pic != 0L)
    {
        v1 = axs(cast(long)__s21066.ptr);
        v2 = axn(n);
        v4 = axs(cast(long)__s21071.ptr);
    }
    else
    {
        v6 = axs(cast(long)__s21074.ptr);
        v7 = axn(n);
        v8 = axnl();
    }
    v10 = ax_st(dst, cast(long)__s21081.ptr);
    return 0;
}
long ax_write_intrinsic(long p1 = 0)
{
    long s = 0;
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
    long idx = p1;
    s = *cast(long*)(ax_strptr + (idx << 3L));
    v1 = axs(cast(long)__s21092.ptr);
    if (ax_pic != 0L)
    {
        v3 = axs(cast(long)__s21098.ptr);
        v4 = axn(idx);
        v6 = axs(cast(long)__s21103.ptr);
    }
    else
    {
        v8 = axs(cast(long)__s21106.ptr);
        v9 = axn(idx);
        v10 = axnl();
    }
    v12 = axs(cast(long)__s21113.ptr);
    v14 = axs(cast(long)__s21116.ptr);
    v15 = axn(cast(long)*cast(ubyte*)(s + 0L));
    v16 = axnl();
    v18 = axs(cast(long)__s21126.ptr);
    return 0;
}
long ax_emit_rodata()
{
    long v0 = 0;
    long v1 = 0;
    long n = 0;
    long s = 0;
    long col = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long v6 = 0;
    long j = 0;
    long v7 = 0;
    long v8 = 0;
    long v9 = 0;
    long v10 = 0;
    long v11 = 0;
    long v12 = 0;
    long v13 = 0;
    if (ax_strn > 0L)
    {
        v1 = axs(cast(long)__s21133.ptr);
        n = 0L;
        while (n <= (ax_strn - 1L))
        {
            s = *cast(long*)(ax_strptr + (n << 3L));
            col = 0L;
            v3 = axs(cast(long)__s21150.ptr);
            v4 = axn(n);
            v6 = axs(cast(long)__s21155.ptr);
            j = 0L;
            while (j <= cast(long)*cast(ubyte*)(s + 0L))
            {
                if (col == 0L)
                {
                    v8 = axs(cast(long)__s21166.ptr);
                }
                else
                {
                    v10 = axs(cast(long)__s21169.ptr);
                }
                v11 = axn(cast(long)*cast(ubyte*)(s + j));
                col = (col + 1L);
                if (col == 12L)
                {
                    v12 = axnl();
                    col = 0L;
                }
                j = (j + 1L);
            }
            if (col > 0L)
            {
                v13 = axnl();
            }
            n = (n + 1L);
        }
    }
    return 0;
}
long ax_fp_binop(long p1 = 0, long p2 = 0, long p3 = 0, long p4 = 0)
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
    long op = p1;
    long dst = p2;
    long a1 = p3;
    long a2 = p4;
    v1 = ax_ld(cast(long)__s21194.ptr, a1);
    v3 = axs(cast(long)__s21197.ptr);
    v5 = ax_ld(cast(long)__s21200.ptr, a2);
    v7 = axs(cast(long)__s21203.ptr);
    v9 = axs(cast(long)__s21206.ptr);
    v10 = axs(op);
    v12 = axs(cast(long)__s21211.ptr);
    v14 = axs(cast(long)__s21214.ptr);
    v16 = ax_st(dst, cast(long)__s21217.ptr);
    return 0;
}
long ax_fp_cmp(long p1 = 0, long p2 = 0, long p3 = 0, long p4 = 0)
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
    long dst = p1;
    long a1 = p2;
    long a2 = p3;
    long setcc = p4;
    v1 = ax_ld(cast(long)__s21225.ptr, a1);
    v3 = axs(cast(long)__s21228.ptr);
    v5 = ax_ld(cast(long)__s21231.ptr, a2);
    v7 = axs(cast(long)__s21234.ptr);
    v9 = axs(cast(long)__s21237.ptr);
    v11 = axs(cast(long)__s21240.ptr);
    v12 = axs(setcc);
    v14 = axs(cast(long)__s21245.ptr);
    v16 = ax_st(dst, cast(long)__s21248.ptr);
    return 0;
}
long ax_itof(long p1 = 0, long p2 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long dst = p1;
    long a1 = p2;
    v1 = ax_ld(cast(long)__s21254.ptr, a1);
    v3 = axs(cast(long)__s21257.ptr);
    v5 = ax_st(dst, cast(long)__s21260.ptr);
    return 0;
}
long ax_ftoi(long p1 = 0, long p2 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long dst = p1;
    long a1 = p2;
    v1 = ax_ld(cast(long)__s21266.ptr, a1);
    v3 = axs(cast(long)__s21269.ptr);
    v5 = ax_st(dst, cast(long)__s21272.ptr);
    return 0;
}
long ax_asmtext(long p1 = 0)
{
    long i = 0;
    long v0 = 0;
    long v1 = 0;
    long s = p1;
    i = 1L;
    while (i <= cast(long)*cast(ubyte*)(s + 0L))
    {
        v0 = binwrch(cast(long)*cast(ubyte*)(s + i));
        i = (i + 1L);
    }
    v1 = axnl();
    return 0;
}
long ax_sym_addr(long p1 = 0)
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
    long sym = p1;
    if (ax_pic != 0L)
    {
        v1 = axs(cast(long)__s21295.ptr);
        v2 = axs(sym);
        v4 = axs(cast(long)__s21300.ptr);
    }
    else
    {
        v6 = axs(cast(long)__s21303.ptr);
        v7 = axs(sym);
        v8 = axnl();
    }
    return 0;
}
long ax_glob_addr(long p1 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long slot = p1;
    v1 = ax_sym_addr(cast(long)__s21312.ptr);
    if (slot > 0L)
    {
        v3 = axs(cast(long)__s21317.ptr);
        v4 = axn((slot * 8L));
        v5 = axnl();
    }
    ax_uses_globals = 1L;
    return 0;
}
long ax_global(long p1 = 0, long p2 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long dst = p1;
    long slot = p2;
    v0 = ax_glob_addr(slot);
    v2 = axs(cast(long)__s21332.ptr);
    v4 = ax_st(dst, cast(long)__s21335.ptr);
    return 0;
}
long ax_globaddr(long p1 = 0, long p2 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long dst = p1;
    long slot = p2;
    v0 = ax_glob_addr(slot);
    v2 = ax_st(dst, cast(long)__s21343.ptr);
    return 0;
}
long ax_gstore(long p1 = 0, long p2 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long slot = p1;
    long val = p2;
    v1 = ax_ld(cast(long)__s21349.ptr, val);
    v2 = ax_glob_addr(slot);
    v4 = axs(cast(long)__s21354.ptr);
    return 0;
}
long ax_funcaddr(long p1 = 0, long p2 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long dst = p1;
    long name = p2;
    v0 = ax_sym_addr(name);
    v2 = ax_st(dst, cast(long)__s21362.ptr);
    return 0;
}
long ax_oomsg()
{
    long v0 = 0;
    return cast(long)__s21365.ptr;
}
long ax_emit_oomsg()
{
    long v0 = 0;
    long s = 0;
    long col = 0;
    long v1 = 0;
    long v2 = 0;
    long j = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long v6 = 0;
    long v7 = 0;
    long v8 = 0;
    long v9 = 0;
    long v10 = 0;
    long v11 = 0;
    s = ax_oomsg();
    col = 0L;
    v2 = axs(cast(long)__s21373.ptr);
    j = 1L;
    while (j <= cast(long)*cast(ubyte*)(s + 0L))
    {
        if (col == 0L)
        {
            v4 = axs(cast(long)__s21384.ptr);
        }
        else
        {
            v6 = axs(cast(long)__s21387.ptr);
        }
        v7 = axn(cast(long)*cast(ubyte*)(s + j));
        col = (col + 1L);
        if (col == 12L)
        {
            v8 = axnl();
            col = 0L;
        }
        j = (j + 1L);
    }
    if (col > 0L)
    {
        v9 = axnl();
    }
    v11 = axs(cast(long)__s21406.ptr);
    return 0;
}
long ax_emit_runtime()
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
    v1 = axs(cast(long)__s21410.ptr);
    v3 = axs(cast(long)__s21413.ptr);
    v5 = axs(cast(long)__s21416.ptr);
    v7 = axs(cast(long)__s21419.ptr);
    v9 = axs(cast(long)__s21422.ptr);
    v11 = axs(cast(long)__s21425.ptr);
    v13 = axs(cast(long)__s21428.ptr);
    v15 = axs(cast(long)__s21431.ptr);
    v17 = axs(cast(long)__s21434.ptr);
    v19 = axs(cast(long)__s21437.ptr);
    v21 = axs(cast(long)__s21440.ptr);
    v23 = axs(cast(long)__s21443.ptr);
    v25 = axs(cast(long)__s21446.ptr);
    v27 = axs(cast(long)__s21449.ptr);
    v29 = axs(cast(long)__s21452.ptr);
    v31 = axs(cast(long)__s21455.ptr);
    v33 = axs(cast(long)__s21458.ptr);
    v35 = axs(cast(long)__s21461.ptr);
    v37 = axs(cast(long)__s21464.ptr);
    v39 = axs(cast(long)__s21467.ptr);
    v41 = axs(cast(long)__s21470.ptr);
    v43 = axs(cast(long)__s21473.ptr);
    v45 = axs(cast(long)__s21476.ptr);
    v47 = axs(cast(long)__s21479.ptr);
    v49 = axs(cast(long)__s21482.ptr);
    v51 = axs(cast(long)__s21485.ptr);
    v53 = axs(cast(long)__s21488.ptr);
    v55 = axs(cast(long)__s21491.ptr);
    v57 = axs(cast(long)__s21494.ptr);
    v59 = axs(cast(long)__s21497.ptr);
    v61 = axs(cast(long)__s21500.ptr);
    v63 = axs(cast(long)__s21503.ptr);
    v65 = axs(cast(long)__s21506.ptr);
    v67 = axs(cast(long)__s21509.ptr);
    v69 = axs(cast(long)__s21512.ptr);
    v71 = axs(cast(long)__s21515.ptr);
    v73 = axs(cast(long)__s21518.ptr);
    v75 = axs(cast(long)__s21521.ptr);
    v77 = axs(cast(long)__s21524.ptr);
    v79 = axs(cast(long)__s21527.ptr);
    v81 = axs(cast(long)__s21530.ptr);
    v83 = axs(cast(long)__s21533.ptr);
    v85 = axs(cast(long)__s21536.ptr);
    v87 = axs(cast(long)__s21539.ptr);
    v89 = axs(cast(long)__s21542.ptr);
    v91 = axs(cast(long)__s21545.ptr);
    v93 = ax_sym_addr(cast(long)__s21548.ptr);
    v95 = axs(cast(long)__s21551.ptr);
    v97 = axs(cast(long)__s21554.ptr);
    v99 = ax_sym_addr(cast(long)__s21557.ptr);
    v101 = axs(cast(long)__s21560.ptr);
    v103 = axs(cast(long)__s21563.ptr);
    v105 = ax_sym_addr(cast(long)__s21566.ptr);
    v107 = axs(cast(long)__s21569.ptr);
    v109 = axs(cast(long)__s21572.ptr);
    v111 = axs(cast(long)__s21575.ptr);
    v113 = axs(cast(long)__s21578.ptr);
    v115 = ax_sym_addr(cast(long)__s21581.ptr);
    v117 = axs(cast(long)__s21584.ptr);
    v119 = axn(cast(long)*cast(ubyte*)(ax_oomsg() + 0L));
    v120 = axnl();
    v122 = axs(cast(long)__s21596.ptr);
    v124 = axs(cast(long)__s21599.ptr);
    v126 = axs(cast(long)__s21602.ptr);
    v128 = axs(cast(long)__s21605.ptr);
    v130 = axs(cast(long)__s21608.ptr);
    v131 = ax_emit_oomsg();
    return 0;
}
long ax_emit_bss()
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
    v1 = axs(cast(long)__s21614.ptr);
    v3 = axs(cast(long)__s21617.ptr);
    v4 = axn(524288L);
    v5 = axnl();
    v7 = axs(cast(long)__s21625.ptr);
    v9 = axs(cast(long)__s21628.ptr);
    v10 = axn(67108864L);
    v11 = axnl();
    v13 = axs(cast(long)__s21636.ptr);
    return 0;
}
long ax_vfill(long p1 = 0, long p2 = 0, long p3 = 0)
{
    long v0 = 0;
    long ltop = 0;
    long v1 = 0;
    long lrem = 0;
    long v2 = 0;
    long ldone = 0;
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
    long addrT = p1;
    long countT = p2;
    long valueT = p3;
    ltop = ir_new_label();
    lrem = ir_new_label();
    ldone = ir_new_label();
    v4 = ax_ld(cast(long)__s21652.ptr, addrT);
    v6 = ax_ld(cast(long)__s21655.ptr, countT);
    v8 = ax_ld(cast(long)__s21658.ptr, valueT);
    v10 = axs(cast(long)__s21661.ptr);
    v12 = axs(cast(long)__s21664.ptr);
    v13 = ax_label(ltop);
    v15 = axs(cast(long)__s21669.ptr);
    v17 = axs(cast(long)__s21672.ptr);
    v18 = axn(lrem);
    v19 = axnl();
    v21 = axs(cast(long)__s21679.ptr);
    v23 = axs(cast(long)__s21682.ptr);
    v25 = axs(cast(long)__s21685.ptr);
    v27 = axs(cast(long)__s21688.ptr);
    v28 = axn(ltop);
    v29 = axnl();
    v30 = ax_label(lrem);
    v32 = axs(cast(long)__s21697.ptr);
    v34 = axs(cast(long)__s21700.ptr);
    v35 = axn(ldone);
    v36 = axnl();
    v38 = axs(cast(long)__s21707.ptr);
    v39 = ax_label(ldone);
    return 0;
}
long ax_vcopy(long p1 = 0, long p2 = 0, long p3 = 0)
{
    long v0 = 0;
    long lsimd = 0;
    long v1 = 0;
    long lscal = 0;
    long v2 = 0;
    long srem = 0;
    long v3 = 0;
    long ldone = 0;
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
    long dstT = p1;
    long srcT = p2;
    long countT = p3;
    lsimd = ir_new_label();
    lscal = ir_new_label();
    srem = ir_new_label();
    ldone = ir_new_label();
    v5 = ax_ld(cast(long)__s21728.ptr, dstT);
    v7 = ax_ld(cast(long)__s21731.ptr, srcT);
    v9 = ax_ld(cast(long)__s21734.ptr, countT);
    v11 = axs(cast(long)__s21737.ptr);
    v13 = axs(cast(long)__s21740.ptr);
    v14 = axn(lsimd);
    v15 = axnl();
    v17 = axs(cast(long)__s21747.ptr);
    v19 = axs(cast(long)__s21750.ptr);
    v21 = axs(cast(long)__s21753.ptr);
    v22 = axn(lsimd);
    v23 = axnl();
    v25 = axs(cast(long)__s21760.ptr);
    v26 = axn(lscal);
    v27 = axnl();
    v28 = ax_label(lsimd);
    v30 = axs(cast(long)__s21769.ptr);
    v32 = axs(cast(long)__s21772.ptr);
    v33 = axn(srem);
    v34 = axnl();
    v36 = axs(cast(long)__s21779.ptr);
    v38 = axs(cast(long)__s21782.ptr);
    v40 = axs(cast(long)__s21785.ptr);
    v41 = axn(lsimd);
    v42 = axnl();
    v43 = ax_label(srem);
    v45 = axs(cast(long)__s21794.ptr);
    v47 = axs(cast(long)__s21797.ptr);
    v48 = axn(ldone);
    v49 = axnl();
    v51 = axs(cast(long)__s21804.ptr);
    v53 = axs(cast(long)__s21807.ptr);
    v54 = axn(ldone);
    v55 = axnl();
    v56 = ax_label(lscal);
    v58 = axs(cast(long)__s21816.ptr);
    v60 = axs(cast(long)__s21819.ptr);
    v61 = axn(ldone);
    v62 = axnl();
    v64 = axs(cast(long)__s21826.ptr);
    v66 = axs(cast(long)__s21829.ptr);
    v68 = axs(cast(long)__s21832.ptr);
    v69 = axn(lscal);
    v70 = axnl();
    v71 = ax_label(ldone);
    return 0;
}
long ax_vmap(long p1 = 0, long p2 = 0, long p3 = 0, long p4 = 0, long p5 = 0)
{
    long v0 = 0;
    long lsimd = 0;
    long v1 = 0;
    long lscal = 0;
    long v2 = 0;
    long srem = 0;
    long v3 = 0;
    long ldone = 0;
    long v4 = 0;
    long v5 = 0;
    long v6 = 0;
    long pop = 0;
    long v7 = 0;
    long v8 = 0;
    long v9 = 0;
    long sop = 0;
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
    long dstT = p1;
    long srcT = p2;
    long scalarT = p3;
    long countT = p4;
    long isSub = p5;
    lsimd = ir_new_label();
    lscal = ir_new_label();
    srem = ir_new_label();
    ldone = ir_new_label();
    if (isSub != 0)
    {
        v5 = cast(long)__s21859.ptr;
    }
    else
    {
        v5 = cast(long)__s21860.ptr;
    }
    pop = v5;
    if (isSub != 0)
    {
        v8 = cast(long)__s21863.ptr;
    }
    else
    {
        v8 = cast(long)__s21864.ptr;
    }
    sop = v8;
    v11 = ax_ld(cast(long)__s21867.ptr, dstT);
    v13 = ax_ld(cast(long)__s21870.ptr, srcT);
    v15 = ax_ld(cast(long)__s21873.ptr, countT);
    v17 = ax_ld(cast(long)__s21876.ptr, scalarT);
    v19 = axs(cast(long)__s21879.ptr);
    v21 = axs(cast(long)__s21882.ptr);
    v23 = axs(cast(long)__s21885.ptr);
    v24 = axn(lsimd);
    v25 = axnl();
    v27 = axs(cast(long)__s21892.ptr);
    v29 = axs(cast(long)__s21895.ptr);
    v31 = axs(cast(long)__s21898.ptr);
    v32 = axn(lsimd);
    v33 = axnl();
    v35 = axs(cast(long)__s21905.ptr);
    v36 = axn(lscal);
    v37 = axnl();
    v38 = ax_label(lsimd);
    v40 = axs(cast(long)__s21914.ptr);
    v42 = axs(cast(long)__s21917.ptr);
    v43 = axn(srem);
    v44 = axnl();
    v46 = axs(cast(long)__s21924.ptr);
    v47 = axs(pop);
    v49 = axs(cast(long)__s21929.ptr);
    v51 = axs(cast(long)__s21932.ptr);
    v53 = axs(cast(long)__s21935.ptr);
    v54 = axn(lsimd);
    v55 = axnl();
    v56 = ax_label(srem);
    v58 = axs(cast(long)__s21944.ptr);
    v60 = axs(cast(long)__s21947.ptr);
    v61 = axn(ldone);
    v62 = axnl();
    v64 = axs(cast(long)__s21954.ptr);
    v66 = ax_ld(cast(long)__s21957.ptr, scalarT);
    v68 = axs(cast(long)__s21960.ptr);
    v69 = axs(sop);
    v71 = axs(cast(long)__s21965.ptr);
    v73 = axs(cast(long)__s21968.ptr);
    v74 = axn(ldone);
    v75 = axnl();
    v76 = ax_label(lscal);
    v78 = axs(cast(long)__s21977.ptr);
    v80 = axs(cast(long)__s21980.ptr);
    v81 = axn(ldone);
    v82 = axnl();
    v84 = axs(cast(long)__s21987.ptr);
    v86 = ax_ld(cast(long)__s21990.ptr, scalarT);
    v88 = axs(cast(long)__s21993.ptr);
    v89 = axs(sop);
    v91 = axs(cast(long)__s21998.ptr);
    v93 = axs(cast(long)__s22001.ptr);
    v95 = axs(cast(long)__s22004.ptr);
    v96 = axn(lscal);
    v97 = axnl();
    v98 = ax_label(ldone);
    return 0;
}
long ax_function_body(long p1 = 0, long p2 = 0, long p3 = 0)
{
    long p = 0;
    long i = 0;
    long nops = 0;
    long nspill = 0;
    long j = 0;
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long op = 0;
    long dst = 0;
    long a1 = 0;
    long a2 = 0;
    long a3 = 0;
    long l1 = 0;
    long l2 = 0;
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
    long from = p1;
    long name = p2;
    long argc = p3;
    p = ir_arena;
    i = from;
    nops = 0L;
    nspill = argc;
    j = from;
L4962:
    if (j >= ir_next) goto L4964; else goto L4965;
L4965:
    if (*cast(long*)(p + (j << 3L)) == 37L) goto L4964; else goto L4963;
L4963:
    nops = (nops + 1L);
    if (*cast(long*)(p + (j << 3L)) == 45L)
    {
        nspill = 6L;
    }
    j = (j + 8L);
    goto L4962;
L4964:
    if (nspill < 0L)
    {
        nspill = 0L;
    }
    if (nspill > 6L)
    {
        nspill = 6L;
    }
    v0 = ax_slot_reset();
    cg_curgen = (cg_curgen + 1L);
    v1 = cg_regalloc(from);
    v3 = ax_prologue(name, ax_frame_bytes(nops), nspill);
L4972:
    if (i >= ir_next) goto L4974; else goto L4973;
L4973:
    op = *cast(long*)(p + (i << 3L));
    dst = *cast(long*)(p + ((i + 1L) << 3L));
    a1 = *cast(long*)(p + ((i + 2L) << 3L));
    a2 = *cast(long*)(p + ((i + 3L) << 3L));
    a3 = *cast(long*)(p + ((i + 4L) << 3L));
    l1 = *cast(long*)(p + ((i + 5L) << 3L));
    l2 = *cast(long*)(p + ((i + 6L) << 3L));
    if (op == 37L)
    {
        v4 = ax_restore_regs();
        v6 = axs(cast(long)__s22113.ptr);
        i = (i + 8L);
        return i;
    }
    if (op == 35L)
    {
        v7 = ax_param(dst, a1);
    }
    if (op == 1L)
    {
        v8 = ax_const(dst, a1, a2);
    }
    if (op == 39L)
    {
        v9 = ax_mov(dst, a1);
    }
    if (op == 4L)
    {
        v11 = ax_bin(cast(long)__s22132.ptr, dst, a1, a2);
    }
    if (op == 5L)
    {
        v13 = ax_bin(cast(long)__s22137.ptr, dst, a1, a2);
    }
    if (op == 9L)
    {
        v15 = ax_bin(cast(long)__s22142.ptr, dst, a1, a2);
    }
    if (op == 10L)
    {
        v17 = ax_bin(cast(long)__s22147.ptr, dst, a1, a2);
    }
    if (op == 11L)
    {
        v19 = ax_bin(cast(long)__s22152.ptr, dst, a1, a2);
    }
    if (op == 6L)
    {
        v20 = ax_mul(dst, a1, a2);
    }
    if (op == 7L)
    {
        v21 = ax_divmod(dst, a1, a2, 0L);
    }
    if (op == 8L)
    {
        v22 = ax_divmod(dst, a1, a2, 1L);
    }
    if (op == 13L)
    {
        v23 = ax_shift(dst, a1, a2, 1L);
    }
    if (op == 14L)
    {
        v24 = ax_shift(dst, a1, a2, 0L);
    }
    if (op == 26L)
    {
        v26 = ax_unary(cast(long)__s22181.ptr, dst, a1);
    }
    if (op == 12L)
    {
        v28 = ax_unary(cast(long)__s22186.ptr, dst, a1);
    }
    if (op == 20L)
    {
        v29 = ax_cmp(dst, a1, a2, 1L);
    }
    if (op == 21L)
    {
        v30 = ax_cmp(dst, a1, a2, 2L);
    }
    if (op == 22L)
    {
        v31 = ax_cmp(dst, a1, a2, 3L);
    }
    if (op == 23L)
    {
        v32 = ax_cmp(dst, a1, a2, 4L);
    }
    if (op == 24L)
    {
        v33 = ax_cmp(dst, a1, a2, 5L);
    }
    if (op == 25L)
    {
        v34 = ax_cmp(dst, a1, a2, 6L);
    }
    if (op == 32L)
    {
        v35 = ax_label(a1);
    }
    if (op == 30L)
    {
        v36 = ax_jmp(l1);
    }
    if (op == 31L)
    {
        v37 = ax_br(a1, l1, l2);
    }
    if (op == 47L)
    {
        v38 = ax_setarg(a1, a2);
    }
    if (op == 33L)
    {
        v39 = ax_call(dst, i);
    }
    if (op == 2L)
    {
        v40 = ax_load(dst, a1);
    }
    if (op == 3L)
    {
        v41 = ax_store(a1, a2);
    }
    if (op == 43L)
    {
        v42 = ax_loadb(dst, a1);
    }
    if (op == 44L)
    {
        v43 = ax_storeb(a1, a2);
    }
    if (op == 68L)
    {
        v44 = ax_load2(dst, a1);
    }
    if (op == 69L)
    {
        v45 = ax_store2(a1, a2);
    }
    if (op == 70L)
    {
        v46 = ax_load4(dst, a1);
    }
    if (op == 71L)
    {
        v47 = ax_store4(a1, a2);
    }
    if (op == 72L)
    {
        v48 = ax_asmtext(a1);
    }
    if (op == 45L)
    {
        v49 = ax_addr(dst, a1);
    }
    if (op == 42L)
    {
        v50 = ax_vecalloc(dst, a1);
    }
    if (op == 48L)
    {
        v51 = ax_stkalloc(dst, a1);
    }
    if (op == 38L)
    {
        v52 = ax_strlit(dst, a1);
    }
    if (op == 51L)
    {
        v54 = ax_fp_binop(cast(long)__s22293.ptr, dst, a1, a2);
    }
    if (op == 52L)
    {
        v56 = ax_fp_binop(cast(long)__s22298.ptr, dst, a1, a2);
    }
    if (op == 53L)
    {
        v58 = ax_fp_binop(cast(long)__s22303.ptr, dst, a1, a2);
    }
    if (op == 54L)
    {
        v60 = ax_fp_binop(cast(long)__s22308.ptr, dst, a1, a2);
    }
    if (op == 55L)
    {
        v62 = ax_fp_cmp(dst, a1, a2, cast(long)__s22313.ptr);
    }
    if (op == 56L)
    {
        v64 = ax_fp_cmp(dst, a1, a2, cast(long)__s22318.ptr);
    }
    if (op == 57L)
    {
        v66 = ax_fp_cmp(dst, a1, a2, cast(long)__s22323.ptr);
    }
    if (op == 58L)
    {
        v68 = ax_fp_cmp(dst, a1, a2, cast(long)__s22328.ptr);
    }
    if (op == 59L)
    {
        v70 = ax_fp_cmp(dst, a1, a2, cast(long)__s22333.ptr);
    }
    if (op == 60L)
    {
        v72 = ax_fp_cmp(dst, a1, a2, cast(long)__s22338.ptr);
    }
    if (op == 61L)
    {
        v73 = ax_itof(dst, a1);
    }
    if (op == 62L)
    {
        v74 = ax_ftoi(dst, a1);
    }
    if (op == 40L)
    {
        v75 = ax_global(dst, a1);
    }
    if (op == 49L)
    {
        v76 = ax_globaddr(dst, a1);
    }
    if (op == 41L)
    {
        v77 = ax_gstore(a1, a2);
    }
    if (op == 50L)
    {
        v78 = ax_funcaddr(dst, a2);
    }
    if (op == 63L)
    {
        v79 = ax_vfill(a1, a2, a3);
    }
    if (op == 64L)
    {
        v80 = ax_vcopy(a1, a2, a3);
    }
    if (op == 65L)
    {
        v81 = ax_vmap(a1, a2, a3, dst, 0L);
    }
    if (op == 66L)
    {
        v82 = ax_vmap(a1, a2, a3, dst, 1L);
    }
    if (op == 34L)
    {
        v83 = ax_return(a1);
    }
    i = (i + 8L);
    goto L4972;
L4974:
    return i;
}
long cg_x86asm_emit(long p1 = 0)
{
    long p = 0;
    long i = 0;
    long v0 = 0;
    long out_ = 0;
    long prev = 0;
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
    long t = 0;
    long l = 0;
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
    long op = 0;
    long v37 = 0;
    long v38 = 0;
    long v39 = 0;
    long v40 = 0;
    long v41 = 0;
    long v42 = 0;
    long v43 = 0;
    long v44 = 0;
    long outname = p1;
    p = ir_arena;
    i = 1L;
    out_ = findoutput(outname);
    prev = 0L;
    if (out_ != 0) goto L5098; else goto L5097;
L5097:
    v2 = writes(cast(long)__s22400.ptr);
    return 0;
L5098:
    ax_slotgen = getvec((262144L + 4L));
    ax_slotmap = getvec((262144L + 4L));
    ax_nametab = getvec((262144L + 4L));
    ax_strptr = getvec(4096L);
    ax_strn = 0L;
    ax_uses_globals = 0L;
    ax_strmeta = getvec((262144L + 4L));
    ax_cis = getvec((262144L + 4L));
    ax_cval = getvec((262144L + 4L));
    cg_temp_reg = getvec((262144L + 4L));
    cg_ra_fd = getvec((262144L + 4L));
    cg_ra_lu = getvec((262144L + 4L));
    cg_ra_bk = getvec((262144L + 4L));
    cg_ra_bn = getvec((262144L + 4L));
    cg_ra_lp = getvec((16384L + 4L));
    cg_ra_lpgen = getvec((16384L + 4L));
    cg_curgen = 0L;
    t = 0L;
    while (t <= (262144L + 3L))
    {
        *cast(long*)(ax_slotgen + (t << 3L)) = 0L;
        *cast(long*)(ax_nametab + (t << 3L)) = 0L;
        *cast(long*)(ax_strmeta + (t << 3L)) = (-1L);
        *cast(long*)(ax_cis + (t << 3L)) = 0L;
        t = (t + 1L);
    }
    l = 0L;
    while (l <= (16384L + 3L))
    {
        *cast(long*)(cg_ra_lpgen + (l << 3L)) = 0L;
        l = (l + 1L);
    }
    ax_curgen = 0L;
    prev = output();
    v18 = selectoutput(out_);
    v20 = axs(cast(long)__s22519.ptr);
    v22 = axs(cast(long)__s22522.ptr);
    v24 = axs(cast(long)__s22525.ptr);
    v26 = axs(cast(long)__s22528.ptr);
    v28 = axs(cast(long)__s22531.ptr);
    v30 = ax_sym_addr(cast(long)__s22534.ptr);
    v32 = axs(cast(long)__s22537.ptr);
    v34 = axs(cast(long)__s22540.ptr);
    v36 = axs(cast(long)__s22543.ptr);
L5107:
    if (i >= ir_next) goto L5109; else goto L5108;
L5108:
    op = *cast(long*)(p + (i << 3L));
    if (op == 36L)
    {
        i = ax_function_body((i + 8L), *cast(long*)(p + ((i + 3L) << 3L)), *cast(long*)(p + ((i + 2L) << 3L)));
    }
    else
    {
        i = (i + 8L);
    }
    goto L5107;
L5109:
    v38 = ax_emit_runtime();
    v39 = ax_emit_rodata();
    v40 = ax_emit_bss();
    v41 = endwrite();
    v42 = selectoutput(prev);
    // "just empty" on success; opt_verbose brings it all back.
    if (opt_verbose != 0) v44 = writef(cast(long)__s22583.ptr, outname);
    return 0;
}
long cg_backend_has_vfill()
{
    return 1L;
}
long cg_jit_function(long p1 = 0)
{
    long name = p1;
    return 0L;
}
long cg_compile_to_elf64(long p1 = 0)
{
    long v0 = 0;
    long outname = p1;
    return cg_x86asm_emit(outname);
}
