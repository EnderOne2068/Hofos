// MMIX backend — Knuth's 64-bit RISC.  M1: HANGMAN -> MMIXAL.
//
// The first Hofos backend written in D rather than BCPL, and deliberately
// written the way D wants rather than as a transliteration: a `switch` over the
// opcode, `Appender!string` for output, an associative array for the register
// map.  The x86 backend is ~3400 lines of generated D; this is under 300.
//
// WHY MMIX IS EASY, AND WHY THAT SHAPES THE DESIGN
//
// Every other Hofos backend keeps temporaries in a memory frame and shuffles
// them through a handful of machine registers, because every other machine has
// a handful of machine registers.  MMIX has 256, and better: $0..$L are LOCAL,
// and the hardware spills the local ring to a register stack in memory by
// itself.  So a temp simply IS a register, `PUSHJ` saves the caller's locals
// with no prologue, and `POP` restores them with no epilogue.  There is no
// frame layout in this file at all -- that absence is the design.
//
// Calling convention (MMIX's own, not one invented here):
//   arguments arrive in $0,$1,...        PUSHJ $h,Func  makes them $0.. for the
//   callee, so the caller places argument k in $(h+1+k);
//   POP 1,0 returns one value, which lands in the caller's $h.
//
// Exit status is taken from $255 at `TRAP 0,Halt,0`, per Knuth's convention.
//
// NO ORACLE: the mnemonics and operand forms below come from the MMIX
// specification, not from running an MMIX assembler and copying what it did.
module hofos.cg.mmix;

import hofos.all;
static import std.file;
static import std.conv;

// HANGMAN opcodes.  These were MANIFEST constants in BCPL, so they were inlined
// at compile time and no D symbol survives the translation -- they have to be
// restated here.  Keep in step with src/hofoshdr.h.
private enum : long
{
    IR_CONST = 1, IR_LOAD = 2, IR_STORE = 3,
    IR_ADD = 4, IR_SUB = 5, IR_MUL = 6, IR_DIV = 7, IR_MOD = 8,
    IR_AND = 9, IR_OR = 10, IR_XOR = 11, IR_SHL = 12, IR_SHR = 13, IR_NOT = 14,
    IR_CMP_EQ = 20, IR_CMP_NE = 21, IR_CMP_LT = 22,
    IR_CMP_LE = 23, IR_CMP_GT = 24, IR_CMP_GE = 25,
    IR_NEG = 26, IR_JMP = 30, IR_BR = 31, IR_LABEL = 32,
    IR_CALL = 33, IR_RETURN = 34, IR_PARAM = 35,
    IR_FUNCDEF = 36, IR_FUNCEND = 37, IR_STRLIT = 38, IR_MOV = 39,
    IR_GLOBAL = 40, IR_GSTORE = 41, IR_VECALLOC = 42,
    IR_LOADB = 43, IR_STOREB = 44, IR_ADDR = 45, IR_NOP = 46, IR_SETARG = 47,
}

private enum NSZ = 8;            // words per HANGMAN instruction

private struct Emitter
{
    string[] out_;
    long[long] reg;              // IR temp -> local register number
    long nextReg;                // next free local
    string[] problems;           // ops this M1 does not cover yet
    // A call's target is not in the CALL: an earlier IR_CONST with a2 == 1
    // parked the NAME in a temp, and the CALL names that temp.
    string[long] callee;

    // A temp becomes a local register on first sight.  MMIX spills the local
    // ring to memory in hardware, so running to hundreds of them is fine and
    // needs no code here.
    long r(long temp)
    {
        if (auto p = temp in reg) return *p;
        reg[temp] = nextReg;
        return nextReg++;
    }

    void line(string s)          { out_ ~= "        " ~ s; }
    void label(string l, string s = "") { out_ ~= l ~ (s.length ? "  " ~ s : ""); }

    // A 64-bit constant needs up to four wydes: SET the top, INC the rest.
    // Small values are overwhelmingly the common case, so they get one word.
    void constant(long dst, long v)
    {
        auto d = "$" ~ std.conv.to!string(dst);
        if (v >= 0 && v < 65536) { line("SETL  " ~ d ~ "," ~ std.conv.to!string(v)); return; }
        if (v < 0 && v >= -65536)
        {
            line("SETL  " ~ d ~ "," ~ std.conv.to!string(-v));
            line("NEG   " ~ d ~ ",0," ~ d);
            return;
        }
        ulong u = cast(ulong)v;
        line("SETH  " ~ d ~ ",#" ~ hex4((u >> 48) & 0xFFFF));
        line("INCMH " ~ d ~ ",#" ~ hex4((u >> 32) & 0xFFFF));
        line("INCML " ~ d ~ ",#" ~ hex4((u >> 16) & 0xFFFF));
        line("INCL  " ~ d ~ ",#" ~ hex4(u & 0xFFFF));
    }

