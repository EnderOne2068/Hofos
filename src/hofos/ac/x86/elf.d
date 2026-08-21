// Generated from BCPL by cg-d.b, split into modules by split.d.
module hofos.ac.x86.elf;

import hofos.all;

long ac_shdr_a(long p1 = 0, long p2 = 0, long p3 = 0, long p4 = 0, long p5 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long nameoff = p1;
    long typ = p2;
    long flags = p3;
    long off = p4;
    long size = p5;
    v0 = ac_put32(nameoff);
    v1 = ac_put32(typ);
    v2 = ac_put64(flags);
    v3 = ac_put64(0L);
    v4 = ac_put64(off);
    v5 = ac_put64(size);
    return 0;
}
long ac_shdr_b(long p1 = 0, long p2 = 0, long p3 = 0, long p4 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long link = p1;
    long info = p2;
    long align_ = p3;
    long entsize = p4;
    v0 = ac_put32(link);
    v1 = ac_put32(info);
    v2 = ac_put64(align_);
    v3 = ac_put64(entsize);
    return 0;
}
long ac_symidx(long p1 = 0, long p2 = 0, long p3 = 0)
{
    long k = 0;
    long v0 = 0;
    long sname = p1;
    long nsym = p2;
    long nm = p3;
    k = 0L;
    while (k <= (nsym - 1L))
    {
        if (ac_streq(*cast(long*)(sname + (k << 3L)), nm) != 0)
        {
            return (k + 1L);
        }
        k = (k + 1L);
    }
    return 0L;
}
long ac_write_obj(long p1 = 0)
{
    long v0 = 0;
    long out_ = 0;
    long prev = 0;
    long v1 = 0;
    long sname = 0;
    long v2 = 0;
    long sval = 0;
    long v3 = 0;
    long sstr = 0;
    long v4 = 0;
    long sshndx = 0;
    long nsym = 0;
    long v5 = 0;
    long strbuf = 0;
    long strlen = 0;
    long nrel = 0;
    long text_off = 0;
    long rod_off = 0;
    long data_off = 0;
    long rela_off = 0;
    long sym_off = 0;
    long str_off = 0;
    long shstr_off = 0;
    long shstr_len = 0;
    long shoff = 0;
    long v6 = 0;
    long v7 = 0;
    long i = 0;
    long v8 = 0;
    long nm = 0;
    long v9 = 0;
    long j = 0;
    long i_2 = 0;
    long v10 = 0;
    long nm_2 = 0;
    long found = 0;
    long k = 0;
    long v11 = 0;
    long j_2 = 0;
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
    long i_3 = 0;
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
    long i_4 = 0;
    long v40 = 0;
    long i_5 = 0;
    long v41 = 0;
    long i_6 = 0;
    long v42 = 0;
    long i_7 = 0;
    long v43 = 0;
    long i_8 = 0;
    long v44 = 0;
    long i_9 = 0;
    long v45 = 0;
    long i_10 = 0;
    long v46 = 0;
    long v47 = 0;
    long v48 = 0;
    long v49 = 0;
    long i_11 = 0;
    long v50 = 0;
    long v51 = 0;
    long v52 = 0;
    long v53 = 0;
    long i_12 = 0;
    long v54 = 0;
    long k_2 = 0;
    long v55 = 0;
    long v56 = 0;
    long info = 0;
    long v57 = 0;
    long v58 = 0;
    long v59 = 0;
    long v60 = 0;
    long v61 = 0;
    long v62 = 0;
    long i_13 = 0;
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
    long i_14 = 0;
    long v127 = 0;
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
    long outname = p1;
    out_ = findoutput(outname);
    prev = 0L;
    sname = getvec(2048L);
    sval = getvec(2048L);
    sstr = getvec(2048L);
    sshndx = getvec(2048L);
    nsym = 0L;
    strbuf = getvec(8192L);
    strlen = 0L;
    nrel = (ac_rn + ac_arn);
    text_off = 64L;
    rod_off = 0L;
    data_off = 0L;
    rela_off = 0L;
    sym_off = 0L;
    str_off = 0L;
    shstr_off = 0L;
    shstr_len = 63L;
    shoff = 0L;
    if (out_ != 0) goto L5852; else goto L5851;
L5851:
    v7 = writef(cast(long)__s26985.ptr, outname);
    return 0;
L5852:
    *cast(ubyte*)(strbuf + 0L) = cast(ubyte)0L;
    strlen = 1L;
    i = 0L;
    while (i <= (ac_ln - 1L))
    {
        if (ac_is_local(*cast(long*)(ac_lname + (i << 3L))) != 0) goto L5858; else goto L5857;
L5857:
        nm = *cast(long*)(ac_lname + (i << 3L));
        *cast(long*)(sname + (nsym << 3L)) = nm;
        *cast(long*)(sval + (nsym << 3L)) = *cast(long*)(ac_loff + (i << 3L));
        *cast(long*)(sstr + (nsym << 3L)) = strlen;
        *cast(long*)(sshndx + (nsym << 3L)) = ac_shndx(*cast(long*)(ac_lsec + (i << 3L)));
        j = 1L;
        while (j <= cast(long)*cast(ubyte*)(nm + 0L))
        {
            *cast(ubyte*)(strbuf + strlen) = cast(ubyte)cast(long)*cast(ubyte*)(nm + j);
            strlen = (strlen + 1L);
            j = (j + 1L);
        }
        *cast(ubyte*)(strbuf + strlen) = cast(ubyte)0L;
        strlen = (strlen + 1L);
        nsym = (nsym + 1L);
L5858:
        i = (i + 1L);
    }
    i_2 = 0L;
    while (i_2 <= ((ac_rn + ac_arn) - 1L))
    {
        if (i_2 < ac_rn)
        {
            v10 = *cast(long*)(ac_rsym + (i_2 << 3L));
        }
        else
        {
            v10 = *cast(long*)(ac_arsym + ((i_2 - ac_rn) << 3L));
        }
        nm_2 = v10;
        found = 0L;
        k = 0L;
        while (k <= (nsym - 1L))
        {
            if (ac_streq(*cast(long*)(sname + (k << 3L)), nm_2) != 0)
            {
                found = 1L;
            }
            k = (k + 1L);
        }
        if (found != 0) goto L5877; else goto L5876;
L5876:
        *cast(long*)(sname + (nsym << 3L)) = nm_2;
        *cast(long*)(sval + (nsym << 3L)) = 0L;
        *cast(long*)(sstr + (nsym << 3L)) = strlen;
        *cast(long*)(sshndx + (nsym << 3L)) = 0L;
        j_2 = 1L;
        while (j_2 <= cast(long)*cast(ubyte*)(nm_2 + 0L))
        {
            *cast(ubyte*)(strbuf + strlen) = cast(ubyte)cast(long)*cast(ubyte*)(nm_2 + j_2);
            strlen = (strlen + 1L);
            j_2 = (j_2 + 1L);
        }
        *cast(ubyte*)(strbuf + strlen) = cast(ubyte)0L;
        strlen = (strlen + 1L);
        nsym = (nsym + 1L);
L5877:
        i_2 = (i_2 + 1L);
    }
    rod_off = ac_align8((text_off + ac_len));
    data_off = ac_align8((rod_off + ac_rodlen));
    rela_off = ac_align8((data_off + ac_datalen));
    sym_off = (rela_off + (nrel * 24L));
    str_off = (sym_off + ((nsym + 1L) * 24L));
    shstr_off = (str_off + strlen);
    shoff = ac_align8((shstr_off + shstr_len));
    prev = output();
    v17 = selectoutput(out_);
    v18 = ac_put(127L);
    v19 = ac_put(69L);
    v20 = ac_put(76L);
    v21 = ac_put(70L);
    v22 = ac_put(2L);
    v23 = ac_put(1L);
    v24 = ac_put(1L);
    v25 = ac_put(0L);
    i_3 = 1L;
    while (i_3 <= 8L)
    {
        v26 = ac_put(0L);
        i_3 = (i_3 + 1L);
    }
    v27 = ac_put16(1L);
    v28 = ac_put16(62L);
    v29 = ac_put32(1L);
    v30 = ac_put64(0L);
    v31 = ac_put64(0L);
    v32 = ac_put64(shoff);
    v33 = ac_put32(0L);
    v34 = ac_put16(64L);
    v35 = ac_put16(0L);
    v36 = ac_put16(0L);
    v37 = ac_put16(64L);
    v38 = ac_put16(9L);
    v39 = ac_put16(8L);
    i_4 = 0L;
    while (i_4 <= (ac_len - 1L))
    {
        v40 = ac_put(cast(long)*cast(ubyte*)(ac_code + i_4));
        i_4 = (i_4 + 1L);
    }
    i_5 = (text_off + ac_len);
    while (i_5 <= (rod_off - 1L))
    {
        v41 = ac_put(0L);
        i_5 = (i_5 + 1L);
    }
    i_6 = 0L;
    while (i_6 <= (ac_rodlen - 1L))
    {
        v42 = ac_put(cast(long)*cast(ubyte*)(ac_rodata + i_6));
        i_6 = (i_6 + 1L);
    }
    i_7 = (rod_off + ac_rodlen);
    while (i_7 <= (data_off - 1L))
    {
        v43 = ac_put(0L);
        i_7 = (i_7 + 1L);
    }
    i_8 = 0L;
    while (i_8 <= (ac_datalen - 1L))
    {
        v44 = ac_put(cast(long)*cast(ubyte*)(ac_data + i_8));
        i_8 = (i_8 + 1L);
    }
    i_9 = (data_off + ac_datalen);
    while (i_9 <= (rela_off - 1L))
    {
        v45 = ac_put(0L);
        i_9 = (i_9 + 1L);
    }
    i_10 = 0L;
    while (i_10 <= (ac_rn - 1L))
    {
        v46 = ac_put64(*cast(long*)(ac_rsite + (i_10 << 3L)));
        v48 = ac_put64(((ac_symidx(sname, nsym, *cast(long*)(ac_rsym + (i_10 << 3L))) << 32L) | 2L));
        v49 = ac_put64((-4L));
        i_10 = (i_10 + 1L);
    }
    i_11 = 0L;
    while (i_11 <= (ac_arn - 1L))
    {
        v50 = ac_put64(*cast(long*)(ac_arsite + (i_11 << 3L)));
        v52 = ac_put64(((ac_symidx(sname, nsym, *cast(long*)(ac_arsym + (i_11 << 3L))) << 32L) | 1L));
        v53 = ac_put64(0L);
        i_11 = (i_11 + 1L);
    }
    i_12 = 1L;
    while (i_12 <= 24L)
    {
        v54 = ac_put(0L);
        i_12 = (i_12 + 1L);
    }
    k_2 = 0L;
    while (k_2 <= (nsym - 1L))
    {
        if (*cast(long*)(sshndx + (k_2 << 3L)) == 0L)
        {
            v55 = 16L;
        }
        else
        {
            if (*cast(long*)(sshndx + (k_2 << 3L)) == 1L)
            {
                v56 = 18L;
            }
            else
            {
                v56 = 17L;
            }
            v55 = v56;
        }
        info = v55;
        v57 = ac_put32(*cast(long*)(sstr + (k_2 << 3L)));
        v58 = ac_put(info);
        v59 = ac_put(0L);
        v60 = ac_put16(*cast(long*)(sshndx + (k_2 << 3L)));
        v61 = ac_put64(*cast(long*)(sval + (k_2 << 3L)));
        v62 = ac_put64(0L);
        k_2 = (k_2 + 1L);
    }
    i_13 = 0L;
    while (i_13 <= (strlen - 1L))
    {
        v63 = ac_put(cast(long)*cast(ubyte*)(strbuf + i_13));
        i_13 = (i_13 + 1L);
    }
    v64 = ac_put(0L);
    v65 = ac_put(46L);
    v66 = ac_put(116L);
    v67 = ac_put(101L);
    v68 = ac_put(120L);
    v69 = ac_put(116L);
    v70 = ac_put(0L);
    v71 = ac_put(46L);
    v72 = ac_put(114L);
    v73 = ac_put(111L);
    v74 = ac_put(100L);
    v75 = ac_put(97L);
    v76 = ac_put(116L);
    v77 = ac_put(97L);
    v78 = ac_put(0L);
    v79 = ac_put(46L);
    v80 = ac_put(100L);
    v81 = ac_put(97L);
    v82 = ac_put(116L);
    v83 = ac_put(97L);
    v84 = ac_put(0L);
    v85 = ac_put(46L);
    v86 = ac_put(98L);
    v87 = ac_put(115L);
    v88 = ac_put(115L);
    v89 = ac_put(0L);
    v90 = ac_put(46L);
    v91 = ac_put(114L);
    v92 = ac_put(101L);
    v93 = ac_put(108L);
    v94 = ac_put(97L);
    v95 = ac_put(46L);
    v96 = ac_put(116L);
    v97 = ac_put(101L);
    v98 = ac_put(120L);
    v99 = ac_put(116L);
    v100 = ac_put(0L);
    v101 = ac_put(46L);
    v102 = ac_put(115L);
    v103 = ac_put(121L);
    v104 = ac_put(109L);
    v105 = ac_put(116L);
    v106 = ac_put(97L);
    v107 = ac_put(98L);
    v108 = ac_put(0L);
    v109 = ac_put(46L);
    v110 = ac_put(115L);
    v111 = ac_put(116L);
    v112 = ac_put(114L);
    v113 = ac_put(116L);
    v114 = ac_put(97L);
    v115 = ac_put(98L);
    v116 = ac_put(0L);
    v117 = ac_put(46L);
    v118 = ac_put(115L);
    v119 = ac_put(104L);
    v120 = ac_put(115L);
    v121 = ac_put(116L);
    v122 = ac_put(114L);
    v123 = ac_put(116L);
    v124 = ac_put(97L);
    v125 = ac_put(98L);
    v126 = ac_put(0L);
    i_14 = (shstr_off + shstr_len);
    while (i_14 <= (shoff - 1L))
    {
        v127 = ac_put(0L);
        i_14 = (i_14 + 1L);
    }
    v128 = ac_shdr_a(0L, 0L, 0L, 0L, 0L);
    v129 = ac_shdr_b(0L, 0L, 0L, 0L);
    v130 = ac_shdr_a(1L, 1L, 6L, text_off, ac_len);
    v131 = ac_shdr_b(0L, 0L, 16L, 0L);
    v132 = ac_shdr_a(7L, 1L, 2L, rod_off, ac_rodlen);
    v133 = ac_shdr_b(0L, 0L, 8L, 0L);
    v134 = ac_shdr_a(15L, 1L, 3L, data_off, ac_datalen);
    v135 = ac_shdr_b(0L, 0L, 8L, 0L);
    v136 = ac_shdr_a(21L, 8L, 3L, rela_off, ac_bsslen);
    v137 = ac_shdr_b(0L, 0L, 8L, 0L);
    v138 = ac_shdr_a(26L, 4L, 0L, rela_off, (nrel * 24L));
    v139 = ac_shdr_b(6L, 1L, 8L, 24L);
    v140 = ac_shdr_a(37L, 2L, 0L, sym_off, ((nsym + 1L) * 24L));
    v141 = ac_shdr_b(7L, 1L, 8L, 24L);
    v142 = ac_shdr_a(45L, 3L, 0L, str_off, strlen);
    v143 = ac_shdr_b(0L, 0L, 1L, 0L);
    v144 = ac_shdr_a(53L, 3L, 0L, shstr_off, shstr_len);
    v145 = ac_shdr_b(0L, 0L, 1L, 0L);
    v146 = endwrite();
    v147 = selectoutput(prev);
    v149 = writef(cast(long)__s27732.ptr, outname, ac_len, ac_rodlen, ac_datalen);
    v151 = writef(cast(long)__s27738.ptr, ac_bsslen, nsym, nrel);
    return 0;
}
long ac_run(long p1 = 0, long p2 = 0, long p3 = 0)
{
    long v0 = 0;
    long mark = 0;
    long ok = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long inname = p1;
    long outname = p2;
    long fmt = p3;
    mark = __alloc(0L);
    ok = 0L;
    v1 = ac_init();
    if (ac_assemble(inname) != 0)
    {
        v3 = ac_write_obj(outname);
        ok = cast(long)(ac_errs == 0L);
    }
    else
    {
        ok = 0L;
    }
    v4 = freevec(mark);
    return ok;
}
