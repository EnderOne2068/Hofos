// Generated from BCPL by cg-d.b, split into modules by split.d.
module hofos.dce;

import hofos.all;

long opt_compose_level(long p1 = 0)
{
    long lvl = p1;
    opt_level = lvl;
    opt_nodce = 0L;
    if (lvl <= 0L)
    {
        opt_flags = 0L;
    }
    else
    {
        opt_flags = (((16L | 32L) | 128L) | 1024L);
        if (lvl >= 2L)
        {
            opt_flags = ((((((opt_flags | 64L) | 512L) | 256L) | 2048L) | 4096L) | 16384L);
        }
        if (lvl >= 3L)
        {
            opt_flags = ((opt_flags | 1L) | 8192L);
        }
        if (lvl >= 4L)
        {
            opt_flags = (opt_flags | 2L);
        }
    }
    return 0;
}
long opt_compose_profile(long p1 = 0)
{
    long code = p1;
    opt_nodce = 0L;
    if (code == 5L) goto L2738; else goto L2741;
L2741:
    if (code == 7L) goto L2739; else goto L2742;
L2742:
    if (code == 6L) goto L2740; else goto L2743;
L2743:
    goto L2737;
L2738:
    opt_level = 2L;
    opt_flags = (((16L | 32L) | 64L) | 2L);
    goto L2736;
L2739:
    opt_level = 2L;
    opt_flags = (((16L | 32L) | 64L) | 2L);
    goto L2736;
L2740:
    opt_level = 1L;
    opt_flags = (16L | 32L);
    goto L2736;
L2737:
    opt_level = 2L;
    opt_flags = ((16L | 32L) | 64L);
L2736:
    return 0;
}
long opt_streq(long p1 = 0, long p2 = 0)
{
    long n = 0;
    long i = 0;
    long a = p1;
    long b = p2;
    n = 0L;
    if (a == 0L) goto L2744; else goto L2746;
L2746:
    if (b == 0L) goto L2744; else goto L2745;
L2744:
    return 0L;
L2745:
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
long parse_opt_flag(long p1 = 0)
{
    long n = 0;
    long li = 0;
    long tok = p1;
    n = 0L;
    li = 0L;
    if (tok == 0L)
    {
        return (-1L);
    }
    n = cast(long)*cast(ubyte*)(tok + 0L);
    if (n < 3L)
    {
        return (-1L);
    }
    if (cast(long)*cast(ubyte*)(tok + 1L) == 45L)
    {
        if (cast(long)*cast(ubyte*)(tok + 2L) == 79L) goto L2760; else goto L2759;
    }
L2759:
    return (-1L);
L2760:
    if (n >= 5L)
    {
        if (cast(long)*cast(ubyte*)(tok + 3L) == 112L) goto L2765; else goto L2763;
L2765:
        if (cast(long)*cast(ubyte*)(tok + 4L) == 116L) goto L2762; else goto L2763;
L2762:
        li = 5L;
    goto L2764;
    }
L2763:
    li = 3L;
L2764:
    if (li > n)
    {
        return (-1L);
    }
    if (cast(long)*cast(ubyte*)(tok + li) >= 48L)
    {
        if (cast(long)*cast(ubyte*)(tok + li) <= 57L) goto L2769; else goto L2770;
L2769:
        return (cast(long)*cast(ubyte*)(tok + li) - 48L);
    }
L2770:
    if (cast(long)*cast(ubyte*)(tok + li) == 102L)
    {
        return 4L;
    }
    if (cast(long)*cast(ubyte*)(tok + li) == 115L)
    {
        return 5L;
    }
    if (cast(long)*cast(ubyte*)(tok + li) == 103L)
    {
        return 6L;
    }
    if (cast(long)*cast(ubyte*)(tok + li) == 122L)
    {
        return 7L;
    }
    return (-1L);
}
long apply_fflag(long p1 = 0)
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
    long tok = p1;
    if (tok == 0L)
    {
        return 0L;
    }
    if (opt_streq(tok, cast(long)__s11526.ptr) != 0) goto L2782; else goto L2784;
L2784:
    if (opt_streq(tok, cast(long)__s11529.ptr) != 0) goto L2782; else goto L2783;
L2782:
    opt_flags = (opt_flags | 1L);
    return 1L;
L2783:
    if (opt_streq(tok, cast(long)__s11536.ptr) != 0) goto L2785; else goto L2787;
L2787:
    if (opt_streq(tok, cast(long)__s11539.ptr) != 0) goto L2785; else goto L2786;
L2785:
    opt_flags = (opt_flags | 2L);
    return 1L;
L2786:
    if (opt_streq(tok, cast(long)__s11546.ptr) != 0) goto L2788; else goto L2790;
L2790:
    if (opt_streq(tok, cast(long)__s11549.ptr) != 0) goto L2788; else goto L2789;
L2788:
    opt_flags = (opt_flags | 4L);
    return 1L;
L2789:
    if (opt_streq(tok, cast(long)__s11556.ptr) != 0)
    {
        opt_flags = (opt_flags | 8L);
        return 1L;
    }
    if (opt_streq(tok, cast(long)__s11563.ptr) != 0) goto L2793; else goto L2795;
L2795:
    if (opt_streq(tok, cast(long)__s11566.ptr) != 0) goto L2793; else goto L2794;
L2793:
    opt_flags = (opt_flags | 16L);
    return 1L;
L2794:
    if (opt_streq(tok, cast(long)__s11573.ptr) != 0)
    {
        opt_flags = (opt_flags | 32L);
        return 1L;
    }
    if (opt_streq(tok, cast(long)__s11580.ptr) != 0)
    {
        opt_flags = (opt_flags | 64L);
        return 1L;
    }
    if (opt_streq(tok, cast(long)__s11587.ptr) != 0)
    {
        opt_flags = (opt_flags | 128L);
        return 1L;
    }
    if (opt_streq(tok, cast(long)__s11594.ptr) != 0)
    {
        opt_flags = (((((opt_flags | 256L) | 128L) | 16L) | 32L) | 64L);
        return 1L;
    }
    if (opt_streq(tok, cast(long)__s11609.ptr) != 0)
    {
        opt_flags = ((((opt_flags | 512L) | 128L) | 16L) | 32L);
        return 1L;
    }
    if (opt_streq(tok, cast(long)__s11622.ptr) != 0)
    {
        opt_flags = (opt_flags & (~512L));
        return 1L;
    }
    if (opt_streq(tok, cast(long)__s11630.ptr) != 0)
    {
        opt_flags = (opt_flags | 1024L);
        return 1L;
    }
    if (opt_streq(tok, cast(long)__s11637.ptr) != 0)
    {
        opt_flags = (opt_flags & (~1024L));
        return 1L;
    }
    if (opt_streq(tok, cast(long)__s11645.ptr) != 0)
    {
        opt_flags = (opt_flags | 32768L);
        return 1L;
    }
    if (opt_streq(tok, cast(long)__s11652.ptr) != 0)
    {
        nn_verbose = 1L;
        return 1L;
    }
    if (opt_streq(tok, cast(long)__s11657.ptr) != 0)
    {
        opt_flags = (opt_flags | 2048L);
        return 1L;
    }
    if (opt_streq(tok, cast(long)__s11664.ptr) != 0)
    {
        opt_flags = (opt_flags & (~2048L));
        return 1L;
    }
    if (opt_streq(tok, cast(long)__s11672.ptr) != 0)
    {
        opt_flags = (opt_flags | 16384L);
        return 1L;
    }
    if (opt_streq(tok, cast(long)__s11679.ptr) != 0)
    {
        opt_flags = (opt_flags & (~16384L));
        return 1L;
    }
    if (opt_streq(tok, cast(long)__s11687.ptr) != 0)
    {
        opt_flags = (opt_flags | 4096L);
        return 1L;
    }
    if (opt_streq(tok, cast(long)__s11694.ptr) != 0)
    {
        opt_flags = (opt_flags & (~4096L));
        return 1L;
    }
    if (opt_streq(tok, cast(long)__s11702.ptr) != 0) goto L2828; else goto L2830;
L2830:
    if (opt_streq(tok, cast(long)__s11705.ptr) != 0) goto L2828; else goto L2829;
L2828:
    opt_flags = (opt_flags | 8192L);
    return 1L;
L2829:
    if (opt_streq(tok, cast(long)__s11712.ptr) != 0)
    {
        opt_flags = (opt_flags & (~8192L));
        return 1L;
    }
    if (opt_streq(tok, cast(long)__s11720.ptr) != 0)
    {
        cg_shared = 1L;
        return 1L;
    }
    if (opt_streq(tok, cast(long)__s11725.ptr) != 0)
    {
        v60 = 1L;
        return 1L;
    }
    if (opt_streq(tok, cast(long)__s11730.ptr) != 0)
    {
        v63 = 0L;
        return 1L;
    }
    if (opt_streq(tok, cast(long)__s11735.ptr) != 0)
    {
        opt_prof_use = 1L;
        return 1L;
    }
    if (opt_streq(tok, cast(long)__s11740.ptr) != 0)
    {
        __mode = 1L;
        return 1L;
    }
    if (opt_streq(tok, cast(long)__s11745.ptr) != 0)
    {
        __mode = 2L;
        return 1L;
    }
    if (opt_streq(tok, cast(long)__s11750.ptr) != 0)
    {
        __mode = 3L;
        return 1L;
    }
    if (opt_streq(tok, cast(long)__s11755.ptr) != 0)
    {
        __mode = 5L;
        return 1L;
    }
    if (opt_streq(tok, cast(long)__s11760.ptr) != 0)
    {
        __mode = 7L;
        return 1L;
    }
    if (opt_streq(tok, cast(long)__s11765.ptr) != 0) goto L2851; else goto L2853;
L2853:
    if (opt_streq(tok, cast(long)__s11768.ptr) != 0) goto L2851; else goto L2852;
L2851:
    __mode = 6L;
    return 1L;
L2852:
    if (opt_streq(tok, cast(long)__s11773.ptr) != 0) goto L2854; else goto L2857;
L2857:
    if (opt_streq(tok, cast(long)__s11776.ptr) != 0) goto L2854; else goto L2856;
L2856:
    if (opt_streq(tok, cast(long)__s11779.ptr) != 0) goto L2854; else goto L2855;
L2854:
    cg_elf_be = 1L;
    return 1L;
L2855:
    if (opt_streq(tok, cast(long)__s11784.ptr) != 0) goto L2858; else goto L2860;
L2860:
    if (opt_streq(tok, cast(long)__s11787.ptr) != 0) goto L2858; else goto L2859;
L2858:
    opt_flags = (opt_flags & (~1L));
    return 1L;
L2859:
    if (opt_streq(tok, cast(long)__s11795.ptr) != 0) goto L2861; else goto L2863;
L2863:
    if (opt_streq(tok, cast(long)__s11798.ptr) != 0) goto L2861; else goto L2862;
L2861:
    opt_flags = (opt_flags & (~2L));
    return 1L;
L2862:
    if (opt_streq(tok, cast(long)__s11806.ptr) != 0)
    {
        opt_flags = (opt_flags & (~4L));
        return 1L;
    }
    if (opt_streq(tok, cast(long)__s11814.ptr) != 0)
    {
        opt_flags = (opt_flags & (~8L));
        return 1L;
    }
    if (opt_streq(tok, cast(long)__s11822.ptr) != 0) goto L2868; else goto L2870;
L2870:
    if (opt_streq(tok, cast(long)__s11825.ptr) != 0) goto L2868; else goto L2869;
L2868:
    opt_flags = (opt_flags & (~16L));
    return 1L;
L2869:
    if (opt_streq(tok, cast(long)__s11833.ptr) != 0)
    {
        opt_flags = (opt_flags & (~32L));
        return 1L;
    }
    if (opt_streq(tok, cast(long)__s11841.ptr) != 0)
    {
        opt_flags = (opt_flags & (~64L));
        return 1L;
    }
    if (opt_streq(tok, cast(long)__s11849.ptr) != 0)
    {
        opt_flags = (opt_flags & (~128L));
        return 1L;
    }
    if (opt_streq(tok, cast(long)__s11857.ptr) != 0)
    {
        opt_prof_use = 0L;
        return 1L;
    }
    return 0L;
}
long opt_parse_args(long p1 = 0, long p2 = 0)
{
    long orig = 0;
    long w = 0;
    long r = 0;
    long v0 = 0;
    long code = 0;
    long v1 = 0;
    long v2 = 0;
    long w_2 = 0;
    long m = 0;
    long r_2 = 0;
    long v3 = 0;
    long i = 0;
    long argv = p1;
    long n = p2;
    orig = n;
    w = 0L;
    r = 0L;
    while (r <= (orig - 1L))
    {
        code = parse_opt_flag(*cast(long*)(argv + (r << 3L)));
        if (code >= 0L)
        {
            if (code <= 4L)
            {
                v1 = opt_compose_level(code);
            }
            else
            {
                v2 = opt_compose_profile(code);
            }
        }
        else
        {
            *cast(long*)(argv + (w << 3L)) = *cast(long*)(argv + (r << 3L));
            w = (w + 1L);
        }
        r = (r + 1L);
    }
    n = w;
    w_2 = 0L;
    m = n;
    r_2 = 0L;
    while (r_2 <= (m - 1L))
    {
        if (apply_fflag(*cast(long*)(argv + (r_2 << 3L))) != 0) goto L2894; else goto L2893;
L2893:
        *cast(long*)(argv + (w_2 << 3L)) = *cast(long*)(argv + (r_2 << 3L));
        w_2 = (w_2 + 1L);
L2894:
        r_2 = (r_2 + 1L);
    }
    n = w_2;
    i = n;
L2895:
    if (i >= orig) goto L2897; else goto L2896;
L2896:
    *cast(long*)(argv + (i << 3L)) = 0L;
    i = (i + 1L);
    goto L2895;
L2897:
    return n;
}
long dce_pure_op(long p1 = 0)
{
    long op = p1;
    if (op == 1L) goto L2900; else goto L2941;
L2941:
    if (op == 38L) goto L2901; else goto L2942;
L2942:
    if (op == 39L) goto L2902; else goto L2943;
L2943:
    if (op == 4L) goto L2903; else goto L2944;
L2944:
    if (op == 5L) goto L2904; else goto L2945;
L2945:
    if (op == 6L) goto L2905; else goto L2946;
L2946:
    if (op == 7L) goto L2906; else goto L2947;
L2947:
    if (op == 8L) goto L2907; else goto L2948;
L2948:
    if (op == 9L) goto L2908; else goto L2949;
L2949:
    if (op == 10L) goto L2909; else goto L2950;
L2950:
    if (op == 11L) goto L2910; else goto L2951;
L2951:
    if (op == 12L) goto L2911; else goto L2952;
L2952:
    if (op == 26L) goto L2912; else goto L2953;
L2953:
    if (op == 13L) goto L2913; else goto L2954;
L2954:
    if (op == 14L) goto L2914; else goto L2955;
L2955:
    if (op == 20L) goto L2915; else goto L2956;
L2956:
    if (op == 21L) goto L2916; else goto L2957;
L2957:
    if (op == 22L) goto L2917; else goto L2958;
L2958:
    if (op == 23L) goto L2918; else goto L2959;
L2959:
    if (op == 24L) goto L2919; else goto L2960;
L2960:
    if (op == 25L) goto L2920; else goto L2961;
L2961:
    if (op == 51L) goto L2921; else goto L2962;
L2962:
    if (op == 52L) goto L2922; else goto L2963;
L2963:
    if (op == 53L) goto L2923; else goto L2964;
L2964:
    if (op == 54L) goto L2924; else goto L2965;
L2965:
    if (op == 55L) goto L2925; else goto L2966;
L2966:
    if (op == 56L) goto L2926; else goto L2967;
L2967:
    if (op == 57L) goto L2927; else goto L2968;
L2968:
    if (op == 58L) goto L2928; else goto L2969;
L2969:
    if (op == 59L) goto L2929; else goto L2970;
L2970:
    if (op == 60L) goto L2930; else goto L2971;
L2971:
    if (op == 61L) goto L2931; else goto L2972;
L2972:
    if (op == 62L) goto L2932; else goto L2973;
L2973:
    if (op == 2L) goto L2933; else goto L2974;
L2974:
    if (op == 43L) goto L2934; else goto L2975;
L2975:
    if (op == 68L) goto L2935; else goto L2976;
L2976:
    if (op == 70L) goto L2936; else goto L2977;
L2977:
    if (op == 45L) goto L2937; else goto L2978;
L2978:
    if (op == 40L) goto L2938; else goto L2979;
L2979:
    if (op == 49L) goto L2939; else goto L2980;
L2980:
    if (op == 50L) goto L2940; else goto L2981;
L2981:
    goto L2899;
L2900:
    return 1L;
L2901:
    return 1L;
L2902:
    return 1L;
L2903:
    return 1L;
L2904:
    return 1L;
L2905:
    return 1L;
L2906:
    return 1L;
L2907:
    return 1L;
L2908:
    return 1L;
L2909:
    return 1L;
L2910:
    return 1L;
L2911:
    return 1L;
L2912:
    return 1L;
L2913:
    return 1L;
L2914:
    return 1L;
L2915:
    return 1L;
L2916:
    return 1L;
L2917:
    return 1L;
L2918:
    return 1L;
L2919:
    return 1L;
L2920:
    return 1L;
L2921:
    return 1L;
L2922:
    return 1L;
L2923:
    return 1L;
L2924:
    return 1L;
L2925:
    return 1L;
L2926:
    return 1L;
L2927:
    return 1L;
L2928:
    return 1L;
L2929:
    return 1L;
L2930:
    return 1L;
L2931:
    return 1L;
L2932:
    return 1L;
L2933:
    return 1L;
L2934:
    return 1L;
L2935:
    return 1L;
L2936:
    return 1L;
L2937:
    return 1L;
L2938:
    return 1L;
L2939:
    return 1L;
L2940:
    return 1L;
L2899:
    return 0L;
L2898:
    return 0;
}
long dce_mark_uses(long p1 = 0, long p2 = 0, long p3 = 0)
{
    long op = 0;
    long a1 = 0;
    long a2 = 0;
    long a3 = 0;
    long l1 = 0;
    long l2 = 0;
    long cnt = 0;
    long cnt_2 = 0;
    long used = p1;
    long p = p2;
    long i = p3;
    op = *cast(long*)(p + (i << 3L));
    a1 = *cast(long*)(p + ((i + 2L) << 3L));
    a2 = *cast(long*)(p + ((i + 3L) << 3L));
    a3 = *cast(long*)(p + ((i + 4L) << 3L));
    l1 = *cast(long*)(p + ((i + 5L) << 3L));
    l2 = *cast(long*)(p + ((i + 6L) << 3L));
    if (op == 4L) goto L2984; else goto L3033;
L3033:
    if (op == 5L) goto L2985; else goto L3034;
L3034:
    if (op == 6L) goto L2986; else goto L3035;
L3035:
    if (op == 7L) goto L2987; else goto L3036;
L3036:
    if (op == 8L) goto L2988; else goto L3037;
L3037:
    if (op == 9L) goto L2989; else goto L3038;
L3038:
    if (op == 10L) goto L2990; else goto L3039;
L3039:
    if (op == 11L) goto L2991; else goto L3040;
L3040:
    if (op == 13L) goto L2992; else goto L3041;
L3041:
    if (op == 14L) goto L2993; else goto L3042;
L3042:
    if (op == 20L) goto L2994; else goto L3043;
L3043:
    if (op == 21L) goto L2995; else goto L3044;
L3044:
    if (op == 22L) goto L2996; else goto L3045;
L3045:
    if (op == 23L) goto L2997; else goto L3046;
L3046:
    if (op == 24L) goto L2998; else goto L3047;
L3047:
    if (op == 25L) goto L2999; else goto L3048;
L3048:
    if (op == 51L) goto L3000; else goto L3049;
L3049:
    if (op == 52L) goto L3001; else goto L3050;
L3050:
    if (op == 53L) goto L3002; else goto L3051;
L3051:
    if (op == 54L) goto L3003; else goto L3052;
L3052:
    if (op == 55L) goto L3004; else goto L3053;
L3053:
    if (op == 56L) goto L3005; else goto L3054;
L3054:
    if (op == 57L) goto L3006; else goto L3055;
L3055:
    if (op == 58L) goto L3007; else goto L3056;
L3056:
    if (op == 59L) goto L3008; else goto L3057;
L3057:
    if (op == 60L) goto L3009; else goto L3058;
L3058:
    if (op == 26L) goto L3010; else goto L3059;
L3059:
    if (op == 12L) goto L3011; else goto L3060;
L3060:
    if (op == 39L) goto L3012; else goto L3061;
L3061:
    if (op == 2L) goto L3013; else goto L3062;
L3062:
    if (op == 43L) goto L3014; else goto L3063;
L3063:
    if (op == 68L) goto L3015; else goto L3064;
L3064:
    if (op == 70L) goto L3016; else goto L3065;
L3065:
    if (op == 61L) goto L3017; else goto L3066;
L3066:
    if (op == 62L) goto L3018; else goto L3067;
L3067:
    if (op == 31L) goto L3019; else goto L3068;
L3068:
    if (op == 34L) goto L3020; else goto L3069;
L3069:
    if (op == 45L) goto L3021; else goto L3070;
L3070:
    if (op == 3L) goto L3022; else goto L3071;
L3071:
    if (op == 44L) goto L3023; else goto L3072;
L3072:
    if (op == 69L) goto L3024; else goto L3073;
L3073:
    if (op == 71L) goto L3025; else goto L3074;
L3074:
    if (op == 63L) goto L3026; else goto L3075;
L3075:
    if (op == 64L) goto L3027; else goto L3076;
L3076:
    if (op == 65L) goto L3028; else goto L3077;
L3077:
    if (op == 66L) goto L3029; else goto L3078;
L3078:
    if (op == 41L) goto L3030; else goto L3079;
L3079:
    if (op == 33L) goto L3031; else goto L3080;
L3080:
    if (op == 47L) goto L3032; else goto L3081;
L3081:
    goto L2983;
L2984:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    if (a2 > 0L)
    {
        *cast(long*)(used + (a2 << 3L)) = 1L;
    }
    goto L2982;
L2985:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    if (a2 > 0L)
    {
        *cast(long*)(used + (a2 << 3L)) = 1L;
    }
    goto L2982;
L2986:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    if (a2 > 0L)
    {
        *cast(long*)(used + (a2 << 3L)) = 1L;
    }
    goto L2982;
L2987:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    if (a2 > 0L)
    {
        *cast(long*)(used + (a2 << 3L)) = 1L;
    }
    goto L2982;
L2988:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    if (a2 > 0L)
    {
        *cast(long*)(used + (a2 << 3L)) = 1L;
    }
    goto L2982;
L2989:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    if (a2 > 0L)
    {
        *cast(long*)(used + (a2 << 3L)) = 1L;
    }
    goto L2982;
L2990:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    if (a2 > 0L)
    {
        *cast(long*)(used + (a2 << 3L)) = 1L;
    }
    goto L2982;
L2991:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    if (a2 > 0L)
    {
        *cast(long*)(used + (a2 << 3L)) = 1L;
    }
    goto L2982;
L2992:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    if (a2 > 0L)
    {
        *cast(long*)(used + (a2 << 3L)) = 1L;
    }
    goto L2982;
L2993:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    if (a2 > 0L)
    {
        *cast(long*)(used + (a2 << 3L)) = 1L;
    }
    goto L2982;
L2994:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    if (a2 > 0L)
    {
        *cast(long*)(used + (a2 << 3L)) = 1L;
    }
    goto L2982;
L2995:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    if (a2 > 0L)
    {
        *cast(long*)(used + (a2 << 3L)) = 1L;
    }
    goto L2982;
L2996:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    if (a2 > 0L)
    {
        *cast(long*)(used + (a2 << 3L)) = 1L;
    }
    goto L2982;
L2997:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    if (a2 > 0L)
    {
        *cast(long*)(used + (a2 << 3L)) = 1L;
    }
    goto L2982;
L2998:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    if (a2 > 0L)
    {
        *cast(long*)(used + (a2 << 3L)) = 1L;
    }
    goto L2982;
L2999:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    if (a2 > 0L)
    {
        *cast(long*)(used + (a2 << 3L)) = 1L;
    }
    goto L2982;
L3000:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    if (a2 > 0L)
    {
        *cast(long*)(used + (a2 << 3L)) = 1L;
    }
    goto L2982;
L3001:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    if (a2 > 0L)
    {
        *cast(long*)(used + (a2 << 3L)) = 1L;
    }
    goto L2982;
L3002:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    if (a2 > 0L)
    {
        *cast(long*)(used + (a2 << 3L)) = 1L;
    }
    goto L2982;
L3003:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    if (a2 > 0L)
    {
        *cast(long*)(used + (a2 << 3L)) = 1L;
    }
    goto L2982;
L3004:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    if (a2 > 0L)
    {
        *cast(long*)(used + (a2 << 3L)) = 1L;
    }
    goto L2982;
L3005:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    if (a2 > 0L)
    {
        *cast(long*)(used + (a2 << 3L)) = 1L;
    }
    goto L2982;
L3006:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    if (a2 > 0L)
    {
        *cast(long*)(used + (a2 << 3L)) = 1L;
    }
    goto L2982;
L3007:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    if (a2 > 0L)
    {
        *cast(long*)(used + (a2 << 3L)) = 1L;
    }
    goto L2982;
L3008:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    if (a2 > 0L)
    {
        *cast(long*)(used + (a2 << 3L)) = 1L;
    }
    goto L2982;
L3009:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    if (a2 > 0L)
    {
        *cast(long*)(used + (a2 << 3L)) = 1L;
    }
    goto L2982;
L3010:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    goto L2982;
L3011:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    goto L2982;
L3012:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    goto L2982;
L3013:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    goto L2982;
L3014:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    goto L2982;
L3015:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    goto L2982;
L3016:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    goto L2982;
L3017:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    goto L2982;
L3018:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    goto L2982;
L3019:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    goto L2982;
L3020:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    goto L2982;
L3021:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    goto L2982;
L3022:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    if (a2 > 0L)
    {
        *cast(long*)(used + (a2 << 3L)) = 1L;
    }
    goto L2982;
L3023:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    if (a2 > 0L)
    {
        *cast(long*)(used + (a2 << 3L)) = 1L;
    }
    goto L2982;
L3024:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    if (a2 > 0L)
    {
        *cast(long*)(used + (a2 << 3L)) = 1L;
    }
    goto L2982;
L3025:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    if (a2 > 0L)
    {
        *cast(long*)(used + (a2 << 3L)) = 1L;
    }
    goto L2982;
L3026:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    if (a2 > 0L)
    {
        *cast(long*)(used + (a2 << 3L)) = 1L;
    }
    if (a3 > 0L)
    {
        *cast(long*)(used + (a3 << 3L)) = 1L;
    }
    goto L2982;
L3027:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    if (a2 > 0L)
    {
        *cast(long*)(used + (a2 << 3L)) = 1L;
    }
    if (a3 > 0L)
    {
        *cast(long*)(used + (a3 << 3L)) = 1L;
    }
    goto L2982;
L3028:
    cnt = *cast(long*)(p + ((i + 1L) << 3L));
    if (cnt > 0L)
    {
        *cast(long*)(used + (cnt << 3L)) = 1L;
    }
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    if (a2 > 0L)
    {
        *cast(long*)(used + (a2 << 3L)) = 1L;
    }
    if (a3 > 0L)
    {
        *cast(long*)(used + (a3 << 3L)) = 1L;
    }
    goto L2982;
L3029:
    cnt_2 = *cast(long*)(p + ((i + 1L) << 3L));
    if (cnt_2 > 0L)
    {
        *cast(long*)(used + (cnt_2 << 3L)) = 1L;
    }
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    if (a2 > 0L)
    {
        *cast(long*)(used + (a2 << 3L)) = 1L;
    }
    if (a3 > 0L)
    {
        *cast(long*)(used + (a3 << 3L)) = 1L;
    }
    goto L2982;
L3030:
    if (a2 > 0L)
    {
        *cast(long*)(used + (a2 << 3L)) = 1L;
    }
    goto L2982;
L3031:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    if (a3 > 0L)
    {
        *cast(long*)(used + (a3 << 3L)) = 1L;
    }
    if (l1 > 0L)
    {
        *cast(long*)(used + (l1 << 3L)) = 1L;
    }
    if (l2 > 0L)
    {
        *cast(long*)(used + (l2 << 3L)) = 1L;
    }
    goto L2982;
L3032:
    if (a1 > 0L)
    {
        *cast(long*)(used + (a1 << 3L)) = 1L;
    }
    goto L2982;
L2983:
L2982:
    return 0;
}
long dce_wf_at(long p1 = 0, long p2 = 0, long p3 = 0)
{
    long k = 0;
    long fstart = p1;
    long nfunc = p2;
    long pos = p3;
    k = 0L;
    while (k <= (nfunc - 1L))
    {
        if (*cast(long*)(fstart + (k << 3L)) == pos)
        {
            return k;
        }
        k = (k + 1L);
    }
    return (-1L);
}
long dce_wf_find(long p1 = 0, long p2 = 0, long p3 = 0)
{
    long k = 0;
    long v0 = 0;
    long fname = p1;
    long nfunc = p2;
    long nm = p3;
    k = 0L;
    while (k <= (nfunc - 1L))
    {
        if (sym_streq(*cast(long*)(fname + (k << 3L)), nm) != 0)
        {
            return k;
        }
        k = (k + 1L);
    }
    return (-1L);
}
long dce_whole_functions()
{
    long p = 0;
    long v0 = 0;
    long fname = 0;
    long v1 = 0;
    long fstart = 0;
    long v2 = 0;
    long fend = 0;
    long v3 = 0;
    long freach = 0;
    long v4 = 0;
    long work = 0;
    long nwork = 0;
    long nfunc = 0;
    long removed = 0;
    long i = 0;
    long j = 0;
    long k = 0;
    long v5 = 0;
    long v6 = 0;
    long v7 = 0;
    long v8 = 0;
    long wp = 0;
    long k_2 = 0;
    long a = 0;
    long nm = 0;
    long v9 = 0;
    long fi = 0;
    long w = 0;
    long r = 0;
    long v10 = 0;
    long v11 = 0;
    long k_3 = 0;
    long e = 0;
    long q = 0;
    long q_2 = 0;
    long qe = 0;
    long v12 = 0;
    long v13 = 0;
    p = ir_arena;
    fname = getvec(2048L);
    fstart = getvec(2048L);
    fend = getvec(2048L);
    freach = getvec(2048L);
    work = getvec(2048L);
    nwork = 0L;
    nfunc = 0L;
    removed = 0L;
    i = 1L;
L3278:
    if (i >= ir_next) goto L3280; else goto L3279;
L3279:
    if (*cast(long*)(p + (i << 3L)) == 36L)
    {
        j = i;
L3284:
        if (j >= ir_next) goto L3286; else goto L3287;
L3287:
        if (*cast(long*)(p + (j << 3L)) == 37L) goto L3286; else goto L3285;
L3285:
        j = (j + 8L);
    goto L3284;
L3286:
        if (j < ir_next)
        {
            j = (j + 8L);
        }
        if (nfunc < 2040L)
        {
            *cast(long*)(fname + (nfunc << 3L)) = *cast(long*)(p + ((i + 3L) << 3L));
            *cast(long*)(fstart + (nfunc << 3L)) = i;
            *cast(long*)(fend + (nfunc << 3L)) = j;
            *cast(long*)(freach + (nfunc << 3L)) = 0L;
            nfunc = (nfunc + 1L);
        }
        i = j;
    }
    else
    {
        i = (i + 8L);
    }
    goto L3278;
L3280:
    k = 0L;
    while (k <= (nfunc - 1L))
    {
        if (sym_streq(*cast(long*)(fname + (k << 3L)), cast(long)__s12888.ptr) != 0) goto L3296; else goto L3298;
L3298:
        if (sym_streq(*cast(long*)(fname + (k << 3L)), cast(long)__s12895.ptr) != 0) goto L3296; else goto L3297;
L3296:
        if (*cast(long*)(freach + (k << 3L)) != 0) goto L3300; else goto L3299;
L3299:
        *cast(long*)(freach + (k << 3L)) = 1L;
        *cast(long*)(work + (nwork << 3L)) = k;
        nwork = (nwork + 1L);
L3300:
L3297:
        k = (k + 1L);
    }
    wp = 0L;
L3301:
    if (wp >= nwork) goto L3303; else goto L3302;
L3302:
    k_2 = *cast(long*)(work + (wp << 3L));
    a = *cast(long*)(fstart + (k_2 << 3L));
    wp = (wp + 1L);
L3304:
    if (a >= *cast(long*)(fend + (k_2 << 3L))) goto L3306; else goto L3305;
L3305:
    nm = 0L;
    if (*cast(long*)(p + (a << 3L)) == 1L)
    {
        if (*cast(long*)(p + ((a + 3L) << 3L)) == 1L) goto L3307; else goto L3308;
L3307:
        nm = *cast(long*)(p + ((a + 2L) << 3L));
    }
L3308:
    if (*cast(long*)(p + (a << 3L)) == 50L)
    {
        nm = *cast(long*)(p + ((a + 3L) << 3L));
    }
    if (nm == 0L) goto L3313; else goto L3312;
L3312:
    fi = dce_wf_find(fname, nfunc, nm);
    if (fi >= 0L)
    {
        if (*cast(long*)(freach + (fi << 3L)) != 0) goto L3317; else goto L3316;
L3316:
        *cast(long*)(freach + (fi << 3L)) = 1L;
        *cast(long*)(work + (nwork << 3L)) = fi;
        nwork = (nwork + 1L);
L3317:
    }
L3313:
    a = (a + 8L);
    goto L3304;
L3306:
    goto L3301;
L3303:
    w = 1L;
    r = 1L;
L3318:
    if (r >= ir_next) goto L3320; else goto L3319;
L3319:
    if (*cast(long*)(p + (r << 3L)) == 36L)
    {
        v11 = dce_wf_at(fstart, nfunc, r);
    }
    else
    {
        v11 = (-1L);
    }
    k_3 = v11;
    if (k_3 >= 0L)
    {
        e = *cast(long*)(fend + (k_3 << 3L));
        if (*cast(long*)(freach + (k_3 << 3L)) != 0)
        {
            q = r;
L3330:
            if (q >= e) goto L3332; else goto L3331;
L3331:
            *cast(long*)(p + (w << 3L)) = *cast(long*)(p + (q << 3L));
            w = (w + 1L);
            q = (q + 1L);
    goto L3330;
L3332:
        }
        else
        {
            removed = (removed + 1L);
        }
        r = e;
    }
    else
    {
        q_2 = r;
        qe = (r + 8L);
L3333:
        if (q_2 >= qe) goto L3335; else goto L3334;
L3334:
        *cast(long*)(p + (w << 3L)) = *cast(long*)(p + (q_2 << 3L));
        w = (w + 1L);
        q_2 = (q_2 + 1L);
    goto L3333;
L3335:
        r = (r + 8L);
    }
    goto L3318;
L3320:
    ir_next = w;
    // Silent on success; opt_verbose gates every optimiser note (see dce.b).
    if (removed > 0L && opt_verbose != 0)
    {
        v13 = writef(cast(long)__s13052.ptr, removed);
    }
    return 0;
}
long dce_ipcp()
{
    long p = 0;
    long v0 = 0;
    long defidx = 0;
    long v1 = 0;
    long defcnt = 0;
    long v2 = 0;
    long fname = 0;
    long v3 = 0;
    long fstart = 0;
    long v4 = 0;
    long fend = 0;
    long v5 = 0;
    long ftaken = 0;
    long v6 = 0;
    long ppos = 0;
    long nfunc = 0;
    long nspec = 0;
    long t = 0;
    long i = 0;
    long dst = 0;
    long i_2 = 0;
    long j = 0;
    long i_3 = 0;
    long nm = 0;
    long k = 0;
    long v7 = 0;
    long k_2 = 0;
    long s = 0;
    long e = 0;
    long nparam = 0;
    long aptaken = 0;
    long z = 0;
    long a = 0;
    long idx = 0;
    long a_2 = 0;
    long tt = 0;
    long z_2 = 0;
    long pi = 0;
    long firstv = 0;
    long havev = 0;
    long ok = 0;
    long nsites = 0;
    long a_3 = 0;
    long callee = 0;
    long v8 = 0;
    long cnm = 0;
    long v9 = 0;
    long v10 = 0;
    long v11 = 0;
    long argt = 0;
    long v = 0;
    long pd = 0;
    long v12 = 0;
    long v13 = 0;
    p = ir_arena;
    defidx = getvec((ir_nextemp + 8L));
    defcnt = getvec((ir_nextemp + 8L));
    fname = getvec(2048L);
    fstart = getvec(2048L);
    fend = getvec(2048L);
    ftaken = getvec(2048L);
    ppos = getvec(8L);
    nfunc = 0L;
    nspec = 0L;
    t = 0L;
    while (t <= (ir_nextemp + 4L))
    {
        *cast(long*)(defidx + (t << 3L)) = 0L;
        *cast(long*)(defcnt + (t << 3L)) = 0L;
        t = (t + 1L);
    }
    i = 1L;
L3342:
    if (i >= ir_next) goto L3344; else goto L3343;
L3343:
    dst = *cast(long*)(p + ((i + 1L) << 3L));
    if (dst > 0L)
    {
        if (*cast(long*)(p + (i << 3L)) != 32L) goto L3348; else goto L3346;
L3348:
        if (*cast(long*)(p + (i << 3L)) != 31L) goto L3347; else goto L3346;
L3347:
        if (*cast(long*)(p + (i << 3L)) != 30L) goto L3345; else goto L3346;
L3345:
        *cast(long*)(defidx + (dst << 3L)) = i;
        *cast(long*)(defcnt + (dst << 3L)) = (*cast(long*)(defcnt + (dst << 3L)) + 1L);
    }
L3346:
    i = (i + 8L);
    goto L3342;
L3344:
    i_2 = 1L;
L3350:
    if (i_2 >= ir_next) goto L3352; else goto L3351;
L3351:
    if (*cast(long*)(p + (i_2 << 3L)) == 36L)
    {
        j = i_2;
L3356:
        if (j >= ir_next) goto L3358; else goto L3359;
L3359:
        if (*cast(long*)(p + (j << 3L)) == 37L) goto L3358; else goto L3357;
L3357:
        j = (j + 8L);
    goto L3356;
L3358:
        if (j < ir_next)
        {
            j = (j + 8L);
        }
        if (nfunc < 2040L)
        {
            *cast(long*)(fname + (nfunc << 3L)) = *cast(long*)(p + ((i_2 + 3L) << 3L));
            *cast(long*)(fstart + (nfunc << 3L)) = i_2;
            *cast(long*)(fend + (nfunc << 3L)) = j;
            *cast(long*)(ftaken + (nfunc << 3L)) = 0L;
            nfunc = (nfunc + 1L);
        }
        i_2 = j;
    }
    else
    {
        i_2 = (i_2 + 8L);
    }
    goto L3350;
L3352:
    i_3 = 1L;
L3364:
    if (i_3 >= ir_next) goto L3366; else goto L3365;
L3365:
    if (*cast(long*)(p + (i_3 << 3L)) == 50L)
    {
        nm = *cast(long*)(p + ((i_3 + 3L) << 3L));
        k = 0L;
        while (k <= (nfunc - 1L))
        {
            if (sym_streq(*cast(long*)(fname + (k << 3L)), nm) != 0)
            {
                *cast(long*)(ftaken + (k << 3L)) = 1L;
            }
            k = (k + 1L);
        }
    }
    i_3 = (i_3 + 8L);
    goto L3364;
L3366:
    k_2 = 0L;
    while (k_2 <= (nfunc - 1L))
    {
        if (*cast(long*)(ftaken + (k_2 << 3L)) != 0) goto L3380; else goto L3379;
L3379:
        s = *cast(long*)(fstart + (k_2 << 3L));
        e = *cast(long*)(fend + (k_2 << 3L));
        nparam = 0L;
        aptaken = 0L;
        z = 0L;
        while (z <= 4L)
        {
            *cast(long*)(ppos + (z << 3L)) = 0L;
            z = (z + 1L);
        }
        a = s;
L3385:
        if (a >= e) goto L3387; else goto L3386;
L3386:
        if (*cast(long*)(p + (a << 3L)) == 35L)
        {
            idx = *cast(long*)(p + ((a + 2L) << 3L));
            if (idx >= 1L)
            {
                if (idx <= 3L) goto L3390; else goto L3391;
L3390:
                *cast(long*)(ppos + (idx << 3L)) = a;
                if (idx > nparam)
                {
                    nparam = idx;
                }
            }
L3391:
        }
        a = (a + 8L);
    goto L3385;
L3387:
        a_2 = s;
L3395:
        if (a_2 >= e) goto L3397; else goto L3396;
L3396:
        if (*cast(long*)(p + (a_2 << 3L)) == 45L)
        {
            tt = *cast(long*)(p + ((a_2 + 2L) << 3L));
            z_2 = 1L;
            while (z_2 <= 3L)
            {
                if (*cast(long*)(ppos + (z_2 << 3L)) != 0L)
                {
                    if (*cast(long*)(p + ((*cast(long*)(ppos + (z_2 << 3L)) + 1L) << 3L)) == tt) goto L3404; else goto L3405;
L3404:
                    aptaken = 1L;
                }
L3405:
                z_2 = (z_2 + 1L);
            }
        }
        a_2 = (a_2 + 8L);
    goto L3395;
L3397:
        if (aptaken != 0) goto L3408; else goto L3407;
L3407:
        pi = 1L;
        while (pi <= nparam)
        {
            if (*cast(long*)(ppos + (pi << 3L)) != 0L)
            {
                firstv = 0L;
                havev = 0L;
                ok = 1L;
                nsites = 0L;
                a_3 = 1L;
L3415:
                if (a_3 >= ir_next) goto L3417; else goto L3416;
L3416:
                if (*cast(long*)(p + (a_3 << 3L)) == 33L)
                {
                    callee = *cast(long*)(p + ((a_3 + 2L) << 3L));
                    if (*cast(long*)(defcnt + (callee << 3L)) == 1L)
                    {
                        if (*cast(long*)(p + (*cast(long*)(defidx + (callee << 3L)) << 3L)) == 1L) goto L3423; else goto L3421;
L3423:
                        if (*cast(long*)(p + ((*cast(long*)(defidx + (callee << 3L)) + 3L) << 3L)) == 1L) goto L3420; else goto L3421;
L3420:
                        v8 = *cast(long*)(p + ((*cast(long*)(defidx + (callee << 3L)) + 2L) << 3L));
    goto L3422;
                    }
L3421:
                    v8 = 0L;
L3422:
                    cnm = v8;
                    if (cnm != 0L)
                    {
                        if (sym_streq(cnm, *cast(long*)(fname + (k_2 << 3L))) != 0) goto L3425; else goto L3426;
L3425:
                        if (pi == 1L)
                        {
                            v10 = *cast(long*)(p + ((a_3 + 4L) << 3L));
                        }
                        else
                        {
                            if (pi == 2L)
                            {
                                v11 = *cast(long*)(p + ((a_3 + 5L) << 3L));
                            }
                            else
                            {
                                v11 = *cast(long*)(p + ((a_3 + 6L) << 3L));
                            }
                            v10 = v11;
                        }
                        argt = v10;
                        if (*cast(long*)(defcnt + (argt << 3L)) == 1L)
                        {
                            if (*cast(long*)(p + (*cast(long*)(defidx + (argt << 3L)) << 3L)) == 1L) goto L3437; else goto L3435;
L3437:
                            if (*cast(long*)(p + ((*cast(long*)(defidx + (argt << 3L)) + 3L) << 3L)) == 0L) goto L3434; else goto L3435;
L3434:
                            v = *cast(long*)(p + ((*cast(long*)(defidx + (argt << 3L)) + 2L) << 3L));
                            nsites = (nsites + 1L);
                            if (havev != 0)
                            {
                                if (v == firstv) goto L3443; else goto L3442;
L3442:
                                ok = 0L;
L3443:
                            }
                            else
                            {
                                firstv = v;
                                havev = 1L;
                            }
    goto L3436;
                        }
L3435:
                        ok = 0L;
L3436:
                    }
L3426:
                }
                a_3 = (a_3 + 8L);
    goto L3415;
L3417:
                if (ok != 0)
                {
                    if (havev != 0) goto L3446; else goto L3445;
L3446:
                    if (nsites > 0L) goto L3444; else goto L3445;
L3444:
                    pd = *cast(long*)(ppos + (pi << 3L));
                    *cast(long*)(p + (pd << 3L)) = 1L;
                    *cast(long*)(p + ((pd + 2L) << 3L)) = firstv;
                    *cast(long*)(p + ((pd + 3L) << 3L)) = 0L;
                    nspec = (nspec + 1L);
                }
L3445:
            }
            pi = (pi + 1L);
        }
L3408:
L3380:
        k_2 = (k_2 + 1L);
    }
    if (nspec > 0L && opt_verbose != 0)
    {
        v13 = writef(cast(long)__s13519.ptr, nspec);
    }
    return nspec;
}
long dce_inl_kind(long p1 = 0)
{
    long op = p1;
    if (op == 35L)
    {
        return 5L;
    }
    if (op == 34L)
    {
        return 6L;
    }
    if (op == 36L) goto L3454; else goto L3456;
L3456:
    if (op == 37L) goto L3454; else goto L3455;
L3454:
    return 7L;
L3455:
    if (op == 1L)
    {
        return 1L;
    }
    if (op == 26L) goto L3459; else goto L3462;
L3462:
    if (op == 12L) goto L3459; else goto L3461;
L3461:
    if (op == 39L) goto L3459; else goto L3460;
L3459:
    return 2L;
L3460:
    if (op >= 4L)
    {
        if (op <= 11L) goto L3463; else goto L3467;
    }
L3467:
    if (op == 13L) goto L3463; else goto L3466;
L3466:
    if (op == 14L) goto L3463; else goto L3465;
L3465:
    if (op >= 20L) goto L3469; else goto L3464;
L3469:
    if (op <= 25L) goto L3463; else goto L3464;
L3463:
    return 3L;
L3464:
    return 0L;
}
long ir_append_raw(long p1 = 0, long p2 = 0, long p3 = 0, long p4 = 0, long p5 = 0)
{
    long n = 0;
    long op = p1;
    long d = p2;
    long a1 = p3;
    long a2 = p4;
    long a3 = p5;
    n = ir_next;
    if (ir_next >= ((8L * 262144L) - 8L))
    {
        return 0L;
    }
    ir_next = (ir_next + 8L);
    *cast(long*)(ir_arena + (n << 3L)) = op;
    *cast(long*)(ir_arena + ((n + 1L) << 3L)) = d;
    *cast(long*)(ir_arena + ((n + 2L) << 3L)) = a1;
    *cast(long*)(ir_arena + ((n + 3L) << 3L)) = a2;
    *cast(long*)(ir_arena + ((n + 4L) << 3L)) = a3;
    *cast(long*)(ir_arena + ((n + 5L) << 3L)) = 0L;
    *cast(long*)(ir_arena + ((n + 6L) << 3L)) = 0L;
    *cast(long*)(ir_arena + ((n + 7L) << 3L)) = 0L;
    return n;
}
long dce_inl_remap(long p1 = 0, long p2 = 0)
{
    long v0 = 0;
    long remap = p1;
    long t = p2;
    if (t == 0L)
    {
        return 0L;
    }
    if (*cast(long*)(remap + (t << 3L)) == 0L)
    {
        *cast(long*)(remap + (t << 3L)) = ir_new_temp();
    }
    return *cast(long*)(remap + (t << 3L));
}
long dce_inline()
{
    long old = 0;
    long oldnext = 0;
    long origtemp = 0;
    long v0 = 0;
    long fname = 0;
    long v1 = 0;
    long fstart = 0;
    long v2 = 0;
    long fend = 0;
    long v3 = 0;
    long finl = 0;
    long v4 = 0;
    long ftaken = 0;
    long v5 = 0;
    long defidx = 0;
    long v6 = 0;
    long defcnt = 0;
    long v7 = 0;
    long remap = 0;
    long nfunc = 0;
    long ninl = 0;
    long t = 0;
    long i = 0;
    long dst = 0;
    long i_2 = 0;
    long j = 0;
    long argc = 0;
    long ok = 0;
    long nret = 0;
    long sz = 0;
    long v8 = 0;
    long kd = 0;
    long i_3 = 0;
    long nm = 0;
    long k = 0;
    long v9 = 0;
    long nsites = 0;
    long i_4 = 0;
    long callee = 0;
    long v10 = 0;
    long cnm = 0;
    long fi = 0;
    long k_2 = 0;
    long v11 = 0;
    long v12 = 0;
    long i_5 = 0;
    long inlined = 0;
    long callee_2 = 0;
    long v13 = 0;
    long cnm_2 = 0;
    long fi_2 = 0;
    long k_3 = 0;
    long v14 = 0;
    long result = 0;
    long a1 = 0;
    long a2 = 0;
    long a3 = 0;
    long b = 0;
    long bend = 0;
    long t_2 = 0;
    long op = 0;
    long v15 = 0;
    long idx = 0;
    long v16 = 0;
    long pt = 0;
    long v17 = 0;
    long v18 = 0;
    long arg = 0;
    long v19 = 0;
    long v20 = 0;
    long rv = 0;
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
    long n = 0;
    long v35 = 0;
    long v36 = 0;
    old = ir_arena;
    oldnext = ir_next;
    origtemp = ir_nextemp;
    fname = getvec(2048L);
    fstart = getvec(2048L);
    fend = getvec(2048L);
    finl = getvec(2048L);
    ftaken = getvec(2048L);
    defidx = getvec((origtemp + 8L));
    defcnt = getvec((origtemp + 8L));
    remap = getvec((origtemp + 8L));
    nfunc = 0L;
    ninl = 0L;
    t = 0L;
    while (t <= (origtemp + 4L))
    {
        *cast(long*)(defidx + (t << 3L)) = 0L;
        *cast(long*)(defcnt + (t << 3L)) = 0L;
        t = (t + 1L);
    }
    i = 1L;
L3480:
    if (i >= oldnext) goto L3482; else goto L3481;
L3481:
    dst = *cast(long*)(old + ((i + 1L) << 3L));
    if (dst > 0L)
    {
        if (*cast(long*)(old + (i << 3L)) != 32L) goto L3486; else goto L3484;
L3486:
        if (*cast(long*)(old + (i << 3L)) != 31L) goto L3485; else goto L3484;
L3485:
        if (*cast(long*)(old + (i << 3L)) != 30L) goto L3483; else goto L3484;
L3483:
        *cast(long*)(defidx + (dst << 3L)) = i;
        *cast(long*)(defcnt + (dst << 3L)) = (*cast(long*)(defcnt + (dst << 3L)) + 1L);
    }
L3484:
    i = (i + 8L);
    goto L3480;
L3482:
    i_2 = 1L;
L3488:
    if (i_2 >= oldnext) goto L3490; else goto L3489;
L3489:
    if (*cast(long*)(old + (i_2 << 3L)) == 36L)
    {
        j = i_2;
        argc = *cast(long*)(old + ((i_2 + 2L) << 3L));
        ok = 1L;
        nret = 0L;
        sz = 0L;
L3494:
        if (j >= oldnext) goto L3496; else goto L3497;
L3497:
        if (*cast(long*)(old + (j << 3L)) == 37L) goto L3496; else goto L3495;
L3495:
        kd = dce_inl_kind(*cast(long*)(old + (j << 3L)));
        if (kd == 0L)
        {
            ok = 0L;
        }
        if (kd == 6L)
        {
            nret = (nret + 1L);
        }
        sz = (sz + 1L);
        j = (j + 8L);
    goto L3494;
L3496:
        if (j < oldnext)
        {
            j = (j + 8L);
        }
        if (nfunc < 2040L)
        {
            *cast(long*)(fname + (nfunc << 3L)) = *cast(long*)(old + ((i_2 + 3L) << 3L));
            *cast(long*)(fstart + (nfunc << 3L)) = i_2;
            *cast(long*)(fend + (nfunc << 3L)) = j;
            *cast(long*)(finl + (nfunc << 3L)) = (((ok & cast(long)(nret == 1L)) & cast(long)(argc <= 3L)) & cast(long)(sz <= 40L));
            *cast(long*)(ftaken + (nfunc << 3L)) = 0L;
            nfunc = (nfunc + 1L);
        }
        i_2 = j;
    }
    else
    {
        i_2 = (i_2 + 8L);
    }
    goto L3488;
L3490:
    i_3 = 1L;
L3506:
    if (i_3 >= oldnext) goto L3508; else goto L3507;
L3507:
    if (*cast(long*)(old + (i_3 << 3L)) == 50L)
    {
        nm = *cast(long*)(old + ((i_3 + 3L) << 3L));
        k = 0L;
        while (k <= (nfunc - 1L))
        {
            if (sym_streq(*cast(long*)(fname + (k << 3L)), nm) != 0)
            {
                *cast(long*)(ftaken + (k << 3L)) = 1L;
            }
            k = (k + 1L);
        }
    }
    i_3 = (i_3 + 8L);
    goto L3506;
L3508:
    nsites = 0L;
    i_4 = 1L;
L3517:
    if (i_4 >= oldnext) goto L3519; else goto L3518;
L3518:
    if (*cast(long*)(old + (i_4 << 3L)) == 33L)
    {
        callee = *cast(long*)(old + ((i_4 + 2L) << 3L));
        if (*cast(long*)(defcnt + (callee << 3L)) == 1L)
        {
            if (*cast(long*)(old + (*cast(long*)(defidx + (callee << 3L)) << 3L)) == 1L) goto L3525; else goto L3523;
L3525:
            if (*cast(long*)(old + ((*cast(long*)(defidx + (callee << 3L)) + 3L) << 3L)) == 1L) goto L3522; else goto L3523;
L3522:
            v10 = *cast(long*)(old + ((*cast(long*)(defidx + (callee << 3L)) + 2L) << 3L));
    goto L3524;
        }
L3523:
        v10 = 0L;
L3524:
        cnm = v10;
        if (cnm == 0L) goto L3528; else goto L3527;
L3527:
        fi = (-1L);
        k_2 = 0L;
        while (k_2 <= (nfunc - 1L))
        {
            if (sym_streq(*cast(long*)(fname + (k_2 << 3L)), cnm) != 0)
            {
                fi = k_2;
            }
            k_2 = (k_2 + 1L);
        }
        if (fi >= 0L)
        {
            if (*cast(long*)(finl + (fi << 3L)) != 0)
            {
                nsites = (nsites + 1L);
            }
        }
L3528:
    }
    i_4 = (i_4 + 8L);
    goto L3517;
L3519:
    ir_arena = getvec((((oldnext + ((nsites * 48L) * 8L)) + (8L * 64L)) + 4L));
    ir_next = 1L;
    i_5 = 1L;
L3539:
    if (i_5 >= oldnext) goto L3541; else goto L3540;
L3540:
    inlined = 0L;
    if (*cast(long*)(old + (i_5 << 3L)) == 33L)
    {
        callee_2 = *cast(long*)(old + ((i_5 + 2L) << 3L));
        if (*cast(long*)(defcnt + (callee_2 << 3L)) == 1L)
        {
            if (*cast(long*)(old + (*cast(long*)(defidx + (callee_2 << 3L)) << 3L)) == 1L) goto L3547; else goto L3545;
L3547:
            if (*cast(long*)(old + ((*cast(long*)(defidx + (callee_2 << 3L)) + 3L) << 3L)) == 1L) goto L3544; else goto L3545;
L3544:
            v13 = *cast(long*)(old + ((*cast(long*)(defidx + (callee_2 << 3L)) + 2L) << 3L));
    goto L3546;
        }
L3545:
        v13 = 0L;
L3546:
        cnm_2 = v13;
        if (cnm_2 == 0L) goto L3550; else goto L3549;
L3549:
        fi_2 = (-1L);
        k_3 = 0L;
        while (k_3 <= (nfunc - 1L))
        {
            if (sym_streq(*cast(long*)(fname + (k_3 << 3L)), cnm_2) != 0)
            {
                fi_2 = k_3;
            }
            k_3 = (k_3 + 1L);
        }
        if (fi_2 >= 0L)
        {
            if (*cast(long*)(finl + (fi_2 << 3L)) != 0) goto L3557; else goto L3558;
L3557:
            result = *cast(long*)(old + ((i_5 + 1L) << 3L));
            a1 = *cast(long*)(old + ((i_5 + 4L) << 3L));
            a2 = *cast(long*)(old + ((i_5 + 5L) << 3L));
            a3 = *cast(long*)(old + ((i_5 + 6L) << 3L));
            b = (*cast(long*)(fstart + (fi_2 << 3L)) + 8L);
            bend = (*cast(long*)(fend + (fi_2 << 3L)) - 8L);
            t_2 = 0L;
            while (t_2 <= (origtemp + 4L))
            {
                *cast(long*)(remap + (t_2 << 3L)) = 0L;
                t_2 = (t_2 + 1L);
            }
L3564:
            if (b >= bend) goto L3566; else goto L3565;
L3565:
            op = *cast(long*)(old + (b << 3L));
            v15 = dce_inl_kind(op);
            if (v15 == 5L) goto L3569; else goto L3575;
L3575:
            if (v15 == 6L) goto L3570; else goto L3576;
L3576:
            if (v15 == 1L) goto L3571; else goto L3577;
L3577:
            if (v15 == 2L) goto L3572; else goto L3578;
L3578:
            if (v15 == 3L) goto L3573; else goto L3579;
L3579:
            if (v15 == 4L) goto L3574; else goto L3580;
L3580:
    goto L3568;
L3569:
            idx = *cast(long*)(old + ((b + 2L) << 3L));
            pt = dce_inl_remap(remap, *cast(long*)(old + ((b + 1L) << 3L)));
            if (idx == 1L)
            {
                v17 = a1;
            }
            else
            {
                if (idx == 2L)
                {
                    v18 = a2;
                }
                else
                {
                    v18 = a3;
                }
                v17 = v18;
            }
            arg = v17;
            v19 = ir_append_raw(39L, pt, arg, 0L, 0L);
    goto L3567;
L3570:
            rv = dce_inl_remap(remap, *cast(long*)(old + ((b + 2L) << 3L)));
            v21 = ir_append_raw(39L, result, rv, 0L, 0L);
    goto L3567;
L3571:
            v23 = ir_append_raw(op, dce_inl_remap(remap, *cast(long*)(old + ((b + 1L) << 3L))), *cast(long*)(old + ((b + 2L) << 3L)), *cast(long*)(old + ((b + 3L) << 3L)), 0L);
    goto L3567;
L3572:
            v24 = dce_inl_remap(remap, *cast(long*)(old + ((b + 1L) << 3L)));
            v26 = ir_append_raw(op, v24, dce_inl_remap(remap, *cast(long*)(old + ((b + 2L) << 3L))), 0L, 0L);
    goto L3567;
L3573:
            v27 = dce_inl_remap(remap, *cast(long*)(old + ((b + 1L) << 3L)));
            v28 = dce_inl_remap(remap, *cast(long*)(old + ((b + 2L) << 3L)));
            v30 = ir_append_raw(op, v27, v28, dce_inl_remap(remap, *cast(long*)(old + ((b + 3L) << 3L))), 0L);
    goto L3567;
L3574:
            v31 = dce_inl_remap(remap, *cast(long*)(old + ((b + 2L) << 3L)));
            v33 = ir_append_raw(op, 0L, v31, dce_inl_remap(remap, *cast(long*)(old + ((b + 3L) << 3L))), 0L);
    goto L3567;
L3568:
L3567:
            b = (b + 8L);
    goto L3564;
L3566:
            ninl = (ninl + 1L);
            inlined = 1L;
        }
L3558:
L3550:
    }
    if (inlined != 0) goto L3588; else goto L3587;
L3587:
    n = ir_append_raw(*cast(long*)(old + (i_5 << 3L)), *cast(long*)(old + ((i_5 + 1L) << 3L)), *cast(long*)(old + ((i_5 + 2L) << 3L)), *cast(long*)(old + ((i_5 + 3L) << 3L)), *cast(long*)(old + ((i_5 + 4L) << 3L)));
    *cast(long*)(ir_arena + ((n + 5L) << 3L)) = *cast(long*)(old + ((i_5 + 5L) << 3L));
    *cast(long*)(ir_arena + ((n + 6L) << 3L)) = *cast(long*)(old + ((i_5 + 6L) << 3L));
    *cast(long*)(ir_arena + ((n + 7L) << 3L)) = *cast(long*)(old + ((i_5 + 7L) << 3L));
L3588:
    i_5 = (i_5 + 8L);
    goto L3539;
L3541:
    if (ninl > 0L && opt_verbose != 0)
    {
        v36 = writef(cast(long)__s14336.ptr, ninl);
    }
    return 0;
}
long dce_tco()
{
    long old = 0;
    long oldnext = 0;
    long v0 = 0;
    long defidx = 0;
    long v1 = 0;
    long defcnt = 0;
    long ntco = 0;
    long t = 0;
    long i = 0;
    long dst = 0;
    long v2 = 0;
    long i_2 = 0;
    long curname = 0;
    long curargc = 0;
    long curloop = 0;
    long needlab = 0;
    long p1 = 0;
    long p2 = 0;
    long p3 = 0;
    long op = 0;
    long n = 0;
    long v3 = 0;
    long v4 = 0;
    long idx = 0;
    long n_2 = 0;
    long v5 = 0;
    long istail = 0;
    long v6 = 0;
    long callee = 0;
    long v7 = 0;
    long cnm = 0;
    long v8 = 0;
    long v9 = 0;
    long t1 = 0;
    long v10 = 0;
    long t2 = 0;
    long v11 = 0;
    long t3 = 0;
    long v12 = 0;
    long v13 = 0;
    long v14 = 0;
    long v15 = 0;
    long v16 = 0;
    long v17 = 0;
    long v18 = 0;
    long nj = 0;
    long v19 = 0;
    long n_3 = 0;
    long v20 = 0;
    long v21 = 0;
    old = ir_arena;
    oldnext = ir_next;
    defidx = getvec((ir_nextemp + 8L));
    defcnt = getvec((ir_nextemp + 8L));
    ntco = 0L;
    t = 0L;
    while (t <= (ir_nextemp + 4L))
    {
        *cast(long*)(defidx + (t << 3L)) = 0L;
        *cast(long*)(defcnt + (t << 3L)) = 0L;
        t = (t + 1L);
    }
    i = 1L;
L3595:
    if (i >= oldnext) goto L3597; else goto L3596;
L3596:
    dst = *cast(long*)(old + ((i + 1L) << 3L));
    if (dst > 0L)
    {
        if (*cast(long*)(old + (i << 3L)) != 32L) goto L3601; else goto L3599;
L3601:
        if (*cast(long*)(old + (i << 3L)) != 31L) goto L3600; else goto L3599;
L3600:
        if (*cast(long*)(old + (i << 3L)) != 30L) goto L3598; else goto L3599;
L3598:
        *cast(long*)(defidx + (dst << 3L)) = i;
        *cast(long*)(defcnt + (dst << 3L)) = (*cast(long*)(defcnt + (dst << 3L)) + 1L);
    }
L3599:
    i = (i + 8L);
    goto L3595;
L3597:
    ir_arena = getvec(((oldnext + (8L * 8192L)) + 4L));
    ir_next = 1L;
    i_2 = 1L;
    curname = 0L;
    curargc = 0L;
    curloop = 0L;
    needlab = 0L;
    p1 = 0L;
    p2 = 0L;
    p3 = 0L;
L3603:
    if (i_2 >= oldnext) goto L3605; else goto L3604;
L3604:
    op = *cast(long*)(old + (i_2 << 3L));
    if (op == 36L)
    {
        n = 0L;
        curname = *cast(long*)(old + ((i_2 + 3L) << 3L));
        curargc = *cast(long*)(old + ((i_2 + 2L) << 3L));
        curloop = ir_new_label();
        needlab = 1L;
        p1 = 0L;
        p2 = 0L;
        p3 = 0L;
        n = ir_append_raw(op, *cast(long*)(old + ((i_2 + 1L) << 3L)), *cast(long*)(old + ((i_2 + 2L) << 3L)), *cast(long*)(old + ((i_2 + 3L) << 3L)), *cast(long*)(old + ((i_2 + 4L) << 3L)));
        *cast(long*)(ir_arena + ((n + 5L) << 3L)) = *cast(long*)(old + ((i_2 + 5L) << 3L));
        *cast(long*)(ir_arena + ((n + 6L) << 3L)) = *cast(long*)(old + ((i_2 + 6L) << 3L));
        *cast(long*)(ir_arena + ((n + 7L) << 3L)) = *cast(long*)(old + ((i_2 + 7L) << 3L));
        i_2 = (i_2 + 8L);
    }
    else
    {
        if (op == 35L)
        {
            idx = *cast(long*)(old + ((i_2 + 2L) << 3L));
            n_2 = 0L;
            if (idx == 1L)
            {
                p1 = *cast(long*)(old + ((i_2 + 1L) << 3L));
            }
            if (idx == 2L)
            {
                p2 = *cast(long*)(old + ((i_2 + 1L) << 3L));
            }
            if (idx == 3L)
            {
                p3 = *cast(long*)(old + ((i_2 + 1L) << 3L));
            }
            n_2 = ir_append_raw(op, *cast(long*)(old + ((i_2 + 1L) << 3L)), *cast(long*)(old + ((i_2 + 2L) << 3L)), *cast(long*)(old + ((i_2 + 3L) << 3L)), *cast(long*)(old + ((i_2 + 4L) << 3L)));
            *cast(long*)(ir_arena + ((n_2 + 5L) << 3L)) = *cast(long*)(old + ((i_2 + 5L) << 3L));
            *cast(long*)(ir_arena + ((n_2 + 6L) << 3L)) = *cast(long*)(old + ((i_2 + 6L) << 3L));
            *cast(long*)(ir_arena + ((n_2 + 7L) << 3L)) = *cast(long*)(old + ((i_2 + 7L) << 3L));
            i_2 = (i_2 + 8L);
        }
        else
        {
            istail = 0L;
            if (needlab != 0)
            {
                v6 = ir_append_raw(32L, 0L, curloop, 0L, 0L);
                needlab = 0L;
            }
            if (op == 33L)
            {
                if ((i_2 + 8L) < oldnext) goto L3625; else goto L3621;
L3625:
                if (*cast(long*)(old + ((i_2 + 8L) << 3L)) == 34L) goto L3624; else goto L3621;
L3624:
                if (*cast(long*)(old + ((i_2 + 1L) << 3L)) == *cast(long*)(old + (((i_2 + 8L) + 2L) << 3L))) goto L3623; else goto L3621;
L3623:
                if (curargc <= 3L) goto L3622; else goto L3621;
L3622:
                if (*cast(long*)(old + ((i_2 + 3L) << 3L)) == curargc) goto L3620; else goto L3621;
L3620:
                callee = *cast(long*)(old + ((i_2 + 2L) << 3L));
                if (*cast(long*)(defcnt + (callee << 3L)) == 1L)
                {
                    if (*cast(long*)(old + (*cast(long*)(defidx + (callee << 3L)) << 3L)) == 1L) goto L3630; else goto L3628;
L3630:
                    if (*cast(long*)(old + ((*cast(long*)(defidx + (callee << 3L)) + 3L) << 3L)) == 1L) goto L3627; else goto L3628;
L3627:
                    v7 = *cast(long*)(old + ((*cast(long*)(defidx + (callee << 3L)) + 2L) << 3L));
    goto L3629;
                }
L3628:
                v7 = 0L;
L3629:
                cnm = v7;
                if (cnm != 0L)
                {
                    if (sym_streq(cnm, curname) != 0) goto L3632; else goto L3633;
L3632:
                    t1 = ir_new_temp();
                    t2 = ir_new_temp();
                    t3 = ir_new_temp();
                    if (curargc >= 1L)
                    {
                        v12 = ir_append_raw(39L, t1, *cast(long*)(old + ((i_2 + 4L) << 3L)), 0L, 0L);
                    }
                    if (curargc >= 2L)
                    {
                        v13 = ir_append_raw(39L, t2, *cast(long*)(old + ((i_2 + 5L) << 3L)), 0L, 0L);
                    }
                    if (curargc >= 3L)
                    {
                        v14 = ir_append_raw(39L, t3, *cast(long*)(old + ((i_2 + 6L) << 3L)), 0L, 0L);
                    }
                    if (curargc >= 1L)
                    {
                        if (p1 != 0L) goto L3641; else goto L3642;
L3641:
                        v15 = ir_append_raw(39L, p1, t1, 0L, 0L);
                    }
L3642:
                    if (curargc >= 2L)
                    {
                        if (p2 != 0L) goto L3644; else goto L3645;
L3644:
                        v16 = ir_append_raw(39L, p2, t2, 0L, 0L);
                    }
L3645:
                    if (curargc >= 3L)
                    {
                        if (p3 != 0L) goto L3647; else goto L3648;
L3647:
                        v17 = ir_append_raw(39L, p3, t3, 0L, 0L);
                    }
L3648:
                    nj = ir_append_raw(30L, 0L, 0L, 0L, 0L);
                    *cast(long*)(ir_arena + ((nj + 5L) << 3L)) = curloop;
                    ntco = (ntco + 1L);
                    istail = 1L;
                    i_2 = (i_2 + (2L * 8L));
                }
L3633:
            }
L3621:
            if (istail != 0) goto L3651; else goto L3650;
L3650:
            n_3 = ir_append_raw(op, *cast(long*)(old + ((i_2 + 1L) << 3L)), *cast(long*)(old + ((i_2 + 2L) << 3L)), *cast(long*)(old + ((i_2 + 3L) << 3L)), *cast(long*)(old + ((i_2 + 4L) << 3L)));
            *cast(long*)(ir_arena + ((n_3 + 5L) << 3L)) = *cast(long*)(old + ((i_2 + 5L) << 3L));
            *cast(long*)(ir_arena + ((n_3 + 6L) << 3L)) = *cast(long*)(old + ((i_2 + 6L) << 3L));
            *cast(long*)(ir_arena + ((n_3 + 7L) << 3L)) = *cast(long*)(old + ((i_2 + 7L) << 3L));
            i_2 = (i_2 + 8L);
L3651:
        }
    }
    goto L3603;
L3605:
    if (ntco > 0L && opt_verbose != 0)
    {
        v21 = writef(cast(long)__s14894.ptr, ntco);
    }
    return ntco;
}
long dce_cse_op(long p1 = 0)
{
    long op = p1;
    return (((cast(long)(op >= 4L) & cast(long)(op <= 14L)) | (cast(long)(op >= 20L) & cast(long)(op <= 26L))) | (cast(long)(op >= 51L) & cast(long)(op <= 62L)));
}
long dce_licm_hoistable(long p1 = 0)
{
    long op = p1;
    if (op == 7L) goto L3654; else goto L3656;
L3656:
    if (op == 8L) goto L3654; else goto L3655;
L3654:
    return 0L;
L3655:
    if (op == 1L)
    {
        return 1L;
    }
    if (op >= 4L)
    {
        if (op <= 14L) goto L3659; else goto L3660;
L3659:
        return 1L;
    }
L3660:
    if (op >= 20L)
    {
        if (op <= 26L) goto L3662; else goto L3663;
L3662:
        return 1L;
    }
L3663:
    if (op >= 51L)
    {
        if (op <= 54L) goto L3665; else goto L3666;
L3665:
        return 1L;
    }
L3666:
    return 0L;
}
long dce_licm_once(long p1 = 0, long p2 = 0, long p3 = 0)
{
    long p = 0;
    long done = 0;
    long k = 0;
    long i = 0;
    long id = 0;
    long i_2 = 0;
    long op = 0;
    long hdr = 0;
    long t = 0;
    long lp = 0;
    long t1 = 0;
    long t2 = 0;
    long lp_2 = 0;
    long lp_3 = 0;
    long prev = 0;
    long q = 0;
    long t_2 = 0;
    long d = 0;
    long o = 0;
    long d_2 = 0;
    long a1 = 0;
    long a2 = 0;
    long inv = 0;
    long ok1 = 0;
    long ok2 = 0;
    long v0 = 0;
    long j = 0;
    long w = 0;
    long w_2 = 0;
    long w_3 = 0;
    long lpos = p1;
    long defd = p2;
    long tmp = p3;
    p = ir_arena;
    done = 0L;
    k = 0L;
    while (k <= (16384L + 3L))
    {
        *cast(long*)(lpos + (k << 3L)) = (-1L);
        k = (k + 1L);
    }
    i = 1L;
L3672:
    if (i >= ir_next) goto L3674; else goto L3673;
L3673:
    if (*cast(long*)(p + (i << 3L)) == 32L)
    {
        id = *cast(long*)(p + ((i + 2L) << 3L));
        if (id >= 0L)
        {
            if (id <= 16384L) goto L3677; else goto L3678;
L3677:
            *cast(long*)(lpos + (id << 3L)) = i;
        }
L3678:
    }
    i = (i + 8L);
    goto L3672;
L3674:
    i_2 = 1L;
L3680:
    if (i_2 >= ir_next) goto L3682; else goto L3683;
L3683:
    if (done != 0L) goto L3682; else goto L3681;
L3681:
    op = *cast(long*)(p + (i_2 << 3L));
    hdr = (-1L);
    if (op == 30L)
    {
        t = *cast(long*)(p + ((i_2 + 5L) << 3L));
        if (t >= 0L)
        {
            if (t <= 16384L)
            {
                lp = *cast(long*)(lpos + (t << 3L));
                if (lp >= 0L)
                {
                    if (lp < i_2)
                    {
                        hdr = lp;
                    }
                }
            }
        }
    }
    if (op == 31L)
    {
        t1 = *cast(long*)(p + ((i_2 + 5L) << 3L));
        t2 = *cast(long*)(p + ((i_2 + 6L) << 3L));
        if (t1 >= 0L)
        {
            if (t1 <= 16384L)
            {
                lp_2 = *cast(long*)(lpos + (t1 << 3L));
                if (lp_2 >= 0L)
                {
                    if (lp_2 < i_2)
                    {
                        hdr = lp_2;
                    }
                }
            }
        }
        if (hdr < 0L)
        {
            if (t2 >= 0L)
            {
                if (t2 <= 16384L)
                {
                    lp_3 = *cast(long*)(lpos + (t2 << 3L));
                    if (lp_3 >= 0L)
                    {
                        if (lp_3 < i_2)
                        {
                            hdr = lp_3;
                        }
                    }
                }
            }
        }
    }
    if (hdr > 8L)
    {
        prev = *cast(long*)(p + ((hdr - 8L) << 3L));
        if (prev == 36L) goto L3717; else goto L3718;
L3718:
        if (prev == 35L) goto L3717; else goto L3716;
L3716:
        q = hdr;
        t_2 = 0L;
        while (t_2 <= (ir_nextemp + 4L))
        {
            *cast(long*)(defd + (t_2 << 3L)) = 0L;
            t_2 = (t_2 + 1L);
        }
L3723:
        if (q > i_2) goto L3725; else goto L3724;
L3724:
        d = *cast(long*)(p + ((q + 1L) << 3L));
        if (d > 0L)
        {
            if (d <= (ir_nextemp + 4L))
            {
                *cast(long*)(defd + (d << 3L)) = (*cast(long*)(defd + (d << 3L)) + 1L);
            }
        }
        q = (q + 8L);
    goto L3723;
L3725:
        q = (hdr + 8L);
L3730:
        if (q > i_2) goto L3732; else goto L3733;
L3733:
        if (done != 0L) goto L3732; else goto L3731;
L3731:
        o = *cast(long*)(p + (q << 3L));
        d_2 = *cast(long*)(p + ((q + 1L) << 3L));
        a1 = *cast(long*)(p + ((q + 2L) << 3L));
        a2 = *cast(long*)(p + ((q + 3L) << 3L));
        inv = 0L;
        if (o == 1L)
        {
            inv = 1L;
        }
        else
        {
            ok1 = 1L;
            ok2 = 1L;
            if (a1 > 0L)
            {
                if (a1 <= (ir_nextemp + 4L))
                {
                    if (*cast(long*)(defd + (a1 << 3L)) != 0L)
                    {
                        ok1 = 0L;
                    }
                }
                else
                {
                    ok1 = 0L;
                }
            }
            if (a2 > 0L)
            {
                if (a2 <= (ir_nextemp + 4L))
                {
                    if (*cast(long*)(defd + (a2 << 3L)) != 0L)
                    {
                        ok2 = 0L;
                    }
                }
                else
                {
                    ok2 = 0L;
                }
            }
            inv = (ok1 & ok2);
        }
        if (inv != 0)
        {
            if (d_2 > 0L) goto L3751; else goto L3752;
L3751:
            if (d_2 <= (ir_nextemp + 4L))
            {
                if (*cast(long*)(defd + (d_2 << 3L)) != 1L)
                {
                    inv = 0L;
                }
            }
        }
L3752:
        if (dce_licm_hoistable(o) != 0)
        {
            if (d_2 > 0L) goto L3760; else goto L3759;
L3760:
            if (inv != 0) goto L3758; else goto L3759;
L3758:
            j = q;
            w = 0L;
            while (w <= (8L - 1L))
            {
                *cast(long*)(tmp + (w << 3L)) = *cast(long*)(p + ((q + w) << 3L));
                w = (w + 1L);
            }
L3766:
            if (j <= hdr) goto L3768; else goto L3767;
L3767:
            w_2 = 0L;
            while (w_2 <= (8L - 1L))
            {
                *cast(long*)(p + ((j + w_2) << 3L)) = *cast(long*)(p + (((j - 8L) + w_2) << 3L));
                w_2 = (w_2 + 1L);
            }
            j = (j - 8L);
    goto L3766;
L3768:
            w_3 = 0L;
            while (w_3 <= (8L - 1L))
            {
                *cast(long*)(p + ((hdr + w_3) << 3L)) = *cast(long*)(tmp + (w_3 << 3L));
                w_3 = (w_3 + 1L);
            }
            done = 1L;
        }
L3759:
        q = (q + 8L);
    goto L3730;
L3732:
L3717:
    }
    i_2 = (i_2 + 8L);
    goto L3680;
L3682:
    return done;
}
long dce_licm()
{
    long n = 0;
    long v0 = 0;
    long lpos = 0;
    long v1 = 0;
    long defd = 0;
    long v2 = 0;
    long tmp = 0;
    long v3 = 0;
    long did = 0;
    long v4 = 0;
    long v5 = 0;
    long v6 = 0;
    long v7 = 0;
    long v8 = 0;
    n = 0L;
    lpos = getvec((16384L + 4L));
    defd = getvec((ir_nextemp + 8L));
    tmp = getvec((8L + 2L));
L3777:
    if (1L != 0)
    {
        did = dce_licm_once(lpos, defd, tmp);
        if (did == 0L)
        {
    goto L3779;
        }
        n = (n + did);
        if (n >= 4096L)
        {
    goto L3779;
        }
    goto L3777;
    }
L3779:
    v4 = freevec(tmp);
    v5 = freevec(defd);
    v6 = freevec(lpos);
    if (n > 0L && opt_verbose != 0)
    {
        v8 = writef(cast(long)__s15296.ptr, n);
    }
    return n;
}
long dce_cse()
{
    long p = 0;
    long i = 0;
    long n = 0;
    long cap = 0;
    long v0 = 0;
    long vop = 0;
    long v1 = 0;
    long va1 = 0;
    long v2 = 0;
    long va2 = 0;
    long v3 = 0;
    long vd = 0;
    long vn = 0;
    long op = 0;
    long d = 0;
    long a1 = 0;
    long a2 = 0;
    long hit = 0;
    long v4 = 0;
    long cse = 0;
    long k = 0;
    long w = 0;
    long k_2 = 0;
    long v5 = 0;
    p = ir_arena;
    i = 1L;
    n = 0L;
    cap = 1024L;
    vop = getvec(cap);
    va1 = getvec(cap);
    va2 = getvec(cap);
    vd = getvec(cap);
    vn = 0L;
L3786:
    if (i >= ir_next) goto L3788; else goto L3787;
L3787:
    op = *cast(long*)(p + (i << 3L));
    if (op == 32L) goto L3789; else goto L3796;
L3796:
    if (op == 30L) goto L3789; else goto L3795;
L3795:
    if (op == 31L) goto L3789; else goto L3794;
L3794:
    if (op == 36L) goto L3789; else goto L3793;
L3793:
    if (op == 37L) goto L3789; else goto L3792;
L3792:
    if (op == 34L) goto L3789; else goto L3790;
L3789:
    vn = 0L;
    goto L3791;
L3790:
    d = *cast(long*)(p + ((i + 1L) << 3L));
    a1 = *cast(long*)(p + ((i + 2L) << 3L));
    a2 = *cast(long*)(p + ((i + 3L) << 3L));
    hit = (-1L);
    cse = dce_cse_op(op);
    if (cse != 0)
    {
        k = 0L;
L3799:
        if (k <= (vn - 1L))
        {
            if (*cast(long*)(vop + (k << 3L)) == op)
            {
                if (*cast(long*)(va1 + (k << 3L)) == a1) goto L3805; else goto L3804;
L3805:
                if (*cast(long*)(va2 + (k << 3L)) == a2) goto L3803; else goto L3804;
L3803:
                hit = k;
    goto L3802;
            }
L3804:
            k = (k + 1L);
    goto L3799;
        }
L3802:
        if (hit >= 0L)
        {
            *cast(long*)(p + (i << 3L)) = 39L;
            *cast(long*)(p + ((i + 2L) << 3L)) = *cast(long*)(vd + (hit << 3L));
            *cast(long*)(p + ((i + 3L) << 3L)) = 0L;
            n = (n + 1L);
        }
    }
    if (d != 0L)
    {
        w = 0L;
        k_2 = 0L;
        while (k_2 <= (vn - 1L))
        {
            if (*cast(long*)(va1 + (k_2 << 3L)) == d) goto L3816; else goto L3818;
L3818:
            if (*cast(long*)(va2 + (k_2 << 3L)) == d) goto L3816; else goto L3817;
L3817:
            if (*cast(long*)(vd + (k_2 << 3L)) == d) goto L3816; else goto L3815;
L3815:
            *cast(long*)(vop + (w << 3L)) = *cast(long*)(vop + (k_2 << 3L));
            *cast(long*)(va1 + (w << 3L)) = *cast(long*)(va1 + (k_2 << 3L));
            *cast(long*)(va2 + (w << 3L)) = *cast(long*)(va2 + (k_2 << 3L));
            *cast(long*)(vd + (w << 3L)) = *cast(long*)(vd + (k_2 << 3L));
            w = (w + 1L);
L3816:
            k_2 = (k_2 + 1L);
        }
        vn = w;
    }
    if (cse != 0)
    {
        if (hit < 0L) goto L3824; else goto L3820;
L3824:
        if (d != 0L) goto L3823; else goto L3820;
L3823:
        if (d != a1) goto L3822; else goto L3820;
L3822:
        if (d != a2) goto L3821; else goto L3820;
L3821:
        if (vn < cap) goto L3819; else goto L3820;
L3819:
        *cast(long*)(vop + (vn << 3L)) = op;
        *cast(long*)(va1 + (vn << 3L)) = a1;
        *cast(long*)(va2 + (vn << 3L)) = a2;
        *cast(long*)(vd + (vn << 3L)) = d;
        vn = (vn + 1L);
    }
L3820:
L3791:
    i = (i + 8L);
    goto L3786;
L3788:
    v5 = freevec(vop);
    return n;
}
long dce_run()
{
    long p = 0;
    long used = 0;
    long total = 0;
    long totalKilled = 0;
    long iters = 0;
    long nfold = 0;
    long v0 = 0;
    long v1 = 0;
    long v2 = 0;
    long v3 = 0;
    long v4 = 0;
    long i = 0;
    long rounds = 0;
    long before = 0;
    long v5 = 0;
    long v6 = 0;
    long v7 = 0;
    long v8 = 0;
    long changedThisPass = 0;
    long i_2 = 0;
    long i_3 = 0;
    long v9 = 0;
    long i_4 = 0;
    long op = 0;
    long dst = 0;
    long v10 = 0;
    long v11 = 0;
    long v12 = 0;
    long v13 = 0;
    long v14 = 0;
    p = ir_arena;
    used = 0L;
    total = 0L;
    totalKilled = 0L;
    iters = 0L;
    nfold = 0L;
    if ((opt_flags & 4096L) != 0L)
    {
        v0 = dce_tco();
    }
    if ((opt_flags & 512L) != 0L)
    {
        v1 = dce_inline();
    }
    if ((opt_flags & 128L) != 0L)
    {
        v2 = dce_whole_functions();
    }
    if ((opt_flags & 256L) != 0L)
    {
        v3 = dce_ipcp();
    }
    if ((opt_flags & (((((((((16L | 32L) | 64L) | 2L) | 128L) | 256L) | 512L) | 2048L) | 4096L) | 16384L)) == 0L)
    {
        return 0;
    }
    p = ir_arena;
    used = getvec((ir_nextemp + 8L));
    i = 1L;
L3836:
    if (i >= ir_next) goto L3838; else goto L3837;
L3837:
    if (*cast(long*)(p + (i << 3L)) != 46L)
    {
        total = (total + 1L);
    }
    i = (i + 8L);
    goto L3836;
L3838:
    rounds = 0L;
L3841:
    if (1L != 0)
    {
        before = (nfold + totalKilled);
        if ((opt_flags & (16L | 64L)) != 0L)
        {
            nfold = (nfold + dce_const_fold());
        }
        if ((opt_flags & 2L) != 0L)
        {
            nfold = (nfold + dce_strength());
        }
        if ((opt_flags & 16384L) != 0L)
        {
            nfold = (nfold + dce_licm());
        }
        if ((opt_flags & 2048L) != 0L)
        {
            nfold = (nfold + dce_cse());
        }
        if ((opt_flags & 32L) != 0L)
        {
L3854:
            if (1L != 0)
            {
                changedThisPass = 0L;
                iters = (iters + 1L);
                i_2 = 0L;
                while (i_2 <= (ir_nextemp + 4L))
                {
                    *cast(long*)(used + (i_2 << 3L)) = 0L;
                    i_2 = (i_2 + 1L);
                }
                i_3 = 1L;
L3861:
                if (i_3 >= ir_next) goto L3863; else goto L3862;
L3862:
                if (*cast(long*)(p + (i_3 << 3L)) != 46L)
                {
                    v9 = dce_mark_uses(used, p, i_3);
                }
                i_3 = (i_3 + 8L);
    goto L3861;
L3863:
                i_4 = 1L;
L3866:
                if (i_4 >= ir_next) goto L3868; else goto L3867;
L3867:
                op = *cast(long*)(p + (i_4 << 3L));
                dst = *cast(long*)(p + ((i_4 + 1L) << 3L));
                if (dce_pure_op(op) != 0)
                {
                    if (dst > 0L) goto L3871; else goto L3870;
L3871:
                    if (*cast(long*)(used + (dst << 3L)) == 0L) goto L3869; else goto L3870;
L3869:
                    *cast(long*)(p + (i_4 << 3L)) = 46L;
                    changedThisPass = (changedThisPass + 1L);
                }
L3870:
                i_4 = (i_4 + 8L);
    goto L3866;
L3868:
                totalKilled = (totalKilled + changedThisPass);
                if (changedThisPass == 0L)
                {
    goto L3856;
                }
    goto L3854;
            }
L3856:
        }
        rounds = (rounds + 1L);
        if (rounds >= 8L)
        {
    goto L3843;
        }
        if ((nfold + totalKilled) == before)
        {
    goto L3843;
        }
    goto L3841;
    }
L3843:
    v11 = freevec(used);
    if ((totalKilled + nfold) > 0L && opt_verbose != 0)
    {
        v12 = diag_pre(4L, 0L);
        v14 = writef(cast(long)__s15703.ptr, totalKilled, nfold, iters);
    }
    return 0;
}
long dce_eval_bin(long p1 = 0, long p2 = 0, long p3 = 0, long p4 = 0)
{
    long op = p1;
    long a = p2;
    long b = p3;
    long ok = p4;
    *cast(long*)(ok + (0L << 3L)) = 1L;
    if (op == 4L) goto L3883; else goto L3892;
L3892:
    if (op == 5L) goto L3884; else goto L3893;
L3893:
    if (op == 6L) goto L3885; else goto L3894;
L3894:
    if (op == 7L) goto L3886; else goto L3895;
L3895:
    if (op == 8L) goto L3887; else goto L3896;
L3896:
    if (op == 9L) goto L3888; else goto L3897;
L3897:
    if (op == 10L) goto L3889; else goto L3898;
L3898:
    if (op == 13L) goto L3890; else goto L3899;
L3899:
    if (op == 14L) goto L3891; else goto L3900;
L3900:
    goto L3882;
L3883:
    return (a + b);
L3884:
    return (a - b);
L3885:
    return (a * b);
L3886:
    if (b == 0L)
    {
        *cast(long*)(ok + (0L << 3L)) = 0L;
        return 0L;
    }
    else
    {
        return (a / b);
    }
    goto L3881;
L3887:
    if (b == 0L)
    {
        *cast(long*)(ok + (0L << 3L)) = 0L;
        return 0L;
    }
    else
    {
        return (a % b);
    }
    goto L3881;
L3888:
    return (a & b);
L3889:
    return (a | b);
L3890:
    return (a << b);
L3891:
    return (a >> b);
L3882:
    *cast(long*)(ok + (0L << 3L)) = 0L;
    return 0L;
L3881:
    return 0;
}
long dce_const_fold()
{
    long p = 0;
    long v0 = 0;
    long defc = 0;
    long v1 = 0;
    long isc = 0;
    long v2 = 0;
    long cval = 0;
    long[2] __v15785;
    long v3 = 0;
    long ok = 0;
    long folded = 0;
    long t = 0;
    long i = 0;
    long d = 0;
    long i_2 = 0;
    long op = 0;
    long dst = 0;
    long a1 = 0;
    long a2 = 0;
    long ca = 0;
    long cb = 0;
    long same = 0;
    long doFold = 0;
    long doAlg = 0;
    long v4 = 0;
    long v = 0;
    long c = 0;
    long did = 0;
    long v5 = 0;
    long v6 = 0;
    long v7 = 0;
    p = ir_arena;
    defc = getvec((ir_nextemp + 8L));
    isc = getvec((ir_nextemp + 8L));
    cval = getvec((ir_nextemp + 8L));
    v3 = cast(long)__v15785.ptr;
    ok = v3;
    folded = 0L;
    t = 0L;
    while (t <= (ir_nextemp + 4L))
    {
        *cast(long*)(defc + (t << 3L)) = 0L;
        *cast(long*)(isc + (t << 3L)) = 0L;
        *cast(long*)(cval + (t << 3L)) = 0L;
        t = (t + 1L);
    }
    i = 1L;
L3911:
    if (i >= ir_next) goto L3913; else goto L3912;
L3912:
    d = *cast(long*)(p + ((i + 1L) << 3L));
    if (d > 0L)
    {
        *cast(long*)(defc + (d << 3L)) = (*cast(long*)(defc + (d << 3L)) + 1L);
    }
    i = (i + 8L);
    goto L3911;
L3913:
    i_2 = 1L;
L3916:
    if (i_2 >= ir_next) goto L3918; else goto L3917;
L3917:
    op = *cast(long*)(p + (i_2 << 3L));
    dst = *cast(long*)(p + ((i_2 + 1L) << 3L));
    a1 = *cast(long*)(p + ((i_2 + 2L) << 3L));
    a2 = *cast(long*)(p + ((i_2 + 3L) << 3L));
    if (dst > 0L)
    {
        if (*cast(long*)(defc + (dst << 3L)) == 1L) goto L3919; else goto L3920;
L3919:
        if (op == 1L)
        {
            *cast(long*)(isc + (dst << 3L)) = 1L;
            *cast(long*)(cval + (dst << 3L)) = a1;
        }
        else
        {
            if (op == 39L)
            {
                if (a1 > 0L)
                {
                    if (*cast(long*)(isc + (a1 << 3L)) != 0L) goto L3928; else goto L3929;
L3928:
                    *cast(long*)(isc + (dst << 3L)) = 1L;
                    *cast(long*)(cval + (dst << 3L)) = *cast(long*)(cval + (a1 << 3L));
                }
L3929:
            }
            else
            {
                if (op >= 4L)
                {
                    if (op <= 14L) goto L3931; else goto L3932;
L3931:
                    ca = (cast(long)(a1 > 0L) & cast(long)(*cast(long*)(isc + (a1 << 3L)) != 0L));
                    cb = (cast(long)(a2 > 0L) & cast(long)(*cast(long*)(isc + (a2 << 3L)) != 0L));
                    same = 0L;
                    doFold = cast(long)((opt_flags & 16L) != 0L);
                    doAlg = cast(long)((opt_flags & 64L) != 0L);
                    if ((opt_flags & 2L) != 0L)
                    {
                        if (a1 > 0L) goto L3936; else goto L3935;
L3936:
                        if (a1 == a2) goto L3934; else goto L3935;
L3934:
                        if (op == 5L) goto L3938; else goto L3941;
L3941:
                        if (op == 11L) goto L3938; else goto L3939;
L3938:
                        *cast(long*)(p + (i_2 << 3L)) = 1L;
                        *cast(long*)(p + ((i_2 + 2L) << 3L)) = 0L;
                        *cast(long*)(p + ((i_2 + 3L) << 3L)) = 0L;
                        *cast(long*)(isc + (dst << 3L)) = 1L;
                        *cast(long*)(cval + (dst << 3L)) = 0L;
                        same = 1L;
    goto L3940;
L3939:
                        if (op == 9L) goto L3942; else goto L3944;
L3944:
                        if (op == 10L) goto L3942; else goto L3943;
L3942:
                        *cast(long*)(p + (i_2 << 3L)) = 39L;
                        *cast(long*)(p + ((i_2 + 2L) << 3L)) = a1;
                        *cast(long*)(p + ((i_2 + 3L) << 3L)) = 0L;
                        same = 1L;
L3943:
L3940:
                        if (same != 0)
                        {
                            folded = (folded + 1L);
                        }
                    }
L3935:
                    if (same != 0)
                    {
                        ca = 0L;
                    }
                    if (same != 0)
                    {
                        cb = 0L;
                    }
                    if (ca != 0)
                    {
                        if (cb != 0) goto L3954; else goto L3952;
L3954:
                        if (doFold != 0) goto L3951; else goto L3952;
L3951:
                        v = dce_eval_bin(op, *cast(long*)(cval + (a1 << 3L)), *cast(long*)(cval + (a2 << 3L)), ok);
                        if (*cast(long*)(ok + (0L << 3L)) != 0)
                        {
                            *cast(long*)(p + (i_2 << 3L)) = 1L;
                            *cast(long*)(p + ((i_2 + 2L) << 3L)) = v;
                            *cast(long*)(p + ((i_2 + 3L) << 3L)) = 0L;
                            *cast(long*)(isc + (dst << 3L)) = 1L;
                            *cast(long*)(cval + (dst << 3L)) = v;
                            folded = (folded + 1L);
                        }
    goto L3953;
                    }
L3952:
                    if (cb != 0)
                    {
                        if (doAlg != 0) goto L3958; else goto L3959;
L3958:
                        c = *cast(long*)(cval + (a2 << 3L));
                        did = 0L;
                        if (op == 6L)
                        {
                            if (c == 0L)
                            {
                                *cast(long*)(p + (i_2 << 3L)) = 1L;
                                *cast(long*)(p + ((i_2 + 2L) << 3L)) = 0L;
                                *cast(long*)(p + ((i_2 + 3L) << 3L)) = 0L;
                                *cast(long*)(isc + (dst << 3L)) = 1L;
                                *cast(long*)(cval + (dst << 3L)) = 0L;
                                did = 1L;
                            }
                            else
                            {
                                if (c == 1L)
                                {
                                    *cast(long*)(p + (i_2 << 3L)) = 39L;
                                    *cast(long*)(p + ((i_2 + 2L) << 3L)) = a1;
                                    *cast(long*)(p + ((i_2 + 3L) << 3L)) = 0L;
                                    did = 1L;
                                }
                            }
                        }
                        else
                        {
                            if (op == 9L)
                            {
                                if (c == 0L)
                                {
                                    *cast(long*)(p + (i_2 << 3L)) = 1L;
                                    *cast(long*)(p + ((i_2 + 2L) << 3L)) = 0L;
                                    *cast(long*)(p + ((i_2 + 3L) << 3L)) = 0L;
                                    *cast(long*)(isc + (dst << 3L)) = 1L;
                                    *cast(long*)(cval + (dst << 3L)) = 0L;
                                    did = 1L;
                                }
                            }
                            else
                            {
                                if (op == 7L)
                                {
                                    if (c == 1L)
                                    {
                                        *cast(long*)(p + (i_2 << 3L)) = 39L;
                                        *cast(long*)(p + ((i_2 + 2L) << 3L)) = a1;
                                        *cast(long*)(p + ((i_2 + 3L) << 3L)) = 0L;
                                        did = 1L;
                                    }
                                }
                                else
                                {
                                    if (c == 0L)
                                    {
                                        if (op == 4L) goto L3981; else goto L3987;
L3987:
                                        if (op == 5L) goto L3981; else goto L3986;
L3986:
                                        if (op == 10L) goto L3981; else goto L3985;
L3985:
                                        if (op == 11L) goto L3981; else goto L3984;
L3984:
                                        if (op == 13L) goto L3981; else goto L3983;
L3983:
                                        if (op == 14L) goto L3981; else goto L3982;
L3981:
                                        *cast(long*)(p + (i_2 << 3L)) = 39L;
                                        *cast(long*)(p + ((i_2 + 2L) << 3L)) = a1;
                                        *cast(long*)(p + ((i_2 + 3L) << 3L)) = 0L;
                                        did = 1L;
L3982:
                                    }
                                }
                            }
                        }
                        if (did != 0)
                        {
                            folded = (folded + 1L);
                        }
                    }
L3959:
L3953:
                }
L3932:
            }
        }
    }
L3920:
    i_2 = (i_2 + 8L);
    goto L3916;
L3918:
    v5 = freevec(cval);
    v6 = freevec(isc);
    v7 = freevec(defc);
    return folded;
}
long log2_pow2(long p1 = 0)
{
    long k = 0;
    long v0 = 0;
    long x = p1;
    k = 0L;
    if (x < 2L)
    {
        return (-1L);
    }
L3992:
    if ((x & 1L) == 1L) goto L3994; else goto L3993;
L3993:
    x = (x >> 1L);
    k = (k + 1L);
    goto L3992;
L3994:
    if (x == 1L)
    {
        v0 = k;
    }
    else
    {
        v0 = (-1L);
    }
    return v0;
}
long dce_strength()
{
    long p = 0;
    long v0 = 0;
    long isc = 0;
    long v1 = 0;
    long cval = 0;
    long v2 = 0;
    long defop = 0;
    long v3 = 0;
    long usec = 0;
    long nred = 0;
    long hi = 0;
    long t = 0;
    long i = 0;
    long op = 0;
    long d = 0;
    long f = 0;
    long u = 0;
    long i_2 = 0;
    long op_2 = 0;
    long a2 = 0;
    long c = 0;
    long v4 = 0;
    long k = 0;
    long v5 = 0;
    long v6 = 0;
    long v7 = 0;
    long v8 = 0;
    p = ir_arena;
    isc = getvec((ir_nextemp + 8L));
    cval = getvec((ir_nextemp + 8L));
    defop = getvec((ir_nextemp + 8L));
    usec = getvec((ir_nextemp + 8L));
    nred = 0L;
    hi = (ir_nextemp + 4L);
    t = 0L;
    while (t <= hi)
    {
        *cast(long*)(isc + (t << 3L)) = 0L;
        *cast(long*)(cval + (t << 3L)) = 0L;
        *cast(long*)(defop + (t << 3L)) = 0L;
        *cast(long*)(usec + (t << 3L)) = 0L;
        t = (t + 1L);
    }
    i = 1L;
L4002:
    if (i >= ir_next) goto L4004; else goto L4003;
L4003:
    op = *cast(long*)(p + (i << 3L));
    d = *cast(long*)(p + ((i + 1L) << 3L));
    if (op == 1L)
    {
        if (d > 0L) goto L4005; else goto L4006;
L4005:
        *cast(long*)(isc + (d << 3L)) = 1L;
        *cast(long*)(cval + (d << 3L)) = *cast(long*)(p + ((i + 2L) << 3L));
        *cast(long*)(defop + (d << 3L)) = i;
    }
L4006:
    f = 2L;
    while (f <= 6L)
    {
        u = *cast(long*)(p + ((i + f) << 3L));
        if (u > 0L)
        {
            if (u <= hi) goto L4012; else goto L4013;
L4012:
            *cast(long*)(usec + (u << 3L)) = (*cast(long*)(usec + (u << 3L)) + 1L);
        }
L4013:
        f = (f + 1L);
    }
    i = (i + 8L);
    goto L4002;
L4004:
    i_2 = 1L;
L4015:
    if (i_2 >= ir_next) goto L4017; else goto L4016;
L4016:
    op_2 = *cast(long*)(p + (i_2 << 3L));
    a2 = *cast(long*)(p + ((i_2 + 3L) << 3L));
    if (a2 > 0L)
    {
        if (a2 <= hi) goto L4022; else goto L4019;
L4022:
        if (*cast(long*)(isc + (a2 << 3L)) != 0L) goto L4021; else goto L4019;
L4021:
        if (*cast(long*)(usec + (a2 << 3L)) == 1L) goto L4020; else goto L4019;
L4020:
        if (*cast(long*)(defop + (a2 << 3L)) != 0L) goto L4018; else goto L4019;
L4018:
        c = *cast(long*)(cval + (a2 << 3L));
        k = log2_pow2(c);
        if (k >= 0L)
        {
            if (op_2 == 6L)
            {
                *cast(long*)(p + (i_2 << 3L)) = 13L;
                *cast(long*)(p + ((*cast(long*)(defop + (a2 << 3L)) + 2L) << 3L)) = k;
                *cast(long*)(cval + (a2 << 3L)) = k;
                nred = (nred + 1L);
            }
        }
    }
L4019:
    i_2 = (i_2 + 8L);
    goto L4015;
L4017:
    v5 = freevec(usec);
    v6 = freevec(defop);
    v7 = freevec(cval);
    v8 = freevec(isc);
    return nred;
}
long prof_read_counts(long p1 = 0, long p2 = 0)
{
    long v0 = 0;
    long v1 = 0;
    long fd = 0;
    long n = 0;
    long v2 = 0;
    long v3 = 0;
    long b0 = 0;
    long w = 0;
    long sh = 0;
    long k = 0;
    long v4 = 0;
    long b = 0;
    long v5 = 0;
    long counts = p1;
    long maxn = p2;
    fd = findinput(cast(long)__s16398.ptr);
    n = 0L;
    if (fd != 0) goto L4029; else goto L4028;
L4028:
    return 0L;
L4029:
    v2 = selectinput(fd);
L4030:
    if (1L != 0)
    {
        b0 = lex_rawbyte();
        w = 0L;
        sh = 0L;
        if (b0 < 0L)
        {
    goto L4032;
        }
        w = (b0 & 255L);
        sh = 8L;
        k = 1L;
        while (k <= 7L)
        {
            b = lex_rawbyte();
            if (b >= 0L)
            {
                w = (w | ((b & 255L) << sh));
            }
            sh = (sh + 8L);
            k = (k + 1L);
        }
        if (n < maxn)
        {
            *cast(long*)(counts + (n << 3L)) = w;
        }
        n = (n + 1L);
    goto L4030;
    }
L4032:
    v5 = endread();
    return n;
}
long prof_reorder()
{
    long p = 0;
    long maxf = 0;
    long v0 = 0;
    long counts = 0;
    long v1 = 0;
    long starts = 0;
    long v2 = 0;
    long cnt = 0;
    long v3 = 0;
    long order = 0;
    long nf = 0;
    long ncounts = 0;
    long prefixEnd = 0;
    long i = 0;
    long v4 = 0;
    long i_2 = 0;
    long first = 0;
    long k = 0;
    long v5 = 0;
    long k_2 = 0;
    long a = 0;
    long key = 0;
    long kc = 0;
    long b = 0;
    long v6 = 0;
    long nw = 0;
    long w = 0;
    long reordered = 0;
    long i_3 = 0;
    long oi = 0;
    long kk = 0;
    long i_4 = 0;
    long v7 = 0;
    long e = 0;
    long i_5 = 0;
    long v8 = 0;
    long v9 = 0;
    long v10 = 0;
    long v11 = 0;
    long v12 = 0;
    long v13 = 0;
    long v14 = 0;
    long v15 = 0;
    p = ir_arena;
    maxf = 8192L;
    counts = getvec((maxf + 4L));
    starts = getvec((maxf + 4L));
    cnt = getvec((maxf + 4L));
    order = getvec((maxf + 4L));
    nf = 0L;
    ncounts = 0L;
    prefixEnd = ir_next;
    i = 0L;
    while (i <= maxf)
    {
        *cast(long*)(counts + (i << 3L)) = 0L;
        i = (i + 1L);
    }
    ncounts = prof_read_counts(counts, maxf);
    i_2 = 1L;
    first = 1L;
L4047:
    if (i_2 >= ir_next) goto L4049; else goto L4048;
L4048:
    if (*cast(long*)(p + (i_2 << 3L)) == 36L)
    {
        if (first != 0)
        {
            prefixEnd = i_2;
            first = 0L;
        }
        if (nf < maxf)
        {
            *cast(long*)(starts + (nf << 3L)) = i_2;
        }
        nf = (nf + 1L);
    }
    i_2 = (i_2 + 8L);
    goto L4047;
L4049:
    if (ncounts == 0L) goto L4056; else goto L4059;
L4059:
    if (nf <= 1L) goto L4056; else goto L4057;
L4056:
    goto L4058;
L4057:
    k = 0L;
    while (k <= (nf - 1L))
    {
        if (k < ncounts)
        {
            v5 = *cast(long*)(counts + (k << 3L));
        }
        else
        {
            v5 = 0L;
        }
        *cast(long*)(cnt + (k << 3L)) = v5;
        k = (k + 1L);
    }
    k_2 = 0L;
    while (k_2 <= (nf - 1L))
    {
        *cast(long*)(order + (k_2 << 3L)) = k_2;
        k_2 = (k_2 + 1L);
    }
    a = 1L;
    while (a <= (nf - 1L))
    {
        key = *cast(long*)(order + (a << 3L));
        kc = *cast(long*)(cnt + (key << 3L));
        b = (a - 1L);
L4075:
        if (b < 0L) goto L4077; else goto L4076;
L4076:
        if (*cast(long*)(cnt + (*cast(long*)(order + (b << 3L)) << 3L)) >= kc)
        {
        }
        else
        {
            *cast(long*)(order + ((b + 1L) << 3L)) = *cast(long*)(order + (b << 3L));
            b = (b - 1L);
    goto L4075;
        }
L4077:
        *cast(long*)(order + ((b + 1L) << 3L)) = key;
        a = (a + 1L);
    }
    nw = getvec((ir_next + 8L));
    w = 1L;
    reordered = 0L;
    i_3 = 1L;
    while (i_3 <= (prefixEnd - 1L))
    {
        *cast(long*)(nw + (w << 3L)) = *cast(long*)(p + (i_3 << 3L));
        w = (w + 1L);
        i_3 = (i_3 + 1L);
    }
    oi = 0L;
    while (oi <= (nf - 1L))
    {
        kk = *cast(long*)(order + (oi << 3L));
        i_4 = *cast(long*)(starts + (kk << 3L));
        if ((kk + 1L) < nf)
        {
            v7 = *cast(long*)(starts + ((kk + 1L) << 3L));
        }
        else
        {
            v7 = ir_next;
        }
        e = v7;
        if (kk != oi)
        {
            reordered = (reordered + 1L);
        }
        while (i_4 <= (e - 1L))
        {
            *cast(long*)(nw + (w << 3L)) = *cast(long*)(p + (i_4 << 3L));
            w = (w + 1L);
            i_4 = (i_4 + 1L);
        }
        oi = (oi + 1L);
    }
    i_5 = 1L;
    while (i_5 <= (ir_next - 1L))
    {
        *cast(long*)(p + (i_5 << 3L)) = *cast(long*)(nw + (i_5 << 3L));
        i_5 = (i_5 + 1L);
    }
    v8 = freevec(nw);
    if (reordered > 0L)
    {
        v9 = diag_pre(4L, 0L);
        v11 = writef(cast(long)__s16673.ptr, reordered, nf, *cast(long*)(order + (0L << 3L)), *cast(long*)(cnt + (*cast(long*)(order + (0L << 3L)) << 3L)));
    }
L4058:
    v12 = freevec(order);
    v13 = freevec(cnt);
    v14 = freevec(starts);
    v15 = freevec(counts);
    return 0;
}