    static string hex4(ulong v)
    {
        static immutable digits = "0123456789ABCDEF";
        char[4] b;
        foreach (i; 0 .. 4) b[3 - i] = digits[(v >> (i * 4)) & 15];
        return b.idup;
    }
}

// `MUL $X,$Y,$Z` and friends: three-address, so a HANGMAN binary op is one
// instruction with no shuffling.  DIV puts the remainder in rR, which is how
// IR_MOD is served -- `GET $X,rR` after the divide, no second division.
private immutable string[long] binOp;
shared static this()
{
    binOp = [
        IR_ADD: "ADD", IR_SUB: "SUB", IR_MUL: "MUL", IR_DIV: "DIV",
        IR_AND: "AND", IR_OR: "OR", IR_XOR: "XOR",
        IR_SHL: "SL",  IR_SHR: "SR",
    ];
}

// CMP yields -1/0/1, so every comparison is CMP followed by a "is it zero /
// negative / positive" test.  ZSZ/ZSN/ZSP turn that into the 0/1 the IR wants
// without a branch.
private immutable string[long] cmpSet;
shared static this()
{
    cmpSet = [
        IR_CMP_EQ: "ZSZ", IR_CMP_NE: "ZSNZ", IR_CMP_LT: "ZSN",
        IR_CMP_GE: "ZSNN", IR_CMP_GT: "ZSP", IR_CMP_LE: "ZSNP",
    ];
}

