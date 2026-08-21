// Generated from BCPL by cg-d.b, split into modules by split.d.
module hofos.vm;

import hofos.all;

long vm_resolve_label(long p1 = 0)
{
    long p = 0;
    long i = 0;
    long label = p1;
    p = ir_arena;
    i = 1L;
L4397:
    if (i >= ir_next) goto L4399; else goto L4398;
L4398:
    if (*cast(long*)(p + (i << 3L)) == 32L)
    {
        if (*cast(long*)(p + ((i + 2L) << 3L)) == label) goto L4400; else goto L4401;
L4400:
        return i;
    }
L4401:
    i = (i + 8L);
    goto L4397;
L4399:
    return (-1L);
}
long vm_run()
{
    long v0 = 0;
    long temps = 0;
    long p = 0;
    long pc = 0;
    long i = 0;
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
    long tgt = 0;
    long v8 = 0;
    long v9 = 0;
    long v10 = 0;
    long tgt_2 = 0;
    long v11 = 0;
    long ti = 0;
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
    temps = getvec((ir_nextemp + 4L));
    p = ir_arena;
    pc = 1L;
    i = 0L;
    while (i <= ir_nextemp)
    {
        *cast(long*)(temps + (i << 3L)) = 0L;
        i = (i + 1L);
    }
L4407:
    if (pc >= ir_next) goto L4409; else goto L4408;
L4408:
    op = *cast(long*)(p + (pc << 3L));
    dst = *cast(long*)(p + ((pc + 1L) << 3L));
    a1 = *cast(long*)(p + ((pc + 2L) << 3L));
    a2 = *cast(long*)(p + ((pc + 3L) << 3L));
    a3 = *cast(long*)(p + ((pc + 4L) << 3L));
    l1 = *cast(long*)(p + ((pc + 5L) << 3L));
    l2 = *cast(long*)(p + ((pc + 6L) << 3L));
    if (op == 1L) goto L4412; else goto L4439;
L4439:
    if (op == 38L) goto L4413; else goto L4440;
L4440:
    if (op == 4L) goto L4414; else goto L4441;
L4441:
    if (op == 5L) goto L4415; else goto L4442;
L4442:
    if (op == 6L) goto L4416; else goto L4443;
L4443:
    if (op == 7L) goto L4417; else goto L4444;
L4444:
    if (op == 8L) goto L4418; else goto L4445;
L4445:
    if (op == 9L) goto L4419; else goto L4446;
L4446:
    if (op == 10L) goto L4420; else goto L4447;
L4447:
    if (op == 26L) goto L4421; else goto L4448;
L4448:
    if (op == 12L) goto L4422; else goto L4449;
L4449:
    if (op == 13L) goto L4423; else goto L4450;
L4450:
    if (op == 14L) goto L4424; else goto L4451;
L4451:
    if (op == 20L) goto L4425; else goto L4452;
L4452:
    if (op == 21L) goto L4426; else goto L4453;
L4453:
    if (op == 22L) goto L4427; else goto L4454;
L4454:
    if (op == 23L) goto L4428; else goto L4455;
L4455:
    if (op == 24L) goto L4429; else goto L4456;
L4456:
    if (op == 25L) goto L4430; else goto L4457;
L4457:
    if (op == 30L) goto L4431; else goto L4458;
L4458:
    if (op == 31L) goto L4432; else goto L4459;
L4459:
    if (op == 34L) goto L4433; else goto L4460;
L4460:
    if (op == 33L) goto L4434; else goto L4461;
L4461:
    if (op == 32L) goto L4435; else goto L4462;
L4462:
    if (op == 36L) goto L4436; else goto L4463;
L4463:
    if (op == 37L) goto L4437; else goto L4464;
L4464:
    if (op == 35L) goto L4438; else goto L4465;
L4465:
    goto L4411;
L4412:
    *cast(long*)(temps + (dst << 3L)) = a1;
    goto L4410;
L4413:
    *cast(long*)(temps + (dst << 3L)) = a1;
    goto L4410;
L4414:
    *cast(long*)(temps + (dst << 3L)) = (*cast(long*)(temps + (a1 << 3L)) + *cast(long*)(temps + (a2 << 3L)));
    goto L4410;
L4415:
    *cast(long*)(temps + (dst << 3L)) = (*cast(long*)(temps + (a1 << 3L)) - *cast(long*)(temps + (a2 << 3L)));
    goto L4410;
L4416:
    *cast(long*)(temps + (dst << 3L)) = (*cast(long*)(temps + (a1 << 3L)) * *cast(long*)(temps + (a2 << 3L)));
    goto L4410;
L4417:
    *cast(long*)(temps + (dst << 3L)) = (*cast(long*)(temps + (a1 << 3L)) / *cast(long*)(temps + (a2 << 3L)));
    goto L4410;
L4418:
    *cast(long*)(temps + (dst << 3L)) = (*cast(long*)(temps + (a1 << 3L)) % *cast(long*)(temps + (a2 << 3L)));
    goto L4410;
L4419:
    *cast(long*)(temps + (dst << 3L)) = (*cast(long*)(temps + (a1 << 3L)) & *cast(long*)(temps + (a2 << 3L)));
    goto L4410;
L4420:
    *cast(long*)(temps + (dst << 3L)) = (*cast(long*)(temps + (a1 << 3L)) | *cast(long*)(temps + (a2 << 3L)));
    goto L4410;
L4421:
    *cast(long*)(temps + (dst << 3L)) = (-*cast(long*)(temps + (a1 << 3L)));
    goto L4410;
L4422:
    *cast(long*)(temps + (dst << 3L)) = (~*cast(long*)(temps + (a1 << 3L)));
    goto L4410;
L4423:
    *cast(long*)(temps + (dst << 3L)) = (*cast(long*)(temps + (a1 << 3L)) << *cast(long*)(temps + (a2 << 3L)));
    goto L4410;
L4424:
    *cast(long*)(temps + (dst << 3L)) = (*cast(long*)(temps + (a1 << 3L)) >> *cast(long*)(temps + (a2 << 3L)));
    goto L4410;
L4425:
    if (*cast(long*)(temps + (a1 << 3L)) == *cast(long*)(temps + (a2 << 3L)))
    {
        v1 = 1L;
    }
    else
    {
        v1 = 0L;
    }
    *cast(long*)(temps + (dst << 3L)) = v1;
    goto L4410;
L4426:
    if (*cast(long*)(temps + (a1 << 3L)) != *cast(long*)(temps + (a2 << 3L)))
    {
        v2 = 1L;
    }
    else
    {
        v2 = 0L;
    }
    *cast(long*)(temps + (dst << 3L)) = v2;
    goto L4410;
L4427:
    if (*cast(long*)(temps + (a1 << 3L)) < *cast(long*)(temps + (a2 << 3L)))
    {
        v3 = 1L;
    }
    else
    {
        v3 = 0L;
    }
    *cast(long*)(temps + (dst << 3L)) = v3;
    goto L4410;
L4428:
    if (*cast(long*)(temps + (a1 << 3L)) <= *cast(long*)(temps + (a2 << 3L)))
    {
        v4 = 1L;
    }
    else
    {
        v4 = 0L;
    }
    *cast(long*)(temps + (dst << 3L)) = v4;
    goto L4410;
L4429:
    if (*cast(long*)(temps + (a1 << 3L)) > *cast(long*)(temps + (a2 << 3L)))
    {
        v5 = 1L;
    }
    else
    {
        v5 = 0L;
    }
    *cast(long*)(temps + (dst << 3L)) = v5;
    goto L4410;
L4430:
    if (*cast(long*)(temps + (a1 << 3L)) >= *cast(long*)(temps + (a2 << 3L)))
    {
        v6 = 1L;
    }
    else
    {
        v6 = 0L;
    }
    *cast(long*)(temps + (dst << 3L)) = v6;
    goto L4410;
L4431:
    tgt = vm_resolve_label(l1);
    if (tgt < 0L)
    {
        v9 = writes(cast(long)__s18430.ptr);
    goto L4409;
    }
    pc = tgt;
    goto L4407;
L4432:
    if (*cast(long*)(temps + (a1 << 3L)) != 0L)
    {
        v10 = l1;
    }
    else
    {
        v10 = l2;
    }
    tgt_2 = v10;
    ti = vm_resolve_label(tgt_2);
    if (ti < 0L)
    {
        v13 = writes(cast(long)__s18446.ptr);
    goto L4409;
    }
    pc = ti;
    goto L4407;
L4433:
    if (a1 != 0L)
    {
        v15 = writef(cast(long)__s18451.ptr, *cast(long*)(temps + (a1 << 3L)));
    }
    else
    {
        v17 = writes(cast(long)__s18458.ptr);
    }
    goto L4409;
L4434:
    v19 = writef(cast(long)__s18461.ptr, a1, a2);
    *cast(long*)(temps + (dst << 3L)) = 0L;
    goto L4410;
L4435:
    goto L4410;
L4436:
    v21 = writef(cast(long)__s18468.ptr, dst);
    goto L4410;
L4437:
    v23 = writef(cast(long)__s18471.ptr);
    goto L4410;
L4438:
    goto L4410;
L4411:
    v25 = writef(cast(long)__s18474.ptr, op);
L4410:
    pc = (pc + 8L);
    goto L4407;
L4409:
    v26 = freevec(temps);
    return 0;
}
