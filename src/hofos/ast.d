// Generated from BCPL by cg-d.b, split into modules by split.d.
module hofos.ast;

import hofos.all;

long ast_init()
{
    long v0 = 0;
    ast_arena = getvec(((8L * 65536L) + 4L));
    ast_next = 1L;
    ast_root = 0L;
    return 0;
}
long ast_new(long p1 = 0, long p2 = 0)
{
    long n = 0;
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long kind = p1;
    long line = p2;
    n = ast_next;
    ast_next = (ast_next + 8L);
    if (ast_next >= (8L * 65536L))
    {
        v1 = writef(cast(long)__s3691.ptr, (n / 8L));
        v2 = __finish();
    }
    *cast(long*)(ast_arena + (n << 3L)) = kind;
    *cast(long*)(ast_arena + ((n + 1L) << 3L)) = 0L;
    *cast(long*)(ast_arena + ((n + 2L) << 3L)) = 0L;
    *cast(long*)(ast_arena + ((n + 3L) << 3L)) = 0L;
    *cast(long*)(ast_arena + ((n + 4L) << 3L)) = 0L;
    *cast(long*)(ast_arena + ((n + 5L) << 3L)) = 0L;
    *cast(long*)(ast_arena + ((n + 6L) << 3L)) = 0L;
    *cast(long*)(ast_arena + ((n + 7L) << 3L)) = line;
    return n;
}
long ast_kind(long p1 = 0)
{
    long n = p1;
    return *cast(long*)(ast_arena + (n << 3L));
}
long ast_get(long p1 = 0, long p2 = 0)
{
    long n = p1;
    long i = p2;
    return *cast(long*)(ast_arena + ((n + i) << 3L));
}
long ast_set(long p1 = 0, long p2 = 0, long p3 = 0)
{
    long n = p1;
    long i = p2;
    long v = p3;
    *cast(long*)(ast_arena + ((n + i) << 3L)) = v;
    return 0;
}
long ast_intern_buf()
{
    long v0 = 0;
    long p = 0;
    long i = 0;
    p = getvec(((lex_buflen / 8L) + 2L));
    *cast(ubyte*)(p + 0L) = cast(ubyte)lex_buflen;
    i = 1L;
    while (i <= lex_buflen)
    {
        *cast(ubyte*)(p + i) = cast(ubyte)cast(long)*cast(ubyte*)(lex_buf + i);
        i = (i + 1L);
    }
    *cast(ubyte*)(p + (lex_buflen + 1L)) = cast(ubyte)0L;
    return p;
}
long ast_print_indent(long p1 = 0)
{
    long i = 0;
    long v0 = 0;
    long v1 = 0;
    long d = p1;
    i = 1L;
    while (i <= d)
    {
        v1 = writes(cast(long)__s3815.ptr);
        i = (i + 1L);
    }
    return 0;
}
long ast_kind_name(long p1 = 0)
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
    long k = p1;
    if (k == 1L) goto L1121; else goto L1144;
L1144:
    if (k == 2L) goto L1122; else goto L1145;
L1145:
    if (k == 3L) goto L1123; else goto L1146;
L1146:
    if (k == 4L) goto L1124; else goto L1147;
L1147:
    if (k == 5L) goto L1125; else goto L1148;
L1148:
    if (k == 6L) goto L1126; else goto L1149;
L1149:
    if (k == 7L) goto L1127; else goto L1150;
L1150:
    if (k == 8L) goto L1128; else goto L1151;
L1151:
    if (k == 9L) goto L1129; else goto L1152;
L1152:
    if (k == 10L) goto L1130; else goto L1153;
L1153:
    if (k == 11L) goto L1131; else goto L1154;
L1154:
    if (k == 12L) goto L1132; else goto L1155;
L1155:
    if (k == 13L) goto L1133; else goto L1156;
L1156:
    if (k == 14L) goto L1134; else goto L1157;
L1157:
    if (k == 15L) goto L1135; else goto L1158;