/// Walk the lowered HANGMAN and write MMIXAL to `outname`.
/// Returns 0 on success, non-zero if the program used something M1 omits.
long cg_mmix_emit(string outname)
{
    auto e = Emitter();
    auto ir = cast(long*)ir_arena;
    const limit = ir_next;

    e.out_ ~= "% Generated by Hofos (cg/mmix.d) -- MMIXAL for Knuth's MMIX.";
    e.out_ ~= "Halt    IS   0";
    e.out_ ~= "        LOC  #100";

    for (long i = 1; i < limit; i += NSZ)
    {
        immutable op  = ir[i];
        immutable dst = ir[i + 1];
        immutable a1  = ir[i + 2];
        immutable a2  = ir[i + 3];

        switch (op)
        {
        case IR_FUNCDEF:
            // Each function starts its local numbering afresh: $0.. are this
            // call's own registers, which is exactly what PUSHJ arranged.
            e.reg = null;
            e.nextReg = 0;
            e.out_ ~= "";
            e.label(bcplString(ir[i + 3]), "IS   @");
            break;

        case IR_FUNCEND:
            break;

        case IR_PARAM:
            // Argument k already IS $k on entry -- nothing to emit, just record
            // where it lives.  (a1 is the 1-based argument index.)
            e.reg[dst] = a1 - 1;
            if (a1 > e.nextReg) e.nextReg = a1;
            break;

        case IR_CONST:
            if (a2 == 1) { e.callee[dst] = bcplString(a1); break; }   // call target
            e.constant(e.r(dst), a1);
            break;

        case IR_MOV:
            e.line("SET   $" ~ n(e.r(dst)) ~ ",$" ~ n(e.r(a1)));
            break;

        case IR_ADD: case IR_SUB: case IR_MUL: case IR_DIV:
        case IR_AND: case IR_OR:  case IR_XOR: case IR_SHL: case IR_SHR:
            e.line(pad(binOp[op]) ~ "$" ~ n(e.r(dst)) ~ ",$" ~ n(e.r(a1))
                                  ~ ",$" ~ n(e.r(a2)));
            break;

        case IR_MOD:
            // The remainder is already in rR from the divide; a second DIV
            // would be a wasted 60-cycle instruction.
            e.line("DIV   $" ~ n(e.r(dst)) ~ ",$" ~ n(e.r(a1)) ~ ",$" ~ n(e.r(a2)));
            e.line("GET   $" ~ n(e.r(dst)) ~ ",rR");
            break;

        case IR_NEG:
            e.line("NEG   $" ~ n(e.r(dst)) ~ ",0,$" ~ n(e.r(a1)));
            break;

        case IR_NOT:
            e.line("NOR   $" ~ n(e.r(dst)) ~ ",$" ~ n(e.r(a1)) ~ ",$" ~ n(e.r(a1)));
            break;

        case IR_CMP_EQ: case IR_CMP_NE: case IR_CMP_LT:
        case IR_CMP_LE: case IR_CMP_GT: case IR_CMP_GE:
            e.line("CMP   $" ~ n(e.r(dst)) ~ ",$" ~ n(e.r(a1)) ~ ",$" ~ n(e.r(a2)));
            e.line(pad(cmpSet[op]) ~ "$" ~ n(e.r(dst)) ~ ",$" ~ n(e.r(dst)) ~ ",1");
            break;

        case IR_LOAD:
            e.line("LDO   $" ~ n(e.r(dst)) ~ ",$" ~ n(e.r(a1)) ~ ",0");
            break;

        case IR_STORE:
            e.line("STO   $" ~ n(e.r(a2)) ~ ",$" ~ n(e.r(a1)) ~ ",0");
            break;

        case IR_LOADB:
            e.line("LDBU  $" ~ n(e.r(dst)) ~ ",$" ~ n(e.r(a1)) ~ ",0");
            break;

        case IR_STOREB:
            e.line("STBU  $" ~ n(e.r(a2)) ~ ",$" ~ n(e.r(a1)) ~ ",0");
            break;

        case IR_LABEL:
            e.label("L" ~ n(a1), "IS   @");
            break;

        case IR_JMP:
            e.line("JMP   L" ~ n(ir[i + 5]));
            break;

        case IR_BR:
            e.line("BNZ   $" ~ n(e.r(a1)) ~ ",L" ~ n(ir[i + 5]));
            e.line("JMP   L" ~ n(ir[i + 6]));
            break;

        case IR_CALL:
            {
                // PUSHJ renumbers: the callee sees $(h+1+k) as its $k.  So the
                // hole must sit above every register in use, and the arguments
                // go directly after it.
                immutable argc = a2;
                immutable hole = e.nextReg;
                e.nextReg = hole + argc + 1;
                foreach (k; 0 .. argc)
                {
                    immutable src = ir[i + 4 + k];
                    e.line("SET   $" ~ n(hole + 1 + k) ~ ",$" ~ n(e.r(src)));
                }
                e.line("PUSHJ $" ~ n(hole) ~ "," ~ e.callee.get(a1, "?unresolved"));
                e.line("SET   $" ~ n(e.r(dst)) ~ ",$" ~ n(hole));
            }
            break;

        case IR_RETURN:
            if (a1 != 0) e.line("SET   $0,$" ~ n(e.r(a1)));
            e.line("POP   1,0");
            break;

        case IR_NOP: case IR_SETARG:
            break;

        default:
            e.problems ~= "HANGMAN op " ~ n(op);
            break;
        }
    }

    // `Main` is where MMIX begins; BCPL's entry is `start`.
    e.out_ ~= "";
    e.out_ ~= "Main    IS   @";
    e.out_ ~= "        PUSHJ $0,start";
    e.out_ ~= "        SET   $255,$0";
    e.out_ ~= "        TRAP  0,Halt,0";

    std.file.write(outname, joinLines(e.out_));

    if (e.problems.length)
    {
        // Loud, not silent: an op quietly dropped is a program that assembles
        // and does the wrong thing.
        foreach (p; uniqueSorted(e.problems))
            std.file.append(outname, "% UNIMPLEMENTED: " ~ p ~ "\n");
        return 1;
    }
    return 0;
}

private string n(long v) { return std.conv.to!string(v); }
private string pad(string mnem)
{
    while (mnem.length < 6) mnem ~= " ";
    return mnem;
}

// The IR holds BCPL strings: a length byte, then the characters.
private string bcplString(long p)
{
    if (p == 0) return "?";
    auto b = cast(ubyte*)p;
    return cast(string)(b[1 .. 1 + b[0]]).idup;
}

private string joinLines(string[] xs)
{
    string s;
    foreach (x; xs) { s ~= x; s ~= "\n"; }
    return s;
}

private string[] uniqueSorted(string[] xs)
{
    import std.algorithm : sort, uniq;
    import std.array : array;
    return xs.dup.sort.uniq.array;
}
