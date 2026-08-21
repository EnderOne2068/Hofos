// Generated from BCPL by cg-d.b, split into modules by split.d.
module hofos.hmread;

import hofos.all;

long irr_is_space(long p1 = 0)
{
    long c = p1;
    return (cast(long)(c == 32L) | cast(long)(c == 9L));
}
long irr_is_digit(long p1 = 0)
{
    long c = p1;
    return (cast(long)(c >= 48L) & cast(long)(c <= 57L));
}
long irr_skip_ws()
{
    long n = 0;
    long v0 = 0;
    n = cast(long)*cast(ubyte*)(irr_line + 0L);
L6556:
    if (irr_pos <= n)
    {
        if (irr_is_space(cast(long)*cast(ubyte*)(irr_line + irr_pos)) != 0) goto L6557; else goto L6558;
L6557:
        irr_pos = (irr_pos + 1L);
    goto L6556;
    }
L6558:
    return 0;
}
long irr_read_word()
{
    long n = 0;
    long k = 0;
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    n = cast(long)*cast(ubyte*)(irr_line + 0L);
    k = 0L;
    *cast(ubyte*)(irr_namebuf + 0L) = cast(ubyte)0L;
    v0 = irr_skip_ws();
L6560:
    if (irr_pos <= n)
    {
        if (irr_is_space(cast(long)*cast(ubyte*)(irr_line + irr_pos)) != 0) goto L6562; else goto L6563;
L6563:
        if (cast(long)*cast(ubyte*)(irr_line + irr_pos) != 44L) goto L6561; else goto L6562;
L6561:
        k = (k + 1L);
        *cast(ubyte*)(irr_namebuf + k) = cast(ubyte)cast(long)*cast(ubyte*)(irr_line + irr_pos);
        irr_pos = (irr_pos + 1L);
    goto L6560;
    }
L6562:
    *cast(ubyte*)(irr_namebuf + 0L) = cast(ubyte)k;
    v2 = irr_skip_ws();
    if (irr_pos <= n)
    {
        if (cast(long)*cast(ubyte*)(irr_line + irr_pos) == 44L) goto L6565; else goto L6566;
L6565:
        irr_pos = (irr_pos + 1L);
    }
L6566:
    return 0;
}
long irr_word_eq_ci(long p1 = 0)
{
    long ua = 0;
    long ub = 0;
    long i = 0;
    long s = p1;
    ua = 0L;
    ub = 0L;
    if (cast(long)*cast(ubyte*)(irr_namebuf + 0L) != cast(long)*cast(ubyte*)(s + 0L))
    {
        return 0L;
    }
    i = 1L;
    while (i <= cast(long)*cast(ubyte*)(s + 0L))
    {
        ua = cast(long)*cast(ubyte*)(irr_namebuf + i);
        ub = cast(long)*cast(ubyte*)(s + i);
        if (ua >= 97L)
        {
            if (ua <= 122L) goto L6582; else goto L6583;
L6582:
            ua = (ua - 32L);
        }
L6583:
        if (ub >= 97L)
        {
            if (ub <= 122L) goto L6585; else goto L6586;
L6585:
            ub = (ub - 32L);
        }
L6586:
        if (ua != ub)
        {
            return 0L;
        }
        i = (i + 1L);
    }
    return 1L;
}
long irr_parse_int()
{
    long n = 0;
    long v = 0;
    long neg = 0;
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    n = cast(long)*cast(ubyte*)(irr_line + 0L);
    v = 0L;
    neg = 0L;
    v0 = irr_skip_ws();
    if (irr_pos <= n)
    {
        if (cast(long)*cast(ubyte*)(irr_line + irr_pos) == 45L) goto L6590; else goto L6591;
L6590:
        neg = 1L;
        irr_pos = (irr_pos + 1L);
    }
L6591:
L6593:
    if (irr_pos <= n)
    {
        if (irr_is_digit(cast(long)*cast(ubyte*)(irr_line + irr_pos)) != 0) goto L6594; else goto L6595;
L6594:
        v = (((v * 10L) + cast(long)*cast(ubyte*)(irr_line + irr_pos)) - 48L);
        irr_pos = (irr_pos + 1L);
    goto L6593;
    }
L6595:
    if (neg != 0)
    {
        v2 = (-v);
    }
    else
    {
        v2 = v;
    }
    return v2;
}
long irr_parse_temp()
{
    long v = 0;
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    v = 0L;
    v0 = irr_skip_ws();
    if (irr_pos <= cast(long)*cast(ubyte*)(irr_line + 0L))
    {
        if (cast(long)*cast(ubyte*)(irr_line + irr_pos) == 116L) goto L6601; else goto L6603;
L6603:
        if (cast(long)*cast(ubyte*)(irr_line + irr_pos) == 84L) goto L6601; else goto L6600;
    }
L6600:
    return 0L;
L6601:
    irr_pos = (irr_pos + 1L);
L6604:
    if (irr_pos <= cast(long)*cast(ubyte*)(irr_line + 0L))
    {
        if (irr_is_digit(cast(long)*cast(ubyte*)(irr_line + irr_pos)) != 0) goto L6605; else goto L6606;
L6605:
        v = (((v * 10L) + cast(long)*cast(ubyte*)(irr_line + irr_pos)) - 48L);
        irr_pos = (irr_pos + 1L);
    goto L6604;
    }
L6606:
    v2 = irr_skip_ws();
    if (irr_pos <= cast(long)*cast(ubyte*)(irr_line + 0L))
    {
        if (cast(long)*cast(ubyte*)(irr_line + irr_pos) == 44L) goto L6608; else goto L6609;
L6608:
        irr_pos = (irr_pos + 1L);
    }
L6609:
    if (v == 0L)
    {
        return 0L;
    }
    v = (v + irr_temp_base);
    if (v > irr_max_temp)
    {
        irr_max_temp = v;
    }
    return v;
}
long irr_parse_label()
{
    long v = 0;
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    v = 0L;
    v0 = irr_skip_ws();
    if (irr_pos <= cast(long)*cast(ubyte*)(irr_line + 0L))
    {
        if (cast(long)*cast(ubyte*)(irr_line + irr_pos) == 76L) goto L6616; else goto L6618;
L6618:
        if (cast(long)*cast(ubyte*)(irr_line + irr_pos) == 108L) goto L6616; else goto L6615;
    }
L6615:
    return 0L;
L6616:
    irr_pos = (irr_pos + 1L);
L6619:
    if (irr_pos <= cast(long)*cast(ubyte*)(irr_line + 0L))
    {
        if (irr_is_digit(cast(long)*cast(ubyte*)(irr_line + irr_pos)) != 0) goto L6620; else goto L6621;
L6620:
        v = (((v * 10L) + cast(long)*cast(ubyte*)(irr_line + irr_pos)) - 48L);
        irr_pos = (irr_pos + 1L);
    goto L6619;
    }
L6621:
    v2 = irr_skip_ws();
    if (irr_pos <= cast(long)*cast(ubyte*)(irr_line + 0L))
    {
        if (cast(long)*cast(ubyte*)(irr_line + irr_pos) == 44L) goto L6623; else goto L6624;
L6623:
        irr_pos = (irr_pos + 1L);
    }
L6624:
    if (v == 0L)
    {
        return 0L;
    }
    v = (v + irr_label_base);
    if (v > irr_max_label)
    {
        irr_max_label = v;
    }
    return v;
}
long irr_parse_string()
{
    long n = 0;
    long v0 = 0;
    long buf = 0;
    long k = 0;
    long v1 = 0;
    long v2 = 0;
    long c = 0;
    long v3 = 0;
    n = cast(long)*cast(ubyte*)(irr_line + 0L);
    buf = getvec(((1024L / 8L) + 4L));
    k = 0L;
    v1 = irr_skip_ws();
    if (irr_pos > n) goto L6630; else goto L6632;
L6632:
    if (cast(long)*cast(ubyte*)(irr_line + irr_pos) != 34L) goto L6630; else goto L6631;
L6630:
    v2 = freevec(buf);
    return 0L;
L6631:
    irr_pos = (irr_pos + 1L);
L6633:
    if (irr_pos <= n)
    {
        if (cast(long)*cast(ubyte*)(irr_line + irr_pos) != 34L) goto L6634; else goto L6635;
L6634:
        c = cast(long)*cast(ubyte*)(irr_line + irr_pos);
        if (c == 42L)
        {
            irr_pos = (irr_pos + 1L);
            if (irr_pos > n)
            {
    goto L6635;
            }
            v3 = cast(long)*cast(ubyte*)(irr_line + irr_pos);
            if (v3 == 110L) goto L6643; else goto L6653;
L6653:
            if (v3 == 78L) goto L6644; else goto L6654;
L6654:
            if (v3 == 116L) goto L6645; else goto L6655;
L6655:
            if (v3 == 84L) goto L6646; else goto L6656;
L6656:
            if (v3 == 115L) goto L6647; else goto L6657;
L6657:
            if (v3 == 83L) goto L6648; else goto L6658;
L6658:
            if (v3 == 99L) goto L6649; else goto L6659;
L6659:
            if (v3 == 67L) goto L6650; else goto L6660;
L6660:
            if (v3 == 42L) goto L6651; else goto L6661;
L6661:
            if (v3 == 34L) goto L6652; else goto L6662;
L6662:
    goto L6642;
L6643:
            c = 10L;
    goto L6641;
L6644:
            c = 10L;
    goto L6641;
L6645:
            c = 9L;
    goto L6641;
L6646:
            c = 9L;
    goto L6641;
L6647:
            c = 32L;
    goto L6641;
L6648:
            c = 32L;
    goto L6641;
L6649:
            c = 13L;
    goto L6641;
L6650:
            c = 13L;
    goto L6641;
L6651:
            c = 42L;
    goto L6641;
L6652:
            c = 34L;
    goto L6641;
L6642:
            c = cast(long)*cast(ubyte*)(irr_line + irr_pos);
L6641:
        }
        k = (k + 1L);
        *cast(ubyte*)(buf + k) = cast(ubyte)c;
        irr_pos = (irr_pos + 1L);
    goto L6633;
    }
L6635:
    if (irr_pos <= n)
    {
        if (cast(long)*cast(ubyte*)(irr_line + irr_pos) == 34L) goto L6663; else goto L6664;
L6663:
        irr_pos = (irr_pos + 1L);
    }
L6664:
    *cast(ubyte*)(buf + 0L) = cast(ubyte)k;
    *cast(ubyte*)(buf + (k + 1L)) = cast(ubyte)0L;
    return buf;
}
long irr_reserve_temp(long p1 = 0)
{
    long t = p1;
    while (ir_nextemp <= t)
    {
        ir_nextemp = (ir_nextemp + 1L);
    }
    return 0;
}
long irr_reserve_label(long p1 = 0)
{
    long l = p1;
    while (ir_nextlabel <= l)
    {
        ir_nextlabel = (ir_nextlabel + 1L);
    }
    return 0;
}
long irr_dispatch()
{
    long v0 = 0;
    long cmd_FUNC = 0;
    long v1 = 0;
    long cmd_ENDFUNC = 0;
    long v2 = 0;
    long cmd_PARAM = 0;
    long v3 = 0;
    long cmd_CONST = 0;
    long v4 = 0;
    long cmd_STRLIT = 0;
    long v5 = 0;
    long cmd_ADD = 0;
    long v6 = 0;
    long cmd_SUB = 0;
    long v7 = 0;
    long cmd_MUL = 0;
    long v8 = 0;
    long cmd_DIV = 0;
    long v9 = 0;
    long cmd_MOD = 0;
    long v10 = 0;
    long cmd_AND = 0;
    long v11 = 0;
    long cmd_OR = 0;
    long v12 = 0;
    long cmd_XOR = 0;
    long v13 = 0;
    long cmd_SHL = 0;
    long v14 = 0;
    long cmd_SHR = 0;
    long v15 = 0;
    long cmd_NEG = 0;
    long v16 = 0;
    long cmd_NOT = 0;
    long v17 = 0;
    long cmd_MOV = 0;
    long v18 = 0;
    long cmd_LOAD = 0;
    long v19 = 0;
    long cmd_LOADB = 0;
    long v20 = 0;
    long cmd_STORE = 0;
    long v21 = 0;
    long cmd_STOREB = 0;
    long v22 = 0;
    long cmd_CMPEQ = 0;
    long v23 = 0;
    long cmd_CMPNE = 0;
    long v24 = 0;
    long cmd_CMPLT = 0;
    long v25 = 0;
    long cmd_CMPLE = 0;
    long v26 = 0;
    long cmd_CMPGT = 0;
    long v27 = 0;
    long cmd_CMPGE = 0;
    long v28 = 0;
    long cmd_JMP = 0;
    long v29 = 0;
    long cmd_BR = 0;
    long v30 = 0;
    long cmd_LABEL = 0;
    long v31 = 0;
    long cmd_CALL = 0;
    long v32 = 0;
    long cmd_RET = 0;
    long v33 = 0;
    long cmd_GLOBAL = 0;
    long v34 = 0;
    long cmd_GSTORE = 0;
    long v35 = 0;
    long cmd_VECALLOC = 0;
    long v36 = 0;
    long cmd_STKALLOC = 0;
    long v37 = 0;
    long cmd_ADDR = 0;
    long v38 = 0;
    long cmd_NOP = 0;
    long v39 = 0;
    long cmd_CALLI = 0;
    long v40 = 0;
    long cmd_SETARG = 0;
    long v41 = 0;
    long cmd_FUNCADDR = 0;
    long v42 = 0;
    long cmd_GLOBADDR = 0;
    long v43 = 0;
    long cmd_FADD = 0;
    long v44 = 0;
    long cmd_FSUB = 0;
    long v45 = 0;
    long cmd_FMUL = 0;
    long v46 = 0;
    long cmd_FDIV = 0;
    long v47 = 0;
    long cmd_FCMPEQ = 0;
    long v48 = 0;
    long cmd_FCMPNE = 0;
    long v49 = 0;
    long cmd_FCMPLT = 0;
    long v50 = 0;
    long cmd_FCMPLE = 0;
    long v51 = 0;
    long cmd_FCMPGT = 0;
    long v52 = 0;
    long cmd_FCMPGE = 0;
    long v53 = 0;
    long cmd_ITOF = 0;
    long v54 = 0;
    long cmd_FTOI = 0;
    long v55 = 0;
    long cmd_VFILL = 0;
    long v56 = 0;
    long cmd_VCOPY = 0;
    long v57 = 0;
    long cmd_VADD = 0;
    long v58 = 0;
    long cmd_VSUB = 0;
    long v59 = 0;
    long v60 = 0;
    long v61 = 0;
    long v62 = 0;
    long fname = 0;
    long argc = 0;
    long t = 0;
    long i = 0;
    long v63 = 0;
    long v64 = 0;
    long v65 = 0;
    long v66 = 0;
    long v67 = 0;
    long v68 = 0;
    long v69 = 0;
    long d = 0;
    long v70 = 0;
    long k = 0;
    long v71 = 0;
    long v72 = 0;
    long v73 = 0;
    long v74 = 0;
    long d_2 = 0;
    long v75 = 0;
    long v = 0;
    long v76 = 0;
    long v77 = 0;
    long v78 = 0;
    long v79 = 0;
    long d_3 = 0;
    long v80 = 0;
    long s = 0;
    long v81 = 0;
    long v82 = 0;
    long v83 = 0;
    long v84 = 0;
    long d_4 = 0;
    long v85 = 0;
    long a = 0;
    long v86 = 0;
    long v87 = 0;
    long v88 = 0;
    long v89 = 0;
    long d_5 = 0;
    long v90 = 0;
    long a_2 = 0;
    long v91 = 0;
    long v92 = 0;
    long v93 = 0;
    long v94 = 0;
    long d_6 = 0;
    long v95 = 0;
    long a_3 = 0;
    long v96 = 0;
    long v97 = 0;
    long v98 = 0;
    long v99 = 0;
    long d_7 = 0;
    long v100 = 0;
    long a_4 = 0;
    long v101 = 0;
    long v102 = 0;
    long v103 = 0;
    long v104 = 0;
    long d_8 = 0;
    long v105 = 0;
    long a_5 = 0;
    long v106 = 0;
    long v107 = 0;
    long v108 = 0;
    long v109 = 0;
    long a_6 = 0;
    long v110 = 0;
    long b = 0;
    long v111 = 0;
    long v112 = 0;
    long v113 = 0;
    long a_7 = 0;
    long v114 = 0;
    long b_2 = 0;
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
    long op = 0;
    long v126 = 0;
    long v127 = 0;
    long v128 = 0;
    long v129 = 0;
    long v130 = 0;
    long v131 = 0;
    long v132 = 0;
    long v133 = 0;
    long v134 = 0;
    long v135 = 0;
    long d_9 = 0;
    long v136 = 0;
    long a_8 = 0;
    long v137 = 0;
    long b_3 = 0;
    long v138 = 0;
    long v139 = 0;
    long v140 = 0;
    long v141 = 0;
    long v142 = 0;
    long v143 = 0;
    long v144 = 0;
    long v145 = 0;
    long op_2 = 0;
    long v146 = 0;
    long v147 = 0;
    long v148 = 0;
    long v149 = 0;
    long v150 = 0;
    long v151 = 0;
    long d_10 = 0;
    long v152 = 0;
    long a_9 = 0;
    long v153 = 0;
    long b_4 = 0;
    long v154 = 0;
    long v155 = 0;
    long v156 = 0;
    long v157 = 0;
    long l = 0;
    long v158 = 0;
    long v159 = 0;
    long v160 = 0;
    long v161 = 0;
    long c = 0;
    long v162 = 0;
    long t_2 = 0;
    long v163 = 0;
    long f = 0;
    long v164 = 0;
    long v165 = 0;
    long v166 = 0;
    long v167 = 0;
    long v168 = 0;
    long l_2 = 0;
    long v169 = 0;
    long v170 = 0;
    long v171 = 0;
    long v172 = 0;
    long d_11 = 0;
    long tCallee = 0;
    long a1 = 0;
    long a2 = 0;
    long a3 = 0;
    long a4 = 0;
    long a5 = 0;
    long argc_2 = 0;
    long fname_2 = 0;
    long v173 = 0;
    long v174 = 0;
    long v175 = 0;
    long i_2 = 0;
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
    long a_10 = 0;
    long v189 = 0;
    long v190 = 0;
    long v191 = 0;
    long d_12 = 0;
    long v192 = 0;
    long slot = 0;
    long v193 = 0;
    long v194 = 0;
    long v195 = 0;
    long v196 = 0;
    long slot_2 = 0;
    long v197 = 0;
    long v_2 = 0;
    long v198 = 0;
    long v199 = 0;
    long v200 = 0;
    long d_13 = 0;
    long v201 = 0;
    long cnt = 0;
    long v202 = 0;
    long v203 = 0;
    long v204 = 0;
    long v205 = 0;
    long d_14 = 0;
    long v206 = 0;
    long cnt_2 = 0;
    long v207 = 0;
    long v208 = 0;
    long v209 = 0;
    long v210 = 0;
    long d_15 = 0;
    long v211 = 0;
    long x = 0;
    long v212 = 0;
    long v213 = 0;
    long v214 = 0;
    long v215 = 0;
    long v216 = 0;
    long v217 = 0;
    long v218 = 0;
    long d_16 = 0;
    long v219 = 0;
    long tc = 0;
    long a1_2 = 0;
    long a2_2 = 0;
    long a3_2 = 0;
    long a4_2 = 0;
    long a5_2 = 0;
    long argc_3 = 0;
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
    long t_3 = 0;
    long v232 = 0;
    long k_2 = 0;
    long v233 = 0;
    long v234 = 0;
    long v235 = 0;
    long d_17 = 0;
    long fname_3 = 0;
    long slot_3 = 0;
    long v236 = 0;
    long v237 = 0;
    long v238 = 0;
    long i_3 = 0;
    long v239 = 0;
    long v240 = 0;
    long v241 = 0;
    long v242 = 0;
    long d_18 = 0;
    long v243 = 0;
    long slot_4 = 0;
    long v244 = 0;
    long v245 = 0;
    long v246 = 0;
    long v247 = 0;
    long v248 = 0;
    long v249 = 0;
    long v250 = 0;
    long v251 = 0;
    long v252 = 0;
    long v253 = 0;
    long v254 = 0;
    long v255 = 0;
    long op_3 = 0;
    long v256 = 0;
    long v257 = 0;
    long v258 = 0;
    long v259 = 0;
    long v260 = 0;
    long v261 = 0;
    long v262 = 0;
    long v263 = 0;
    long v264 = 0;
    long v265 = 0;
    long d_19 = 0;
    long v266 = 0;
    long a_11 = 0;
    long v267 = 0;
    long b_5 = 0;
    long v268 = 0;
    long v269 = 0;
    long v270 = 0;
    long v271 = 0;
    long d_20 = 0;
    long v272 = 0;
    long a_12 = 0;
    long v273 = 0;
    long v274 = 0;
    long v275 = 0;
    long v276 = 0;
    long d_21 = 0;
    long v277 = 0;
    long a_13 = 0;
    long v278 = 0;
    long v279 = 0;
    long v280 = 0;
    long v281 = 0;
    long a_14 = 0;
    long v282 = 0;
    long b_6 = 0;
    long v283 = 0;
    long c_2 = 0;
    long v284 = 0;
    long v285 = 0;
    long v286 = 0;
    long a_15 = 0;
    long v287 = 0;
    long b_7 = 0;
    long v288 = 0;
    long c_3 = 0;
    long v289 = 0;
    long v290 = 0;
    long v291 = 0;
    long cnt_3 = 0;
    long v292 = 0;
    long d_22 = 0;
    long v293 = 0;
    long s_2 = 0;
    long v294 = 0;
    long sc = 0;
    long v295 = 0;
    long v296 = 0;
    long v297 = 0;
    long cnt_4 = 0;
    long v298 = 0;
    long d_23 = 0;
    long v299 = 0;
    long s_3 = 0;
    long v300 = 0;
    long sc_2 = 0;
    long v301 = 0;
    long v302 = 0;
    long v303 = 0;
    cmd_FUNC = cast(long)__s32307.ptr;
    cmd_ENDFUNC = cast(long)__s32309.ptr;
    cmd_PARAM = cast(long)__s32311.ptr;
    cmd_CONST = cast(long)__s32313.ptr;
    cmd_STRLIT = cast(long)__s32315.ptr;
    cmd_ADD = cast(long)__s32317.ptr;
    cmd_SUB = cast(long)__s32319.ptr;
    cmd_MUL = cast(long)__s32321.ptr;
    cmd_DIV = cast(long)__s32323.ptr;
    cmd_MOD = cast(long)__s32325.ptr;
    cmd_AND = cast(long)__s32327.ptr;
    cmd_OR = cast(long)__s32329.ptr;
    cmd_XOR = cast(long)__s32331.ptr;
    cmd_SHL = cast(long)__s32333.ptr;
    cmd_SHR = cast(long)__s32335.ptr;
    cmd_NEG = cast(long)__s32337.ptr;
    cmd_NOT = cast(long)__s32339.ptr;
    cmd_MOV = cast(long)__s32341.ptr;
    cmd_LOAD = cast(long)__s32343.ptr;
    cmd_LOADB = cast(long)__s32345.ptr;
    cmd_STORE = cast(long)__s32347.ptr;
    cmd_STOREB = cast(long)__s32349.ptr;
    cmd_CMPEQ = cast(long)__s32351.ptr;
    cmd_CMPNE = cast(long)__s32353.ptr;
    cmd_CMPLT = cast(long)__s32355.ptr;
    cmd_CMPLE = cast(long)__s32357.ptr;
    cmd_CMPGT = cast(long)__s32359.ptr;
    cmd_CMPGE = cast(long)__s32361.ptr;
    cmd_JMP = cast(long)__s32363.ptr;
    cmd_BR = cast(long)__s32365.ptr;
    cmd_LABEL = cast(long)__s32367.ptr;
    cmd_CALL = cast(long)__s32369.ptr;
    cmd_RET = cast(long)__s32371.ptr;
    cmd_GLOBAL = cast(long)__s32373.ptr;
    cmd_GSTORE = cast(long)__s32375.ptr;
    cmd_VECALLOC = cast(long)__s32377.ptr;
    cmd_STKALLOC = cast(long)__s32379.ptr;
    cmd_ADDR = cast(long)__s32381.ptr;
    cmd_NOP = cast(long)__s32383.ptr;
    cmd_CALLI = cast(long)__s32385.ptr;
    cmd_SETARG = cast(long)__s32387.ptr;
    cmd_FUNCADDR = cast(long)__s32389.ptr;
    cmd_GLOBADDR = cast(long)__s32391.ptr;
    cmd_FADD = cast(long)__s32393.ptr;
    cmd_FSUB = cast(long)__s32395.ptr;
    cmd_FMUL = cast(long)__s32397.ptr;
    cmd_FDIV = cast(long)__s32399.ptr;
    cmd_FCMPEQ = cast(long)__s32401.ptr;
    cmd_FCMPNE = cast(long)__s32403.ptr;
    cmd_FCMPLT = cast(long)__s32405.ptr;
    cmd_FCMPLE = cast(long)__s32407.ptr;
    cmd_FCMPGT = cast(long)__s32409.ptr;
    cmd_FCMPGE = cast(long)__s32411.ptr;
    cmd_ITOF = cast(long)__s32413.ptr;
    cmd_FTOI = cast(long)__s32415.ptr;
    cmd_VFILL = cast(long)__s32417.ptr;
    cmd_VCOPY = cast(long)__s32419.ptr;
    cmd_VADD = cast(long)__s32421.ptr;
    cmd_VSUB = cast(long)__s32423.ptr;
    v59 = irr_read_word();
    if (cast(long)*cast(ubyte*)(irr_namebuf + 0L) == 0L)
    {
        return 0;
    }
    if (irr_word_eq_ci(cmd_FUNC) != 0)
    {
        v61 = irr_read_word();
        fname = getvec(64L);
        argc = 0L;
        t = 0L;
        i = 0L;
        while (i <= cast(long)*cast(ubyte*)(irr_namebuf + 0L))
        {
            *cast(ubyte*)(fname + i) = cast(ubyte)cast(long)*cast(ubyte*)(irr_namebuf + i);
            i = (i + 1L);
        }
        argc = irr_parse_int();
        t = ir_new_temp();
        v65 = ir_emit(36L, t, argc, fname, 0L);
    }
    else
    {
        if (irr_word_eq_ci(cmd_ENDFUNC) != 0)
        {
            v67 = ir_emit(37L, 0L, 0L, 0L, 0L);
        }
        else
        {
            if (irr_word_eq_ci(cmd_PARAM) != 0)
            {
                d = irr_parse_temp();
                k = irr_parse_int();
                v71 = irr_reserve_temp(d);
                v72 = ir_emit(35L, d, k, 0L, 0L);
            }
            else
            {
                if (irr_word_eq_ci(cmd_CONST) != 0)
                {
                    d_2 = irr_parse_temp();
                    v = irr_parse_int();
                    v76 = irr_reserve_temp(d_2);
                    v77 = ir_emit(1L, d_2, v, 0L, 0L);
                }
                else
                {
                    if (irr_word_eq_ci(cmd_STRLIT) != 0)
                    {
                        d_3 = irr_parse_temp();
                        s = irr_parse_string();
                        v81 = irr_reserve_temp(d_3);
                        if (s != 0L)
                        {
                            v82 = ir_emit(38L, d_3, s, 0L, 0L);
                        }
                    }
                    else
                    {
                        if (irr_word_eq_ci(cmd_MOV) != 0)
                        {
                            d_4 = irr_parse_temp();
                            a = irr_parse_temp();
                            v86 = irr_reserve_temp(d_4);
                            v87 = ir_emit(39L, d_4, a, 0L, 0L);
                        }
                        else
                        {
                            if (irr_word_eq_ci(cmd_NEG) != 0)
                            {
                                d_5 = irr_parse_temp();
                                a_2 = irr_parse_temp();
                                v91 = irr_reserve_temp(d_5);
                                v92 = ir_emit(26L, d_5, a_2, 0L, 0L);
                            }
                            else
                            {
                                if (irr_word_eq_ci(cmd_NOT) != 0)
                                {
                                    d_6 = irr_parse_temp();
                                    a_3 = irr_parse_temp();
                                    v96 = irr_reserve_temp(d_6);
                                    v97 = ir_emit(12L, d_6, a_3, 0L, 0L);
                                }
                                else
                                {
                                    if (irr_word_eq_ci(cmd_LOAD) != 0)
                                    {
                                        d_7 = irr_parse_temp();
                                        a_4 = irr_parse_temp();
                                        v101 = irr_reserve_temp(d_7);
                                        v102 = ir_emit(2L, d_7, a_4, 0L, 0L);
                                    }
                                    else
                                    {
                                        if (irr_word_eq_ci(cmd_LOADB) != 0)
                                        {
                                            d_8 = irr_parse_temp();
                                            a_5 = irr_parse_temp();
                                            v106 = irr_reserve_temp(d_8);
                                            v107 = ir_emit(43L, d_8, a_5, 0L, 0L);
                                        }
                                        else
                                        {
                                            if (irr_word_eq_ci(cmd_STORE) != 0)
                                            {
                                                a_6 = irr_parse_temp();
                                                b = irr_parse_temp();
                                                v111 = ir_emit(3L, 0L, a_6, b, 0L);
                                            }
                                            else
                                            {
                                                if (irr_word_eq_ci(cmd_STOREB) != 0)
                                                {
                                                    a_7 = irr_parse_temp();
                                                    b_2 = irr_parse_temp();
                                                    v115 = ir_emit(44L, 0L, a_7, b_2, 0L);
                                                }
                                                else
                                                {
                                                    if (irr_word_eq_ci(cmd_ADD) != 0) goto L6716; else goto L6727;
L6727:
                                                    if (irr_word_eq_ci(cmd_SUB) != 0) goto L6716; else goto L6726;
L6726:
                                                    if (irr_word_eq_ci(cmd_MUL) != 0) goto L6716; else goto L6725;
L6725:
                                                    if (irr_word_eq_ci(cmd_DIV) != 0) goto L6716; else goto L6724;
L6724:
                                                    if (irr_word_eq_ci(cmd_MOD) != 0) goto L6716; else goto L6723;
L6723:
                                                    if (irr_word_eq_ci(cmd_AND) != 0) goto L6716; else goto L6722;
L6722:
                                                    if (irr_word_eq_ci(cmd_OR) != 0) goto L6716; else goto L6721;
L6721:
                                                    if (irr_word_eq_ci(cmd_XOR) != 0) goto L6716; else goto L6720;
L6720:
                                                    if (irr_word_eq_ci(cmd_SHL) != 0) goto L6716; else goto L6719;
L6719:
                                                    if (irr_word_eq_ci(cmd_SHR) != 0) goto L6716; else goto L6717;
L6716:
                                                    op = 4L;
                                                    if (irr_word_eq_ci(cmd_SUB) != 0)
                                                    {
                                                        op = 5L;
                                                    }
                                                    if (irr_word_eq_ci(cmd_MUL) != 0)
                                                    {
                                                        op = 6L;
                                                    }
                                                    if (irr_word_eq_ci(cmd_DIV) != 0)
                                                    {
                                                        op = 7L;
                                                    }
                                                    if (irr_word_eq_ci(cmd_MOD) != 0)
                                                    {
                                                        op = 8L;
                                                    }
                                                    if (irr_word_eq_ci(cmd_AND) != 0)
                                                    {
                                                        op = 9L;
                                                    }
                                                    if (irr_word_eq_ci(cmd_OR) != 0)
                                                    {
                                                        op = 10L;
                                                    }
                                                    if (irr_word_eq_ci(cmd_XOR) != 0)
                                                    {
                                                        op = 11L;
                                                    }
                                                    if (irr_word_eq_ci(cmd_SHL) != 0)
                                                    {
                                                        op = 13L;
                                                    }
                                                    if (irr_word_eq_ci(cmd_SHR) != 0)
                                                    {
                                                        op = 14L;
                                                    }
                                                    d_9 = irr_parse_temp();
                                                    a_8 = irr_parse_temp();
                                                    b_3 = irr_parse_temp();
                                                    v138 = irr_reserve_temp(d_9);
                                                    v139 = ir_emit(op, d_9, a_8, b_3, 0L);
    goto L6718;
L6717:
                                                    if (irr_word_eq_ci(cmd_CMPEQ) != 0) goto L6746; else goto L6753;
L6753:
                                                    if (irr_word_eq_ci(cmd_CMPNE) != 0) goto L6746; else goto L6752;
L6752:
                                                    if (irr_word_eq_ci(cmd_CMPLT) != 0) goto L6746; else goto L6751;
L6751:
                                                    if (irr_word_eq_ci(cmd_CMPLE) != 0) goto L6746; else goto L6750;
L6750:
                                                    if (irr_word_eq_ci(cmd_CMPGT) != 0) goto L6746; else goto L6749;
L6749:
                                                    if (irr_word_eq_ci(cmd_CMPGE) != 0) goto L6746; else goto L6747;
L6746:
                                                    op_2 = 20L;
                                                    if (irr_word_eq_ci(cmd_CMPNE) != 0)
                                                    {
                                                        op_2 = 21L;
                                                    }
                                                    if (irr_word_eq_ci(cmd_CMPLT) != 0)
                                                    {
                                                        op_2 = 22L;
                                                    }
                                                    if (irr_word_eq_ci(cmd_CMPLE) != 0)
                                                    {
                                                        op_2 = 23L;
                                                    }
                                                    if (irr_word_eq_ci(cmd_CMPGT) != 0)
                                                    {
                                                        op_2 = 24L;
                                                    }
                                                    if (irr_word_eq_ci(cmd_CMPGE) != 0)
                                                    {
                                                        op_2 = 25L;
                                                    }
                                                    d_10 = irr_parse_temp();
                                                    a_9 = irr_parse_temp();
                                                    b_4 = irr_parse_temp();
                                                    v154 = irr_reserve_temp(d_10);
                                                    v155 = ir_emit(op_2, d_10, a_9, b_4, 0L);
    goto L6748;
L6747:
                                                    if (irr_word_eq_ci(cmd_JMP) != 0)
                                                    {
                                                        l = irr_parse_label();
                                                        v158 = irr_reserve_label(l);
                                                        v159 = ir_emit_jmp(l);
                                                    }
                                                    else
                                                    {
                                                        if (irr_word_eq_ci(cmd_BR) != 0)
                                                        {
                                                            c = irr_parse_temp();
                                                            t_2 = irr_parse_label();
                                                            f = irr_parse_label();
                                                            v164 = irr_reserve_label(t_2);
                                                            v165 = irr_reserve_label(f);
                                                            v166 = ir_emit_br(c, t_2, f);
                                                        }
                                                        else
                                                        {
                                                            if (irr_word_eq_ci(cmd_LABEL) != 0)
                                                            {
                                                                l_2 = irr_parse_label();
                                                                v169 = irr_reserve_label(l_2);
                                                                v170 = ir_emit_label(l_2);
                                                            }
                                                            else
                                                            {
                                                                if (irr_word_eq_ci(cmd_CALL) != 0)
                                                                {
                                                                    d_11 = irr_parse_temp();
                                                                    tCallee = 0L;
                                                                    a1 = 0L;
                                                                    a2 = 0L;
                                                                    a3 = 0L;
                                                                    a4 = 0L;
                                                                    a5 = 0L;
                                                                    argc_2 = 0L;
                                                                    fname_2 = 0L;
                                                                    v173 = irr_reserve_temp(d_11);
                                                                    v174 = irr_read_word();
                                                                    fname_2 = getvec(64L);
                                                                    i_2 = 0L;
                                                                    while (i_2 <= cast(long)*cast(ubyte*)(irr_namebuf + 0L))
                                                                    {
                                                                        *cast(ubyte*)(fname_2 + i_2) = cast(ubyte)cast(long)*cast(ubyte*)(irr_namebuf + i_2);
                                                                        i_2 = (i_2 + 1L);
                                                                    }
                                                                    tCallee = ir_new_temp();
                                                                    v177 = ir_emit(1L, tCallee, fname_2, 1L, 0L);
                                                                    a1 = irr_parse_temp();
                                                                    a2 = irr_parse_temp();
                                                                    a3 = irr_parse_temp();
                                                                    a4 = irr_parse_temp();
                                                                    a5 = irr_parse_temp();
                                                                    if (a1 > 0L)
                                                                    {
                                                                        argc_2 = 1L;
                                                                    }
                                                                    if (a2 > 0L)
                                                                    {
                                                                        argc_2 = 2L;
                                                                    }
                                                                    if (a3 > 0L)
                                                                    {
                                                                        argc_2 = 3L;
                                                                    }
                                                                    if (a4 > 0L)
                                                                    {
                                                                        argc_2 = 4L;
                                                                    }
                                                                    if (a5 > 0L)
                                                                    {
                                                                        argc_2 = 5L;
                                                                    }
                                                                    if (a4 > 0L)
                                                                    {
                                                                        v183 = ir_emit(47L, 0L, a4, 4L, 0L);
                                                                    }
                                                                    if (a5 > 0L)
                                                                    {
                                                                        v184 = ir_emit(47L, 0L, a5, 5L, 0L);
                                                                    }
                                                                    v186 = ir_set_arg3(ir_emit_call(d_11, tCallee, argc_2, a1, a2), a3);
                                                                }
                                                                else
                                                                {
                                                                    if (irr_word_eq_ci(cmd_RET) != 0)
                                                                    {
                                                                        a_10 = irr_parse_temp();
                                                                        v189 = ir_emit(34L, 0L, a_10, 0L, 0L);
                                                                    }
                                                                    else
                                                                    {
                                                                        if (irr_word_eq_ci(cmd_GLOBAL) != 0)
                                                                        {
                                                                            d_12 = irr_parse_temp();
                                                                            slot = irr_parse_int();
                                                                            v193 = irr_reserve_temp(d_12);
                                                                            v194 = ir_emit(40L, d_12, slot, 0L, 0L);
                                                                        }
                                                                        else
                                                                        {
                                                                            if (irr_word_eq_ci(cmd_GSTORE) != 0)
                                                                            {
                                                                                slot_2 = irr_parse_int();
                                                                                v_2 = irr_parse_temp();
                                                                                v198 = ir_emit(41L, 0L, slot_2, v_2, 0L);
                                                                            }
                                                                            else
                                                                            {
                                                                                if (irr_word_eq_ci(cmd_VECALLOC) != 0)
                                                                                {
                                                                                    d_13 = irr_parse_temp();
                                                                                    cnt = irr_parse_int();
                                                                                    v202 = irr_reserve_temp(d_13);
                                                                                    v203 = ir_emit(42L, d_13, cnt, 0L, 0L);
                                                                                }
                                                                                else
                                                                                {
                                                                                    if (irr_word_eq_ci(cmd_STKALLOC) != 0)
                                                                                    {
                                                                                        d_14 = irr_parse_temp();
                                                                                        cnt_2 = irr_parse_int();
                                                                                        v207 = irr_reserve_temp(d_14);
                                                                                        v208 = ir_emit(48L, d_14, cnt_2, 0L, 0L);
                                                                                    }
                                                                                    else
                                                                                    {
                                                                                        if (irr_word_eq_ci(cmd_ADDR) != 0)
                                                                                        {
                                                                                            d_15 = irr_parse_temp();
                                                                                            x = irr_parse_temp();
                                                                                            v212 = irr_reserve_temp(d_15);
                                                                                            v213 = irr_reserve_temp(x);
                                                                                            v214 = ir_emit(45L, d_15, x, 0L, 0L);
                                                                                        }
                                                                                        else
                                                                                        {
                                                                                            if (irr_word_eq_ci(cmd_NOP) != 0)
                                                                                            {
                                                                                                v216 = ir_emit(46L, 0L, 0L, 0L, 0L);
                                                                                            }
                                                                                            else
                                                                                            {
                                                                                                if (irr_word_eq_ci(cmd_CALLI) != 0)
                                                                                                {
                                                                                                    d_16 = irr_parse_temp();
                                                                                                    tc = irr_parse_temp();
                                                                                                    a1_2 = 0L;
                                                                                                    a2_2 = 0L;
                                                                                                    a3_2 = 0L;
                                                                                                    a4_2 = 0L;
                                                                                                    a5_2 = 0L;
                                                                                                    argc_3 = 0L;
                                                                                                    v220 = irr_reserve_temp(d_16);
                                                                                                    a1_2 = irr_parse_temp();
                                                                                                    a2_2 = irr_parse_temp();
                                                                                                    a3_2 = irr_parse_temp();
                                                                                                    a4_2 = irr_parse_temp();
                                                                                                    a5_2 = irr_parse_temp();
                                                                                                    if (a1_2 > 0L)
                                                                                                    {
                                                                                                        argc_3 = 1L;
                                                                                                    }
                                                                                                    if (a2_2 > 0L)
                                                                                                    {
                                                                                                        argc_3 = 2L;
                                                                                                    }
                                                                                                    if (a3_2 > 0L)
                                                                                                    {
                                                                                                        argc_3 = 3L;
                                                                                                    }
                                                                                                    if (a4_2 > 0L)
                                                                                                    {
                                                                                                        argc_3 = 4L;
                                                                                                    }
                                                                                                    if (a5_2 > 0L)
                                                                                                    {
                                                                                                        argc_3 = 5L;
                                                                                                    }
                                                                                                    if (a4_2 > 0L)
                                                                                                    {
                                                                                                        v226 = ir_emit(47L, 0L, a4_2, 4L, 0L);
                                                                                                    }
                                                                                                    if (a5_2 > 0L)
                                                                                                    {
                                                                                                        v227 = ir_emit(47L, 0L, a5_2, 5L, 0L);
                                                                                                    }
                                                                                                    v229 = ir_set_arg3(ir_emit_call(d_16, tc, argc_3, a1_2, a2_2), a3_2);
                                                                                                }
                                                                                                else
                                                                                                {
                                                                                                    if (irr_word_eq_ci(cmd_SETARG) != 0)
                                                                                                    {
                                                                                                        t_3 = irr_parse_temp();
                                                                                                        k_2 = irr_parse_int();
                                                                                                        v233 = ir_emit(47L, 0L, t_3, k_2, 0L);
                                                                                                    }
                                                                                                    else
                                                                                                    {
                                                                                                        if (irr_word_eq_ci(cmd_FUNCADDR) != 0)
                                                                                                        {
                                                                                                            d_17 = irr_parse_temp();
                                                                                                            fname_3 = 0L;
                                                                                                            slot_3 = 0L;
                                                                                                            v236 = irr_reserve_temp(d_17);
                                                                                                            v237 = irr_read_word();
                                                                                                            fname_3 = getvec(64L);
                                                                                                            i_3 = 0L;
                                                                                                            while (i_3 <= cast(long)*cast(ubyte*)(irr_namebuf + 0L))
                                                                                                            {
                                                                                                                *cast(ubyte*)(fname_3 + i_3) = cast(ubyte)cast(long)*cast(ubyte*)(irr_namebuf + i_3);
                                                                                                                i_3 = (i_3 + 1L);
                                                                                                            }
                                                                                                            slot_3 = irr_parse_int();
                                                                                                            v240 = ir_emit(50L, d_17, slot_3, fname_3, 0L);
                                                                                                        }
                                                                                                        else
                                                                                                        {
                                                                                                            if (irr_word_eq_ci(cmd_GLOBADDR) != 0)
                                                                                                            {
                                                                                                                d_18 = irr_parse_temp();
                                                                                                                slot_4 = irr_parse_int();
                                                                                                                v244 = irr_reserve_temp(d_18);
                                                                                                                v245 = ir_emit(49L, d_18, slot_4, 0L, 0L);
                                                                                                            }
                                                                                                            else
                                                                                                            {
                                                                                                                if (irr_word_eq_ci(cmd_FADD) != 0) goto L6845; else goto L6856;
L6856:
                                                                                                                if (irr_word_eq_ci(cmd_FSUB) != 0) goto L6845; else goto L6855;
L6855:
                                                                                                                if (irr_word_eq_ci(cmd_FMUL) != 0) goto L6845; else goto L6854;
L6854:
                                                                                                                if (irr_word_eq_ci(cmd_FDIV) != 0) goto L6845; else goto L6853;
L6853:
                                                                                                                if (irr_word_eq_ci(cmd_FCMPEQ) != 0) goto L6845; else goto L6852;
L6852:
                                                                                                                if (irr_word_eq_ci(cmd_FCMPNE) != 0) goto L6845; else goto L6851;
L6851:
                                                                                                                if (irr_word_eq_ci(cmd_FCMPLT) != 0) goto L6845; else goto L6850;
L6850:
                                                                                                                if (irr_word_eq_ci(cmd_FCMPLE) != 0) goto L6845; else goto L6849;
L6849:
                                                                                                                if (irr_word_eq_ci(cmd_FCMPGT) != 0) goto L6845; else goto L6848;
L6848:
                                                                                                                if (irr_word_eq_ci(cmd_FCMPGE) != 0) goto L6845; else goto L6846;
L6845:
                                                                                                                op_3 = 51L;
                                                                                                                if (irr_word_eq_ci(cmd_FSUB) != 0)
                                                                                                                {
                                                                                                                    op_3 = 52L;
                                                                                                                }
                                                                                                                if (irr_word_eq_ci(cmd_FMUL) != 0)
                                                                                                                {
                                                                                                                    op_3 = 53L;
                                                                                                                }
                                                                                                                if (irr_word_eq_ci(cmd_FDIV) != 0)
                                                                                                                {
                                                                                                                    op_3 = 54L;
                                                                                                                }
                                                                                                                if (irr_word_eq_ci(cmd_FCMPEQ) != 0)
                                                                                                                {
                                                                                                                    op_3 = 59L;
                                                                                                                }
                                                                                                                if (irr_word_eq_ci(cmd_FCMPNE) != 0)
                                                                                                                {
                                                                                                                    op_3 = 60L;
                                                                                                                }
                                                                                                                if (irr_word_eq_ci(cmd_FCMPLT) != 0)
                                                                                                                {
                                                                                                                    op_3 = 55L;
                                                                                                                }
                                                                                                                if (irr_word_eq_ci(cmd_FCMPLE) != 0)
                                                                                                                {
                                                                                                                    op_3 = 56L;
                                                                                                                }
                                                                                                                if (irr_word_eq_ci(cmd_FCMPGT) != 0)
                                                                                                                {
                                                                                                                    op_3 = 57L;
                                                                                                                }
                                                                                                                if (irr_word_eq_ci(cmd_FCMPGE) != 0)
                                                                                                                {
                                                                                                                    op_3 = 58L;
                                                                                                                }
                                                                                                                d_19 = irr_parse_temp();
                                                                                                                a_11 = irr_parse_temp();
                                                                                                                b_5 = irr_parse_temp();
                                                                                                                v268 = irr_reserve_temp(d_19);
                                                                                                                v269 = ir_emit(op_3, d_19, a_11, b_5, 0L);
    goto L6847;
L6846:
                                                                                                                if (irr_word_eq_ci(cmd_ITOF) != 0)
                                                                                                                {
                                                                                                                    d_20 = irr_parse_temp();
                                                                                                                    a_12 = irr_parse_temp();
                                                                                                                    v273 = irr_reserve_temp(d_20);
                                                                                                                    v274 = ir_emit(61L, d_20, a_12, 0L, 0L);
                                                                                                                }
                                                                                                                else
                                                                                                                {
                                                                                                                    if (irr_word_eq_ci(cmd_FTOI) != 0)
                                                                                                                    {
                                                                                                                        d_21 = irr_parse_temp();
                                                                                                                        a_13 = irr_parse_temp();
                                                                                                                        v278 = irr_reserve_temp(d_21);
                                                                                                                        v279 = ir_emit(62L, d_21, a_13, 0L, 0L);
                                                                                                                    }
                                                                                                                    else
                                                                                                                    {
                                                                                                                        if (irr_word_eq_ci(cmd_VFILL) != 0)
                                                                                                                        {
                                                                                                                            a_14 = irr_parse_temp();
                                                                                                                            b_6 = irr_parse_temp();
                                                                                                                            c_2 = irr_parse_temp();
                                                                                                                            v284 = ir_emit(63L, 0L, a_14, b_6, c_2);
                                                                                                                        }
                                                                                                                        else
                                                                                                                        {
                                                                                                                            if (irr_word_eq_ci(cmd_VCOPY) != 0)
                                                                                                                            {
                                                                                                                                a_15 = irr_parse_temp();
                                                                                                                                b_7 = irr_parse_temp();
                                                                                                                                c_3 = irr_parse_temp();
                                                                                                                                v289 = ir_emit(64L, 0L, a_15, b_7, c_3);
                                                                                                                            }
                                                                                                                            else
                                                                                                                            {
                                                                                                                                if (irr_word_eq_ci(cmd_VADD) != 0)
                                                                                                                                {
                                                                                                                                    cnt_3 = irr_parse_temp();
                                                                                                                                    d_22 = irr_parse_temp();
                                                                                                                                    s_2 = irr_parse_temp();
                                                                                                                                    sc = irr_parse_temp();
                                                                                                                                    v295 = ir_emit(65L, cnt_3, d_22, s_2, sc);
                                                                                                                                }
                                                                                                                                else
                                                                                                                                {
                                                                                                                                    if (irr_word_eq_ci(cmd_VSUB) != 0)
                                                                                                                                    {
                                                                                                                                        cnt_4 = irr_parse_temp();
                                                                                                                                        d_23 = irr_parse_temp();
                                                                                                                                        s_3 = irr_parse_temp();
                                                                                                                                        sc_2 = irr_parse_temp();
                                                                                                                                        v301 = ir_emit(66L, cnt_4, d_23, s_3, sc_2);
                                                                                                                                    }
                                                                                                                                    else
                                                                                                                                    {
                                                                                                                                        v303 = writef(cast(long)__s33237.ptr, irr_namebuf);
                                                                                                                                    }
                                                                                                                                }
                                                                                                                            }
                                                                                                                        }
                                                                                                                    }
                                                                                                                }
L6847:
                                                                                                            }
                                                                                                        }
                                                                                                    }
                                                                                                }
                                                                                            }
                                                                                        }
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
L6748:
L6718:
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return 0;
}
long irr_read_unit(long p1 = 0)
{
    long v0 = 0;
    long st = 0;
    long prev = 0;
    long ch = 0;
    long k = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long v5 = 0;
    long v6 = 0;
    long p = 0;
    long v7 = 0;
    long v8 = 0;
    long v9 = 0;
    long path = p1;
    st = findinput(path);
    prev = 0L;
    ch = 0L;
    k = 0L;
    if (st != 0) goto L6894; else goto L6893;
L6893:
    v2 = writef(cast(long)__s33252.ptr, path);
    return 0L;
L6894:
    prev = input();
    v4 = selectinput(st);
L6895:
    if (1L != 0)
    {
        ch = rdch();
        k = 0L;
        *cast(ubyte*)(irr_line + 0L) = cast(ubyte)0L;
L6898:
        if (ch == 10L) goto L6900; else goto L6901;
L6901:
        if (ch == -1L) goto L6900; else goto L6899;
L6899:
        if (k < (1024L - 1L))
        {
            k = (k + 1L);
            *cast(ubyte*)(irr_line + k) = cast(ubyte)ch;
        }
        ch = rdch();
    goto L6898;
L6900:
        *cast(ubyte*)(irr_line + 0L) = cast(ubyte)k;
        irr_pos = 1L;
        p = 1L;
L6904:
        if (p <= (k - 1L))
        {
            if (cast(long)*cast(ubyte*)(irr_line + p) == 59L) goto L6907; else goto L6909;
L6909:
            if (cast(long)*cast(ubyte*)(irr_line + p) == 47L) goto L6910; else goto L6908;
L6910:
            if (cast(long)*cast(ubyte*)(irr_line + (p + 1L)) == 47L) goto L6907; else goto L6908;
L6907:
            *cast(ubyte*)(irr_line + 0L) = cast(ubyte)(p - 1L);
    goto L6906;
L6908:
            p = (p + 1L);
    goto L6904;
        }
L6906:
        if (cast(long)*cast(ubyte*)(irr_line + 0L) > 0L)
        {
            v7 = irr_dispatch();
        }
        if (ch == -1L)
        {
    goto L6897;
        }
    goto L6895;
    }
L6897:
    v8 = endread();
    if (prev != 0)
    {
        v9 = selectinput(prev);
    }
    return 1L;
}
long irr_init_bufs()
{
    long v0 = 0;
    long v1 = 0;
    irr_line = getvec(((1024L / 8L) + 4L));
    irr_namebuf = getvec(((1024L / 8L) + 4L));
    irr_max_temp = 0L;
    irr_max_label = 0L;
    irr_temp_base = 0L;
    irr_label_base = 0L;
    irr_ndup = 0L;
    return 0;
}
long irr_load(long p1 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long path = p1;
    v0 = irr_init_bufs();
    v1 = ir_init();
    v2 = irr_read_unit(path);
    return 0;
}
long hm_streq(long p1 = 0, long p2 = 0)
{
    long i = 0;
    long a = p1;
    long b = p2;
    if (a == 0L)
    {
        return 0L;
    }
    if (b == 0L)
    {
        return 0L;
    }
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
long hm_check_dups()
{
    long p = 0;
    long i = 0;
    long nm = 0;
    long j = 0;
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    p = ir_arena;
    i = 1L;
    irr_ndup = 0L;
L6929:
    if (i >= ir_next) goto L6931; else goto L6930;
L6930:
    if (*cast(long*)(p + (i << 3L)) == 36L)
    {
        nm = *cast(long*)(p + ((i + 3L) << 3L));
        j = (i + 8L);
L6934:
        if (j >= ir_next) goto L6936; else goto L6935;
L6935:
        if (*cast(long*)(p + (j << 3L)) == 36L)
        {
            if (hm_streq(nm, *cast(long*)(p + ((j + 3L) << 3L))) != 0)
            {
                v2 = writef(cast(long)__s33429.ptr, nm);
                irr_ndup = (irr_ndup + 1L);
            }
        }
        j = (j + 8L);
    goto L6934;
L6936:
    }
    i = (i + 8L);
    goto L6929;
L6931:
    return 0;
}
long hm_merge(long p1 = 0, long p2 = 0)
{
    long ok = 0;
    long v0 = 0;
    long v1 = 0;
    long u = 0;
    long v2 = 0;
    long v3 = 0;
    long paths = p1;
    long n = p2;
    ok = 1L;
    v0 = irr_init_bufs();
    v1 = ir_init();
    u = 0L;
    while (u <= (n - 1L))
    {
        irr_temp_base = (ir_nextemp - 1L);
        irr_label_base = (ir_nextlabel - 1L);
        if (irr_read_unit(*cast(long*)(paths + (u << 3L))) != 0) goto L6946; else goto L6945;
L6945:
        ok = 0L;
L6946:
        u = (u + 1L);
    }
    irr_temp_base = 0L;
    irr_label_base = 0L;
    v3 = hm_check_dups();
    if (irr_ndup > 0L)
    {
        ok = 0L;
    }
    return ok;
}
