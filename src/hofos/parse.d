// Generated from BCPL by cg-d.b, split into modules by split.d.
// Hand-maintained from 2026-08-15: see parse_search_hdrs.
module hofos.parse;

import hofos.all;

// Extra GET search directories, in BCPL string form (length in byte 0).  Built
// once at start-up so the pointers handed to parse_try_dir stay valid.
private __gshared ubyte[][] _extraHdrDirs;
shared static this()
{
    foreach (d; ["C:/Hofos/deprecated", "/mnt/c/Hofos/deprecated",
                 "C:/Hofos/deprecated/backup_only", "/mnt/c/Hofos/deprecated/backup_only"])
    {
        auto b = new ubyte[d.length + 2];
        b[0] = cast(ubyte)d.length;
        foreach (i, c; d) b[i + 1] = cast(ubyte)c;
        _extraHdrDirs ~= b;
    }
}

long parse_near()
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
    v0 = lex_token;
    if (v0 == 1L) goto L1286; else goto L1291;
L1291:
    if (v0 == 4L) goto L1287; else goto L1292;
L1292:
    if (v0 == 2L) goto L1288; else goto L1293;
L1293:
    if (v0 == 3L) goto L1289; else goto L1294;
L1294:
    if (v0 == 0L) goto L1290; else goto L1295;
L1295:
    goto L1285;
L1286:
    v2 = writef(cast(long)__s4360.ptr, lex_value);
    goto L1284;
L1287:
    v4 = writef(cast(long)__s4364.ptr, lex_buf);
    goto L1284;
L1288:
    v6 = writes(cast(long)__s4368.ptr);
    goto L1284;
L1289:
    v8 = writes(cast(long)__s4371.ptr);
    goto L1284;
L1290:
    v10 = writes(cast(long)__s4374.ptr);
    goto L1284;
L1285:
    if (lex_token >= 200L)
    {
        v12 = writef(cast(long)__s4380.ptr, lex_buf);
    }
    else
    {
        v15 = writef(cast(long)__s4384.ptr, lex_tok_name(lex_token));
    }