L1158:
    if (k == 16L) goto L1136; else goto L1159;
L1159:
    if (k == 17L) goto L1137; else goto L1160;
L1160:
    if (k == 18L) goto L1138; else goto L1161;
L1161:
    if (k == 19L) goto L1139; else goto L1162;
L1162:
    if (k == 20L) goto L1140; else goto L1163;
L1163:
    if (k == 21L) goto L1141; else goto L1164;
L1164:
    if (k == 22L) goto L1142; else goto L1165;
L1165:
    if (k == 23L) goto L1143; else goto L1166;
L1166:
    goto L1120;
L1121:
    return cast(long)__s3866.ptr;
L1122:
    return cast(long)__s3867.ptr;
L1123:
    return cast(long)__s3868.ptr;
L1124:
    return cast(long)__s3869.ptr;
L1125:
    return cast(long)__s3870.ptr;
L1126:
    return cast(long)__s3871.ptr;
L1127:
    return cast(long)__s3872.ptr;
L1128:
    return cast(long)__s3873.ptr;
L1129:
    return cast(long)__s3874.ptr;
L1130:
    return cast(long)__s3875.ptr;
L1131:
    return cast(long)__s3876.ptr;
L1132:
    return cast(long)__s3877.ptr;
L1133:
    return cast(long)__s3878.ptr;
L1134:
    return cast(long)__s3879.ptr;
L1135:
    return cast(long)__s3880.ptr;
L1136:
    return cast(long)__s3881.ptr;
L1137:
    return cast(long)__s3882.ptr;
L1138:
    return cast(long)__s3883.ptr;
L1139:
    return cast(long)__s3884.ptr;
L1140:
    return cast(long)__s3885.ptr;
L1141:
    return cast(long)__s3886.ptr;
L1142:
    return cast(long)__s3887.ptr;
L1143:
    return cast(long)__s3888.ptr;
L1120:
    return cast(long)__s3889.ptr;
