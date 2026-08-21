// Generated from BCPL by cg-d.b, split into modules by split.d.
module hofos.nnopt;

import hofos.all;

long nn_mul(long p1 = 0, long p2 = 0)
{
    long a = p1;
    long b = p2;
    return ((a * b) / 65536L);
}
long nn_relu(long p1 = 0)
{
    long v0 = 0;
    long x = p1;
    if (x < 0L)
    {
        v0 = 0L;
    }
    else
    {
        v0 = x;
    }
    return v0;
}
long nn_rand()
{
    nn_seed = (((nn_seed * 1103515245L) + 12345L) & 1073741823L);
    return nn_seed;
}
long nn_rweight()
{
    long v0 = 0;
    return ((nn_rand() % (65536L / 2L)) - (65536L / 4L));
}
long nn_action(long p1 = 0)
{
    long base = 0;
    long k = p1;
    base = (16L | 32L);
    if (k == 0L) goto L4108; else goto L4115;
L4115:
    if (k == 1L) goto L4109; else goto L4116;
L4116:
    if (k == 2L) goto L4110; else goto L4117;
L4117:
    if (k == 3L) goto L4111; else goto L4118;
L4118:
    if (k == 4L) goto L4112; else goto L4119;
L4119:
    if (k == 5L) goto L4113; else goto L4120;
L4120:
    if (k == 6L) goto L4114; else goto L4121;
L4121:
    goto L4107;
L4108:
    return base;
L4109:
    return (base | 64L);
L4110:
    return ((base | 64L) | 2048L);
L4111:
    return (((base | 64L) | 2048L) | 16384L);
L4112:
    return (((base | 64L) | 2048L) | 4096L);
L4113:
    return ((((base | 64L) | 2048L) | 16384L) | 4096L);
L4114:
    return (((((base | 64L) | 2048L) | 16384L) | 4096L) | 1L);
L4107:
    return ((((((base | 64L) | 2048L) | 16384L) | 4096L) | 1L) | 2L);
L4106:
    return 0;
}
long nn_features()
{
    long p = 0;
    long i = 0;
    long n = 0;
    long arith = 0;
    long cmps = 0;
    long brs = 0;
    long calls = 0;
    long mems = 0;
    long consts = 0;
    long movs = 0;
    long backj = 0;
    long funcs = 0;
    long k = 0;
    long op = 0;
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    p = ir_arena;
    i = 1L;
    n = 0L;
    arith = 0L;
    cmps = 0L;
    brs = 0L;
    calls = 0L;
    mems = 0L;
    consts = 0L;
    movs = 0L;
    backj = 0L;
    funcs = 0L;
    k = 0L;
    while (k <= (16L - 1L))
    {
        *cast(long*)(nn_feat + (k << 3L)) = 0L;
        k = (k + 1L);
    }
L4126:
    if (i >= ir_next) goto L4128; else goto L4127;
L4127:
    op = *cast(long*)(p + (i << 3L));
    n = (n + 1L);
    if (op == 4L) goto L4129; else goto L4139;
L4139:
    if (op == 5L) goto L4129; else goto L4138;
L4138:
    if (op == 6L) goto L4129; else goto L4137;
L4137:
    if (op == 7L) goto L4129; else goto L4136;
L4136:
    if (op == 8L) goto L4129; else goto L4135;
L4135:
    if (op == 9L) goto L4129; else goto L4134;
L4134:
    if (op == 10L) goto L4129; else goto L4133;
L4133:
    if (op == 11L) goto L4129; else goto L4132;
L4132:
    if (op == 26L) goto L4129; else goto L4131;
L4131:
    if (op == 12L) goto L4129; else goto L4130;
L4129:
    arith = (arith + 1L);
L4130:
    if (op == 20L) goto L4140; else goto L4146;
L4146:
    if (op == 21L) goto L4140; else goto L4145;
L4145:
    if (op == 22L) goto L4140; else goto L4144;
L4144:
    if (op == 23L) goto L4140; else goto L4143;
L4143:
    if (op == 24L) goto L4140; else goto L4142;
L4142:
    if (op == 25L) goto L4140; else goto L4141;
L4140:
    cmps = (cmps + 1L);
L4141:
    if (op == 31L) goto L4147; else goto L4149;
L4149:
    if (op == 30L) goto L4147; else goto L4148;
L4147:
    brs = (brs + 1L);
L4148:
    if (op == 33L)
    {
        calls = (calls + 1L);
    }
    if (op == 2L) goto L4152; else goto L4155;
L4155:
    if (op == 3L) goto L4152; else goto L4154;
L4154:
    if (op == 42L) goto L4152; else goto L4153;
L4152:
    mems = (mems + 1L);
L4153:
    if (op == 1L)
    {
        consts = (consts + 1L);
    }
    if (op == 39L)
    {
        movs = (movs + 1L);
    }
    if (op == 36L)
    {
        funcs = (funcs + 1L);
    }
    if (op == 30L)
    {
        if (*cast(long*)(p + ((i + 5L) << 3L)) < *cast(long*)(p + ((i + 1L) << 3L))) goto L4162; else goto L4163;
L4162:
        backj = (backj + 1L);
    }
L4163:
    i = (i + 8L);
    goto L4126;
L4128:
    if (n == 0L)
    {
        n = 1L;
    }
    *cast(long*)(nn_feat + (0L << 3L)) = ((arith * 65536L) / n);
    *cast(long*)(nn_feat + (1L << 3L)) = ((cmps * 65536L) / n);
    *cast(long*)(nn_feat + (2L << 3L)) = ((brs * 65536L) / n);
    *cast(long*)(nn_feat + (3L << 3L)) = ((calls * 65536L) / n);
    *cast(long*)(nn_feat + (4L << 3L)) = ((mems * 65536L) / n);
    *cast(long*)(nn_feat + (5L << 3L)) = ((consts * 65536L) / n);
    *cast(long*)(nn_feat + (6L << 3L)) = ((movs * 65536L) / n);
    *cast(long*)(nn_feat + (7L << 3L)) = ((backj * 65536L) / n);
    *cast(long*)(nn_feat + (8L << 3L)) = ((funcs * 65536L) / n);
    if (n > 100L)
    {
        v0 = 65536L;
    }
    else
    {
        v0 = 0L;
    }
    *cast(long*)(nn_feat + (9L << 3L)) = v0;
    if (n > 1000L)
    {
        v1 = 65536L;
    }
    else
    {
        v1 = 0L;
    }
    *cast(long*)(nn_feat + (10L << 3L)) = v1;
    if (n > 10000L)
    {
        v2 = 65536L;
    }
    else
    {
        v2 = 0L;
    }
    *cast(long*)(nn_feat + (11L << 3L)) = v2;
    if (backj > 0L)
    {
        v3 = 65536L;
    }
    else
    {
        v3 = 0L;
    }
    *cast(long*)(nn_feat + (12L << 3L)) = v3;
    if (calls > 0L)
    {
        v4 = 65536L;
    }
    else
    {
        v4 = 0L;
    }
    *cast(long*)(nn_feat + (13L << 3L)) = v4;
    if (mems > 0L)
    {
        v5 = 65536L;
    }
    else
    {
        v5 = 0L;
    }
    *cast(long*)(nn_feat + (14L << 3L)) = v5;
    *cast(long*)(nn_feat + (15L << 3L)) = 65536L;
    return 0;
}
long nn_init()
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long v6 = 0;
    long i = 0;
    long v7 = 0;
    long i_2 = 0;
    long i_3 = 0;
    long v8 = 0;
    long i_4 = 0;
    if (nn_ready != 0L)
    {
        return 0;
    }
    nn_seed = 20260805L;
    nn_w1 = getvec(((12L * 16L) + 2L));
    nn_b1 = getvec((12L + 2L));
    nn_w2 = getvec(((8L * 12L) + 2L));
    nn_b2 = getvec((8L + 2L));
    nn_feat = getvec((16L + 2L));
    nn_hid = getvec((12L + 2L));
    nn_out = getvec((8L + 2L));
    i = 0L;
    while (i <= ((12L * 16L) - 1L))
    {
        *cast(long*)(nn_w1 + (i << 3L)) = nn_rweight();
        i = (i + 1L);
    }
    i_2 = 0L;
    while (i_2 <= (12L - 1L))
    {
        *cast(long*)(nn_b1 + (i_2 << 3L)) = 0L;
        i_2 = (i_2 + 1L);
    }
    i_3 = 0L;
    while (i_3 <= ((8L * 12L) - 1L))
    {
        *cast(long*)(nn_w2 + (i_3 << 3L)) = nn_rweight();
        i_3 = (i_3 + 1L);
    }
    i_4 = 0L;
    while (i_4 <= (8L - 1L))
    {
        *cast(long*)(nn_b2 + (i_4 << 3L)) = 0L;
        i_4 = (i_4 + 1L);
    }
    nn_ready = 1L;
    return 0;
}
long nn_forward()
{
    long h = 0;
    long s = 0;
    long f = 0;
    long v0 = 0;
    long v1 = 0;
    long a = 0;
    long s_2 = 0;
    long h_2 = 0;
    long v2 = 0;
    h = 0L;
    while (h <= (12L - 1L))
    {
        s = *cast(long*)(nn_b1 + (h << 3L));
        f = 0L;
        while (f <= (16L - 1L))
        {
            s = (s + nn_mul(*cast(long*)(nn_w1 + (((h * 16L) + f) << 3L)), *cast(long*)(nn_feat + (f << 3L))));
            f = (f + 1L);
        }
        *cast(long*)(nn_hid + (h << 3L)) = nn_relu(s);
        h = (h + 1L);
    }
    a = 0L;
    while (a <= (8L - 1L))
    {
        s_2 = *cast(long*)(nn_b2 + (a << 3L));
        h_2 = 0L;
        while (h_2 <= (12L - 1L))
        {
            s_2 = (s_2 + nn_mul(*cast(long*)(nn_w2 + (((a * 12L) + h_2) << 3L)), *cast(long*)(nn_hid + (h_2 << 3L))));
            h_2 = (h_2 + 1L);
        }
        *cast(long*)(nn_out + (a << 3L)) = s_2;
        a = (a + 1L);
    }
    return 0;
}
long nn_train(long p1 = 0, long p2 = 0)
{
    long err = 0;
    long v0 = 0;
    long d = 0;
    long h = 0;
    long v1 = 0;
    long gh = 0;
    long v2 = 0;
    long f = 0;
    long v3 = 0;
    long a = p1;
    long target = p2;
    err = (*cast(long*)(nn_out + (a << 3L)) - target);
    d = nn_mul(err, 655L);
    h = 0L;
    while (h <= (12L - 1L))
    {
        gh = nn_mul(d, *cast(long*)(nn_w2 + (((a * 12L) + h) << 3L)));
        *cast(long*)(nn_w2 + (((a * 12L) + h) << 3L)) = (*cast(long*)(nn_w2 + (((a * 12L) + h) << 3L)) - nn_mul(d, *cast(long*)(nn_hid + (h << 3L))));
        if (*cast(long*)(nn_hid + (h << 3L)) > 0L)
        {
            f = 0L;
            while (f <= (16L - 1L))
            {
                *cast(long*)(nn_w1 + (((h * 16L) + f) << 3L)) = (*cast(long*)(nn_w1 + (((h * 16L) + f) << 3L)) - nn_mul(gh, *cast(long*)(nn_feat + (f << 3L))));
                f = (f + 1L);
            }
        }
        h = (h + 1L);
    }
    *cast(long*)(nn_b2 + (a << 3L)) = (*cast(long*)(nn_b2 + (a << 3L)) - d);
    return 0;
}
long nn_save()
{
    long p = 0;
    long v0 = 0;
    long i = 0;
    p = ir_arena;
    nn_snapn = ir_next;
    if (nn_snap == 0L)
    {
        nn_snap = getvec((((262144L * 8L) / 8L) + 2L));
    }
    i = 0L;
    while (i <= (ir_next - 1L))
    {
        *cast(long*)(nn_snap + (i << 3L)) = *cast(long*)(p + (i << 3L));
        i = (i + 1L);
    }
    nn_snapte = ir_nextemp;
    nn_snaptl = ir_nextlabel;
    return 0;
}
long nn_load()
{
    long p = 0;
    long i = 0;
    p = ir_arena;
    i = 0L;
    while (i <= (nn_snapn - 1L))
    {
        *cast(long*)(p + (i << 3L)) = *cast(long*)(nn_snap + (i << 3L));
        i = (i + 1L);
    }
    ir_next = nn_snapn;
    ir_nextemp = nn_snapte;
    ir_nextlabel = nn_snaptl;
    return 0;
}
long nn_eval()
{
    long p = 0;
    long v0 = 0;
    long temps = 0;
    long pc = 0;
    long steps = 0;
    long result = 0;
    long i = 0;
    long op = 0;
    long dst = 0;
    long a1 = 0;
    long a2 = 0;
    long l1 = 0;
    long l2 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long v6 = 0;
    long v7 = 0;
    long t = 0;
    long v8 = 0;
    long v9 = 0;
    long v10 = 0;
    long t_2 = 0;
    long v11 = 0;
    long v12 = 0;
    long v13 = 0;
    p = ir_arena;
    temps = getvec((ir_nextemp + 8L));
    pc = 1L;
    steps = 0L;
    result = 0L;
    nn_ok = 1L;
    nn_steps = 0L;
    i = 0L;
    while (i <= (ir_nextemp + 4L))
    {
        *cast(long*)(temps + (i << 3L)) = 0L;
        i = (i + 1L);
    }
L4243:
    if (pc >= ir_next) goto L4245; else goto L4244;
L4244:
    op = *cast(long*)(p + (pc << 3L));
    dst = *cast(long*)(p + ((pc + 1L) << 3L));
    a1 = *cast(long*)(p + ((pc + 2L) << 3L));
    a2 = *cast(long*)(p + ((pc + 3L) << 3L));
    l1 = *cast(long*)(p + ((pc + 5L) << 3L));
    l2 = *cast(long*)(p + ((pc + 6L) << 3L));
    steps = (steps + 1L);
    if (steps > 200000L)
    {
        nn_ok = 0L;
    }
    else
    {
        if (op == 1L) goto L4250; else goto L4274;
L4274:
        if (op == 39L) goto L4251; else goto L4275;
L4275:
        if (op == 4L) goto L4252; else goto L4276;
L4276:
        if (op == 5L) goto L4253; else goto L4277;
L4277:
        if (op == 6L) goto L4254; else goto L4278;
L4278:
        if (op == 7L) goto L4255; else goto L4279;
L4279:
        if (op == 8L) goto L4256; else goto L4280;
L4280:
        if (op == 9L) goto L4257; else goto L4281;
L4281:
        if (op == 10L) goto L4258; else goto L4282;
L4282:
        if (op == 11L) goto L4259; else goto L4283;
L4283:
        if (op == 26L) goto L4260; else goto L4284;
L4284:
        if (op == 12L) goto L4261; else goto L4285;
L4285:
        if (op == 20L) goto L4262; else goto L4286;
L4286:
        if (op == 21L) goto L4263; else goto L4287;
L4287:
        if (op == 22L) goto L4264; else goto L4288;
L4288:
        if (op == 23L) goto L4265; else goto L4289;
L4289:
        if (op == 24L) goto L4266; else goto L4290;
L4290:
        if (op == 25L) goto L4267; else goto L4291;
L4291:
        if (op == 32L) goto L4268; else goto L4292;
L4292:
        if (op == 36L) goto L4269; else goto L4293;
L4293:
        if (op == 30L) goto L4270; else goto L4294;
L4294:
        if (op == 31L) goto L4271; else goto L4295;
L4295:
        if (op == 34L) goto L4272; else goto L4296;
L4296:
        if (op == 37L) goto L4273; else goto L4297;
L4297:
    goto L4249;
L4250:
        *cast(long*)(temps + (dst << 3L)) = a1;
    goto L4248;
L4251:
        *cast(long*)(temps + (dst << 3L)) = *cast(long*)(temps + (a1 << 3L));
    goto L4248;
L4252:
        *cast(long*)(temps + (dst << 3L)) = (*cast(long*)(temps + (a1 << 3L)) + *cast(long*)(temps + (a2 << 3L)));
    goto L4248;
L4253:
        *cast(long*)(temps + (dst << 3L)) = (*cast(long*)(temps + (a1 << 3L)) - *cast(long*)(temps + (a2 << 3L)));
    goto L4248;
L4254:
        *cast(long*)(temps + (dst << 3L)) = (*cast(long*)(temps + (a1 << 3L)) * *cast(long*)(temps + (a2 << 3L)));
    goto L4248;
L4255:
        if (*cast(long*)(temps + (a2 << 3L)) == 0L)
        {
            nn_ok = 0L;
    goto L4245;
        }
        *cast(long*)(temps + (dst << 3L)) = (*cast(long*)(temps + (a1 << 3L)) / *cast(long*)(temps + (a2 << 3L)));
    goto L4248;
L4256:
        if (*cast(long*)(temps + (a2 << 3L)) == 0L)
        {
            nn_ok = 0L;
    goto L4245;
        }
        *cast(long*)(temps + (dst << 3L)) = (*cast(long*)(temps + (a1 << 3L)) % *cast(long*)(temps + (a2 << 3L)));
    goto L4248;
L4257:
        *cast(long*)(temps + (dst << 3L)) = (*cast(long*)(temps + (a1 << 3L)) & *cast(long*)(temps + (a2 << 3L)));
    goto L4248;
L4258:
        *cast(long*)(temps + (dst << 3L)) = (*cast(long*)(temps + (a1 << 3L)) | *cast(long*)(temps + (a2 << 3L)));
    goto L4248;
L4259:
        *cast(long*)(temps + (dst << 3L)) = (*cast(long*)(temps + (a1 << 3L)) ^ *cast(long*)(temps + (a2 << 3L)));
    goto L4248;
L4260:
        *cast(long*)(temps + (dst << 3L)) = (-*cast(long*)(temps + (a1 << 3L)));
    goto L4248;
L4261:
        *cast(long*)(temps + (dst << 3L)) = (~*cast(long*)(temps + (a1 << 3L)));
    goto L4248;
L4262:
        if (*cast(long*)(temps + (a1 << 3L)) == *cast(long*)(temps + (a2 << 3L)))
        {
            v1 = 1L;
        }
        else
        {
            v1 = 0L;
        }
        *cast(long*)(temps + (dst << 3L)) = v1;
    goto L4248;
L4263:
        if (*cast(long*)(temps + (a1 << 3L)) != *cast(long*)(temps + (a2 << 3L)))
        {
            v2 = 1L;
        }
        else
        {
            v2 = 0L;
        }
        *cast(long*)(temps + (dst << 3L)) = v2;
    goto L4248;
L4264:
        if (*cast(long*)(temps + (a1 << 3L)) < *cast(long*)(temps + (a2 << 3L)))
        {
            v3 = 1L;
        }
        else
        {
            v3 = 0L;
        }
        *cast(long*)(temps + (dst << 3L)) = v3;
    goto L4248;
L4265:
        if (*cast(long*)(temps + (a1 << 3L)) <= *cast(long*)(temps + (a2 << 3L)))
        {
            v4 = 1L;
        }
        else
        {
            v4 = 0L;
        }
        *cast(long*)(temps + (dst << 3L)) = v4;
    goto L4248;
L4266:
        if (*cast(long*)(temps + (a1 << 3L)) > *cast(long*)(temps + (a2 << 3L)))
        {
            v5 = 1L;
        }
        else
        {
            v5 = 0L;
        }
        *cast(long*)(temps + (dst << 3L)) = v5;
    goto L4248;
L4267:
        if (*cast(long*)(temps + (a1 << 3L)) >= *cast(long*)(temps + (a2 << 3L)))
        {
            v6 = 1L;
        }
        else
        {
            v6 = 0L;
        }
        *cast(long*)(temps + (dst << 3L)) = v6;
    goto L4248;
L4268:
    goto L4248;
L4269:
    goto L4248;
L4270:
        t = vm_resolve_label(l1);
        if (t < 0L)
        {
            nn_ok = 0L;
        }
        else
        {
            pc = t;
            steps = steps;
    goto L4243;
        }
    goto L4248;
L4271:
        if (*cast(long*)(temps + (a1 << 3L)) != 0L)
        {
            v9 = vm_resolve_label(l1);
        }
        else
        {
            v9 = vm_resolve_label(l2);
        }
        t_2 = v9;
        if (t_2 < 0L)
        {
            nn_ok = 0L;
        }
        else
        {
            pc = t_2;
    goto L4243;
        }
    goto L4248;
L4272:
        if (a1 != 0L)
        {
            v11 = *cast(long*)(temps + (a1 << 3L));
        }
        else
        {
            v11 = 0L;
        }
        result = v11;
        nn_steps = steps;
        v12 = freevec(temps);
        return result;
L4273:
    goto L4248;
L4249:
        nn_ok = 0L;
L4248:
        if (nn_ok != 0) goto L4333; else goto L4332;
L4332:
    goto L4245;
L4333:
        pc = (pc + 8L);
    goto L4243;
    }
L4245:
    nn_steps = steps;
    v13 = freevec(temps);
    return 0L;
}
long nn_structural()
{
    long p = 0;
    long i = 0;
    long depth = 0;
    long op = 0;
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    p = ir_arena;
    i = 1L;
    depth = 0L;
L4334:
    if (i >= ir_next) goto L4336; else goto L4335;
L4335:
    op = *cast(long*)(p + (i << 3L));
    if (op == 36L)
    {
        depth = (depth + 1L);
    }
    if (op == 37L)
    {
        depth = (depth - 1L);
    }
    if (depth < 0L)
    {
        return 0L;
    }
    if (op == 30L)
    {
        if (vm_resolve_label(*cast(long*)(p + ((i + 5L) << 3L))) < 0L)
        {
            return 0L;
        }
    }
    if (op == 31L)
    {
        if (vm_resolve_label(*cast(long*)(p + ((i + 5L) << 3L))) < 0L)
        {
            return 0L;
        }
        if (vm_resolve_label(*cast(long*)(p + ((i + 6L) << 3L))) < 0L)
        {
            return 0L;
        }
    }
    i = (i + 8L);
    goto L4334;
L4336:
    return cast(long)(depth == 0L);
}
long nn_cost(long p1 = 0, long p2 = 0)
{
    long steps = p1;
    long evaluable = p2;
    if (evaluable != 0)
    {
        return steps;
    }
    return ((ir_next - 1L) / 8L);
}
long nn_run()
{
    long bestk = 0;
    long bestcost = 0;
    long baseok = 0;
    long basesteps = 0;
    long baseval = 0;
    long[1] __v17882;
    long v0 = 0;
    long order = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long v6 = 0;
    long i = 0;
    long i_2 = 0;
    long j = 0;
    long t = 0;
    long try_ = 0;
    long k = 0;
    long ok = 0;
    long steps = 0;
    long val = 0;
    long cost = 0;
    long saveflags = 0;
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
    long basec = 0;
    long v17 = 0;
    long rew = 0;
    long v18 = 0;
    long v19 = 0;
    long saveflags_2 = 0;
    long v20 = 0;
    long v21 = 0;
    long v22 = 0;
    long v23 = 0;
    long v24 = 0;
    long v25 = 0;
    long v26 = 0;
    bestk = (-1L);
    bestcost = 0L;
    baseok = 0L;
    basesteps = 0L;
    baseval = 0L;
    v0 = cast(long)__v17882.ptr;
    order = v0;
    if (nn_active != 0L)
    {
        return 0;
    }
    nn_active = 1L;
    v1 = nn_init();
    v2 = nn_save();
    baseval = nn_eval();
    baseok = nn_ok;
    basesteps = nn_steps;
    bestcost = nn_cost(basesteps, baseok);
    v5 = nn_features();
    v6 = nn_forward();
    i = 0L;
    while (i <= (8L - 1L))
    {
        *cast(long*)(order + (i << 3L)) = i;
        i = (i + 1L);
    }
    i_2 = 0L;
    while (i_2 <= (8L - 2L))
    {
        j = (i_2 + 1L);
        while (j <= (8L - 1L))
        {
            if (*cast(long*)(nn_out + (*cast(long*)(order + (j << 3L)) << 3L)) > *cast(long*)(nn_out + (*cast(long*)(order + (i_2 << 3L)) << 3L)))
            {
                t = *cast(long*)(order + (i_2 << 3L));
                *cast(long*)(order + (i_2 << 3L)) = *cast(long*)(order + (j << 3L));
                *cast(long*)(order + (j << 3L)) = t;
            }
            j = (j + 1L);
        }
        i_2 = (i_2 + 1L);
    }
    try_ = 0L;
    while (try_ <= (3L - 1L))
    {
        k = *cast(long*)(order + (try_ << 3L));
        ok = 0L;
        steps = 0L;
        val = 0L;
        cost = 0L;
        saveflags = opt_flags;
        v7 = nn_load();
        opt_flags = (nn_action(k) | (opt_flags & 1024L));
        v9 = dce_run();
        opt_flags = saveflags;
        val = nn_eval();
        ok = nn_ok;
        steps = nn_steps;
        cost = nn_cost(steps, ok);
        if (nn_structural() != 0)
        {
            if (baseok != 0)
            {
                if (ok != 0) goto L4380; else goto L4378;
L4380:
                if (val != baseval) goto L4375; else goto L4378;
            }
L4378:
            if (baseok != 0) goto L4382; else goto L4376;
L4382:
            if (ok != 0) goto L4376; else goto L4375;
        }
L4375:
        if (nn_verbose != 0L)
        {
            v14 = writef(cast(long)__s18005.ptr, k);
        }
        v15 = nn_train(k, (-65536L));
    goto L4377;
L4376:
        if (cost < bestcost)
        {
            bestcost = cost;
            bestk = k;
        }
        basec = nn_cost(basesteps, baseok);
        if (basec > 0L)
        {
            v17 = (((basec - cost) * 65536L) / basec);
        }
        else
        {
            v17 = 0L;
        }
        rew = v17;
        v18 = nn_train(k, rew);
L4377:
        try_ = (try_ + 1L);
    }
    v19 = nn_load();
    if (bestk >= 0L)
    {
        saveflags_2 = opt_flags;
        opt_flags = (nn_action(bestk) | (opt_flags & 1024L));
        v21 = dce_run();
        opt_flags = saveflags_2;
        if (nn_verbose != 0L)
        {
            v23 = writef(cast(long)__s18045.ptr, bestk, bestcost);
        }
    }
    else
    {
        v24 = dce_run();
        if (nn_verbose != 0L)
        {
            v26 = writes(cast(long)__s18053.ptr);
        }
    }
    nn_active = 0L;
    return 0;
}
