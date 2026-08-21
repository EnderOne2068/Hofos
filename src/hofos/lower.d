// Generated from BCPL by cg-d.b, split into modules by split.d.
module hofos.lower;

import hofos.all;

long lower_binop_to_ir(long p1 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long op = p1;
    if (op == 130L) goto L2154; else goto L2180;
L2180:
    if (op == 131L) goto L2155; else goto L2181;
L2181:
    if (op == 132L) goto L2156; else goto L2182;
L2182:
    if (op == 133L) goto L2157; else goto L2183;
L2183:
    if (op == 225L) goto L2158; else goto L2184;
L2184:
    if (op == 135L) goto L2159; else goto L2185;
L2185:
    if (op == 136L) goto L2160; else goto L2186;
L2186:
    if (op == 140L) goto L2161; else goto L2187;
L2187:
    if (op == 141L) goto L2162; else goto L2188;
L2188:
    if (op == 120L) goto L2163; else goto L2189;
L2189:
    if (op == 121L) goto L2164; else goto L2190;
L2190:
    if (op == 122L) goto L2165; else goto L2191;
L2191:
    if (op == 123L) goto L2166; else goto L2192;
L2192:
    if (op == 124L) goto L2167; else goto L2193;
L2193:
    if (op == 125L) goto L2168; else goto L2194;
L2194:
    if (op == 139L) goto L2169; else goto L2195;
L2195:
    if (op == 252L) goto L2170; else goto L2196;
L2196:
    if (op == 253L) goto L2171; else goto L2197;
L2197:
    if (op == 254L) goto L2172; else goto L2198;
L2198:
    if (op == 255L) goto L2173; else goto L2199;
L2199:
    if (op == 256L) goto L2174; else goto L2200;
L2200:
    if (op == 257L) goto L2175; else goto L2201;
L2201:
    if (op == 258L) goto L2176; else goto L2202;
L2202:
    if (op == 259L) goto L2177; else goto L2203;
L2203:
    if (op == 260L) goto L2178; else goto L2204;
L2204:
    if (op == 261L) goto L2179; else goto L2205;
L2205:
    goto L2153;
L2154:
    return 4L;
L2155:
    return 5L;
L2156:
    return 6L;
L2157:
    return 7L;
L2158:
    return 8L;
L2159:
    return 9L;
L2160:
    return 10L;
L2161:
    return 13L;
L2162:
    return 14L;
L2163:
    return 20L;
L2164:
    return 21L;
L2165:
    return 22L;
L2166:
    return 23L;
L2167:
    return 24L;
L2168:
    return 25L;
L2169:
    return 11L;
L2170:
    return 51L;
L2171:
    return 52L;
L2172:
    return 53L;
L2173:
    return 54L;
L2174:
    return 59L;
L2175:
    return 60L;
L2176:
    return 55L;
L2177:
    return 56L;
L2178:
    return 57L;
L2179:
    return 58L;
L2153:
    v1 = writef(cast(long)__s8511.ptr, op);
    v2 = __finish();
L2152:
    return 0;
}
long ast_subtree_loopctl(long p1 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long cnt = 0;
    long v2 = 0;
    long lim = 0;
    long k = 0;
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
    long c = 0;
    long v16 = 0;
    long v17 = 0;
    long v18 = 0;
    long v19 = 0;
    long v20 = 0;
    long n = p1;
    if (n == 0L)
    {
        return 0L;
    }
    v0 = ast_kind(n);
    if (v0 == 20L) goto L2210; else goto L2229;
L2229:
    if (v0 == 21L) goto L2211; else goto L2230;
L2230:
    if (v0 == 17L) goto L2212; else goto L2231;
L2231:
    if (v0 == 15L) goto L2213; else goto L2232;
L2232:
    if (v0 == 16L) goto L2214; else goto L2233;
L2233:
    if (v0 == 11L) goto L2215; else goto L2234;
L2234:
    if (v0 == 12L) goto L2216; else goto L2235;
L2235:
    if (v0 == 13L) goto L2217; else goto L2236;
L2236:
    if (v0 == 14L) goto L2218; else goto L2237;
L2237:
    if (v0 == 26L) goto L2219; else goto L2238;
L2238:
    if (v0 == 9L) goto L2220; else goto L2239;
L2239:
    if (v0 == 4L) goto L2221; else goto L2240;
L2240:
    if (v0 == 10L) goto L2222; else goto L2241;
L2241:
    if (v0 == 18L) goto L2223; else goto L2242;
L2242:
    if (v0 == 19L) goto L2224; else goto L2243;
L2243:
    if (v0 == 90L) goto L2225; else goto L2244;
L2244:
    if (v0 == 1L) goto L2226; else goto L2245;
L2245:
    if (v0 == 2L) goto L2227; else goto L2246;
L2246:
    if (v0 == 3L) goto L2228; else goto L2247;
L2247:
    goto L2209;
L2210:
    return 1L;
L2211:
    return 1L;
L2212:
    return 0L;
L2213:
    return 0L;
L2214:
    return 0L;
L2215:
    cnt = ast_get(n, 7L);
    if (cnt > 5L)
    {
        v2 = 5L;
    }
    else
    {
        v2 = cnt;
    }
    lim = v2;
    k = 1L;
    while (k <= lim)
    {
        if (ast_subtree_loopctl(ast_get(n, k)) != 0)
        {
            return 1L;
        }
        k = (k + 1L);
    }
    if (cnt == 6L)
    {
        return ast_subtree_loopctl(ast_get(n, 6L));
    }
    return 0L;
L2216:
    return ast_subtree_loopctl(ast_get(n, 2L));
L2217:
    return ast_subtree_loopctl(ast_get(n, 2L));
L2218:
    v12 = ast_subtree_loopctl(ast_get(n, 2L));
    return (v12 | ast_subtree_loopctl(ast_get(n, 3L)));
L2219:
    c = ast_get(n, 2L);
    if (ast_subtree_loopctl(ast_get(n, 3L)) != 0)
    {
        return 1L;
    }
L2261:
    if (c == 0L) goto L2263; else goto L2262;
L2262:
    if (ast_subtree_loopctl(ast_get(c, 2L)) != 0)
    {
        return 1L;
    }
    c = ast_get(c, 3L);
    goto L2261;
L2263:
    return 0L;
L2220:
    return 0L;
L2221:
    return 0L;
L2222:
    return 0L;
L2223:
    return 0L;
L2224:
    return 0L;
L2225:
    return 0L;
L2226:
    return 0L;
L2227:
    return 0L;
L2228:
    return 0L;
L2209:
    return 1L;
L2208:
    return 0;
}
long ast_vec_invariant(long p1 = 0, long p2 = 0)
{
    long v0 = 0;
    long k = 0;
    long v1 = 0;
    long v2 = 0;
    long node = p1;
    long forVar = p2;
    k = ast_kind(node);
    if (k == 1L)
    {
        return 1L;
    }
    if (k == 3L)
    {
        return cast(long)(sym_streq(ast_get(node, 1L), forVar) == 0L);
    }
    return 0L;
}
long ast_indexed_by(long p1 = 0, long p2 = 0)
{
    long idx = 0;
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long v6 = 0;
    long node = p1;
    long forVar = p2;
    idx = 0L;
    if (ast_kind(node) != 7L)
    {
        return 0L;
    }
    idx = ast_get(node, 2L);
    if (ast_kind(idx) != 3L)
    {
        return 0L;
    }
    if (sym_streq(ast_get(idx, 1L), forVar) != 0) goto L2275; else goto L2274;
L2274:
    return 0L;
L2275:
    return ast_vec_invariant(ast_get(node, 1L), forVar);
}
long prof_is_start(long p1 = 0)
{
    long v0 = 0;
    long t = 0;
    long i = 0;
    long s = p1;
    t = cast(long)__s8694.ptr;
    if (s == 0L)
    {
        return 0L;
    }
    if (cast(long)*cast(ubyte*)(s + 0L) != cast(long)*cast(ubyte*)(t + 0L))
    {
        return 0L;
    }
    i = 1L;
    while (i <= cast(long)*cast(ubyte*)(t + 0L))
    {
        if (cast(long)*cast(ubyte*)(s + i) != cast(long)*cast(ubyte*)(t + i))
        {
            return 0L;
        }
        i = (i + 1L);
    }
    return 1L;
}
long prof_skip(long p1 = 0)
{
    long v0 = 0;
    long p = 0;
    long i = 0;
    long s = p1;
    p = cast(long)__s8723.ptr;
    if (s == 0L)
    {
        return 1L;
    }
    if (cast(long)*cast(ubyte*)(s + 0L) < cast(long)*cast(ubyte*)(p + 0L))
    {
        return 0L;
    }
    i = 1L;
    while (i <= cast(long)*cast(ubyte*)(p + 0L))
    {
        if (cast(long)*cast(ubyte*)(s + i) != cast(long)*cast(ubyte*)(p + i))
        {
            return 0L;
        }
        i = (i + 1L);
    }
    return 1L;
}
long lower_prof_call(long p1 = 0, long p2 = 0, long p3 = 0)
{
    long v0 = 0;
    long callee = 0;
    long v1 = 0;
    long rT = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long argT = 0;
    long v5 = 0;
    long v6 = 0;
    long v7 = 0;
    long v8 = 0;
    long v9 = 0;
    long cname = p1;
    long hasArg = p2;
    long argval = p3;
    callee = ir_new_temp();
    rT = ir_new_temp();
    v3 = ir_emit(1L, callee, ast_intern_cstr(cname), 1L, 0L);
    if (hasArg != 0)
    {
        argT = ir_new_temp();
        v5 = ir_emit(1L, argT, argval, 0L, 0L);
        v7 = ir_set_arg3(ir_emit_call(rT, callee, 1L, argT, 0L), 0L);
    }
    else
    {
        v9 = ir_set_arg3(ir_emit_call(rT, callee, 0L, 0L, 0L), 0L);
    }
    return 0;
}
long lower_expr(long p1 = 0)
{
    long t = 0;
    long op = 0;
    long lhs = 0;
    long rhs = 0;
    long v = 0;
    long irop = 0;
    long callee = 0;
    long argc = 0;
    long c = 0;
    long lthen = 0;
    long lelse = 0;
    long lend = 0;
    long tv = 0;
    long ev = 0;
    long name = 0;
    long sym = 0;
    long base = 0;
    long idx = 0;
    long addr = 0;
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
    long t2 = 0;
    long v24 = 0;
    long v25 = 0;
    long v26 = 0;
    long q = 0;
    long v27 = 0;
    long qi = 0;
    long v28 = 0;
    long qf = 0;
    long v29 = 0;
    long m = 0;
    long v30 = 0;
    long v31 = 0;
    long v32 = 0;
    long v33 = 0;
    long v34 = 0;
    long v35 = 0;
    long v36 = 0;
    long v37 = 0;
    long v38 = 0;
    long operandNode = 0;
    long v39 = 0;
    long v40 = 0;
    long nm = 0;
    long v41 = 0;
    long s = 0;
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
    long v2_ = 0;
    long v52 = 0;
    long one = 0;
    long v53 = 0;
    long t1 = 0;
    long v54 = 0;
    long tr = 0;
    long v55 = 0;
    long v56 = 0;
    long v57 = 0;
    long v58 = 0;
    long v59 = 0;
    long v60 = 0;
    long v61 = 0;
    long v62 = 0;
    long sizeNode = 0;
    long sz = 0;
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
    long three = 0;
    long v75 = 0;
    long sc = 0;
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
    long sig = 0;
    long v90 = 0;
    long fexp = 0;
    long v91 = 0;
    long res = 0;
    long v92 = 0;
    long ae = 0;
    long v93 = 0;
    long c_2 = 0;
    long v94 = 0;
    long v95 = 0;
    long v96 = 0;
    long step = 0;
    long scale = 0;
    long v97 = 0;
    long sc_2 = 0;
    long v98 = 0;
    long fsc = 0;
    long v99 = 0;
    long nr = 0;
    long k_2 = 0;
    long v100 = 0;
    long v101 = 0;
    long v102 = 0;
    long v103 = 0;
    long v104 = 0;
    long v105 = 0;
    long v106 = 0;
    long v107 = 0;
    long v108 = 0;
    long sel = 0;
    long shift = 0;
    long len = 0;
    long off = 0;
    long v109 = 0;
    long v110 = 0;
    long ptr = 0;
    long res_2 = 0;
    long v111 = 0;
    long oc = 0;
    long v112 = 0;
    long a = 0;
    long v113 = 0;
    long v114 = 0;
    long v115 = 0;
    long v116 = 0;
    long v117 = 0;
    long sc_3 = 0;
    long v118 = 0;
    long sh = 0;
    long v119 = 0;
    long v120 = 0;
    long v121 = 0;
    long mc = 0;
    long v122 = 0;
    long md = 0;
    long v123 = 0;
    long v124 = 0;
    long v125 = 0;
    long cnode = 0;
    long direct = 0;
    long v126 = 0;
    long v127 = 0;
    long v128 = 0;
    long s_2 = 0;
    long v129 = 0;
    long v130 = 0;
    long v131 = 0;
    long v132 = 0;
    long v133 = 0;
    long arg1 = 0;
    long arg2 = 0;
    long arg3 = 0;
    long arg4 = 0;
    long arg5 = 0;
    long ai = 0;
    long v134 = 0;
    long v135 = 0;
    long av = 0;
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
    long v155 = 0;
    long v156 = 0;
    long v157 = 0;
    long v158 = 0;
    long v159 = 0;
    long n = p1;
    t = 0L;
    op = 0L;
    lhs = 0L;
    rhs = 0L;
    v = 0L;
    irop = 0L;
    callee = 0L;
    argc = 0L;
    c = 0L;
    lthen = 0L;
    lelse = 0L;
    lend = 0L;
    tv = 0L;
    ev = 0L;
    name = 0L;
    sym = 0L;
    base = 0L;
    idx = 0L;
    addr = 0L;
    if (n == 0L)
    {
        return 0L;
    }
    v0 = ast_kind(n);
    if (v0 == 1L) goto L2303; else goto L2318;
L2318:
    if (v0 == 2L) goto L2304; else goto L2319;
L2319:
    if (v0 == 3L) goto L2305; else goto L2320;
L2320:
    if (v0 == 5L) goto L2306; else goto L2321;
L2321:
    if (v0 == 6L) goto L2307; else goto L2322;
L2322:
    if (v0 == 25L) goto L2308; else goto L2323;
L2323:
    if (v0 == 7L) goto L2309; else goto L2324;
L2324:
    if (v0 == 24L) goto L2310; else goto L2325;
L2325:
    if (v0 == 30L) goto L2311; else goto L2326;
L2326:
    if (v0 == 28L) goto L2312; else goto L2327;
L2327:
    if (v0 == 29L) goto L2313; else goto L2328;
L2328:
    if (v0 == 4L) goto L2314; else goto L2329;
L2329:
    if (v0 == 8L) goto L2315; else goto L2330;
L2330:
    if (v0 == 22L) goto L2316; else goto L2331;
L2331:
    if (v0 == 31L) goto L2317; else goto L2332;
L2332:
    goto L2302;
L2303:
    t = ir_new_temp();
    v3 = ir_emit(1L, t, ast_get(n, 1L), 0L, 0L);
    return t;
L2304:
    t = ir_new_temp();
    v6 = ir_emit(38L, t, ast_get(n, 1L), 0L, 0L);
    return t;
L2305:
    name = ast_get(n, 1L);
    sym = sym_lookup(name);
    if (sym >= 0L)
    {
        k = *cast(long*)(sym_kinds + (sym << 3L));
        if (k == 1L)
        {
            return *cast(long*)(sym_values + (sym << 3L));
        }
        else
        {
            if (k == 2L)
            {
                t = ir_new_temp();
                v10 = ir_emit(1L, t, *cast(long*)(sym_values + (sym << 3L)), 0L, 0L);
                return t;
            }
            else
            {
                if (k == 4L)
                {
                    t = ir_new_temp();
                    v12 = ir_emit(50L, t, 0L, name, 0L);
                    return t;
                }
                else
                {
                    t = ir_new_temp();
                    v14 = ir_emit(40L, t, *cast(long*)(sym_values + (sym << 3L)), name, 0L);
                    return t;
                }
            }
        }
    }
    else
    {
        t = ir_new_temp();
        v16 = ir_emit(1L, t, name, 1L, 0L);
        return t;
    }
    goto L2301;
L2306:
    op = ast_get(n, 1L);
    lhs = lower_expr(ast_get(n, 2L));
    rhs = lower_expr(ast_get(n, 3L));
    t = ir_new_temp();
    if (op == 138L)
    {
        t2 = ir_new_temp();
        v24 = ir_emit(11L, t, lhs, rhs, 0L);
        v25 = ir_emit(12L, t2, t, 0L, 0L);
        return t2;
    }
    if (op == 263L)
    {
        q = ir_new_temp();
        qi = ir_new_temp();
        qf = ir_new_temp();
        m = ir_new_temp();
        v30 = ir_emit(54L, q, lhs, rhs, 0L);
        v31 = ir_emit(62L, qi, q, 0L, 0L);
        v32 = ir_emit(61L, qf, qi, 0L, 0L);
        v33 = ir_emit(53L, m, rhs, qf, 0L);
        v34 = ir_emit(52L, t, lhs, m, 0L);
        return t;
    }
    v36 = ir_emit(lower_binop_to_ir(op), t, lhs, rhs, 0L);
    return t;
L2307:
    op = ast_get(n, 1L);
    if (op == 110L)
    {
        operandNode = ast_get(n, 2L);
        if (ast_kind(operandNode) == 3L)
        {
            nm = ast_get(operandNode, 1L);
            s = sym_lookup(nm);
            if (s >= 0L)
            {
                if (*cast(long*)(sym_kinds + (s << 3L)) == 1L) goto L2353; else goto L2354;
L2353:
                t = ir_new_temp();
                v43 = ir_emit(45L, t, *cast(long*)(sym_values + (s << 3L)), 0L, 0L);
                return t;
            }
L2354:
            if (s >= 0L)
            {
                if (*cast(long*)(sym_kinds + (s << 3L)) == 4L) goto L2356; else goto L2357;
L2356:
                t = ir_new_temp();
                v45 = ir_emit(50L, t, 0L, nm, 0L);
                return t;
            }
L2357:
        }
    }
    if (op == 111L)
    {
        v = lower_expr(ast_get(n, 2L));
        t = ir_new_temp();
        v49 = ir_emit(2L, t, v, 0L, 0L);
        return t;
    }
    if (op == 262L)
    {
        v2_ = lower_expr(ast_get(n, 2L));
        one = ir_new_temp();
        t1 = ir_new_temp();
        tr = ir_new_temp();
        v55 = ir_emit(1L, one, 1L, 0L, 0L);
        v56 = ir_emit(13L, t1, v2_, one, 0L);
        v57 = ir_emit(14L, tr, t1, one, 0L);
        return tr;
    }
    v = lower_expr(ast_get(n, 2L));
    t = ir_new_temp();
    irop = 12L;
    if (op == 131L)
    {
        irop = 26L;
    }
    if (op == 137L)
    {
        irop = 12L;
    }
    if (op == 250L)
    {
        irop = 61L;
    }
    if (op == 251L)
    {
        irop = 62L;
    }
    v61 = ir_emit(irop, t, v, 0L, 0L);
    return t;
L2308:
    sizeNode = ast_get(n, 1L);
    sz = 0L;
    if (ast_kind(sizeNode) == 1L)
    {
        sz = ast_get(sizeNode, 1L);
    }
    else
    {
        v66 = writes(cast(long)__s9156.ptr);
    }
    t = ir_new_temp();
    v68 = ir_emit(42L, t, sz, 0L, 0L);
    return t;
L2309:
    base = lower_expr(ast_get(n, 1L));
    idx = lower_expr(ast_get(n, 2L));
    addr = ir_new_temp();
    three = ir_new_temp();
    sc = ir_new_temp();
    v76 = ir_emit(1L, three, cg_word_shift, 0L, 0L);
    v77 = ir_emit(13L, sc, idx, three, 0L);
    v78 = ir_emit(4L, addr, base, sc, 0L);
    t = ir_new_temp();
    v80 = ir_emit(2L, t, addr, 0L, 0L);
    return t;
L2310:
    base = lower_expr(ast_get(n, 1L));
    idx = lower_expr(ast_get(n, 2L));
    addr = ir_new_temp();
    v86 = ir_emit(4L, addr, base, idx, 0L);
    t = ir_new_temp();
    v88 = ir_emit(43L, t, addr, 0L, 0L);
    return t;
L2311:
    sig = ast_get(n, 1L);
    fexp = ast_get(n, 2L);
    res = ir_new_temp();
    if (fexp < 0L)
    {
        v92 = (-fexp);
    }
    else
    {
        v92 = fexp;
    }
    ae = v92;
    c_2 = ir_new_temp();
    v94 = ir_emit(1L, c_2, sig, 0L, 0L);
    v95 = ir_emit(61L, res, c_2, 0L, 0L);
    while (ae > 0L)
    {
        if (ae > 18L)
        {
            v96 = 18L;
        }
        else
        {
            v96 = ae;
        }
        step = v96;
        scale = 1L;
        sc_2 = ir_new_temp();
        fsc = ir_new_temp();
        nr = ir_new_temp();
        k_2 = 1L;
        while (k_2 <= step)
        {
            scale = (scale * 10L);
            k_2 = (k_2 + 1L);
        }
        v100 = ir_emit(1L, sc_2, scale, 0L, 0L);
        v101 = ir_emit(61L, fsc, sc_2, 0L, 0L);
        if (fexp > 0L)
        {
            v102 = ir_emit(53L, nr, res, fsc, 0L);
        }
        else
        {
            v103 = ir_emit(54L, nr, res, fsc, 0L);
        }
        res = nr;
        ae = (ae - step);
    }
    return res;
L2312:
    t = ir_new_temp();
    v106 = ir_emit(1L, t, parse_const_eval(n), 0L, 0L);
    return t;
L2313:
    sel = parse_const_eval(ast_get(n, 1L));
    shift = (sel & 255L);
    len = ((sel >> 8L) & 255L);
    off = (sel >> 16L);
    ptr = lower_expr(ast_get(n, 2L));
    res_2 = 0L;
    addr = ptr;
    if (off != 0L)
    {
        oc = ir_new_temp();
        a = ir_new_temp();
        v113 = ir_emit(1L, oc, (off << cg_word_shift), 0L, 0L);
        v114 = ir_emit(4L, a, ptr, oc, 0L);
        addr = a;
    }
    t = ir_new_temp();
    v116 = ir_emit(2L, t, addr, 0L, 0L);
    res_2 = t;
    if (shift > 0L)
    {
        sc_3 = ir_new_temp();
        sh = ir_new_temp();
        v119 = ir_emit(1L, sc_3, shift, 0L, 0L);
        v120 = ir_emit(14L, sh, res_2, sc_3, 0L);
        res_2 = sh;
    }
    if (len > 0L)
    {
        mc = ir_new_temp();
        md = ir_new_temp();
        v123 = ir_emit(1L, mc, ((1L << len) - 1L), 0L, 0L);
        v124 = ir_emit(9L, md, res_2, mc, 0L);
        res_2 = md;
    }
    return res_2;
L2314:
    cnode = ast_get(n, 1L);
    direct = 0L;
    if (ast_kind(cnode) == 3L)
    {
        s_2 = sym_lookup(ast_get(cnode, 1L));
        if (s_2 < 0L)
        {
            direct = 1L;
        }
        else
        {
            if (*cast(long*)(sym_kinds + (s_2 << 3L)) == 4L)
            {
                direct = 1L;
            }
        }
    }
    if (direct != 0)
    {
        callee = ir_new_temp();
        v131 = ir_emit(1L, callee, ast_get(cnode, 1L), 1L, 0L);
    }
    else
    {
        callee = lower_expr(cnode);
    }
    argc = ast_get(n, 7L);
    arg1 = 0L;
    arg2 = 0L;
    arg3 = 0L;
    arg4 = 0L;
    arg5 = 0L;
    ai = 1L;
    while (ai <= argc)
    {
        if (ai <= 5L)
        {
            av = lower_expr(ast_get(n, (1L + ai)));
            if (ai == 1L)
            {
                arg1 = av;
            }
            if (ai == 2L)
            {
                arg2 = av;
            }
            if (ai == 3L)
            {
                arg3 = av;
            }
            if (ai == 4L)
            {
                arg4 = av;
            }
            if (ai == 5L)
            {
                arg5 = av;
            }
        }
        ai = (ai + 1L);
    }
    v136 = ir_emit(47L, 0L, arg4, 4L, 0L);
    v137 = ir_emit(47L, 0L, arg5, 5L, 0L);
    t = ir_new_temp();
    v140 = ir_set_arg3(ir_emit_call(t, callee, argc, arg1, arg2), arg3);
    return t;
L2315:
    lthen = ir_new_label();
    lelse = ir_new_label();
    lend = ir_new_label();
    t = ir_new_temp();
    v146 = lower_cond(ast_get(n, 1L), lthen, lelse);
    v147 = ir_emit_label(lthen);
    tv = lower_expr(ast_get(n, 2L));
    v150 = ir_emit(39L, t, tv, 0L, 0L);
    v151 = ir_emit_jmp(lend);
    v152 = ir_emit_label(lelse);
    ev = lower_expr(ast_get(n, 3L));
    v155 = ir_emit(39L, t, ev, 0L, 0L);
    v156 = ir_emit_label(lend);
    return t;
L2316:
    v158 = lower_command(ast_get(n, 1L));
    return 0L;
L2317:
    return lower_match(n);
L2302:
    return 0L;
L2301:
    return 0;
}
long lower_cond(long p1 = 0, long p2 = 0, long p3 = 0)
{
    long v0 = 0;
    long k = 0;
    long v1 = 0;
    long op = 0;
    long v2 = 0;
    long lnext = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long v6 = 0;
    long v7 = 0;
    long v8 = 0;
    long lnext_2 = 0;
    long v9 = 0;
    long v10 = 0;
    long v11 = 0;
    long v12 = 0;
    long v13 = 0;
    long v14 = 0;
    long v15 = 0;
    long v16 = 0;
    long c = 0;
    long v17 = 0;
    long n = p1;
    long ltrue = p2;
    long lfalse = p3;
    k = ast_get(n, 0L);
    op = ast_get(n, 1L);
    if (k == 5L)
    {
        if (op == 136L) goto L2422; else goto L2423;
L2422:
        lnext = ir_new_label();
        v4 = lower_cond(ast_get(n, 2L), ltrue, lnext);
        v5 = ir_emit_label(lnext);
        v7 = lower_cond(ast_get(n, 3L), ltrue, lfalse);
    goto L2424;
    }
L2423:
    if (k == 5L)
    {
        if (op == 135L) goto L2426; else goto L2427;
L2426:
        lnext_2 = ir_new_label();
        v10 = lower_cond(ast_get(n, 2L), lnext_2, lfalse);
        v11 = ir_emit_label(lnext_2);
        v13 = lower_cond(ast_get(n, 3L), ltrue, lfalse);
    goto L2428;
    }
L2427:
    if (k == 6L)
    {
        if (op == 137L) goto L2430; else goto L2434;
L2434:
        if (op == 222L) goto L2430; else goto L2431;
L2430:
        v15 = lower_cond(ast_get(n, 2L), lfalse, ltrue);
    goto L2432;
    }
L2431:
    c = lower_expr(n);
    v17 = ir_emit_br(c, ltrue, lfalse);
L2432:
L2428:
L2424:
    return 0;
}
long lower_ploc(long p1 = 0, long p2 = 0)
{
    long sh = 0;
    long o = 0;
    long addr = 0;
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long v6 = 0;
    long base = p1;
    long offset = p2;
    sh = 0L;
    o = 0L;
    addr = 0L;
    if (offset == 0L)
    {
        return base;
    }
    sh = ir_new_temp();
    o = ir_new_temp();
    addr = ir_new_temp();
    v3 = ir_emit(1L, sh, cg_word_shift, 0L, 0L);
    v4 = ir_emit(1L, o, offset, 0L, 0L);
    v5 = ir_emit(13L, o, o, sh, 0L);
    v6 = ir_emit(4L, addr, base, o, 0L);
    return addr;
}
long lower_pat_relop(long p1 = 0)
{
    long tk = p1;
    if (tk == 122L) goto L2439; else goto L2451;
L2451:
    if (tk == 123L) goto L2440; else goto L2452;
L2452:
    if (tk == 124L) goto L2441; else goto L2453;
L2453:
    if (tk == 125L) goto L2442; else goto L2454;
L2454:
    if (tk == 120L) goto L2443; else goto L2455;
L2455:
    if (tk == 121L) goto L2444; else goto L2456;
L2456:
    if (tk == 258L) goto L2445; else goto L2457;
L2457:
    if (tk == 259L) goto L2446; else goto L2458;
L2458:
    if (tk == 260L) goto L2447; else goto L2459;
L2459:
    if (tk == 261L) goto L2448; else goto L2460;
L2460:
    if (tk == 256L) goto L2449; else goto L2461;
L2461:
    if (tk == 257L) goto L2450; else goto L2462;
L2462:
    goto L2438;
L2439:
    return 22L;
L2440:
    return 23L;
L2441:
    return 24L;
L2442:
    return 25L;
L2443:
    return 20L;
L2444:
    return 21L;
L2445:
    return 55L;
L2446:
    return 56L;
L2447:
    return 57L;
L2448:
    return 58L;
L2449:
    return 59L;
L2450:
    return 60L;
L2438:
    return 20L;
L2437:
    return 0;
}
long lower_pattern(long p1 = 0, long p2 = 0, long p3 = 0, long p4 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long t = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long v6 = 0;
    long t_2 = 0;
    long v7 = 0;
    long v8 = 0;
    long cv = 0;
    long v9 = 0;
    long c = 0;
    long v10 = 0;
    long lc = 0;
    long v11 = 0;
    long v12 = 0;
    long v13 = 0;
    long v14 = 0;
    long v15 = 0;
    long v16 = 0;
    long t_3 = 0;
    long v17 = 0;
    long v18 = 0;
    long lo = 0;
    long v19 = 0;
    long v20 = 0;
    long hi = 0;
    long v21 = 0;
    long c1 = 0;
    long v22 = 0;
    long c2 = 0;
    long v23 = 0;
    long l1 = 0;
    long v24 = 0;
    long l2 = 0;
    long v25 = 0;
    long v26 = 0;
    long v27 = 0;
    long v28 = 0;
    long v29 = 0;
    long v30 = 0;
    long v31 = 0;
    long v32 = 0;
    long v33 = 0;
    long t_4 = 0;
    long v34 = 0;
    long v35 = 0;
    long rhs = 0;
    long v36 = 0;
    long c_2 = 0;
    long v37 = 0;
    long lc_2 = 0;
    long v38 = 0;
    long v39 = 0;
    long v40 = 0;
    long v41 = 0;
    long v42 = 0;
    long v43 = 0;
    long v44 = 0;
    long v45 = 0;
    long nb = 0;
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
    long lp2 = 0;
    long v59 = 0;
    long lok = 0;
    long v60 = 0;
    long v61 = 0;
    long v62 = 0;
    long v63 = 0;
    long v64 = 0;
    long v65 = 0;
    long v66 = 0;
    long v67 = 0;
    long v68 = 0;
    long pat = p1;
    long base = p2;
    long offset = p3;
    long lfail = p4;
    v0 = ast_kind(pat);
    if (v0 == 33L) goto L2465; else goto L2476;
L2476:
    if (v0 == 35L) goto L2466; else goto L2477;
L2477:
    if (v0 == 34L) goto L2467; else goto L2478;
L2478:
    if (v0 == 36L) goto L2468; else goto L2479;
L2479:
    if (v0 == 37L) goto L2469; else goto L2480;
L2480:
    if (v0 == 38L) goto L2470; else goto L2481;
L2481:
    if (v0 == 39L) goto L2471; else goto L2482;
L2482:
    if (v0 == 41L) goto L2472; else goto L2483;
L2483:
    if (v0 == 40L) goto L2473; else goto L2484;
L2484:
    if (v0 == 42L) goto L2474; else goto L2485;
L2485:
    if (v0 == 43L) goto L2475; else goto L2486;
L2486:
    goto L2464;
L2465:
    goto L2463;
L2466:
    t = ir_new_temp();
    v3 = ir_emit(2L, t, lower_ploc(base, offset), 0L, 0L);
    v5 = sym_add(ast_get(pat, 1L), 1L, t);
    goto L2463;
L2467:
    t_2 = ir_new_temp();
    cv = lower_expr(ast_get(pat, 1L));
    c = ir_new_temp();
    lc = ir_new_label();
    v12 = ir_emit(2L, t_2, lower_ploc(base, offset), 0L, 0L);
    v13 = ir_emit(20L, c, t_2, cv, 0L);
    v14 = ir_emit_br(c, lc, lfail);
    v15 = ir_emit_label(lc);
    goto L2463;
L2468:
    t_3 = ir_new_temp();
    lo = lower_expr(ast_get(pat, 1L));
    hi = lower_expr(ast_get(pat, 2L));
    c1 = ir_new_temp();
    c2 = ir_new_temp();
    l1 = ir_new_label();
    l2 = ir_new_label();
    v26 = ir_emit(2L, t_3, lower_ploc(base, offset), 0L, 0L);
    v27 = ir_emit(25L, c1, t_3, lo, 0L);
    v28 = ir_emit_br(c1, l1, lfail);
    v29 = ir_emit_label(l1);
    v30 = ir_emit(23L, c2, t_3, hi, 0L);
    v31 = ir_emit_br(c2, l2, lfail);
    v32 = ir_emit_label(l2);
    goto L2463;
L2469:
    t_4 = ir_new_temp();
    rhs = lower_expr(ast_get(pat, 2L));
    c_2 = ir_new_temp();
    lc_2 = ir_new_label();
    v39 = ir_emit(2L, t_4, lower_ploc(base, offset), 0L, 0L);
    v42 = ir_emit(lower_pat_relop(ast_get(pat, 1L)), c_2, t_4, rhs, 0L);
    v43 = ir_emit_br(c_2, lc_2, lfail);
    v44 = ir_emit_label(lc_2);
    goto L2463;
L2470:
    nb = ir_new_temp();
    v47 = ir_emit(2L, nb, lower_ploc(base, offset), 0L, 0L);
    v49 = lower_pattern(ast_get(pat, 1L), nb, 0L, lfail);
    goto L2463;
L2471:
    v51 = lower_pattern(ast_get(pat, 1L), base, offset, lfail);
    v53 = lower_pattern(ast_get(pat, 2L), base, offset, lfail);
    goto L2463;
L2472:
    v55 = lower_pattern(ast_get(pat, 1L), base, offset, lfail);
    v57 = lower_pattern(ast_get(pat, 2L), base, (offset + 1L), lfail);
    goto L2463;
L2473:
    lp2 = ir_new_label();
    lok = ir_new_label();
    v61 = lower_pattern(ast_get(pat, 1L), base, offset, lp2);
    v62 = ir_emit_jmp(lok);
    v63 = ir_emit_label(lp2);
    v65 = lower_pattern(ast_get(pat, 2L), base, offset, lfail);
    v66 = ir_emit_label(lok);
    goto L2463;
L2474:
    v67 = ir_emit_jmp(lfail);
    goto L2463;
L2475:
    v68 = ir_emit_jmp(cg_argv_patch_off);
    goto L2463;
L2464:
L2463:
    return 0;
}
long lower_match(long p1 = 0)
{
    long v0 = 0;
    long argBlk = 0;
    long v1 = 0;
    long items = 0;
    long v2 = 0;
    long flags = 0;
    long isEvery = 0;
    long isExpr = 0;
    long v3 = 0;
    long argc = 0;
    long v4 = 0;
    long lend = 0;
    long v5 = 0;
    long result = 0;
    long v6 = 0;
    long base = 0;
    long savedNext = 0;
    long savedExit = 0;
    long it = 0;
    long v7 = 0;
    long i = 0;
    long v8 = 0;
    long v9 = 0;
    long v10 = 0;
    long v11 = 0;
    long v12 = 0;
    long v13 = 0;
    long pat = 0;
    long v14 = 0;
    long body_ = 0;
    long v15 = 0;
    long lfail = 0;
    long savedSym = 0;
    long v16 = 0;
    long v17 = 0;
    long bv = 0;
    long v18 = 0;
    long s = 0;
    long v19 = 0;
    long v20 = 0;
    long v21 = 0;
    long v22 = 0;
    long v23 = 0;
    long v24 = 0;
    long v25 = 0;
    long v26 = 0;
    long v27 = 0;
    long node = p1;
    argBlk = ast_get(node, 1L);
    items = ast_get(node, 2L);
    flags = ast_get(node, 7L);
    isEvery = cast(long)((flags & 1L) != 0L);
    isExpr = cast(long)((flags & 2L) != 0L);
    argc = ast_get(argBlk, 7L);
    lend = ir_new_label();
    result = ir_new_temp();
    base = ir_new_temp();
    savedNext = parse_match_counter;
    savedExit = cg_argv_patch_off;
    it = items;
    v7 = ir_emit(42L, base, argc, 0L, 0L);
    i = 1L;
    while (i <= argc)
    {
        v8 = lower_ploc(base, (i - 1L));
        v11 = ir_emit(3L, 0L, v8, lower_expr(ast_get(argBlk, i)), 0L);
        i = (i + 1L);
    }
    v12 = ir_emit(1L, result, 0L, 0L, 0L);
    cg_argv_patch_off = lend;
L2491:
    if (it == 0L) goto L2493; else goto L2492;
L2492:
    pat = ast_get(it, 1L);
    body_ = ast_get(it, 2L);
    lfail = ir_new_label();
    savedSym = sym_count;
    parse_match_counter = lfail;
    v16 = lower_pattern(pat, base, 0L, lfail);
    if (isExpr != 0)
    {
        bv = lower_expr(body_);
        if (isEvery != 0)
        {
            s = ir_new_temp();
            v19 = ir_emit(4L, s, result, bv, 0L);
            v20 = ir_emit(39L, result, s, 0L, 0L);
        }
        else
        {
            v21 = ir_emit(39L, result, bv, 0L, 0L);
            v22 = ir_emit_jmp(lend);
        }
    }
    else
    {
        v23 = lower_command(body_);
        if (isEvery != 0) goto L2501; else goto L2500;
L2500:
        v24 = ir_emit_jmp(lend);
L2501:
    }
    v25 = ir_emit_label(lfail);
    sym_count = savedSym;
    it = ast_get(it, 3L);
    goto L2491;
L2493:
    v27 = ir_emit_label(lend);
    parse_match_counter = savedNext;
    cg_argv_patch_off = savedExit;
    return result;
}
long lower_command(long p1 = 0)
{
    long cnt = 0;
    long fdef = 0;
    long name = 0;
    long argc = 0;
    long t = 0;
    long body_ = 0;
    long kind = 0;
    long init = 0;
    long v = 0;
    long rhs = 0;
    long c = 0;
    long lthen = 0;
    long lelse = 0;
    long lend = 0;
    long lbody = 0;
    long ltop = 0;
    long lhs = 0;
    long sym = 0;
    long lhsKind = 0;
    long v0 = 0;
    long v1 = 0;
    long i = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long v6 = 0;
    long v7 = 0;
    long v8 = 0;
    long v9 = 0;
    long v10 = 0;
    long i_2 = 0;
    long v11 = 0;
    long pt = 0;
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
    long vv = 0;
    long v24 = 0;
    long v25 = 0;
    long v26 = 0;
    long v27 = 0;
    long v28 = 0;
    long v29 = 0;
    long slot = 0;
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
    long base = 0;
    long v44 = 0;
    long v45 = 0;
    long idx = 0;
    long v46 = 0;
    long three = 0;
    long v47 = 0;
    long sc = 0;
    long v48 = 0;
    long addr = 0;
    long v49 = 0;
    long v50 = 0;
    long v51 = 0;
    long v52 = 0;
    long v53 = 0;
    long v54 = 0;
    long base_2 = 0;
    long v55 = 0;
    long v56 = 0;
    long idx_2 = 0;
    long v57 = 0;
    long addr_2 = 0;
    long v58 = 0;
    long v59 = 0;
    long v60 = 0;
    long v61 = 0;
    long sel = 0;
    long shift = 0;
    long len = 0;
    long off = 0;
    long v62 = 0;
    long v63 = 0;
    long ptr = 0;
    long v64 = 0;
    long maskip = 0;
    long addr_3 = 0;
    long v65 = 0;
    long word = 0;
    long v66 = 0;
    long cleared = 0;
    long vsh = 0;
    long v67 = 0;
    long masked = 0;
    long v68 = 0;
    long newv = 0;
    long v69 = 0;
    long oc = 0;
    long v70 = 0;
    long a = 0;
    long v71 = 0;
    long v72 = 0;
    long v73 = 0;
    long v74 = 0;
    long nm = 0;
    long v75 = 0;
    long v76 = 0;
    long v77 = 0;
    long sc_2 = 0;
    long v78 = 0;
    long s = 0;
    long v79 = 0;
    long v80 = 0;
    long v81 = 0;
    long mc = 0;
    long v82 = 0;
    long v83 = 0;
    long v84 = 0;
    long v85 = 0;
    long v86 = 0;
    long v87 = 0;
    long v88 = 0;
    long addr_4 = 0;
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
    long savedBreak = 0;
    long savedLoop = 0;
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
    long savedBreak_2 = 0;
    long savedLoop_2 = 0;
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
    long v142 = 0;
    long v143 = 0;
    long v144 = 0;
    long v145 = 0;
    long v146 = 0;
    long v147 = 0;
    long v148 = 0;
    long sN = 0;
    long v149 = 0;
    long eN = 0;
    long v150 = 0;
    long stN = 0;
    long v151 = 0;
    long v152 = 0;
    long v153 = 0;
    long v154 = 0;
    long v155 = 0;
    long v_2 = 0;
    long v156 = 0;
    long ev = 0;
    long v157 = 0;
    long v158 = 0;
    long v159 = 0;
    long nameN = 0;
    long v160 = 0;
    long loopVar = 0;
    long v161 = 0;
    long v162 = 0;
    long v163 = 0;
    long v164 = 0;
    long v165 = 0;
    long forVar = 0;
    long v166 = 0;
    long stN2 = 0;
    long v167 = 0;
    long stmt = 0;
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
    long lhs_2 = 0;
    long v178 = 0;
    long rhs_2 = 0;
    long v179 = 0;
    long vbase = 0;
    long v180 = 0;
    long vidx = 0;
    long v181 = 0;
    long isFill = 0;
    long isCopy = 0;
    long isMap = 0;
    long mapSub = 0;
    long mapBase = 0;
    long mapScalar = 0;
    long v182 = 0;
    long v183 = 0;
    long ridx = 0;
    long v184 = 0;
    long v185 = 0;
    long v186 = 0;
    long v187 = 0;
    long v188 = 0;
    long v189 = 0;
    long v190 = 0;
    long bop = 0;
    long v191 = 0;
    long bl = 0;
    long v192 = 0;
    long br = 0;
    long v193 = 0;
    long lIdx = 0;
    long v194 = 0;
    long rIdx = 0;
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
    long sT = 0;
    long v207 = 0;
    long v208 = 0;
    long eT = 0;
    long v209 = 0;
    long bT = 0;
    long v210 = 0;
    long dsh = 0;
    long v211 = 0;
    long dso = 0;
    long v212 = 0;
    long dad = 0;
    long v213 = 0;
    long cnT = 0;
    long v214 = 0;
    long onT = 0;
    long v215 = 0;
    long v216 = 0;
    long v217 = 0;
    long v218 = 0;
    long v219 = 0;
    long v220 = 0;
    long v221 = 0;
    long v222 = 0;
    long v223 = 0;
    long v224 = 0;
    long srcBaseNode = 0;
    long v225 = 0;
    long wbT = 0;
    long v226 = 0;
    long ssh = 0;
    long v227 = 0;
    long sso = 0;
    long v228 = 0;
    long sad = 0;
    long v229 = 0;
    long v230 = 0;
    long v231 = 0;
    long v232 = 0;
    long v233 = 0;
    long v234 = 0;
    long v235 = 0;
    long v236 = 0;
    long name_2 = 0;
    long v237 = 0;
    long startNode = 0;
    long v238 = 0;
    long endNode = 0;
    long v239 = 0;
    long stepNode = 0;
    long v240 = 0;
    long bodyNode = 0;
    long v241 = 0;
    long iter = 0;
    long v242 = 0;
    long endT = 0;
    long stepT = 0;
    long savedBreak_3 = 0;
    long savedLoop_3 = 0;
    long lstep = 0;
    long isNegStep = 0;
    long v243 = 0;
    long v244 = 0;
    long v245 = 0;
    long v246 = 0;
    long sk = 0;
    long v247 = 0;
    long v248 = 0;
    long inner = 0;
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
    long cmpT = 0;
    long v259 = 0;
    long v260 = 0;
    long v261 = 0;
    long v262 = 0;
    long v263 = 0;
    long v264 = 0;
    long v265 = 0;
    long nextT = 0;
    long v266 = 0;
    long v267 = 0;
    long v268 = 0;
    long v269 = 0;
    long v270 = 0;
    long v271 = 0;
    long v272 = 0;
    long v273 = 0;
    long v274 = 0;
    long v275 = 0;
    long v276 = 0;
    long v277 = 0;
    long savedSwBreak = 0;
    long v278 = 0;
    long v279 = 0;
    long swExpr = 0;
    long v280 = 0;
    long head = 0;
    long v281 = 0;
    long defBody = 0;
    long v282 = 0;
    long lend_2 = 0;
    long v283 = 0;
    long ldef = 0;
    long clause = 0;
    long caseVal = 0;
    long cBody = 0;
    long cNext = 0;
    long kT = 0;
    long cmpT_2 = 0;
    long lThen = 0;
    long lElse = 0;
    long it = 0;
    long v284 = 0;
    long lc = 0;
    long v285 = 0;
    long v286 = 0;
    long v287 = 0;
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
    long v302 = 0;
    long v303 = 0;
    long v304 = 0;
    long v305 = 0;
    long v306 = 0;
    long v307 = 0;
    long v308 = 0;
    long n = p1;
    cnt = 0L;
    fdef = 0L;
    name = 0L;
    argc = 0L;
    t = 0L;
    body_ = 0L;
    kind = 0L;
    init = 0L;
    v = 0L;
    rhs = 0L;
    c = 0L;
    lthen = 0L;
    lelse = 0L;
    lend = 0L;
    lbody = 0L;
    ltop = 0L;
    lhs = 0L;
    sym = 0L;
    lhsKind = 0L;
    if (n == 0L)
    {
        return 0;
    }
    v0 = ast_kind(n);
    if (v0 == 11L) goto L2506; else goto L2524;
L2524:
    if (v0 == 10L) goto L2507; else goto L2525;
L2525:
    if (v0 == 9L) goto L2508; else goto L2526;
L2526:
    if (v0 == 12L) goto L2509; else goto L2527;
L2527:
    if (v0 == 13L) goto L2510; else goto L2528;
L2528:
    if (v0 == 14L) goto L2511; else goto L2529;
L2529:
    if (v0 == 15L) goto L2512; else goto L2530;
L2530:
    if (v0 == 16L) goto L2513; else goto L2531;
L2531:
    if (v0 == 20L) goto L2514; else goto L2532;
L2532:
    if (v0 == 21L) goto L2515; else goto L2533;
L2533:
    if (v0 == 31L) goto L2516; else goto L2534;
L2534:
    if (v0 == 42L) goto L2517; else goto L2535;
L2535:
    if (v0 == 43L) goto L2518; else goto L2536;
L2536:
    if (v0 == 17L) goto L2519; else goto L2537;
L2537:
    if (v0 == 18L) goto L2520; else goto L2538;
L2538:
    if (v0 == 19L) goto L2521; else goto L2539;
L2539:
    if (v0 == 26L) goto L2522; else goto L2540;
L2540:
    if (v0 == 90L) goto L2523; else goto L2541;
L2541:
    goto L2505;
L2506:
    cnt = ast_get(n, 7L);
    i = 1L;
    while (i <= cnt)
    {
        if (i <= 6L)
        {
            v3 = lower_command(ast_get(n, i));
        }
        i = (i + 1L);
    }
    return 0;
L2507:
    fdef = ast_get(n, 2L);
    if (fdef != 0L)
    {
        if (ast_kind(fdef) == 23L) goto L2548; else goto L2549;
L2548:
        name = ast_get(n, 1L);
        argc = ast_get(fdef, 6L);
        t = ir_new_temp();
        v9 = ir_emit(36L, t, argc, name, 0L);
        v10 = sym_add(name, 4L, t);
        i_2 = 1L;
        while (i_2 <= argc)
        {
            if (i_2 <= 5L)
            {
                pt = ir_new_temp();
                v13 = ir_emit(35L, pt, i_2, ast_get(fdef, i_2), 0L);
                v15 = sym_add(ast_get(fdef, i_2), 1L, pt);
            }
            i_2 = (i_2 + 1L);
        }
        prof_cur_start = prof_is_start(name);
        if ((opt_flags & 4L) != 0L)
        {
            if (prof_skip(name) != 0) goto L2560; else goto L2559;
L2559:
            v19 = lower_prof_call(cast(long)__s10175.ptr, 1L, prof_funcid);
L2560:
            prof_funcid = (prof_funcid + 1L);
        }
        body_ = ast_get(fdef, 7L);
        if (body_ != 0L)
        {
            kind = ast_kind(body_);
            if (kind == 11L) goto L2563; else goto L2579;
L2579:
            if (kind == 12L) goto L2563; else goto L2578;
L2578:
            if (kind == 13L) goto L2563; else goto L2577;
L2577:
            if (kind == 14L) goto L2563; else goto L2576;
L2576:
            if (kind == 15L) goto L2563; else goto L2575;
L2575:
            if (kind == 16L) goto L2563; else goto L2574;
L2574:
            if (kind == 17L) goto L2563; else goto L2573;
L2573:
            if (kind == 26L) goto L2563; else goto L2572;
L2572:
            if (kind == 20L) goto L2563; else goto L2571;
L2571:
            if (kind == 21L) goto L2563; else goto L2570;
L2570:
            if (kind == 90L) goto L2563; else goto L2569;
L2569:
            if (kind == 18L) goto L2563; else goto L2568;
L2568:
            if (kind == 19L) goto L2563; else goto L2567;
L2567:
            if (kind == 9L) goto L2563; else goto L2566;
L2566:
            if (kind == 10L) goto L2563; else goto L2564;
L2563:
            v22 = lower_command(body_);
    goto L2565;
L2564:
            vv = lower_expr(body_);
            v24 = ir_emit(34L, 0L, vv, 0L, 0L);
L2565:
        }
        v25 = ir_emit(37L, 0L, 0L, 0L, 0L);
        return 0;
    }
L2549:
    name = ast_get(n, 1L);
    init = ast_get(n, 3L);
    v = lower_expr(init);
    slot = ir_new_temp();
    v30 = ir_emit(39L, slot, v, 0L, 0L);
    v31 = sym_add(name, 1L, slot);
    return 0;
L2508:
    lhs = ast_get(n, 1L);
    rhs = lower_expr(ast_get(n, 2L));
    lhsKind = ast_kind(lhs);
    if (lhsKind == 3L)
    {
        sym = sym_lookup(ast_get(lhs, 1L));
        if (sym >= 0L)
        {
            if (*cast(long*)(sym_kinds + (sym << 3L)) == 1L) goto L2583; else goto L2584;
L2583:
            v38 = ir_emit(39L, *cast(long*)(sym_values + (sym << 3L)), rhs, 0L, 0L);
    goto L2585;
        }
L2584:
        if (sym >= 0L)
        {
            if (*cast(long*)(sym_kinds + (sym << 3L)) == 3L) goto L2587; else goto L2588;
L2587:
            v39 = ir_emit(41L, 0L, *cast(long*)(sym_values + (sym << 3L)), rhs, 0L);
    goto L2589;
        }
L2588:
        v41 = writef(cast(long)__s10312.ptr);
L2589:
L2585:
    }
    else
    {
        if (lhsKind == 7L)
        {
            base = lower_expr(ast_get(lhs, 1L));
            idx = lower_expr(ast_get(lhs, 2L));
            three = ir_new_temp();
            sc = ir_new_temp();
            addr = ir_new_temp();
            v49 = ir_emit(1L, three, cg_word_shift, 0L, 0L);
            v50 = ir_emit(13L, sc, idx, three, 0L);
            v51 = ir_emit(4L, addr, base, sc, 0L);
            v52 = ir_emit(3L, 0L, addr, rhs, 0L);
        }
        else
        {
            if (lhsKind == 24L)
            {
                base_2 = lower_expr(ast_get(lhs, 1L));
                idx_2 = lower_expr(ast_get(lhs, 2L));
                addr_2 = ir_new_temp();
                v58 = ir_emit(4L, addr_2, base_2, idx_2, 0L);
                v59 = ir_emit(44L, 0L, addr_2, rhs, 0L);
            }
            else
            {
                if (lhsKind == 29L)
                {
                    sel = parse_const_eval(ast_get(lhs, 1L));
                    shift = (sel & 255L);
                    len = ((sel >> 8L) & 255L);
                    off = (sel >> 16L);
                    ptr = lower_expr(ast_get(lhs, 2L));
                    if (len == 0L)
                    {
                        v64 = ((-1L) << shift);
                    }
                    else
                    {
                        v64 = (((1L << len) - 1L) << shift);
                    }
                    maskip = v64;
                    addr_3 = ptr;
                    word = ir_new_temp();
                    cleared = ir_new_temp();
                    vsh = rhs;
                    masked = ir_new_temp();
                    newv = ir_new_temp();
                    if (off != 0L)
                    {
                        oc = ir_new_temp();
                        a = ir_new_temp();
                        v71 = ir_emit(1L, oc, (off << cg_word_shift), 0L, 0L);
                        v72 = ir_emit(4L, a, ptr, oc, 0L);
                        addr_3 = a;
                    }
                    v73 = ir_emit(2L, word, addr_3, 0L, 0L);
                    nm = ir_new_temp();
                    v75 = ir_emit(1L, nm, (~maskip), 0L, 0L);
                    v76 = ir_emit(9L, cleared, word, nm, 0L);
                    if (shift > 0L)
                    {
                        sc_2 = ir_new_temp();
                        s = ir_new_temp();
                        v79 = ir_emit(1L, sc_2, shift, 0L, 0L);
                        v80 = ir_emit(13L, s, rhs, sc_2, 0L);
                        vsh = s;
                    }
                    mc = ir_new_temp();
                    v82 = ir_emit(1L, mc, maskip, 0L, 0L);
                    v83 = ir_emit(9L, masked, vsh, mc, 0L);
                    v84 = ir_emit(10L, newv, cleared, masked, 0L);
                    v85 = ir_emit(3L, 0L, addr_3, newv, 0L);
                }
                else
                {
                    if (lhsKind == 6L)
                    {
                        if (ast_get(lhs, 1L) == 111L) goto L2607; else goto L2608;
L2607:
                        addr_4 = lower_expr(ast_get(lhs, 2L));
                        v89 = ir_emit(3L, 0L, addr_4, rhs, 0L);
    goto L2609;
                    }
L2608:
                    v91 = writes(cast(long)__s10527.ptr);
L2609:
                }
            }
        }
    }
    return 0;
L2509:
    lthen = ir_new_label();
    lend = ir_new_label();
    v95 = lower_cond(ast_get(n, 1L), lthen, lend);
    v96 = ir_emit_label(lthen);
    v98 = lower_command(ast_get(n, 2L));
    v99 = ir_emit_label(lend);
    return 0;
L2510:
    lthen = ir_new_label();
    lend = ir_new_label();
    v103 = lower_cond(ast_get(n, 1L), lend, lthen);
    v104 = ir_emit_label(lthen);
    v106 = lower_command(ast_get(n, 2L));
    v107 = ir_emit_label(lend);
    return 0;
L2511:
    lthen = ir_new_label();
    lelse = ir_new_label();
    lend = ir_new_label();
    v112 = lower_cond(ast_get(n, 1L), lthen, lelse);
    v113 = ir_emit_label(lthen);
    v115 = lower_command(ast_get(n, 2L));
    v116 = ir_emit_jmp(lend);
    v117 = ir_emit_label(lelse);
    v119 = lower_command(ast_get(n, 3L));
    v120 = ir_emit_label(lend);
    return 0;
L2512:
    savedBreak = cg_faddr_count;
    savedLoop = gloop_continue;
    ltop = ir_new_label();
    lbody = ir_new_label();
    lend = ir_new_label();
    gloop_continue = ltop;
    cg_faddr_count = lend;
    v124 = ir_emit_label(ltop);
    v126 = lower_cond(ast_get(n, 1L), lbody, lend);
    v127 = ir_emit_label(lbody);
    v129 = lower_command(ast_get(n, 2L));
    v130 = ir_emit_jmp(ltop);
    v131 = ir_emit_label(lend);
    cg_faddr_count = savedBreak;
    gloop_continue = savedLoop;
    return 0;
L2513:
    savedBreak_2 = cg_faddr_count;
    savedLoop_2 = gloop_continue;
    ltop = ir_new_label();
    lbody = ir_new_label();
    lend = ir_new_label();
    gloop_continue = ltop;
    cg_faddr_count = lend;
    v135 = ir_emit_label(ltop);
    v137 = lower_cond(ast_get(n, 1L), lend, lbody);
    v138 = ir_emit_label(lbody);
    v140 = lower_command(ast_get(n, 2L));
    v141 = ir_emit_jmp(ltop);
    v142 = ir_emit_label(lend);
    cg_faddr_count = savedBreak_2;
    gloop_continue = savedLoop_2;
    return 0;
L2514:
    if (cg_faddr_count > 0L)
    {
        v143 = ir_emit_jmp(cg_faddr_count);
    }
    return 0;
L2515:
    if (gloop_continue > 0L)
    {
        v144 = ir_emit_jmp(gloop_continue);
    }
    return 0;
L2516:
    v145 = lower_match(n);
    return 0;
L2517:
    if (parse_match_counter > 0L)
    {
        v146 = ir_emit_jmp(parse_match_counter);
    }
    return 0;
L2518:
    if (cg_argv_patch_off > 0L)
    {
        v147 = ir_emit_jmp(cg_argv_patch_off);
    }
    return 0;
L2519:
    sN = ast_get(n, 2L);
    eN = ast_get(n, 3L);
    stN = ast_get(n, 4L);
    if ((opt_flags & 1L) != 0L)
    {
        if (ast_kind(sN) == 1L) goto L2622; else goto L2620;
L2622:
        if (ast_kind(eN) == 1L) goto L2621; else goto L2620;
L2621:
        if (stN == 0L) goto L2619; else goto L2624;
L2624:
        if (ast_kind(stN) == 1L) goto L2625; else goto L2620;
L2625:
        if (ast_get(stN, 1L) == 1L) goto L2619; else goto L2620;
L2619:
        v_2 = ast_get(sN, 1L);
        ev = ast_get(eN, 1L);
        if ((ev - v_2) <= 7L)
        {
            if (ast_subtree_loopctl(ast_get(n, 5L)) == 0L) goto L2626; else goto L2627;
L2626:
            nameN = ast_get(n, 1L);
            while (v_2 <= ev)
            {
                loopVar = ir_new_temp();
                v161 = sym_add(nameN, 1L, loopVar);
                v162 = ir_emit(1L, loopVar, v_2, 0L, 0L);
                v164 = lower_command(ast_get(n, 5L));
                sym_count = (sym_count - 1L);
                v_2 = (v_2 + 1L);
            }
            return 0;
        }
L2627:
    }
L2620:
    forVar = ast_get(n, 1L);
    stN2 = ast_get(n, 4L);
    stmt = ast_get(n, 5L);
    if (ast_kind(stmt) == 11L)
    {
        if (ast_get(stmt, 7L) == 1L) goto L2633; else goto L2634;
L2633:
        stmt = ast_get(stmt, 1L);
    }
L2634:
    if ((opt_flags & 8192L) != 0L)
    {
        if (cg_backend_has_vfill() != 0) goto L2640; else goto L2637;
L2640:
        if (stN2 == 0L) goto L2639; else goto L2642;
L2642:
        if (ast_kind(stN2) == 1L) goto L2643; else goto L2637;
L2643:
        if (ast_get(stN2, 1L) == 1L) goto L2639; else goto L2637;
L2639:
        if (ast_kind(stmt) == 9L) goto L2638; else goto L2637;
L2638:
        if (ast_kind(ast_get(stmt, 1L)) == 7L) goto L2636; else goto L2637;
L2636:
        lhs_2 = ast_get(stmt, 1L);
        rhs_2 = ast_get(stmt, 2L);
        vbase = ast_get(lhs_2, 1L);
        vidx = ast_get(lhs_2, 2L);
        isFill = ast_vec_invariant(rhs_2, forVar);
        isCopy = 0L;
        isMap = 0L;
        mapSub = 0L;
        mapBase = 0L;
        mapScalar = 0L;
        if (ast_kind(rhs_2) == 7L)
        {
            ridx = ast_get(rhs_2, 2L);
            if (ast_kind(ridx) == 3L)
            {
                if (sym_streq(ast_get(ridx, 1L), forVar) != 0) goto L2648; else goto L2647;
L2648:
                if (ast_vec_invariant(ast_get(rhs_2, 1L), forVar) != 0) goto L2646; else goto L2647;
L2646:
                isCopy = 1L;
            }
L2647:
        }
        if (ast_kind(rhs_2) == 5L)
        {
            bop = ast_get(rhs_2, 1L);
            if (bop == 130L) goto L2652; else goto L2654;
L2654:
            if (bop == 131L) goto L2652; else goto L2653;
L2652:
            bl = ast_get(rhs_2, 2L);
            br = ast_get(rhs_2, 3L);
            lIdx = ast_indexed_by(bl, forVar);
            rIdx = ast_indexed_by(br, forVar);
            if (bop == 130L)
            {
                if (lIdx != 0)
                {
                    if (ast_vec_invariant(br, forVar) != 0) goto L2658; else goto L2659;
L2658:
                    isMap = 1L;
                    mapBase = ast_get(bl, 1L);
                    mapScalar = br;
    goto L2660;
                }
L2659:
                if (rIdx != 0)
                {
                    if (ast_vec_invariant(bl, forVar) != 0) goto L2662; else goto L2663;
L2662:
                    isMap = 1L;
                    mapBase = ast_get(br, 1L);
                    mapScalar = bl;
                }
L2663:
L2660:
            }
            else
            {
                if (lIdx != 0)
                {
                    if (ast_vec_invariant(br, forVar) != 0) goto L2665; else goto L2666;
L2665:
                    isMap = 1L;
                    mapSub = 1L;
                    mapBase = ast_get(bl, 1L);
                    mapScalar = br;
                }
L2666:
            }
L2653:
        }
        if (ast_kind(vidx) == 3L)
        {
            if (sym_streq(ast_get(vidx, 1L), forVar) != 0) goto L2671; else goto L2669;
L2671:
            if (ast_vec_invariant(vbase, forVar) != 0) goto L2670; else goto L2669;
L2670:
            if (isFill != 0) goto L2668; else goto L2674;
L2674:
            if (isCopy != 0) goto L2668; else goto L2673;
L2673:
            if (isMap != 0) goto L2668; else goto L2669;
L2668:
            sT = lower_expr(ast_get(n, 2L));
            eT = lower_expr(ast_get(n, 3L));
            bT = lower_expr(vbase);
            dsh = ir_new_temp();
            dso = ir_new_temp();
            dad = ir_new_temp();
            cnT = ir_new_temp();
            onT = ir_new_temp();
            v215 = ir_emit(1L, dsh, cg_word_shift, 0L, 0L);
            v216 = ir_emit(13L, dso, sT, dsh, 0L);
            v217 = ir_emit(4L, dad, bT, dso, 0L);
            v218 = ir_emit(5L, cnT, eT, sT, 0L);
            v219 = ir_emit(1L, onT, 1L, 0L, 0L);
            v220 = ir_emit(4L, cnT, cnT, onT, 0L);
            if (isFill != 0)
            {
                v222 = ir_emit(63L, 0L, dad, cnT, lower_expr(rhs_2));
            }
            else
            {
                if (isMap != 0)
                {
                    v223 = mapBase;
                }
                else
                {
                    v223 = ast_get(rhs_2, 1L);
                }
                srcBaseNode = v223;
                wbT = lower_expr(srcBaseNode);
                ssh = ir_new_temp();
                sso = ir_new_temp();
                sad = ir_new_temp();
                v229 = ir_emit(1L, ssh, cg_word_shift, 0L, 0L);
                v230 = ir_emit(13L, sso, sT, ssh, 0L);
                v231 = ir_emit(4L, sad, wbT, sso, 0L);
                if (isMap != 0)
                {
                    if (mapSub != 0)
                    {
                        v232 = 66L;
                    }
                    else
                    {
                        v232 = 65L;
                    }
                    v234 = ir_emit(v232, cnT, dad, sad, lower_expr(mapScalar));
                }
                else
                {
                    v235 = ir_emit(64L, 0L, dad, sad, cnT);
                }
            }
            return 0;
        }
L2669:
    }
L2637:
    name_2 = ast_get(n, 1L);
    startNode = ast_get(n, 2L);
    endNode = ast_get(n, 3L);
    stepNode = ast_get(n, 4L);
    bodyNode = ast_get(n, 5L);
    iter = lower_expr(startNode);
    endT = lower_expr(endNode);
    stepT = 0L;
    savedBreak_3 = cg_faddr_count;
    savedLoop_3 = gloop_continue;
    lstep = 0L;
    isNegStep = 0L;
    v243 = sym_add(name_2, 1L, iter);
    if (stepNode == 0L)
    {
        stepT = ir_new_temp();
        v245 = ir_emit(1L, stepT, 1L, 0L, 0L);
    }
    else
    {
        sk = ast_kind(stepNode);
        if (sk == 6L)
        {
            if (ast_get(stepNode, 1L) == 131L) goto L2690; else goto L2691;
L2690:
            inner = ast_get(stepNode, 2L);
            if (inner != 0L)
            {
                if (ast_kind(inner) == 1L) goto L2695; else goto L2694;
L2695:
                if (ast_get(inner, 1L) > 0L) goto L2693; else goto L2694;
L2693:
                isNegStep = 1L;
            }
L2694:
        }
L2691:
        if (sk == 1L)
        {
            if (ast_get(stepNode, 1L) < 0L) goto L2697; else goto L2698;
L2697:
            isNegStep = 1L;
        }
L2698:
        stepT = lower_expr(stepNode);
    }
    ltop = ir_new_label();
    lbody = ir_new_label();
    lstep = ir_new_label();
    lend = ir_new_label();
    gloop_continue = lstep;
    cg_faddr_count = lend;
    v257 = ir_emit_label(ltop);
    cmpT = ir_new_temp();
    if (isNegStep != 0)
    {
        v259 = ir_emit(25L, cmpT, iter, endT, 0L);
    }
    else
    {
        v260 = ir_emit(23L, cmpT, iter, endT, 0L);
    }
    v261 = ir_emit_br(cmpT, lbody, lend);
    v262 = ir_emit_label(lbody);
    v263 = lower_command(bodyNode);
    v264 = ir_emit_label(lstep);
    nextT = ir_new_temp();
    v266 = ir_emit(4L, nextT, iter, stepT, 0L);
    v267 = ir_emit(39L, iter, nextT, 0L, 0L);
    v268 = ir_emit_jmp(ltop);
    v269 = ir_emit_label(lend);
    sym_count = (sym_count - 1L);
    cg_faddr_count = savedBreak_3;
    gloop_continue = savedLoop_3;
    return 0;
L2520:
    v_2 = lower_expr(ast_get(n, 1L));
    if (prof_cur_start != 0)
    {
        if ((opt_flags & 4L) != 0L) goto L2703; else goto L2704;
L2703:
        v273 = lower_prof_call(cast(long)__s11170.ptr, 0L, 0L);
    }
L2704:
    v274 = ir_emit(34L, 0L, v_2, 0L, 0L);
    return 0;
L2521:
    if (prof_cur_start != 0)
    {
        if ((opt_flags & 4L) != 0L) goto L2706; else goto L2707;
L2706:
        v276 = lower_prof_call(cast(long)__s11187.ptr, 0L, 0L);
    }
L2707:
    v277 = ir_emit(34L, 0L, 0L, 0L, 0L);
    return 0;
L2522:
    savedSwBreak = gswitch_break;
    swExpr = lower_expr(ast_get(n, 1L));
    head = ast_get(n, 2L);
    defBody = ast_get(n, 3L);
    lend_2 = ir_new_label();
    ldef = ir_new_label();
    clause = head;
    caseVal = 0L;
    cBody = 0L;
    cNext = 0L;
    kT = 0L;
    cmpT_2 = 0L;
    lThen = 0L;
    lElse = 0L;
    gswitch_break = lend_2;
    it = head;
L2709:
    if (it == 0L) goto L2711; else goto L2710;
L2710:
    lc = ir_new_label();
    v285 = ast_set(it, 4L, lc);
    it = ast_get(it, 3L);
    goto L2709;
L2711:
    clause = head;
L2712:
    if (clause == 0L) goto L2714; else goto L2713;
L2713:
    caseVal = ast_get(clause, 1L);
    cNext = ast_get(clause, 3L);
    kT = ir_new_temp();
    cmpT_2 = ir_new_temp();
    v291 = ir_emit(1L, kT, caseVal, 0L, 0L);
    v292 = ir_emit(20L, cmpT_2, swExpr, kT, 0L);
    lThen = ast_get(clause, 4L);
    lElse = ir_new_label();
    v295 = ir_emit_br(cmpT_2, lThen, lElse);
    v296 = ir_emit_label(lElse);
    clause = cNext;
    goto L2712;
L2714:
    v297 = ir_emit_jmp(ldef);
    clause = head;
L2715:
    if (clause == 0L) goto L2717; else goto L2716;
L2716:
    v299 = ir_emit_label(ast_get(clause, 4L));
    v301 = lower_command(ast_get(clause, 2L));
    v302 = ir_emit_jmp(lend_2);
    clause = ast_get(clause, 3L);
    goto L2715;
L2717:
    v304 = ir_emit_label(ldef);
    if (defBody != 0L)
    {
        v305 = lower_command(defBody);
    }
    v306 = ir_emit_label(lend_2);
    gswitch_break = savedSwBreak;
    return 0;
L2523:
    if (gswitch_break > 0L)
    {
        v307 = ir_emit_jmp(gswitch_break);
    }
    return 0;
L2505:
    v308 = lower_expr(n);
L2504:
    return 0;
}
long lower_program()
{
    long v0 = 0;
    long v1 = 0;
    if (sym_names == 0L)
    {
        v0 = sym_init();
    }
    prof_funcid = 0L;
    prof_cur_start = 0L;
    if (cg_word_shift == 1L) goto L2725; else goto L2726;
L2726:
    if (cg_word_shift == 2L) goto L2725; else goto L2724;
L2724:
    cg_word_shift = 3L;
L2725:
    cg_faddr_count = 0L;
    gloop_continue = 0L;
    gswitch_break = 0L;
    v1 = lower_command(ast_root);
    return 0;
}