L1119:
    return 0;
}
long ast_child_slots(long p1 = 0, long p2 = 0)
{
    long i = 0;
    long i_2 = 0;
    long i_3 = 0;
    long kind = p1;
    long slots = p2;
    i = 0L;
    while (i <= 7L)
    {
        *cast(long*)(slots + (i << 3L)) = 0L;
        i = (i + 1L);
    }
    if (kind == 1L) goto L1173; else goto L1192;
L1192:
    if (kind == 2L) goto L1174; else goto L1193;
L1193:
    if (kind == 3L) goto L1175; else goto L1194;
L1194:
    if (kind == 4L) goto L1176; else goto L1195;
L1195:
    if (kind == 5L) goto L1177; else goto L1196;
L1196:
    if (kind == 6L) goto L1178; else goto L1197;
L1197:
    if (kind == 7L) goto L1179; else goto L1198;
L1198:
    if (kind == 9L) goto L1180; else goto L1199;
L1199:
    if (kind == 8L) goto L1181; else goto L1200;
L1200:
    if (kind == 14L) goto L1182; else goto L1201;
L1201:
    if (kind == 10L) goto L1183; else goto L1202;
L1202:
    if (kind == 11L) goto L1184; else goto L1203;
L1203:
    if (kind == 12L) goto L1185; else goto L1204;
L1204:
    if (kind == 13L) goto L1186; else goto L1205;
L1205:
    if (kind == 15L) goto L1187; else goto L1206;
L1206:
    if (kind == 16L) goto L1188; else goto L1207;
L1207:
    if (kind == 18L) goto L1189; else goto L1208;
L1208:
    if (kind == 22L) goto L1190; else goto L1209;
L1209:
    if (kind == 23L) goto L1191; else goto L1210;
L1210:
    goto L1172;
L1173:
    goto L1171;
L1174:
    goto L1171;
L1175:
    goto L1171;
L1176:
    *cast(long*)(slots + (1L << 3L)) = 1L;
    i_2 = 2L;
    while (i_2 <= 6L)
    {
        *cast(long*)(slots + (i_2 << 3L)) = 1L;
        i_2 = (i_2 + 1L);
    }
    goto L1171;
L1177:
    *cast(long*)(slots + (2L << 3L)) = 1L;
    *cast(long*)(slots + (3L << 3L)) = 1L;
    goto L1171;
L1178:
    *cast(long*)(slots + (2L << 3L)) = 1L;
    goto L1171;
L1179:
    *cast(long*)(slots + (1L << 3L)) = 1L;
    *cast(long*)(slots + (2L << 3L)) = 1L;
    goto L1171;
L1180:
    *cast(long*)(slots + (1L << 3L)) = 1L;
    *cast(long*)(slots + (2L << 3L)) = 1L;
    goto L1171;
L1181:
    *cast(long*)(slots + (1L << 3L)) = 1L;
    *cast(long*)(slots + (2L << 3L)) = 1L;
    *cast(long*)(slots + (3L << 3L)) = 1L;
    goto L1171;
L1182:
    *cast(long*)(slots + (1L << 3L)) = 1L;
    *cast(long*)(slots + (2L << 3L)) = 1L;
    *cast(long*)(slots + (3L << 3L)) = 1L;
    goto L1171;
L1183:
    *cast(long*)(slots + (2L << 3L)) = 1L;
    *cast(long*)(slots + (3L << 3L)) = 1L;
    goto L1171;
L1184:
    i_3 = 1L;
    while (i_3 <= 6L)
    {
        *cast(long*)(slots + (i_3 << 3L)) = 1L;
        i_3 = (i_3 + 1L);
    }
    goto L1171;
L1185:
    *cast(long*)(slots + (1L << 3L)) = 1L;
    *cast(long*)(slots + (2L << 3L)) = 1L;
    goto L1171;
L1186:
    *cast(long*)(slots + (1L << 3L)) = 1L;
    *cast(long*)(slots + (2L << 3L)) = 1L;
    goto L1171;
L1187:
    *cast(long*)(slots + (1L << 3L)) = 1L;
    *cast(long*)(slots + (2L << 3L)) = 1L;
    goto L1171;
L1188:
    *cast(long*)(slots + (1L << 3L)) = 1L;
    *cast(long*)(slots + (2L << 3L)) = 1L;
    goto L1171;
L1189:
    *cast(long*)(slots + (1L << 3L)) = 1L;
    goto L1171;
L1190:
    *cast(long*)(slots + (1L << 3L)) = 1L;
    goto L1171;
L1191:
    *cast(long*)(slots + (7L << 3L)) = 1L;
    goto L1171;
L1172:
L1171:
    return 0;
}
long sym_init()
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    sym_names = getvec((8192L + 4L));
    sym_kinds = getvec((8192L + 4L));
    sym_values = getvec((8192L + 4L));
    sym_count = 0L;
    mfst_count = 0L;
    glob_count = 0L;
    return 0;
}
long sym_streq(long p1 = 0, long p2 = 0)
{
    long n = 0;
    long i = 0;
    long a = p1;
    long b = p2;
    n = 0L;
    if (a == 0L) goto L1219; else goto L1221;
L1221:
    if (b == 0L) goto L1219; else goto L1220;
L1219:
    return 0L;
L1220:
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
long sym_lookup(long p1 = 0)
{
    long i = 0;
    long v0 = 0;
    long name = p1;
    i = (sym_count - 1L);
    while (i >= 0L)
    {
        if (sym_streq(*cast(long*)(sym_names + (i << 3L)), name) != 0)
        {
            return i;
        }
        i = (i + (-1L));
    }
    return (-1L);
}
long sym_add(long p1 = 0, long p2 = 0, long p3 = 0)
{
    long i = 0;
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long sl = 0;
    long name = p1;
    long kind = p2;
    long value = p3;
    i = sym_count;
    if (i >= 8192L)
    {
        v1 = writes(cast(long)__s4172.ptr);
        v2 = __finish();
    }
    *cast(long*)(sym_names + (i << 3L)) = name;
    *cast(long*)(sym_kinds + (i << 3L)) = kind;
    *cast(long*)(sym_values + (i << 3L)) = value;
    sym_count = (i + 1L);
    if (kind == 1L)
    {
        if (ir_tname != 0L)
        {
            if (value > 0L) goto L1242; else goto L1241;
L1242:
            if (value <= 65536L) goto L1240; else goto L1241;
L1240:
            *cast(long*)(ir_tname + (value << 3L)) = name;
        }
L1241:
    }
    if (kind == 2L)
    {
        mfst_count = (mfst_count + 1L);
    }
    if (kind == 3L)
    {
        if (value <= 0L)
        {
            *cast(long*)(sym_values + (i << 3L)) = glob_count;
            glob_count = (glob_count + 1L);
        }
        if (value > 0L)
        {
            if (value >= glob_count) goto L1250; else goto L1251;
L1250:
            glob_count = (value + 1L);
        }
L1251:
        if (ir_gname != 0L)
        {
            sl = *cast(long*)(sym_values + (i << 3L));
            if (sl >= 0L)
            {
                if (sl <= 4096L) goto L1255; else goto L1256;
L1255:
                *cast(long*)(ir_gname + (sl << 3L)) = name;
            }
L1256:
        }
    }
    return i;
}
long ast_dump(long p1 = 0, long p2 = 0)
{
    long kind = 0;
    long[9] __v4248;
    long v0 = 0;
    long slots = 0;
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
    long i = 0;
    long v29 = 0;
    long c = 0;
    long v30 = 0;
    long v31 = 0;
    long v32 = 0;
    long v33 = 0;
    long n = p1;
    long depth = p2;
    kind = 0L;
    v0 = cast(long)__v4248.ptr;
    slots = v0;
    if (n == 0L)
    {
        return 0;
    }
    kind = ast_kind(n);
    v2 = ast_print_indent(depth);
    v5 = writef(cast(long)__s4257.ptr, ast_kind_name(kind));
    if (kind == 1L) goto L1262; else goto L1268;
L1268:
    if (kind == 2L) goto L1263; else goto L1269;
L1269:
    if (kind == 3L) goto L1264; else goto L1270;
L1270:
    if (kind == 10L) goto L1265; else goto L1271;
L1271:
    if (kind == 5L) goto L1266; else goto L1272;
L1272:
    if (kind == 6L) goto L1267; else goto L1273;
L1273:
    goto L1261;
L1262:
    v8 = writef(cast(long)__s4274.ptr, ast_get(n, 1L));
    goto L1260;
L1263:
    v11 = writef(cast(long)__s4280.ptr, ast_get(n, 1L));
    goto L1260;
L1264:
    v14 = writef(cast(long)__s4286.ptr, ast_get(n, 1L));
    goto L1260;
L1265:
    v17 = writef(cast(long)__s4292.ptr, ast_get(n, 1L));
    goto L1260;
L1266:
    v21 = writef(cast(long)__s4298.ptr, lex_tok_name(ast_get(n, 1L)));
    goto L1260;
L1267:
    v25 = writef(cast(long)__s4306.ptr, lex_tok_name(ast_get(n, 1L)));
    goto L1260;
L1261:
L1260:
    v27 = writes(cast(long)__s4314.ptr);
    v28 = ast_child_slots(kind, slots);
    i = 1L;
    while (i <= 7L)
    {
        if (*cast(long*)(slots + (i << 3L)) != 0L)
        {
            c = ast_get(n, i);
            if (c != 0L)
            {
                if (c > 0L) goto L1282; else goto L1281;
L1282:
                if (c < ast_next) goto L1280; else goto L1281;
L1280:
                v30 = ast_dump(c, (depth + 1L));
            }
L1281:
        }
        i = (i + 1L);
    }
    v31 = ast_print_indent(depth);
    v33 = writes(cast(long)__s4345.ptr);
    return 0;
}
