// mmixc — a Hofos driver for MMIX, written in D.
//
// The whole point of the D port: a driver is now this short.  The BCPL drivers
// are 400+ lines each because they hand-roll argument parsing and option state;
// here the front end is just three calls and the backend is a fourth.
module mmixc;

import hofos;
import hofos.cg.mmix;
static import std.stdio;

int main(string[] args)
{
    if (args.length < 2)
    {
        std.stdio.stderr.writeln("usage: mmixc SRC.b [-out OUT.mms]");
        return 20;
    }
    string src = args[1];
    string outn = args.length >= 4 && args[2] == "-out" ? args[3] : "a.mms";

    // The front end, in the order cmd_ir uses.  ast_init/ir_init allocate the
    // arenas and lex_next primes the first token -- skip any of the three and
    // parse_program walks off into unallocated memory.
    __unbuf = 1;                 // GET stream switching does not survive a
                                 // BCPL-level read-ahead; see lex.b
    long st = findinput(cast(long)toBcpl(src).ptr);
    if (st == 0) { std.stdio.stderr.writeln("cannot open " ~ src); return 20; }
    selectinput(st);
    lex_init();
    ast_init();
    ir_init();
    lex_next();
    ast_root = parse_program();
    endread();
    lower_program();

    long rc = cg_mmix_emit(outn);
    std.stdio.writefln("  output:  %s  (MMIXAL)%s", outn,
                       rc ? "  -- with UNIMPLEMENTED ops, see the file" : "");
    return cast(int)rc;
}

// BCPL strings carry their length in byte 0, so a D string has to be repacked
// before the compiler's own I/O will accept it.
private ubyte[] toBcpl(string s)
{
    auto b = new ubyte[s.length + 2];
    b[0] = cast(ubyte)s.length;
    foreach (i, c; s) b[i + 1] = cast(ubyte)c;
    return b;
}
