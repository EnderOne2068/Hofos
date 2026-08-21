// app.d — HDC's entry point: read a .d file, parse it with libdparse, generate
// Hofos HANGMAN through the visitor, and emit a native executable via libhofos.
module app;

import hofos, codegen;
import dparse.lexer, dparse.parser, dparse.ast, dparse.rollback_allocator;
import std.stdio, std.file, std.string;

void main(string[] args)
{
    if (args.length < 2)
    {
        stderr.writeln("usage: hdc SRC.d [-o OUT]");
        return;
    }
    string src = args[1];
    string outp = "a.out";
    for (size_t i = 2; i + 1 < args.length; i++)
        if (args[i] == "-o") outp = args[i + 1];

    auto source = cast(ubyte[]) read(src);

    // --- parse with libdparse -------------------------------------------------
    LexerConfig config;
    config.fileName = src;
    StringCache cache = StringCache(StringCache.defaultBucketCount);
    auto tokens = getTokensForParser(source, config, &cache);

    uint errCount;
    void onError(string fn, size_t line, size_t col, string msg, bool isErr)
    {
        if (isErr) { errCount++; stderr.writefln("%s(%d:%d): %s", fn, line, col, msg); }
    }
    RollbackAllocator rba;
    Module mod = parseModule(tokens, src, &rba, &onError);
    if (errCount) { stderr.writefln("hdc: %d parse error(s)", errCount); return; }

    // --- generate + emit ------------------------------------------------------
    hofos_begin();
    auto cg = new CodeGen();
    cg.module_(mod);
    hofos_optimize(2);
    hofos_emit_elf(bcpl(outp));
}