L1284:
    return 0;
}
long parse_error(long p1 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long msg = p1;
    diag_nerr = (diag_nerr + 1L);
    v0 = diag_pre(2L, lex_lastline);
    v2 = writef(cast(long)__s4399.ptr, msg);
    v3 = parse_near();
    v5 = writes(cast(long)__s4404.ptr);
    return 0;
}
long parse_expect(long p1 = 0, long p2 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long tk = p1;
    long ctx = p2;
    if (lex_token != tk)
    {
        v0 = parse_error(ctx);
    }
    else
    {
        v1 = lex_next();
    }
    return 0;
}
long tok_is_mul(long p1 = 0)
{
    long t = p1;
    return (((((cast(long)(t == 132L) | cast(long)(t == 133L)) | cast(long)(t == 225L)) | cast(long)(t == 254L)) | cast(long)(t == 255L)) | cast(long)(t == 263L));
}
long tok_is_add(long p1 = 0)
{
    long t = p1;
    return (((cast(long)(t == 130L) | cast(long)(t == 131L)) | cast(long)(t == 252L)) | cast(long)(t == 253L));
}
long tok_is_shift(long p1 = 0)
{
    long t = p1;
    return (cast(long)(t == 140L) | cast(long)(t == 141L));
}
long tok_is_cmp(long p1 = 0)
{
    long t = p1;
    return (((((((((((cast(long)(t == 120L) | cast(long)(t == 121L)) | cast(long)(t == 122L)) | cast(long)(t == 123L)) | cast(long)(t == 124L)) | cast(long)(t == 125L)) | cast(long)(t == 256L)) | cast(long)(t == 257L)) | cast(long)(t == 258L)) | cast(long)(t == 259L)) | cast(long)(t == 260L)) | cast(long)(t == 261L));
}
long ast_intern_cstr(long p1 = 0)
{
    long n = 0;
    long v0 = 0;
    long p = 0;
    long i = 0;
    long s = p1;
    n = cast(long)*cast(ubyte*)(s + 0L);
    p = getvec(((n / 8L) + 2L));
    *cast(ubyte*)(p + 0L) = cast(ubyte)n;
    i = 1L;
    while (i <= n)
    {
        *cast(ubyte*)(p + i) = cast(ubyte)cast(long)*cast(ubyte*)(s + i);
        i = (i + 1L);
    }
    *cast(ubyte*)(p + (n + 1L)) = cast(ubyte)0L;
    return p;
}
long parse_make_index(long p1 = 0, long p2 = 0, long p3 = 0)
{
    long v0 = 0;
    long nameNode = 0;
    long v1 = 0;
    long idxNode = 0;
    long v2 = 0;
    long indexNode = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long v6 = 0;
    long name_ptr = p1;
    long idx = p2;
    long line = p3;
    nameNode = ast_new(3L, line);
    idxNode = ast_new(1L, line);
    indexNode = ast_new(7L, line);
    v3 = ast_set(nameNode, 1L, name_ptr);
    v4 = ast_set(idxNode, 1L, idx);
    v5 = ast_set(indexNode, 1L, nameNode);
    v6 = ast_set(indexNode, 2L, idxNode);
    return indexNode;
}
long parse_make_let(long p1 = 0, long p2 = 0, long p3 = 0)
{
    long v0 = 0;
    long n = 0;
    long v1 = 0;
    long v2 = 0;
    long name_ptr = p1;
    long init = p2;
    long line = p3;
    n = ast_new(10L, line);
    v1 = ast_set(n, 1L, name_ptr);
    v2 = ast_set(n, 3L, init);
    return n;
}
long parse_const_eval(long p1 = 0)
{
    long v0 = 0;
    long k = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long s = 0;
    long v4 = 0;
    long op = 0;
    long v5 = 0;
    long v6 = 0;
    long v = 0;
    long v7 = 0;
    long op_2 = 0;
    long v8 = 0;
    long v9 = 0;
    long a = 0;
    long v10 = 0;
    long v11 = 0;
    long b = 0;
    long v12 = 0;
    long v13 = 0;
    long v14 = 0;
    long v15 = 0;
    long len = 0;
    long v16 = 0;
    long v17 = 0;
    long sh = 0;
    long v18 = 0;
    long v19 = 0;
    long off = 0;
    long node = p1;
    k = ast_kind(node);
    if (k == 1L) goto L1308; else goto L1313;
L1313:
    if (k == 3L) goto L1309; else goto L1314;
L1314:
    if (k == 6L) goto L1310; else goto L1315;
L1315:
    if (k == 5L) goto L1311; else goto L1316;
L1316:
    if (k == 28L) goto L1312; else goto L1317;
L1317:
    goto L1307;
L1308:
    return ast_get(node, 1L);
L1309:
    s = sym_lookup(ast_get(node, 1L));
    if (s >= 0L)
    {
        if (*cast(long*)(sym_kinds + (s << 3L)) == 2L) goto L1318; else goto L1319;
L1318:
        diag_nmanifest = (diag_nmanifest + 1L);
        return *cast(long*)(sym_values + (s << 3L));
    }
L1319:
    cg_temp_reg = 1L;
    return 0L;
L1320:
    goto L1306;
L1310:
    op = ast_get(node, 1L);
    v = parse_const_eval(ast_get(node, 2L));
    if (op == 131L)
    {
        return (-v);
    }
    else
    {
        if (op == 137L)
        {
            return (~v);
        }
        else
        {
            if (op == 130L)
            {
                return v;
            }
            else
            {
                cg_temp_reg = 1L;
                return 0L;
            }
        }
    }
    goto L1306;
L1311:
    op_2 = ast_get(node, 1L);
    a = parse_const_eval(ast_get(node, 2L));
    b = parse_const_eval(ast_get(node, 3L));
    if (op_2 == 130L) goto L1333; else goto L1342;
L1342:
    if (op_2 == 131L) goto L1334; else goto L1343;
L1343:
    if (op_2 == 132L) goto L1335; else goto L1344;
L1344:
    if (op_2 == 133L) goto L1336; else goto L1345;
L1345:
    if (op_2 == 134L) goto L1337; else goto L1346;
L1346:
    if (op_2 == 135L) goto L1338; else goto L1347;
L1347:
    if (op_2 == 136L) goto L1339; else goto L1348;
L1348:
    if (op_2 == 140L) goto L1340; else goto L1349;
L1349:
    if (op_2 == 141L) goto L1341; else goto L1350;
L1350:
    goto L1332;
L1333:
    return (a + b);
L1334:
    return (a - b);
L1335:
    return (a * b);
L1336:
    if (b == 0L)
    {
        v12 = 0L;
    }
    else
    {
        v12 = (a / b);
    }
    return v12;
L1337:
    if (b == 0L)
    {
        v13 = 0L;
    }
    else
    {
        v13 = (a % b);
    }
    return v13;
L1338:
    return (a & b);
L1339:
    return (a | b);
L1340:
    return (a << b);
L1341:
    return (a >> b);
L1332:
    cg_temp_reg = 1L;
    return 0L;
L1331:
    goto L1306;
L1312:
    len = parse_const_eval(ast_get(node, 1L));
    sh = parse_const_eval(ast_get(node, 2L));
    off = parse_const_eval(ast_get(node, 3L));
    return (((sh & 255L) | ((len & 255L) << 8L)) | (off << 16L));
L1307:
    cg_temp_reg = 1L;
    return 0L;
L1306:
    return 0;
}
long parse_fresh_match_name()
{
    long[7] __v4708;
    long v0 = 0;
    long buf = 0;
    long n = 0;
    long v1 = 0;
    v0 = cast(long)__v4708.ptr;
    buf = v0;
    n = parse_match_counter;
    parse_match_counter = (n + 1L);
    *cast(ubyte*)(buf + 0L) = cast(ubyte)4L;
    *cast(ubyte*)(buf + 1L) = cast(ubyte)95L;
    *cast(ubyte*)(buf + 2L) = cast(ubyte)109L;
    *cast(ubyte*)(buf + 3L) = cast(ubyte)(48L + ((n / 10L) % 10L));
    *cast(ubyte*)(buf + 4L) = cast(ubyte)(48L + (n % 10L));
    *cast(ubyte*)(buf + 5L) = cast(ubyte)0L;
    return ast_intern_cstr(buf);
}
long parse_primary()
{
    long line = 0;
    long n = 0;
    long body_ = 0;
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
    long[4] __v4878;
    long v38 = 0;
    long nums = 0;
    long cnt = 0;
    long v39 = 0;
    long s = 0;
    long v40 = 0;
    long zero = 0;
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
    line = lex_lastline;
    n = 0L;
    body_ = 0L;
    v0 = lex_token;
    if (v0 == 1L) goto L1359; else goto L1371;
L1371:
    if (v0 == 2L) goto L1360; else goto L1372;
L1372:
    if (v0 == 4L) goto L1361; else goto L1373;
L1373:
    if (v0 == 239L) goto L1362; else goto L1374;
L1374:
    if (v0 == 210L) goto L1363; else goto L1375;
L1375:
    if (v0 == 100L) goto L1364; else goto L1376;
L1376:
    if (v0 == 242L) goto L1365; else goto L1377;
L1377:
    if (v0 == 245L) goto L1366; else goto L1378;
L1378:
    if (v0 == 268L) goto L1367; else goto L1379;
L1379:
    if (v0 == 244L) goto L1368; else goto L1380;
L1380:
    if (v0 == 112L) goto L1369; else goto L1381;
L1381:
    if (v0 == 248L) goto L1370; else goto L1382;
L1382:
    goto L1358;
L1359:
    if (lex_numtype == 1L)
    {
        n = ast_new(30L, line);
        v2 = ast_set(n, 1L, lex_value);
        v3 = ast_set(n, 2L, lex_fexp);
    }
    else
    {
        n = ast_new(1L, line);
        v5 = ast_set(n, 1L, lex_value);
    }
    v6 = lex_next();
    return n;
L1360:
    n = ast_new(2L, line);
    v9 = ast_set(n, 1L, ast_intern_buf());
    v10 = lex_next();
    return n;
L1361:
    n = ast_new(3L, line);
    v13 = ast_set(n, 1L, ast_intern_buf());
    v14 = lex_next();
    return n;
L1362:
    n = ast_new(1L, line);
    v16 = ast_set(n, 1L, 1L);
    v17 = lex_next();
    return n;
L1363:
    n = ast_new(1L, line);
    v19 = ast_set(n, 1L, 0L);
    v20 = lex_next();
    return n;
L1364:
    v21 = lex_next();
    n = parse_expr();
    v24 = parse_expect(101L, cast(long)__s4841.ptr);
    return n;
L1365:
    v25 = lex_next();
    body_ = parse_command();
    n = ast_new(22L, line);
    v28 = ast_set(n, 1L, body_);
    return n;
L1366:
    return parse_match_construct(0L);
L1367:
    return parse_match_construct(1L);
L1368:
    v31 = lex_next();
    body_ = parse_primary();
    n = ast_new(25L, line);
    v34 = ast_set(n, 1L, body_);
    return n;
L1369:
    v35 = lex_next();
    n = ast_new(1L, line);
    v37 = ast_set(n, 1L, 0L);
    return n;
L1370:
    v38 = cast(long)__v4878.ptr;
    nums = v38;
    cnt = 0L;
    s = ast_new(28L, line);
    zero = ast_new(1L, line);
    v41 = ast_set(zero, 1L, 0L);
    v42 = lex_next();
    *cast(long*)(nums + (0L << 3L)) = parse_primary();
    cnt = 1L;
    while (lex_token == 108L)
    {
        v44 = lex_next();
        if (cnt < 3L)
        {
            *cast(long*)(nums + (cnt << 3L)) = parse_primary();
            cnt = (cnt + 1L);
        }
    }
    if (cnt == 1L)
    {
        v46 = ast_set(s, 1L, zero);
        v47 = ast_set(s, 2L, zero);
        v48 = ast_set(s, 3L, *cast(long*)(nums + (0L << 3L)));
    }
    else
    {
        if (cnt == 2L)
        {
            v49 = ast_set(s, 1L, zero);
            v50 = ast_set(s, 2L, *cast(long*)(nums + (0L << 3L)));
            v51 = ast_set(s, 3L, *cast(long*)(nums + (1L << 3L)));
        }
        else
        {
            v52 = ast_set(s, 1L, *cast(long*)(nums + (0L << 3L)));
            v53 = ast_set(s, 2L, *cast(long*)(nums + (1L << 3L)));
            v54 = ast_set(s, 3L, *cast(long*)(nums + (2L << 3L)));
        }
    }
    return s;
L1358:
    v56 = parse_error(cast(long)__s4979.ptr);
    v57 = lex_next();
    return ast_new(1L, line);
L1357:
    return 0;
}
long parse_postfix()
{
    long line = 0;
    long v0 = 0;
    long e = 0;
    long idx = 0;
    long n = 0;
    long argcount = 0;
    long a = 0;
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
    line = lex_lastline;
    e = parse_primary();
    idx = 0L;
    n = 0L;
    argcount = 0L;
    a = 0L;
L1397:
    if (1L != 0)
    {
        v1 = lex_token;
        if (v1 == 111L) goto L1402; else goto L1407;
L1407:
        if (v1 == 113L) goto L1403; else goto L1408;
L1408:
        if (v1 == 223L) goto L1404; else goto L1409;
L1409:
        if (v1 == 249L) goto L1405; else goto L1410;
L1410:
        if (v1 == 100L) goto L1406; else goto L1411;
L1411:
    goto L1401;
L1402:
        v2 = lex_next();
        idx = parse_primary();
        n = ast_new(7L, line);
        v5 = ast_set(n, 1L, e);
        v6 = ast_set(n, 2L, idx);
        e = n;
    goto L1397;
L1403:
        v7 = lex_next();
        idx = parse_primary();
        n = ast_new(24L, line);
        v10 = ast_set(n, 1L, e);
        v11 = ast_set(n, 2L, idx);
        e = n;
    goto L1397;
L1404:
        v12 = lex_next();
        idx = parse_primary();
        n = ast_new(29L, line);
        v15 = ast_set(n, 1L, e);
        v16 = ast_set(n, 2L, idx);
        e = n;
    goto L1397;
L1405:
        v17 = lex_next();
        idx = parse_primary();
        n = ast_new(29L, line);
        v20 = ast_set(n, 1L, e);
        v21 = ast_set(n, 2L, idx);
        e = n;
    goto L1397;
L1406:
        if (lex_lastline > lex_prevline)
        {
    goto L1399;
        }
        v22 = lex_next();
        n = ast_new(4L, line);
        v24 = ast_set(n, 1L, e);
        argcount = 0L;
        if (lex_token == 101L) goto L1415; else goto L1414;
L1414:
L1416:
        if (1L != 0)
        {
            a = parse_expr();
            argcount = (argcount + 1L);
            if (argcount <= 5L)
            {
                v26 = ast_set(n, (1L + argcount), a);
            }
            if (lex_token == 106L) goto L1422; else goto L1421;
L1421:
    goto L1418;
L1422:
            v27 = lex_next();
    goto L1416;
        }
L1418:
L1415:
        v29 = parse_expect(101L, cast(long)__s5097.ptr);
        v30 = ast_set(n, 7L, argcount);
        e = n;
    goto L1397;
L1401:
    goto L1399;
L1400:
    goto L1397;
    }
L1399:
    return e;
}
long parse_unary()
{
    long line = 0;
    long op = 0;
    long operand = 0;
    long n = 0;
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long e = 0;
    long zero = 0;
    long cmp = 0;
    long neg = 0;
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
    line = lex_lastline;
    op = 0L;
    operand = 0L;
    n = 0L;
    if (lex_token == 131L) goto L1423; else goto L1430;
L1430:
    if (lex_token == 137L) goto L1423; else goto L1429;
L1429:
    if (lex_token == 111L) goto L1423; else goto L1428;
L1428:
    if (lex_token == 110L) goto L1423; else goto L1427;
L1427:
    if (lex_token == 250L) goto L1423; else goto L1426;
L1426:
    if (lex_token == 251L) goto L1423; else goto L1425;
L1425:
    if (lex_token == 262L) goto L1423; else goto L1424;
L1423:
    op = lex_token;
    v0 = lex_next();
    operand = parse_unary();
    n = ast_new(6L, line);
    v3 = ast_set(n, 1L, op);
    v4 = ast_set(n, 2L, operand);
    return n;
L1424:
    if (lex_token == 247L)
    {
        e = 0L;
        zero = 0L;
        cmp = 0L;
        neg = 0L;
        v5 = lex_next();
        e = parse_unary();
        zero = ast_new(1L, line);
        v8 = ast_set(zero, 1L, 0L);
        cmp = ast_new(5L, line);
        v10 = ast_set(cmp, 1L, 122L);
        v11 = ast_set(cmp, 2L, e);
        v12 = ast_set(cmp, 3L, zero);
        neg = ast_new(6L, line);
        v14 = ast_set(neg, 1L, 131L);
        v15 = ast_set(neg, 2L, e);
        n = ast_new(8L, line);
        v17 = ast_set(n, 1L, cmp);
        v18 = ast_set(n, 2L, neg);
        v19 = ast_set(n, 3L, e);
        return n;
    }
    return parse_postfix();
}
long parse_relchain()
{
    long line = 0;
    long v0 = 0;
    long prev = 0;
    long chain = 0;
    long v1 = 0;
    long v2 = 0;
    long cop = 0;
    long rhs = 0;
    long cmpn = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long v6 = 0;
    long v7 = 0;
    long v8 = 0;
    long v9 = 0;
    long andn = 0;
    long v10 = 0;
    long v11 = 0;
    long v12 = 0;
    line = lex_lastline;
    prev = parse_binop_at(3L);
    chain = 0L;
    if (tok_is_cmp(lex_token) != 0) goto L1434; else goto L1433;
L1433:
    return prev;
L1434:
L1435:
    if (tok_is_cmp(lex_token) != 0)
    {
        cop = lex_token;
        rhs = 0L;
        cmpn = 0L;
        v3 = lex_next();
        rhs = parse_binop_at(3L);
        cmpn = ast_new(5L, line);
        v6 = ast_set(cmpn, 1L, cop);
        v7 = ast_set(cmpn, 2L, prev);
        v8 = ast_set(cmpn, 3L, rhs);
        if (chain == 0L)
        {
            chain = cmpn;
        }
        else
        {
            andn = ast_new(5L, line);
            v10 = ast_set(andn, 1L, 135L);
            v11 = ast_set(andn, 2L, chain);
            v12 = ast_set(andn, 3L, cmpn);
            chain = andn;
        }
        prev = rhs;
    goto L1435;
    }
    return chain;
}
long parse_binop_at(long p1 = 0)
{
    long line = 0;
    long lhs = 0;
    long op = 0;
    long rhs = 0;
    long n = 0;
    long take = 0;
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
    long level = p1;
    line = lex_lastline;
    lhs = 0L;
    op = 0L;
    rhs = 0L;
    n = 0L;
    take = 0L;
    if (level == 4L)
    {
        return parse_relchain();
    }
    if (level == 0L)
    {
        lhs = parse_unary();
    }
    else
    {
        lhs = parse_binop_at((level - 1L));
    }
L1446:
    if (1L != 0)
    {
        op = lex_token;
        take = 0L;
        if (level == 1L) goto L1451; else goto L1458;
L1458:
        if (level == 2L) goto L1452; else goto L1459;
L1459:
        if (level == 3L) goto L1453; else goto L1460;
L1460:
        if (level == 4L) goto L1454; else goto L1461;
L1461:
        if (level == 5L) goto L1455; else goto L1462;
L1462:
        if (level == 6L) goto L1456; else goto L1463;
L1463:
        if (level == 7L) goto L1457; else goto L1464;
L1464:
    goto L1450;
L1451:
        take = tok_is_mul(op);
    goto L1449;
L1452:
        take = tok_is_add(op);
    goto L1449;
L1453:
        take = tok_is_shift(op);
    goto L1449;
L1454:
        take = tok_is_cmp(op);
    goto L1449;
L1455:
        take = cast(long)(op == 135L);
    goto L1449;
L1456:
        take = cast(long)(op == 136L);
    goto L1449;
L1457:
        take = (cast(long)(op == 138L) | cast(long)(op == 139L));
    goto L1449;
L1450:
        take = 0L;
L1449:
        if (take != 0) goto L1466; else goto L1465;
L1465:
    goto L1448;
L1466:
        v7 = lex_next();
        if (level == 0L)
        {
            rhs = parse_unary();
        }
        else
        {
            rhs = parse_binop_at((level - 1L));
        }
        n = ast_new(5L, line);
        v11 = ast_set(n, 1L, op);
        v12 = ast_set(n, 2L, lhs);
        v13 = ast_set(n, 3L, rhs);
        lhs = n;
    goto L1446;
    }
L1448:
    return lhs;
}
long parse_expr()
{
    long line = 0;
    long v0 = 0;
    long e = 0;
    long thn = 0;
    long els = 0;
    long n = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long v6 = 0;
    long v7 = 0;
    long v8 = 0;
    long v9 = 0;
    line = lex_lastline;
    e = parse_binop_at(7L);
    thn = 0L;
    els = 0L;
    n = 0L;
    if (lex_token == 116L)
    {
        v1 = lex_next();
        thn = parse_expr();
        v4 = parse_expect(106L, cast(long)__s5364.ptr);
        els = parse_expr();
        n = ast_new(8L, line);
        v7 = ast_set(n, 1L, e);
        v8 = ast_set(n, 2L, thn);
        v9 = ast_set(n, 3L, els);
        return n;
    }
    return e;
}
long parse_maybe_repeat(long p1 = 0, long p2 = 0)
{
    long v0 = 0;
    long trueNode = 0;
    long v1 = 0;
    long loopn = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long isUntil = 0;
    long cond = 0;
    long v6 = 0;
    long v7 = 0;
    long ifNode = 0;
    long v8 = 0;
    long brNode = 0;
    long v9 = 0;
    long blk = 0;
    long v10 = 0;
    long trueN = 0;
    long v11 = 0;
    long loopn_2 = 0;
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
    long cmd = p1;
    long line = p2;
    if (lex_token == 226L)
    {
        trueNode = ast_new(1L, line);
        loopn = ast_new(15L, line);
        v2 = lex_next();
        v3 = ast_set(trueNode, 1L, 1L);
        v4 = ast_set(loopn, 1L, trueNode);
        v5 = ast_set(loopn, 2L, cmd);
        return loopn;
    }
    if (lex_token == 228L) goto L1474; else goto L1476;
L1476:
    if (lex_token == 227L) goto L1474; else goto L1475;
L1474:
    isUntil = cast(long)(lex_token == 227L);
    cond = 0L;
    if (isUntil != 0)
    {
        v6 = 12L;
    }
    else
    {
        v6 = 13L;
    }
    ifNode = ast_new(v6, line);
    brNode = ast_new(20L, line);
    blk = ast_new(11L, line);
    trueN = ast_new(1L, line);
    loopn_2 = ast_new(15L, line);
    v12 = lex_next();
    cond = parse_expr();
    v14 = ast_set(ifNode, 1L, cond);
    v15 = ast_set(ifNode, 2L, brNode);
    v16 = ast_set(blk, 1L, cmd);
    v17 = ast_set(blk, 2L, ifNode);
    v18 = ast_set(blk, 7L, 2L);
    v19 = ast_set(trueN, 1L, 1L);
    v20 = ast_set(loopn_2, 1L, trueN);
    v21 = ast_set(loopn_2, 2L, blk);
    return loopn_2;
L1475:
    return cmd;
}
long parse_block()
{
    long line = 0;
    long blk = 0;
    long cur = 0;
    long count = 0;
    long s = 0;
    long cmdLine = 0;
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long sub = 0;
    long v6 = 0;
    long v7 = 0;
    long v8 = 0;
    long v9 = 0;
    long v10 = 0;
    long v11 = 0;
    long v12 = 0;
    line = lex_lastline;
    blk = 0L;
    cur = 0L;
    count = 0L;
    s = 0L;
    cmdLine = 0L;
    v1 = parse_expect(104L, cast(long)__s5485.ptr);
    blk = ast_new(11L, line);
    cur = blk;
L1480:
    if (lex_token == 105L) goto L1482; else goto L1483;
L1483:
    if (lex_token == 0L) goto L1482; else goto L1481;
L1481:
    cmdLine = lex_lastline;
    s = parse_command();
    s = parse_maybe_repeat(s, cmdLine);
    if (count >= 5L)
    {
        sub = ast_new(11L, line);
        v6 = ast_set(cur, 6L, sub);
        v7 = ast_set(cur, 7L, 6L);
        cur = sub;
        count = 0L;
    }
    count = (count + 1L);
    v8 = ast_set(cur, count, s);
    if (lex_token == 107L)
    {
        v9 = lex_next();
    }
    goto L1480;
L1482:
    v11 = parse_expect(105L, cast(long)__s5526.ptr);
    v12 = ast_set(cur, 7L, count);
    return blk;
}
long parse_skip_decl()
{
    long v0 = 0;
    long depth = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long v6 = 0;
    if (lex_token == 0L) goto L1489; else goto L1488;
L1488:
    v0 = lex_next();
L1489:
    if (lex_token == 100L)
    {
        depth = 1L;
        v1 = lex_next();
L1492:
        if (depth == 0L) goto L1494; else goto L1495;
L1495:
        if (lex_token == 0L) goto L1494; else goto L1493;
L1493:
        if (lex_token == 100L)
        {
            depth = (depth + 1L);
        }
        if (lex_token == 101L)
        {
            depth = (depth - 1L);
        }
        v2 = lex_next();
    goto L1492;
L1494:
    }
    if (lex_token == 120L)
    {
        v3 = lex_next();
        v4 = parse_expr();
    }
    else
    {
        if (lex_token == 201L)
        {
            v5 = lex_next();
            v6 = parse_command();
        }
    }
    return 0;
}
long parse_let_single()
{
    long line = 0;
    long name = 0;
    long n = 0;
    long fdef = 0;
    long argcount = 0;
    long body_ = 0;
    long init = 0;
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
    line = lex_lastline;
    name = 0L;
    n = 0L;
    fdef = 0L;
    argcount = 0L;
    body_ = 0L;
    init = 0L;
    if (lex_token != 4L)
    {
        if (lex_token == 1L)
        {
            v1 = parse_error(cast(long)__s5597.ptr);
        }
        else
        {
            if (lex_token >= 200L)
            {
                v3 = parse_error(cast(long)__s5603.ptr);
            }
            else
            {
                v5 = parse_error(cast(long)__s5606.ptr);
            }
        }
        v6 = parse_skip_decl();
        return 0L;
    }
    name = ast_intern_buf();
    v8 = lex_next();
    n = ast_new(10L, line);
    v10 = ast_set(n, 1L, name);
    if (lex_token == 100L)
    {
        v11 = lex_next();
        fdef = ast_new(23L, line);
        argcount = 0L;
        if (lex_token == 101L) goto L1516; else goto L1515;
L1515:
L1517:
        if (1L != 0)
        {
            if (lex_token != 4L)
            {
                v14 = parse_error(cast(long)__s5638.ptr);
    goto L1519;
            }
            argcount = (argcount + 1L);
            if (argcount <= 5L)
            {
                v16 = ast_set(fdef, argcount, ast_intern_buf());
            }
            v17 = lex_next();
            if (lex_token == 106L) goto L1525; else goto L1524;
L1524:
    goto L1519;
L1525:
            v18 = lex_next();
    goto L1517;
        }
L1519:
L1516:
        v20 = parse_expect(101L, cast(long)__s5657.ptr);
        v21 = ast_set(fdef, 6L, argcount);
        if (lex_token == 120L)
        {
            v22 = lex_next();
            body_ = parse_expr();
            v24 = ast_set(fdef, 7L, body_);
        }
        else
        {
            if (lex_token == 201L)
            {
                v25 = lex_next();
                body_ = parse_command();
                v27 = ast_set(fdef, 7L, body_);
            }
            else
            {
                v29 = parse_error(cast(long)__s5683.ptr);
            }
        }
        v30 = ast_set(n, 2L, fdef);
        return n;
    }
    v32 = parse_expect(120L, cast(long)__s5690.ptr);
    init = parse_expr();
    v34 = ast_set(n, 3L, init);
    return n;
}
long parse_let()
{
    long line = 0;
    long v0 = 0;
    long first = 0;
    long blk = 0;
    long count = 0;
    long cur = 0;
    long nxt = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long sub = 0;
    long v6 = 0;
    long v7 = 0;
    long v8 = 0;
    long v9 = 0;
    line = lex_lastline;
    first = parse_let_single();
    blk = 0L;
    count = 0L;
    cur = 0L;
    nxt = 0L;
    if (lex_token != 200L)
    {
        return first;
    }
    blk = ast_new(11L, line);
    v2 = ast_set(blk, 1L, first);
    count = 1L;
    cur = blk;
    while (lex_token == 200L)
    {
        v3 = lex_next();
        nxt = parse_let_single();
        if (count >= 5L)
        {
            sub = ast_new(11L, line);
            v6 = ast_set(cur, 6L, sub);
            v7 = ast_set(cur, 7L, 6L);
            cur = sub;
            count = 0L;
        }
        count = (count + 1L);
        v8 = ast_set(cur, count, nxt);
    }
    v9 = ast_set(cur, 7L, count);
    return blk;
}
long parse_case_body()
{
    long v0 = 0;
    long blk = 0;
    long cnt = 0;
    long cur = 0;
    long d = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long sub = 0;
    long v4 = 0;
    long v5 = 0;
    long v6 = 0;
    long v7 = 0;
    blk = ast_new(11L, lex_lastline);
    cnt = 0L;
    cur = blk;
    d = 0L;
L1539:
    if (lex_token == 208L) goto L1541; else goto L1546;
L1546:
    if (lex_token == 204L) goto L1541; else goto L1545;
L1545:
    if (lex_token == 205L) goto L1541; else goto L1544;
L1544:
    if (lex_token == 105L) goto L1541; else goto L1543;
L1543:
    if (lex_token == 246L) goto L1541; else goto L1542;
L1542:
    if (lex_token == 0L) goto L1541; else goto L1540;
L1540:
    if (lex_token == 107L)
    {
        v1 = lex_next();
    goto L1539;
    }
    d = parse_command();
    if (cnt >= 5L)
    {
        sub = ast_new(11L, lex_lastline);
        v4 = ast_set(cur, 6L, sub);
        v5 = ast_set(cur, 7L, 6L);
        cur = sub;
        cnt = 0L;
    }
    cnt = (cnt + 1L);
    v6 = ast_set(cur, cnt, d);
    goto L1539;
L1541:
    v7 = ast_set(cur, 7L, cnt);
    return blk;
}
long parse_pat_starts_term(long p1 = 0)
{
    long t = p1;
    return (((((((((((((((((((cast(long)(t == 112L) | cast(long)(t == 102L)) | cast(long)(t == 100L)) | cast(long)(t == 1L)) | cast(long)(t == 4L)) | cast(long)(t == 131L)) | cast(long)(t == 266L)) | cast(long)(t == 267L)) | cast(long)(t == 122L)) | cast(long)(t == 123L)) | cast(long)(t == 124L)) | cast(long)(t == 125L)) | cast(long)(t == 120L)) | cast(long)(t == 121L)) | cast(long)(t == 258L)) | cast(long)(t == 259L)) | cast(long)(t == 260L)) | cast(long)(t == 261L)) | cast(long)(t == 256L)) | cast(long)(t == 257L));
}
long parse_pat_operand()
{
    long line = 0;
    long inner = 0;
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long u = 0;
    long v6 = 0;
    long v7 = 0;
    long v8 = 0;
    long n = 0;
    long v9 = 0;
    long v10 = 0;
    long v11 = 0;
    long n_2 = 0;
    long v12 = 0;
    long v13 = 0;
    long v14 = 0;
    long v15 = 0;
    long v16 = 0;
    long v17 = 0;
    line = lex_lastline;
    if (lex_token == 131L)
    {
        inner = 0L;
        v0 = lex_next();
        inner = parse_pat_operand();
        if (ast_kind(inner) == 1L)
        {
            v4 = ast_set(inner, 1L, (-ast_get(inner, 1L)));
            return inner;
        }
        else
        {
            u = ast_new(6L, line);
            v6 = ast_set(u, 1L, 131L);
            v7 = ast_set(u, 2L, inner);
            return u;
        }
    }
    else
    {
        if (lex_token == 1L)
        {
            n = ast_new(1L, line);
            v9 = ast_set(n, 1L, lex_value);
            v10 = lex_next();
            return n;
        }
        else
        {
            if (lex_token == 4L)
            {
                n_2 = ast_new(3L, line);
                v13 = ast_set(n_2, 1L, ast_intern_buf());
                v14 = lex_next();
                return n_2;
            }
            else
            {
                v16 = parse_error(cast(long)__s5930.ptr);
                return ast_new(1L, line);
            }
        }
    }
    return 0;
}
long parse_pat_term()
{
    long line = 0;
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long p = 0;
    long v6 = 0;
    long v7 = 0;
    long v8 = 0;
    long v9 = 0;
    long v10 = 0;
    long n = 0;
    long v11 = 0;
    long p_2 = 0;
    long v12 = 0;
    long v13 = 0;
    long v14 = 0;
    long v15 = 0;
    long op = 0;
    long rhs = 0;
    long v16 = 0;
    long v17 = 0;
    long v18 = 0;
    long n_2 = 0;
    long v19 = 0;
    long v20 = 0;
    long v21 = 0;
    long opd = 0;
    long hi = 0;
    long v22 = 0;
    long v23 = 0;
    long v24 = 0;
    long n_3 = 0;
    long v25 = 0;
    long v26 = 0;
    long v27 = 0;
    long v28 = 0;
    long n_4 = 0;
    long v29 = 0;
    long v = 0;
    long v30 = 0;
    long v31 = 0;
    long n_5 = 0;
    long v32 = 0;
    long num = 0;
    long v33 = 0;
    long v34 = 0;
    long v35 = 0;
    long n_6 = 0;
    long v36 = 0;
    long v37 = 0;
    line = lex_lastline;
    if (lex_token == 112L)
    {
        v0 = lex_next();
        return ast_new(33L, line);
    }
    if (lex_token == 266L)
    {
        v2 = lex_next();
        return ast_new(42L, line);
    }
    if (lex_token == 267L)
    {
        v4 = lex_next();
        return ast_new(43L, line);
    }
    if (lex_token == 102L)
    {
        p = 0L;
        v6 = lex_next();
        p = parse_pattern();
        v9 = parse_expect(103L, cast(long)__s5973.ptr);
        n = ast_new(38L, line);
        v11 = ast_set(n, 1L, p);
        return n;
    }
    if (lex_token == 100L)
    {
        p_2 = 0L;
        v12 = lex_next();
        p_2 = parse_pattern();
        v15 = parse_expect(101L, cast(long)__s5993.ptr);
        return p_2;
    }
    if (lex_token == 122L) goto L1573; else goto L1585;
L1585:
    if (lex_token == 123L) goto L1573; else goto L1584;
L1584:
    if (lex_token == 124L) goto L1573; else goto L1583;
L1583:
    if (lex_token == 125L) goto L1573; else goto L1582;
L1582:
    if (lex_token == 120L) goto L1573; else goto L1581;
L1581:
    if (lex_token == 121L) goto L1573; else goto L1580;
L1580:
    if (lex_token == 258L) goto L1573; else goto L1579;
L1579:
    if (lex_token == 259L) goto L1573; else goto L1578;
L1578:
    if (lex_token == 260L) goto L1573; else goto L1577;
L1577:
    if (lex_token == 261L) goto L1573; else goto L1576;
L1576:
    if (lex_token == 256L) goto L1573; else goto L1575;
L1575:
    if (lex_token == 257L) goto L1573; else goto L1574;
L1573:
    op = lex_token;
    rhs = 0L;
    v16 = lex_next();
    rhs = parse_pat_operand();
    n_2 = ast_new(37L, line);
    v19 = ast_set(n_2, 1L, op);
    v20 = ast_set(n_2, 2L, rhs);
    return n_2;
L1574:
    opd = parse_pat_operand();
    if (lex_token == 264L)
    {
        hi = 0L;
        v22 = lex_next();
        hi = parse_pat_operand();
        n_3 = ast_new(36L, line);
        v25 = ast_set(n_3, 1L, opd);
        v26 = ast_set(n_3, 2L, hi);
        return n_3;
    }
    if (ast_kind(opd) == 1L)
    {
        n_4 = ast_new(34L, line);
        v29 = ast_set(n_4, 1L, opd);
        return n_4;
    }
    else
    {
        v = 0L;
        cg_temp_reg = 0L;
        v = parse_const_eval(opd);
        if (cg_temp_reg == 0L)
        {
            n_5 = ast_new(34L, line);
            num = ast_new(1L, line);
            v33 = ast_set(num, 1L, v);
            v34 = ast_set(n_5, 1L, num);
            return n_5;
        }
        else
        {
            n_6 = ast_new(35L, line);
            v37 = ast_set(n_6, 1L, ast_get(opd, 1L));
            return n_6;
        }
    }
    return 0;
}
long parse_pat_juxt()
{
    long v0 = 0;
    long p = 0;
    long v1 = 0;
    long v2 = 0;
    long q = 0;
    long v3 = 0;
    long n = 0;
    long v4 = 0;
    long v5 = 0;
    p = parse_pat_term();
L1594:
    if (parse_pat_starts_term(lex_token) != 0)
    {
        q = parse_pat_term();
        n = ast_new(39L, lex_lastline);
        v4 = ast_set(n, 1L, p);
        v5 = ast_set(n, 2L, q);
        p = n;
    goto L1594;
    }
    return p;
}
long parse_pat_or()
{
    long v0 = 0;
    long p = 0;
    long q = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long n = 0;
    long v4 = 0;
    long v5 = 0;
    p = parse_pat_juxt();
    while (lex_token == 136L)
    {
        q = 0L;
        v1 = lex_next();
        q = parse_pat_juxt();
        n = ast_new(40L, lex_lastline);
        v4 = ast_set(n, 1L, p);
        v5 = ast_set(n, 2L, q);
        p = n;
    }
    return p;
}
long parse_pattern()
{
    long v0 = 0;
    long p = 0;
    long q = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long n = 0;
    long v4 = 0;
    long v5 = 0;
    p = parse_pat_or();
    while (lex_token == 106L)
    {
        q = 0L;
        v1 = lex_next();
        q = parse_pat_or();
        n = ast_new(41L, lex_lastline);
        v4 = ast_set(n, 1L, p);
        v5 = ast_set(n, 2L, q);
        p = n;
    }
    return p;
}
long parse_match_construct(long p1 = 0)
{
    long line = 0;
    long v0 = 0;
    long argBlk = 0;
    long argc = 0;
    long itemHead = 0;
    long itemTail = 0;
    long isExpr = 0;
    long v1 = 0;
    long node = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long a = 0;
    long v6 = 0;
    long v7 = 0;
    long v8 = 0;
    long v9 = 0;
    long v10 = 0;
    long pat = 0;
    long body_ = 0;
    long v11 = 0;
    long item = 0;
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
    long isEvery = p1;
    line = lex_lastline;
    argBlk = ast_new(11L, line);
    argc = 0L;
    itemHead = 0L;
    itemTail = 0L;
    isExpr = (-1L);
    node = ast_new(31L, line);
    v2 = lex_next();
    v4 = parse_expect(100L, cast(long)__s6208.ptr);
L1603:
    if (lex_token == 101L) goto L1605; else goto L1606;
L1606:
    if (lex_token == 0L) goto L1605; else goto L1604;
L1604:
    a = parse_expr();
    if (argc < 6L)
    {
        argc = (argc + 1L);
        v6 = ast_set(argBlk, argc, a);
    }
    if (lex_token == 106L) goto L1610; else goto L1609;
L1609:
    goto L1605;
L1610:
    v7 = lex_next();
    goto L1603;
L1605:
    v9 = parse_expect(101L, cast(long)__s6232.ptr);
    v10 = ast_set(argBlk, 7L, argc);
    while (lex_token == 108L)
    {
        pat = 0L;
        body_ = 0L;
        item = ast_new(32L, lex_lastline);
        v12 = lex_next();
        pat = parse_pattern();
        if (lex_token == 117L)
        {
            if (isExpr == 0L)
            {
                v15 = parse_error(cast(long)__s6259.ptr);
            }
            isExpr = 1L;
            v16 = lex_next();
            body_ = parse_expr();
        }
        else
        {
            if (lex_token == 201L)
            {
                if (isExpr == 1L)
                {
                    v19 = parse_error(cast(long)__s6272.ptr);
                }
                isExpr = 0L;
                v20 = lex_next();
                body_ = parse_command();
            }
            else
            {
                v23 = parse_error(cast(long)__s6280.ptr);
                body_ = ast_new(1L, line);
            }
        }
        v25 = ast_set(item, 1L, pat);
        v26 = ast_set(item, 2L, body_);
        v27 = ast_set(item, 3L, 0L);
        if (itemHead == 0L)
        {
            itemHead = item;
            itemTail = item;
        }
        else
        {
            v28 = ast_set(itemTail, 3L, item);
            itemTail = item;
        }
    }
    if (lex_token == 109L)
    {
        v29 = lex_next();
    }
    v30 = ast_set(node, 1L, argBlk);
    v31 = ast_set(node, 2L, itemHead);
    if (isEvery != 0)
    {
        v32 = 1L;
    }
    else
    {
        v32 = 0L;
    }
    if (isExpr == 1L)
    {
        v33 = 2L;
    }
    else
    {
        v33 = 0L;
    }
    v34 = ast_set(node, 7L, (v32 | v33));
    return node;
}
long parse_command()
{
    long line = 0;
    long n = 0;
    long c = 0;
    long t = 0;
    long e = 0;
    long body_ = 0;
    long lhs = 0;
    long rhs = 0;
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long swExpr = 0;
    long v6 = 0;
    long swNode = 0;
    long head = 0;
    long tail = 0;
    long defaultBody = 0;
    long caseLine = 0;
    long caseExpr = 0;
    long caseVal = 0;
    long caseBody = 0;
    long caseNode = 0;
    long v7 = 0;
    long v8 = 0;
    long v9 = 0;
    long v10 = 0;
    long v11 = 0;
    long v12 = 0;
    long[64] __v6445;
    long v13 = 0;
    long caseVals = 0;
    long nVals = 0;
    long mfS = 0;
    long v14 = 0;
    long v15 = 0;
    long v16 = 0;
    long v17 = 0;
    long v18 = 0;
    long v19 = 0;
    long v20 = 0;
    long k = 0;
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
    long scrutExpr = 0;
    long v40 = 0;
    long mName = 0;
    long v41 = 0;
    long letNode = 0;
    long v42 = 0;
    long tagExpr = 0;
    long v43 = 0;
    long swNode_2 = 0;
    long head_2 = 0;
    long tail_2 = 0;
    long defaultBody_2 = 0;
    long[64] __v6567;
    long v44 = 0;
    long caseVals2 = 0;
    long nVals2 = 0;
    long[8] __v6571;
    long v45 = 0;
    long varNames = 0;
    long nVars = 0;
    long caseLine_2 = 0;
    long caseExpr_2 = 0;
    long caseVal_2 = 0;
    long caseBody_2 = 0;
    long caseNode_2 = 0;
    long wrappedBody = 0;
    long wrapBlk = 0;
    long wrapCount = 0;
    long wrapCur = 0;
    long ix = 0;
    long letN = 0;
    long mfS_2 = 0;
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
    long ix_2 = 0;
    long v62 = 0;
    long v63 = 0;
    long v64 = 0;
    long sub = 0;
    long v65 = 0;
    long v66 = 0;
    long v67 = 0;
    long v68 = 0;
    long sub_2 = 0;
    long v69 = 0;
    long v70 = 0;
    long v71 = 0;
    long v72 = 0;
    long ix_3 = 0;
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
    long outer = 0;
    long v90 = 0;
    long v91 = 0;
    long v92 = 0;
    long v93 = 0;
    long v94 = 0;
    long v95 = 0;
    long gName = 0;
    long gSlot = 0;
    long slotExpr = 0;
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
    long gName_2 = 0;
    long gSlot_2 = 0;
    long slotExpr_2 = 0;
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
    long mfName = 0;
    long mfVal = 0;
    long initE = 0;
    long initK = 0;
    long initS = 0;
    long v128 = 0;
    long v129 = 0;
    long v130 = 0;
    long v131 = 0;
    long v132 = 0;
    long v133 = 0;
    long v134 = 0;
    long v135 = 0;
    long v136 = 0;
    long v137 = 0;
    long v138 = 0;
    long v139 = 0;
    long v140 = 0;
    long v141 = 0;
    long mfName_2 = 0;
    long initE_2 = 0;
    long v142 = 0;
    long v143 = 0;
    long v144 = 0;
    long v145 = 0;
    long v146 = 0;
    long mfVal_2 = 0;
    long v147 = 0;
    long v148 = 0;
    long v149 = 0;
    long v150 = 0;
    long v151 = 0;
    long v152 = 0;
    long v153 = 0;
    long v154 = 0;
    long v155 = 0;
    long v156 = 0;
    long v157 = 0;
    long v158 = 0;
    long cName = 0;
    long v159 = 0;
    long callNode = 0;
    long v160 = 0;
    long v161 = 0;
    long v162 = 0;
    long v163 = 0;
    long v164 = 0;
    long v165 = 0;
    long v166 = 0;
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
    long v185 = 0;
    long v186 = 0;
    long v187 = 0;
    long v188 = 0;
    long v189 = 0;
    long v190 = 0;
    long v191 = 0;
    long v192 = 0;
    long v193 = 0;
    long v194 = 0;
    long v195 = 0;
    long v196 = 0;
    long v197 = 0;
    long v198 = 0;
    long v199 = 0;
    long v200 = 0;
    long v201 = 0;
    long v202 = 0;
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
    long name = 0;
    long startE = 0;
    long endE = 0;
    long stepE = 0;
    long bodyN = 0;
    long v219 = 0;
    long v220 = 0;
    long v221 = 0;
    long v222 = 0;
    long v223 = 0;
    long v224 = 0;
    long v225 = 0;
    long v226 = 0;
    long v227 = 0;
    long v228 = 0;
    long v229 = 0;
    long v230 = 0;
    long v231 = 0;
    long v232 = 0;
    long v233 = 0;
    long v234 = 0;
    long v235 = 0;
    long v236 = 0;
    long[7] __v7277;
    long v237 = 0;
    long lhsv = 0;
    long nl = 0;
    long isop = 0;
    long aop = 0;
    long blk = 0;
    long v238 = 0;
    long v239 = 0;
    long v240 = 0;
    long v241 = 0;
    long v242 = 0;
    long v243 = 0;
    long v244 = 0;
    long v245 = 0;
    long v246 = 0;
    long i = 0;
    long l = 0;
    long v247 = 0;
    long r = 0;
    long a = 0;
    long v248 = 0;
    long bn = 0;
    long v249 = 0;
    long v250 = 0;
    long v251 = 0;
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
    long v262 = 0;
    long v263 = 0;
    long op = 0;
    long bn_2 = 0;
    long v264 = 0;
    long v265 = 0;
    long v266 = 0;
    long v267 = 0;
    long v268 = 0;
    long v269 = 0;
    long v270 = 0;
    long v271 = 0;
    long v272 = 0;
    line = lex_lastline;
    n = 0L;
    c = 0L;
    t = 0L;
    e = 0L;
    body_ = 0L;
    lhs = 0L;
    rhs = 0L;
    v0 = lex_token;
    if (v0 == 218L) goto L1637; else goto L1658;
L1658:
    if (v0 == 104L) goto L1638; else goto L1659;
L1659:
    if (v0 == 234L) goto L1639; else goto L1660;
L1660:
    if (v0 == 268L) goto L1640; else goto L1661;
L1661:
    if (v0 == 245L) goto L1641; else goto L1662;
L1662:
    if (v0 == 214L) goto L1642; else goto L1663;
L1663:
    if (v0 == 220L) goto L1643; else goto L1664;
L1664:
    if (v0 == 229L) goto L1644; else goto L1665;
L1665:
    if (v0 == 230L) goto L1645; else goto L1666;
L1666:
    if (v0 == 211L) goto L1646; else goto L1667;
L1667:
    if (v0 == 202L) goto L1647; else goto L1668;
L1668:
    if (v0 == 219L) goto L1648; else goto L1669;
L1669:
    if (v0 == 266L) goto L1649; else goto L1670;
L1670:
    if (v0 == 267L) goto L1650; else goto L1671;
L1671:
    if (v0 == 208L) goto L1651; else goto L1672;
L1672:
    if (v0 == 216L) goto L1652; else goto L1673;
L1673:
    if (v0 == 240L) goto L1653; else goto L1674;
L1674:
    if (v0 == 236L) goto L1654; else goto L1675;
L1675:
    if (v0 == 243L) goto L1655; else goto L1676;
L1676:
    if (v0 == 241L) goto L1656; else goto L1677;
L1677:
    if (v0 == 212L) goto L1657; else goto L1678;
L1678:
    goto L1636;
L1637:
    v1 = lex_next();
    return parse_let();
L1638:
    return parse_block();
L1639:
    v4 = lex_next();
    swExpr = parse_expr();
    swNode = ast_new(26L, line);
    head = 0L;
    tail = 0L;
    defaultBody = 0L;
    caseLine = 0L;
    caseExpr = 0L;
    caseVal = 0L;
    caseBody = 0L;
    caseNode = 0L;
    v7 = ast_set(swNode, 1L, swExpr);
    if (lex_token == 217L)
    {
        v8 = lex_next();
    }
    v10 = parse_expect(104L, cast(long)__s6424.ptr);
L1681:
    if (lex_token == 105L) goto L1683; else goto L1684;
L1684:
    if (lex_token == 0L) goto L1683; else goto L1682;
L1682:
    if (lex_token == 208L)
    {
        v11 = lex_next();
    goto L1681;
    }
    if (lex_token == 107L)
    {
        v12 = lex_next();
    goto L1681;
    }
    if (lex_token == 204L)
    {
        v13 = cast(long)__v6445.ptr;
        caseVals = v13;
        nVals = 0L;
        mfS = 0L;
        caseLine = lex_lastline;
L1692:
        if (1L != 0)
        {
            v14 = lex_next();
            caseExpr = parse_expr();
            cg_temp_reg = 0L;
            caseVal = parse_const_eval(caseExpr);
            if (cg_temp_reg != 0)
            {
                v18 = parse_error(cast(long)__s6462.ptr);
            }
            if (lex_token == 108L)
            {
                v19 = lex_next();
            }
            if (nVals < 64L)
            {
                *cast(long*)(caseVals + (nVals << 3L)) = caseVal;
                nVals = (nVals + 1L);
            }
            if (lex_token == 204L) goto L1702; else goto L1701;
L1701:
    goto L1694;
L1702:
    goto L1692;
        }
L1694:
        caseBody = parse_case_body();
        k = 0L;
        while (k <= (nVals - 1L))
        {
            caseNode = ast_new(27L, caseLine);
            v22 = ast_set(caseNode, 1L, *cast(long*)(caseVals + (k << 3L)));
            v23 = ast_set(caseNode, 2L, caseBody);
            v24 = ast_set(caseNode, 3L, 0L);
            if (head == 0L)
            {
                head = caseNode;
                tail = caseNode;
            }
            else
            {
                v25 = ast_set(tail, 3L, caseNode);
                tail = caseNode;
            }
            k = (k + 1L);
        }
    }
    else
    {
        if (lex_token == 205L)
        {
            v26 = lex_next();
            if (lex_token == 108L)
            {
                v27 = lex_next();
            }
            defaultBody = parse_case_body();
        }
        else
        {
            v30 = parse_error(cast(long)__s6522.ptr);
            v31 = lex_next();
        }
    }
    goto L1681;
L1683:
    v33 = parse_expect(105L, cast(long)__s6528.ptr);
    v34 = ast_set(swNode, 2L, head);
    v35 = ast_set(swNode, 3L, defaultBody);
    return swNode;
L1640:
    return parse_match_construct(1L);
L1641:
    return parse_match_construct(0L);
L1715:
    if (lex_token == 105L) goto L1717; else goto L1719;
L1719:
    if (lex_token == 246L) goto L1717; else goto L1718;
L1718:
    if (lex_token == 0L) goto L1717; else goto L1716;
L1716:
    if (lex_token == 208L)
    {
        v49 = lex_next();
    goto L1715;
    }
    if (lex_token == 107L)
    {
        v50 = lex_next();
    goto L1715;
    }
    if (lex_token == 204L)
    {
        nVals2 = 0L;
        nVars = 0L;
        caseLine_2 = lex_lastline;
L1727:
        if (1L != 0)
        {
            v51 = lex_next();
            caseExpr_2 = parse_expr();
            cg_temp_reg = 0L;
            caseVal_2 = parse_const_eval(caseExpr_2);
            if (cg_temp_reg != 0)
            {
                v55 = parse_error(cast(long)__s6641.ptr);
            }
            if (nVals2 < 64L)
            {
                *cast(long*)(caseVals2 + (nVals2 << 3L)) = caseVal_2;
                nVals2 = (nVals2 + 1L);
            }
            if (lex_token == 106L)
            {
                nVars = 0L;
                while (lex_token == 106L)
                {
                    v56 = lex_next();
                    if (lex_token == 4L)
                    {
                        if (nVars < 8L)
                        {
                            *cast(long*)(varNames + (nVars << 3L)) = ast_intern_buf();
                            nVars = (nVars + 1L);
                        }
                        v58 = lex_next();
                    }
                }
            }
            if (lex_token == 108L)
            {
                v59 = lex_next();
            }
            if (lex_token == 204L) goto L1746; else goto L1745;
L1745:
    goto L1729;
L1746:
    goto L1727;
        }
L1729:
        caseBody_2 = parse_case_body();
        if (nVars > 0L)
        {
            wrapBlk = ast_new(11L, caseLine_2);
            wrapCount = 0L;
            wrapCur = wrapBlk;
            ix_2 = 0L;
            while (ix_2 <= (nVars - 1L))
            {
                letN = parse_make_let(*cast(long*)(varNames + (ix_2 << 3L)), parse_make_index(mName, (ix_2 + 1L), caseLine_2), caseLine_2);
                if (wrapCount >= 5L)
                {
                    sub = ast_new(11L, caseLine_2);
                    v65 = ast_set(wrapCur, 6L, sub);
                    v66 = ast_set(wrapCur, 7L, 6L);
                    wrapCur = sub;
                    wrapCount = 0L;
                }
                wrapCount = (wrapCount + 1L);
                v67 = ast_set(wrapCur, wrapCount, letN);
                ix_2 = (ix_2 + 1L);
            }
            if (wrapCount >= 5L)
            {
                sub_2 = ast_new(11L, caseLine_2);
                v69 = ast_set(wrapCur, 6L, sub_2);
                v70 = ast_set(wrapCur, 7L, 6L);
                wrapCur = sub_2;
                wrapCount = 0L;
            }
            wrapCount = (wrapCount + 1L);
            v71 = ast_set(wrapCur, wrapCount, caseBody_2);
            v72 = ast_set(wrapCur, 7L, wrapCount);
            wrappedBody = wrapBlk;
        }
        else
        {
            wrappedBody = caseBody_2;
        }
        ix_3 = 0L;
        while (ix_3 <= (nVals2 - 1L))
        {
            caseNode_2 = ast_new(27L, caseLine_2);
            v74 = ast_set(caseNode_2, 1L, *cast(long*)(caseVals2 + (ix_3 << 3L)));
            v75 = ast_set(caseNode_2, 2L, wrappedBody);
            v76 = ast_set(caseNode_2, 3L, 0L);
            if (head_2 == 0L)
            {
                head_2 = caseNode_2;
                tail_2 = caseNode_2;
            }
            else
            {
                v77 = ast_set(tail_2, 3L, caseNode_2);
                tail_2 = caseNode_2;
            }
            ix_3 = (ix_3 + 1L);
        }
    }
    else
    {
        if (lex_token == 205L)
        {
            v78 = lex_next();
            if (lex_token == 108L)
            {
                v79 = lex_next();
            }
            defaultBody_2 = parse_case_body();
        }
        else
        {
            v82 = parse_error(cast(long)__s6785.ptr);
            v83 = lex_next();
        }
    }
    goto L1715;
L1717:
    if (lex_token == 246L)
    {
        v84 = lex_next();
    }
    else
    {
        v86 = parse_expect(105L, cast(long)__s6796.ptr);
    }
    v87 = ast_set(swNode_2, 2L, head_2);
    v88 = ast_set(swNode_2, 3L, defaultBody_2);
    outer = ast_new(11L, line);
    v90 = ast_set(outer, 1L, letNode);
    v91 = ast_set(outer, 2L, swNode_2);
    v92 = ast_set(outer, 7L, 2L);
    return outer;
L1642:
    v93 = lex_next();
    if (lex_token == 104L)
    {
        v95 = parse_expect(104L, cast(long)__s6825.ptr);
        gName = 0L;
        gSlot = 0L;
        slotExpr = 0L;
L1776:
        if (lex_token == 105L) goto L1778; else goto L1779;
L1779:
        if (lex_token == 0L) goto L1778; else goto L1777;
L1777:
        if (lex_token == 107L) goto L1780; else goto L1782;
L1782:
        if (lex_token == 106L) goto L1780; else goto L1781;
L1780:
        v96 = lex_next();
    goto L1776;
L1781:
        if (lex_token != 4L)
        {
            v98 = parse_error(cast(long)__s6851.ptr);
            v99 = lex_next();
    goto L1776;
        }
        gName = ast_intern_buf();
        v101 = lex_next();
        v103 = parse_expect(108L, cast(long)__s6861.ptr);
        slotExpr = parse_expr();
        if (ast_kind(slotExpr) == 1L)
        {
            gSlot = ast_get(slotExpr, 1L);
        }
        else
        {
            v108 = parse_error(cast(long)__s6873.ptr);
        }
        v109 = sym_add(gName, 3L, gSlot);
    goto L1776;
L1778:
        v111 = parse_expect(105L, cast(long)__s6880.ptr);
    }
    else
    {
        gName_2 = 0L;
        gSlot_2 = 0L;
        slotExpr_2 = 0L;
        if (lex_token != 4L)
        {
            v113 = parse_error(cast(long)__s6892.ptr);
        }
        else
        {
            gName_2 = ast_intern_buf();
            v115 = lex_next();
            v117 = parse_expect(108L, cast(long)__s6900.ptr);
            slotExpr_2 = parse_expr();
            if (ast_kind(slotExpr_2) == 1L)
            {
                gSlot_2 = ast_get(slotExpr_2, 1L);
            }
            else
            {
                v122 = parse_error(cast(long)__s6912.ptr);
            }
            v123 = sym_add(gName_2, 3L, gSlot_2);
        }
    }
    return ast_new(1L, line);
L1643:
    v125 = lex_next();
    if (lex_token == 104L)
    {
        v127 = parse_expect(104L, cast(long)__s6927.ptr);
        mfName = 0L;
        mfVal = 0L;
        initE = 0L;
        initK = 0L;
        initS = 0L;
L1797:
        if (lex_token == 105L) goto L1799; else goto L1800;
L1800:
        if (lex_token == 0L) goto L1799; else goto L1798;
L1798:
        if (lex_token == 107L) goto L1801; else goto L1803;
L1803:
        if (lex_token == 106L) goto L1801; else goto L1802;
L1801:
        v128 = lex_next();
    goto L1797;
L1802:
        if (lex_token != 4L)
        {
            v129 = lex_next();
    goto L1797;
        }
        mfName = ast_intern_buf();
        v131 = lex_next();
        if (lex_token == 120L) goto L1807; else goto L1806;
L1806:
L1808:
        if (lex_token == 107L) goto L1810; else goto L1814;
L1814:
        if (lex_token == 106L) goto L1810; else goto L1813;
L1813:
        if (lex_token == 105L) goto L1810; else goto L1812;
L1812:
        if (lex_token == 0L) goto L1810; else goto L1811;
L1811:
        if (lex_token == 4L) goto L1810; else goto L1809;
L1809:
        v132 = lex_next();
    goto L1808;
L1810:
    goto L1797;
L1807:
        v133 = lex_next();
        initE = parse_expr();
        cg_temp_reg = 0L;
        mfVal = parse_const_eval(initE);
        v136 = sym_add(mfName, 2L, mfVal);
    goto L1797;
L1799:
        v138 = parse_expect(105L, cast(long)__s6994.ptr);
    }
    else
    {
        if (lex_token != 4L)
        {
            v140 = parse_error(cast(long)__s7000.ptr);
        }
        else
        {
            mfName_2 = ast_intern_buf();
            initE_2 = 0L;
            v142 = lex_next();
            v144 = parse_expect(120L, cast(long)__s7011.ptr);
            initE_2 = parse_expr();
            cg_temp_reg = 0L;
            mfVal_2 = parse_const_eval(initE_2);
            if (cg_temp_reg != 0)
            {
                v148 = parse_error(cast(long)__s7021.ptr);
            }
            v149 = sym_add(mfName_2, 2L, mfVal_2);
        }
    }
    return ast_new(1L, line);
L1644:
    v151 = lex_next();
    n = ast_new(18L, line);
    v154 = ast_set(n, 1L, parse_expr());
    return n;
L1645:
    v155 = lex_next();
    return ast_new(19L, line);
L1646:
    v157 = lex_next();
    cName = ast_new(3L, line);
    callNode = ast_new(4L, line);
    v162 = ast_set(cName, 1L, ast_intern_cstr(cast(long)__s7057.ptr));
    v163 = ast_set(callNode, 1L, cName);
    v164 = ast_set(callNode, 7L, 0L);
    return callNode;
L1647:
    v165 = lex_next();
    return ast_new(20L, line);
L1648:
    v167 = lex_next();
    return ast_new(21L, line);
L1649:
    v169 = lex_next();
    return ast_new(42L, line);
L1650:
    v171 = lex_next();
    return ast_new(43L, line);
L1651:
    v173 = lex_next();
    return ast_new(90L, line);
L1652:
    v175 = lex_next();
    c = parse_expr();
    if (lex_token == 237L)
    {
        v177 = lex_next();
    }
    if (lex_token == 206L)
    {
        v178 = lex_next();
    }
    t = parse_command();
    n = ast_new(12L, line);
    v181 = ast_set(n, 1L, c);
    v182 = ast_set(n, 2L, t);
    return n;
L1653:
    v183 = lex_next();
    c = parse_expr();
    if (lex_token == 206L)
    {
        v185 = lex_next();
    }
    t = parse_command();
    n = ast_new(13L, line);
    v188 = ast_set(n, 1L, c);
    v189 = ast_set(n, 2L, t);
    return n;
L1654:
    v190 = lex_next();
    c = parse_expr();
    if (lex_token == 237L)
    {
        v192 = lex_next();
    }
    t = parse_command();
    v195 = parse_expect(207L, cast(long)__s7150.ptr);
    e = parse_command();
    n = ast_new(14L, line);
    v198 = ast_set(n, 1L, c);
    v199 = ast_set(n, 2L, t);
    v200 = ast_set(n, 3L, e);
    return n;
L1655:
    v201 = lex_next();
    c = parse_expr();
    if (lex_token == 206L)
    {
        v203 = lex_next();
    }
    body_ = parse_command();
    n = ast_new(15L, line);
    v206 = ast_set(n, 1L, c);
    v207 = ast_set(n, 2L, body_);
    return n;
L1656:
    v208 = lex_next();
    c = parse_expr();
    if (lex_token == 206L)
    {
        v210 = lex_next();
    }
    body_ = parse_command();
    n = ast_new(16L, line);
    v213 = ast_set(n, 1L, c);
    v214 = ast_set(n, 2L, body_);
    return n;
L1657:
    v215 = lex_next();
    if (lex_token != 4L)
    {
        v217 = parse_error(cast(long)__s7212.ptr);
        return 0L;
    }
    name = ast_intern_buf();
    startE = 0L;
    endE = 0L;
    stepE = 0L;
    bodyN = 0L;
    v219 = lex_next();
    v221 = parse_expect(120L, cast(long)__s7230.ptr);
    startE = parse_expr();
    v224 = parse_expect(238L, cast(long)__s7236.ptr);
    endE = parse_expr();
    if (lex_token == 203L)
    {
        v226 = lex_next();
        stepE = parse_expr();
    }
    if (lex_token == 206L)
    {
        v228 = lex_next();
    }
    bodyN = parse_command();
    n = ast_new(17L, line);
    v231 = ast_set(n, 1L, name);
    v232 = ast_set(n, 2L, startE);
    v233 = ast_set(n, 3L, endE);
    v234 = ast_set(n, 4L, stepE);
    v235 = ast_set(n, 5L, bodyN);
    return n;
L1636:
    lhs = parse_expr();
    if (lex_token == 106L)
    {
        v237 = cast(long)__v7277.ptr;
        lhsv = v237;
        nl = 1L;
        isop = 0L;
        aop = 0L;
        blk = 0L;
        *cast(long*)(lhsv + (0L << 3L)) = lhs;
L1840:
        if (lex_token == 106L)
        {
            v238 = lex_next();
            if (nl > 5L)
            {
                v240 = parse_error(cast(long)__s7299.ptr);
    goto L1842;
            }
            *cast(long*)(lhsv + (nl << 3L)) = parse_expr();
            nl = (nl + 1L);
    goto L1840;
        }
L1842:
        if (lex_token == 115L)
        {
            v242 = lex_next();
        }
        else
        {
            if (lex_token == 118L)
            {
                isop = 1L;
                aop = lex_opassign_op;
                v243 = lex_next();
            }
            else
            {
                v245 = parse_error(cast(long)__s7321.ptr);
                return lhs;
            }
        }
        blk = ast_new(11L, line);
        i = 0L;
        while (i <= (nl - 1L))
        {
            l = *cast(long*)(lhsv + (i << 3L));
            r = parse_expr();
            a = 0L;
            if (isop != 0)
            {
                bn = ast_new(5L, line);
                v249 = ast_set(bn, 1L, aop);
                v250 = ast_set(bn, 2L, l);
                v251 = ast_set(bn, 3L, r);
                r = bn;
            }
            a = ast_new(9L, line);
            v253 = ast_set(a, 1L, l);
            v254 = ast_set(a, 2L, r);
            v255 = ast_set(blk, (i + 1L), a);
            if (i < (nl - 1L))
            {
                v257 = parse_expect(106L, cast(long)__s7372.ptr);
            }
            i = (i + 1L);
        }
        v258 = ast_set(blk, 7L, nl);
        return blk;
    }
    if (lex_token == 115L)
    {
        v259 = lex_next();
        rhs = parse_expr();
        n = ast_new(9L, line);
        v262 = ast_set(n, 1L, lhs);
        v263 = ast_set(n, 2L, rhs);
        return n;
    }
    if (lex_token == 118L)
    {
        op = lex_opassign_op;
        bn_2 = 0L;
        v264 = lex_next();
        rhs = parse_expr();
        bn_2 = ast_new(5L, line);
        v267 = ast_set(bn_2, 1L, op);
        v268 = ast_set(bn_2, 2L, lhs);
        v269 = ast_set(bn_2, 3L, rhs);
        n = ast_new(9L, line);
        v271 = ast_set(n, 1L, lhs);
        v272 = ast_set(n, 2L, bn_2);
        return n;
    }
    return lhs;
L1635:
    return 0;
}
long parse_try_dir(long p1 = 0, long p2 = 0)
{
    long[81] __v7429;
    long v0 = 0;
    long full = 0;
    long dl = 0;
    long nl = 0;
    long fl = 0;
    long st = 0;
    long i = 0;
    long i_2 = 0;
    long v1 = 0;
    long dir = p1;
    long name = p2;
    v0 = cast(long)__v7429.ptr;
    full = v0;
    dl = cast(long)*cast(ubyte*)(dir + 0L);
    nl = cast(long)*cast(ubyte*)(name + 0L);
    fl = ((dl + 1L) + nl);
    st = 0L;
    if (fl > 79L)
    {
        return 0L;
    }
    i = 1L;
    while (i <= dl)
    {
        *cast(ubyte*)(full + i) = cast(ubyte)cast(long)*cast(ubyte*)(dir + i);
        i = (i + 1L);
    }
    *cast(ubyte*)(full + (dl + 1L)) = cast(ubyte)47L;
    i_2 = 1L;
    while (i_2 <= nl)
    {
        *cast(ubyte*)(full + ((dl + 1L) + i_2)) = cast(ubyte)cast(long)*cast(ubyte*)(name + i_2);
        i_2 = (i_2 + 1L);
    }
    *cast(ubyte*)(full + 0L) = cast(ubyte)fl;
    *cast(ubyte*)(full + (fl + 1L)) = cast(ubyte)0L;
    st = findinput(full);
    return st;
}
long parse_search_hdrs(long p1 = 0)
{
    long st = 0;
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
    st = 0L;
    // ★ THE BCPL SOURCES LIVE IN deprecated/ NOW; src/ is this D tree.  This
    // hardcoded list is the ONLY thing that resolves a GET -- BCPL64HDRS and
    // HofosHDRS are both unset in practice -- so it has to know the new home.
    // Written as D rather than as another __sNNNN byte array because this file
    // is hand-maintained from here on.
    foreach (d; _extraHdrDirs)
    {
        st = parse_try_dir(cast(long)d.ptr, name);
        if (st != 0) return st;
    }
    st = parse_try_dir(cast(long)__s7482.ptr, name);
    if (st != 0)
    {
        return st;
    }
    st = parse_try_dir(cast(long)__s7485.ptr, name);
    if (st != 0)
    {
        return st;
    }
    st = parse_try_dir(cast(long)__s7488.ptr, name);
    if (st != 0)
    {
        return st;
    }
    st = parse_try_dir(cast(long)__s7491.ptr, name);
    if (st != 0)
    {
        return st;
    }
    st = parse_try_dir(cast(long)__s7494.ptr, name);
    if (st != 0)
    {
        return st;
    }
    st = parse_try_dir(cast(long)__s7497.ptr, name);
    if (st != 0)
    {
        return st;
    }
    return 0L;
}
long parse_program()
{
    long v0 = 0;
    long root = 0;
    long cur = 0;
    long count = 0;
    long d = 0;
    long v1 = 0;
    long[65] __v7520;
    long v2 = 0;
    long incName = 0;
    long incStream = 0;
    long incIsPeach = 0;
    long savedInput = 0;
    long savedCh = 0;
    long savedLine = 0;
    long savedCol = 0;
    long savedEof = 0;
    long sn = 0;
    long v3 = 0;
    long i = 0;
    long hasDot = 0;
    long i_2 = 0;
    long[65] __v7571;
    long v4 = 0;
    long pn = 0;
    long i_3 = 0;
    long v5 = 0;
    long v6 = 0;
    long v7 = 0;
    long v8 = 0;
    long v9 = 0;
    long v10 = 0;
    long v11 = 0;
    long m0 = 0;
    long v12 = 0;
    long m1 = 0;
    long v13 = 0;
    long m2 = 0;
    long v14 = 0;
    long m3 = 0;
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
    long sub = 0;
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
    long sub_2 = 0;
    long v41 = 0;
    long v42 = 0;
    long v43 = 0;
    long v44 = 0;
    root = ast_new(11L, 1L);
    cur = 0L;
    count = 0L;
    d = 0L;
    v1 = sym_init();
    cur = root;
L1885:
    if (lex_token != 0L)
    {
        if (lex_token == 213L)
        {
            v2 = cast(long)__v7520.ptr;
            incName = v2;
            incStream = 0L;
            incIsPeach = 0L;
            savedInput = 0L;
            savedCh = 0L;
            savedLine = 0L;
            savedCol = 0L;
            savedEof = 0L;
            sn = 0L;
            v3 = lex_next();
            if (lex_token == 2L)
            {
                sn = cast(long)*cast(ubyte*)(lex_buf + 0L);
                i = 0L;
                while (i <= sn)
                {
                    *cast(ubyte*)(incName + i) = cast(ubyte)cast(long)*cast(ubyte*)(lex_buf + i);
                    i = (i + 1L);
                }
                hasDot = 0L;
                i_2 = 1L;
                while (i_2 <= sn)
                {
                    if (cast(long)*cast(ubyte*)(incName + i_2) == 46L)
                    {
                        hasDot = 1L;
                    }
                    i_2 = (i_2 + 1L);
                }
                if (hasDot != 0) goto L1904; else goto L1903;
L1903:
                if ((opt_flags & 8L) != 0L)
                {
                    v4 = cast(long)__v7571.ptr;
                    pn = v4;
                    i_3 = 0L;
                    while (i_3 <= sn)
                    {
                        *cast(ubyte*)(pn + i_3) = cast(ubyte)cast(long)*cast(ubyte*)(incName + i_3);
                        i_3 = (i_3 + 1L);
                    }
                    if ((sn + 4L) <= 64L)
                    {
                        *cast(ubyte*)(pn + (sn + 1L)) = cast(ubyte)46L;
                        *cast(ubyte*)(pn + (sn + 2L)) = cast(ubyte)112L;
                        *cast(ubyte*)(pn + (sn + 3L)) = cast(ubyte)99L;
                        *cast(ubyte*)(pn + (sn + 4L)) = cast(ubyte)104L;
                        *cast(ubyte*)(pn + 0L) = cast(ubyte)(sn + 4L);
                        *cast(ubyte*)(pn + (sn + 5L)) = cast(ubyte)0L;
                        incStream = findinput(pn);
                        if (incStream != 0) goto L1914; else goto L1913;
L1913:
                        incStream = parse_search_hdrs(pn);
L1914:
                        if (incStream != 0)
                        {
                            incIsPeach = 1L;
                        }
                    }
                }
                if (incStream != 0) goto L1918; else goto L1917;
L1917:
                if ((sn + 2L) <= 64L)
                {
                    *cast(ubyte*)(incName + (sn + 1L)) = cast(ubyte)46L;
                    *cast(ubyte*)(incName + (sn + 2L)) = cast(ubyte)104L;
                    *cast(ubyte*)(incName + 0L) = cast(ubyte)(sn + 2L);
                    *cast(ubyte*)(incName + (sn + 3L)) = cast(ubyte)0L;
                }
L1918:
L1904:
                if (incStream != 0) goto L1922; else goto L1921;
L1921:
                incStream = findinput(incName);
L1922:
                if (incStream != 0) goto L1924; else goto L1923;
L1923:
                incStream = parse_search_hdrs(incName);
L1924:
                if (incStream != 0)
                {
                    savedInput = input();
                    savedCh = lex_ch;
                    savedLine = lex_line;
                    savedCol = lex_col;
                    savedEof = lex_eof_seen;
                    v10 = selectinput(incStream);
                    lex_eof_seen = 0L;
                    lex_line = 1L;
                    lex_col = 0L;
                    if (incIsPeach != 0)
                    {
                        m0 = lex_rawbyte();
                        m1 = lex_rawbyte();
                        m2 = lex_rawbyte();
                        m3 = lex_rawbyte();
                        if (m0 == 80L)
                        {
                            if (m1 == 67L) goto L1935; else goto L1932;
L1935:
                            if (m2 == 72L) goto L1934; else goto L1932;
L1934:
                            if (m3 == 49L) goto L1931; else goto L1932;
L1931:
                            lex_replay = 1L;
                            v15 = lex_next();
    goto L1933;
                        }
L1932:
                        v17 = writef(cast(long)__s7672.ptr, incName);
                        lex_token = 0L;
L1933:
                    }
                    else
                    {
                        lex_ch = 32L;
                        v18 = lex_advance();
                        v19 = lex_next();
                    }
L1937:
                    if (lex_token != 0L)
                    {
                        if (lex_token == 109L)
                        {
                            v20 = lex_next();
    goto L1937;
                        }
                        if (lex_token == 107L)
                        {
                            v21 = lex_next();
    goto L1937;
                        }
                        if (lex_token == 213L)
                        {
                            v22 = lex_next();
                            if (lex_token == 2L)
                            {
                                v23 = lex_next();
                            }
    goto L1937;
                        }
                        d = parse_command();
                        if (count >= 5L)
                        {
                            sub = ast_new(11L, 1L);
                            v26 = ast_set(cur, 6L, sub);
                            v27 = ast_set(cur, 7L, 6L);
                            cur = sub;
                            count = 0L;
                        }
                        count = (count + 1L);
                        v28 = ast_set(cur, count, d);
    goto L1937;
                    }
                    v29 = endread();
                    lex_replay = 0L;
                    v30 = selectinput(savedInput);
                    lex_ch = savedCh;
                    lex_line = savedLine;
                    lex_col = savedCol;
                    lex_eof_seen = savedEof;
                    v31 = lex_next();
                }
                else
                {
                    v33 = writef(cast(long)__s7732.ptr, incName);
                    v34 = lex_next();
                }
            }
            else
            {
                v36 = writef(cast(long)__s7737.ptr, lex_lastline);
            }
    goto L1885;
        }
        if (lex_token == 109L)
        {
            v37 = lex_next();
    goto L1885;
        }
        if (lex_token == 107L)
        {
            v38 = lex_next();
    goto L1885;
        }
        d = parse_command();
        if (count >= 5L)
        {
            sub_2 = ast_new(11L, 1L);
            v41 = ast_set(cur, 6L, sub_2);
            v42 = ast_set(cur, 7L, 6L);
            cur = sub_2;
            count = 0L;
        }
        count = (count + 1L);
        v43 = ast_set(cur, count, d);
    goto L1885;
    }
    v44 = ast_set(cur, 7L, count);
    return root;
}
