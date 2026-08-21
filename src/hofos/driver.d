// Generated from BCPL by cg-d.b, split into modules by split.d.
module hofos.driver;

import hofos.all;

long str_eq(long p1 = 0, long p2 = 0)
{
    long n = 0;
    long i = 0;
    long a = p1;
    long b = p2;
    n = 0L;
    if (a == 0L) goto L6949; else goto L6951;
L6951:
    if (b == 0L) goto L6949; else goto L6950;
L6949:
    return 0L;
L6950:
    if (cast(long)*cast(ubyte*)(a + 0L) != cast(long)*cast(ubyte*)(b + 0L))
    {
        return 0L;
    }
    n = cast(long)*cast(ubyte*)(a + 0L);
    i = 1L;
    while (i <= n)
    {
        if (cast(long)*cast(ubyte*)(a + i) != cast(long)*cast(ubyte*)(b + i))
        {
            return 0L;
        }
        i = (i + 1L);
    }
    return 1L;
}
long str_last_dot(long p1 = 0)
{
    long i = 0;
    long s = p1;
    i = cast(long)*cast(ubyte*)(s + 0L);
    while (i >= 1L)
    {
        if (cast(long)*cast(ubyte*)(s + i) == 46L)
        {
            return i;
        }
        i = (i + (-1L));
    }
    return 0L;
}
long str_ends_with(long p1 = 0, long p2 = 0)
{
    long sn = 0;
    long tn = 0;
    long off = 0;
    long i = 0;
    long s = p1;
    long suffix = p2;
    sn = cast(long)*cast(ubyte*)(s + 0L);
    tn = cast(long)*cast(ubyte*)(suffix + 0L);
    off = (sn - tn);
    if (sn < tn)
    {
        return 0L;
    }
    i = 1L;
    while (i <= tn)
    {
        if (cast(long)*cast(ubyte*)(s + (off + i)) != cast(long)*cast(ubyte*)(suffix + i))
        {
            return 0L;
        }
        i = (i + 1L);
    }
    return 1L;
}
long auto_output(long p1 = 0, long p2 = 0)
{
    long v0 = 0;
    long dotpos = 0;
    long v1 = 0;
    long stemlen = 0;
    long i = 0;
    long src = p1;
    long dst = p2;
    dotpos = str_last_dot(src);
    if (dotpos > 0L)
    {
        v1 = (dotpos - 1L);
    }
    else
    {
        v1 = cast(long)*cast(ubyte*)(src + 0L);
    }
    stemlen = v1;
    i = 1L;
    while (i <= stemlen)
    {
        *cast(ubyte*)(dst + i) = cast(ubyte)cast(long)*cast(ubyte*)(src + i);
        i = (i + 1L);
    }
    *cast(ubyte*)(dst + (stemlen + 1L)) = cast(ubyte)46L;
    *cast(ubyte*)(dst + (stemlen + 2L)) = cast(ubyte)101L;
    *cast(ubyte*)(dst + (stemlen + 3L)) = cast(ubyte)108L;
    *cast(ubyte*)(dst + (stemlen + 4L)) = cast(ubyte)102L;
    *cast(ubyte*)(dst + 0L) = cast(ubyte)(stemlen + 4L);
    *cast(ubyte*)(dst + (stemlen + 5L)) = cast(ubyte)0L;
    return 0;
}
long with_ext(long p1 = 0, long p2 = 0, long p3 = 0)
{
    long v0 = 0;
    long dot = 0;
    long v1 = 0;
    long stem = 0;
    long i = 0;
    long i_2 = 0;
    long base = p1;
    long ext = p2;
    long dst = p3;
    dot = str_last_dot(base);
    if (dot > 0L)
    {
        v1 = (dot - 1L);
    }
    else
    {
        v1 = cast(long)*cast(ubyte*)(base + 0L);
    }
    stem = v1;
    i = 1L;
    while (i <= stem)
    {
        *cast(ubyte*)(dst + i) = cast(ubyte)cast(long)*cast(ubyte*)(base + i);
        i = (i + 1L);
    }
    *cast(ubyte*)(dst + (stem + 1L)) = cast(ubyte)46L;
    i_2 = 1L;
    while (i_2 <= cast(long)*cast(ubyte*)(ext + 0L))
    {
        *cast(ubyte*)(dst + ((stem + 1L) + i_2)) = cast(ubyte)cast(long)*cast(ubyte*)(ext + i_2);
        i_2 = (i_2 + 1L);
    }
    *cast(ubyte*)(dst + 0L) = cast(ubyte)((stem + 1L) + cast(long)*cast(ubyte*)(ext + 0L));
    *cast(ubyte*)(dst + ((stem + 2L) + cast(long)*cast(ubyte*)(ext + 0L))) = cast(ubyte)0L;
    return 0;
}
long cg_x86asm_link(long p1 = 0)
{
    long[65] __v33731;
    long v0 = 0;
    long sname = 0;
    long[65] __v33733;
    long v1 = 0;
    long oname = 0;
    long mark = 0;
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
    long[2] __v33766;
    long v17 = 0;
    long objs = 0;
    long v18 = 0;
    long v19 = 0;
    long v20 = 0;
    long v21 = 0;
    long v22 = 0;
    long v23 = 0;
    long v24 = 0;
    long v25 = 0;
    long out_ = p1;
    v0 = cast(long)__v33731.ptr;
    sname = v0;
    v1 = cast(long)__v33733.ptr;
    oname = v1;
    mark = 0L;
    if (str_ends_with(out_, cast(long)__s33738.ptr) != 0)
    {
        ax_pic = 1L;
    }
    if (str_ends_with(out_, cast(long)__s33742.ptr) != 0)
    {
        v6 = cg_compile_to_elf64(out_);
        return 0;
    }
    v8 = with_ext(out_, cast(long)__s33747.ptr, sname);
    mark = __alloc(0L);
    v10 = cg_compile_to_elf64(sname);
    v11 = freevec(mark);
    __unbuf = 0L;
    if (str_ends_with(out_, cast(long)__s33758.ptr) != 0)
    {
        if (ac_run(sname, out_, 0L) != 0) goto L7000; else goto L6999;
L6999:
        v16 = writes(cast(long)__s33764.ptr);
L7000:
    }
    else
    {
        v17 = cast(long)__v33766.ptr;
        objs = v17;
        v19 = with_ext(out_, cast(long)__s33769.ptr, oname);
        if (ac_run(sname, oname, 0L) != 0) goto L7002; else goto L7001;
L7001:
        v22 = writes(cast(long)__s33775.ptr);
        return 0;
L7002:
        *cast(long*)(objs + (0L << 3L)) = oname;
        if (fl_run(objs, 1L, out_) != 0) goto L7004; else goto L7003;
L7003:
        v25 = writes(cast(long)__s33785.ptr);
        return 0;
L7004:
    }
    return 0;
}
long usage()
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    return __usage_lang(cast(long)__s33789.ptr, cast(long)__s33790.ptr, cast(long)__s33791.ptr, cast(long)__s33792.ptr, cast(long)__s33793.ptr);
}
long open_for_read(long p1 = 0)
{
    long v0 = 0;
    long st = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long name = p1;
    st = findinput(name);
    if (st != 0) goto L7006; else goto L7005;
L7005:
    v2 = writef(cast(long)__s33801.ptr, name);
    return 0L;
L7006:
    v3 = selectinput(st);
    v4 = lex_init();
    return st;
}
long cmd_tokenize(long p1 = 0)
{
    long v0 = 0;
    long prev = 0;
    long v1 = 0;
    long st = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long name = p1;
    prev = input();
    st = open_for_read(name);
    if (st != 0) goto L7008; else goto L7007;
L7007:
    return 0;
L7008:
L7009:
    if (1L != 0)
    {
        v2 = lex_next();
        if (lex_token == 0L)
        {
    goto L7011;
        }
        v3 = lex_print();
    goto L7009;
    }
L7011:
    v4 = endread();
    if (prev != 0)
    {
        v5 = selectinput(prev);
    }
    return 0;
}
long cmd_parse(long p1 = 0)
{
    long v0 = 0;
    long prev = 0;
    long v1 = 0;
    long st = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long v6 = 0;
    long v7 = 0;
    long v8 = 0;
    long v9 = 0;
    long name = p1;
    prev = input();
    st = open_for_read(name);
    if (st != 0) goto L7017; else goto L7016;
L7016:
    return 0;
L7017:
    v2 = ast_init();
    v3 = lex_next();
    ast_root = parse_program();
    v5 = endread();
    if (prev != 0)
    {
        v6 = selectinput(prev);
    }
    v8 = writef(cast(long)__s33847.ptr, ((ast_next - 1L) / 8L));
    v9 = ast_dump(ast_root, 0L);
    return 0;
}
long cmd_ir(long p1 = 0)
{
    long v0 = 0;
    long prev = 0;
    long v1 = 0;
    long st = 0;
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
    prev = input();
    st = open_for_read(name);
    if (st != 0) goto L7021; else goto L7020;
L7020:
    return 0;
L7021:
    v2 = ast_init();
    v3 = ir_init();
    v4 = lex_next();
    ast_root = parse_program();
    v6 = endread();
    if (prev != 0)
    {
        v7 = selectinput(prev);
    }
    v8 = lower_program();
    v10 = writef(cast(long)__s33881.ptr, ((ir_next - 1L) / 8L), (ir_nextemp - 1L), (ir_nextlabel - 1L));
    v11 = hm_dump();
    return 0;
}
long cmd_jit_run(long p1 = 0)
{
    long v0 = 0;
    long prev = 0;
    long v1 = 0;
    long st = 0;
    long fn = 0;
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
    long name = p1;
    prev = input();
    st = open_for_read(name);
    fn = 0L;
    if (st != 0) goto L7025; else goto L7024;
L7024:
    return 0;
L7025:
    v2 = ast_init();
    v3 = ir_init();
    v4 = lex_next();
    ast_root = parse_program();
    v6 = endread();
    if (prev != 0)
    {
        v7 = selectinput(prev);
    }
    v8 = lower_program();
    if (diag_nerr > 0L)
    {
        v10 = writef(cast(long)__s33933.ptr, diag_nerr);
        return 0;
    }
    opt_flags = (opt_flags | 128L);
    if ((opt_flags & 32768L) != 0L)
    {
        v11 = nn_run();
    }
    else
    {
        v12 = dce_run();
    }
    fn = cg_jit_function(cast(long)__s33949.ptr);
    if (fn == 0L)
    {
        v16 = writes(cast(long)__s33954.ptr);
        v17 = vm_run();
    }
    else
    {
        v19 = writes(cast(long)__s33959.ptr);
        v20 = (cast(long function())fn)();
    }
    return 0;
}
long cmd_compile(long p1 = 0, long p2 = 0)
{
    long v0 = 0;
    long prev = 0;
    long v1 = 0;
    long st = 0;
    long[65] __v33973;
    long v2 = 0;
    long outbuf = 0;
    long useOut = 0;
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
    long src = p1;
    long out_ = p2;
    prev = input();
    st = open_for_read(src);
    v2 = cast(long)__v33973.ptr;
    outbuf = v2;
    useOut = out_;
    diag_srcname = src;
    diag_nerr = 0L;
    diag_nmanifest = 0L;
    if (st != 0) goto L7037; else goto L7036;
L7036:
    v4 = writes(cast(long)__s33979.ptr);
    v5 = __exitcode(1L);
L7037:
    v6 = ast_init();
    v7 = ir_init();
    v8 = lex_next();
    ast_root = parse_program();
    v10 = endread();
    if (prev != 0)
    {
        v11 = selectinput(prev);
    }
    if (diag_nmanifest > 0L && opt_verbose != 0)   // only when asked; see dce.b
    {
        v13 = writes(cast(long)__s34000.ptr);
        v14 = writen(diag_nmanifest);
        v16 = writes(cast(long)__s34006.ptr);
    }
    if (diag_nerr > 0L)
    {
        v18 = writes(cast(long)__s34012.ptr);
        return 0;
    }
    v19 = lower_program();
    if (useOut != 0L)
    {
        if (cast(long)*cast(ubyte*)(useOut + 0L) == 1L) goto L7046; else goto L7045;
L7046:
        if (cast(long)*cast(ubyte*)(useOut + 1L) == 63L) goto L7044; else goto L7045;
L7044:
        v20 = auto_output(src, outbuf);
        useOut = outbuf;
    }
L7045:
    if (opt_prof_use != 0)
    {
        v21 = prof_reorder();
    }
    if (opt_nodce != 0) goto L7051; else goto L7050;
L7050:
    if ((opt_flags & 32768L) != 0L)
    {
        v22 = nn_run();
    }
    else
    {
        v23 = dce_run();
    }
L7051:
    if (opt_target_id != 0L)
    {
        v25 = writes(cast(long)__s34047.ptr);
    }
    v26 = cg_x86asm_link(useOut);
    return 0;
}
long cmd_fromwir(long p1 = 0, long p2 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long src = p1;
    long out_ = p2;
    diag_srcname = src;
    v0 = irr_load(src);
    if ((opt_flags & 32768L) != 0L)
    {
        v1 = nn_run();
    }
    else
    {
        v2 = dce_run();
    }
    v3 = cg_x86asm_link(out_);
    return 0;
}
long cmd_merge(long p1 = 0, long p2 = 0, long p3 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long paths = p1;
    long nunits = p2;
    long out_ = p3;
    diag_srcname = *cast(long*)(paths + (0L << 3L));
    if (hm_merge(paths, nunits) != 0) goto L7065; else goto L7064;
L7064:
    return 0L;
L7065:
    v2 = writef(cast(long)__s34100.ptr, nunits);
    if ((opt_flags & 32768L) != 0L)
    {
        v3 = nn_run();
    }
    else
    {
        v4 = dce_run();
    }
    v5 = cg_x86asm_link(out_);
    return 1L;
}
long find_arrow(long p1 = 0, long p2 = 0)
{
    long v0 = 0;
    long marker = 0;
    long i = 0;
    long v1 = 0;
    long argv = p1;
    long n = p2;
    marker = cast(long)__s34117.ptr;
    i = 0L;
    while (i <= (n - 1L))
    {
        if (*cast(long*)(argv + (i << 3L)) != 0L)
        {
            if (str_eq(*cast(long*)(argv + (i << 3L)), marker) != 0)
            {
                return i;
            }
        }
        i = (i + 1L);
    }
    return (-1L);
}
long start()
{
    long[17] __v34207;
    long v0 = 0;
    long argv = 0;
    long rargs = 0;
    long arrowIdx = 0;
    long src = 0;
    long out_ = 0;
    long sub = 0;
    long n = 0;
    long[65] __v34221;
    long v1 = 0;
    long autoOut = 0;
    long shiftFrom = 0;
    long i = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long v6 = 0;
    long i_2 = 0;
    long v7 = 0;
    long v8 = 0;
    long j = 0;
    long tok = 0;
    long v9 = 0;
    long v10 = 0;
    long tgt = 0;
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
    long nin = 0;
    long mout = 0;
    long v27 = 0;
    long ai = 0;
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
    v0 = cast(long)__v34207.ptr;
    argv = v0;
    rargs = 0L;
    arrowIdx = 0L;
    src = 0L;
    out_ = 0L;
    sub = 0L;
    n = 0L;
    v1 = cast(long)__v34221.ptr;
    autoOut = v1;
    shiftFrom = 0L;
    i = 0L;
    while (i <= 16L)
    {
        *cast(long*)(argv + (i << 3L)) = 0L;
        i = (i + 1L);
    }
    __unbuf = 1L;
    opt_nodce = 0L;
    v2 = opt_compose_level(2L);
    opt_prof_use = 0L;
    __mode = 0L;
    cg_asm_mode = 1L;
    rargs = rdargs(cast(long)__s34243.ptr, argv, 16L);
    if (rargs != 0) goto L7100; else goto L7099;
L7099:
    v6 = writes(cast(long)__s34247.ptr);
    return 20L;
L7100:
    i_2 = 0L;
    while (i_2 <= 7L)
    {
        if (*cast(long*)(argv + (i_2 << 3L)) != 0L)
        {
            n = (n + 1L);
        }
        i_2 = (i_2 + 1L);
    }
    if (n == 0L)
    {
        v8 = writes(cast(long)__s34266.ptr);
        return 20L;
    }
    opt_target_id = 0L;
    j = 0L;
L7109:
    if (j >= n) goto L7111; else goto L7110;
L7110:
    tok = *cast(long*)(argv + (j << 3L));
    if (tok != 0L)
    {
        if (cast(long)*cast(ubyte*)(tok + 0L) == 2L) goto L7116; else goto L7113;
L7116:
        if (cast(long)*cast(ubyte*)(tok + 1L) == 45L) goto L7115; else goto L7113;
L7115:
        if (cast(long)*cast(ubyte*)(tok + 2L) == 116L) goto L7112; else goto L7113;
L7112:
        if ((j + 1L) >= n)
        {
            v10 = writes(cast(long)__s34299.ptr);
            return 20L;
        }
        tgt = *cast(long*)(argv + ((j + 1L) << 3L));
        if (cast(long)*cast(ubyte*)(tgt + 0L) >= 5L)
        {
            if (cast(long)*cast(ubyte*)(tgt + 1L) == 97L) goto L7120; else goto L7121;
L7120:
            if (cast(long)*cast(ubyte*)(tgt + 2L) == 97L)
            {
                if (cast(long)*cast(ubyte*)(tgt + 3L) == 114L) goto L7123; else goto L7124;
L7123:
                opt_target_id = 1L;
            }
L7124:
            if (cast(long)*cast(ubyte*)(tgt + 2L) == 114L)
            {
                if (cast(long)*cast(ubyte*)(tgt + 3L) == 109L) goto L7126; else goto L7127;
L7126:
                opt_target_id = 1L;
            }
L7127:
        }
L7121:
        if (cast(long)*cast(ubyte*)(tgt + 0L) >= 4L)
        {
            if (cast(long)*cast(ubyte*)(tgt + 1L) == 114L) goto L7129; else goto L7130;
L7129:
            if (cast(long)*cast(ubyte*)(tgt + 2L) == 105L)
            {
                if (cast(long)*cast(ubyte*)(tgt + 3L) == 115L) goto L7132; else goto L7133;
L7132:
                opt_target_id = 2L;
            }
L7133:
            if (cast(long)*cast(ubyte*)(tgt + 2L) == 118L)
            {
                if (cast(long)*cast(ubyte*)(tgt + 3L) == 54L) goto L7135; else goto L7136;
L7135:
                opt_target_id = 2L;
            }
L7136:
        }
L7130:
        while (j <= (n - 3L))
        {
            *cast(long*)(argv + (j << 3L)) = *cast(long*)(argv + ((j + 2L) << 3L));
            j = (j + 1L);
        }
        *cast(long*)(argv + ((n - 1L) << 3L)) = 0L;
        *cast(long*)(argv + ((n - 2L) << 3L)) = 0L;
        n = (n - 2L);
    goto L7114;
    }
L7113:
    j = (j + 1L);
L7114:
    goto L7109;
L7111:
    n = opt_parse_args(argv, n);
    if (n > 0L)
    {
        if (str_eq(*cast(long*)(argv + (0L << 3L)), cast(long)__s34413.ptr) != 0) goto L7142; else goto L7147;
L7147:
        if (str_eq(*cast(long*)(argv + (0L << 3L)), cast(long)__s34421.ptr) != 0) goto L7142; else goto L7146;
L7146:
        if (str_eq(*cast(long*)(argv + (0L << 3L)), cast(long)__s34429.ptr) != 0) goto L7142; else goto L7145;
L7145:
        if (str_eq(*cast(long*)(argv + (0L << 3L)), cast(long)__s34437.ptr) != 0) goto L7142; else goto L7143;
L7142:
        v20 = usage();
        return 0L;
    }
L7143:
    if (__mode >= 1L)
    {
        if (__mode <= 3L) goto L7148; else goto L7149;
L7148:
        if (*cast(long*)(argv + (0L << 3L)) != 0) goto L7152; else goto L7151;
L7151:
        v22 = writes(cast(long)__s34454.ptr);
        return 20L;
L7152:
        v23 = __mode;
        if (v23 == 1L) goto L7155; else goto L7158;
L7158:
        if (v23 == 2L) goto L7156; else goto L7159;
L7159:
        if (v23 == 3L) goto L7157; else goto L7160;
L7160:
    goto L7154;
L7155:
        v24 = cmd_tokenize(*cast(long*)(argv + (0L << 3L)));
    goto L7153;
L7156:
        v25 = cmd_parse(*cast(long*)(argv + (0L << 3L)));
    goto L7153;
L7157:
        v26 = cmd_ir(*cast(long*)(argv + (0L << 3L)));
    goto L7153;
L7154:
L7153:
        return 0L;
    }
L7149:
    if (__mode == 7L)
    {
        nin = 0L;
        mout = 0L;
        ai = find_arrow(argv, n);
        if (ai > 0L)
        {
            nin = ai;
            mout = *cast(long*)(argv + ((ai + 1L) << 3L));
            if (mout == 0L)
            {
                v28 = auto_output(*cast(long*)(argv + (0L << 3L)), autoOut);
                mout = autoOut;
            }
        }
        else
        {
            nin = n;
            v29 = auto_output(*cast(long*)(argv + (0L << 3L)), autoOut);
            mout = autoOut;
        }
        if (nin == 0L)
        {
            v31 = writes(cast(long)__s34523.ptr);
            return 20L;
        }
        if (cmd_merge(argv, nin, mout) != 0) goto L7171; else goto L7170;
L7170:
        return 20L;
L7171:
        return 0L;
    }
    if (n == 0L)
    {
        v34 = writes(cast(long)__s34533.ptr);
        return 20L;
    }
    if (__mode == 6L)
    {
        if (*cast(long*)(argv + (0L << 3L)) != 0) goto L7177; else goto L7176;
L7176:
        v36 = writes(cast(long)__s34545.ptr);
        return 20L;
L7177:
        v37 = cmd_jit_run(*cast(long*)(argv + (0L << 3L)));
        return 0L;
    }
    arrowIdx = find_arrow(argv, n);
    if (arrowIdx == 0L)
    {
        v40 = writes(cast(long)__s34561.ptr);
        return 20L;
    }
    if (arrowIdx > 0L)
    {
        src = *cast(long*)(argv + ((arrowIdx - 1L) << 3L));
        out_ = *cast(long*)(argv + ((arrowIdx + 1L) << 3L));
        if (out_ == 0L) goto L7183; else goto L7185;
L7185:
        if (cast(long)*cast(ubyte*)(out_ + 0L) == 1L) goto L7186; else goto L7184;
L7186:
        if (cast(long)*cast(ubyte*)(out_ + 1L) == 63L) goto L7183; else goto L7184;
L7183:
        v41 = auto_output(src, autoOut);
        out_ = autoOut;
L7184:
    }
    else
    {
        src = *cast(long*)(argv + (0L << 3L));
        v42 = auto_output(src, autoOut);
        out_ = autoOut;
    }
    if (__mode == 5L)
    {
        v43 = cmd_fromwir(src, out_);
    }
    else
    {
        v44 = cmd_compile(src, out_);
    }
    return 0L;
}
