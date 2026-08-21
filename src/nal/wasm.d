/**
 * wasm.d — ELF64 → WebAssembly (.wasm) emitter, v0.
 *
 * WASM is a different beast from x86/ARM/RISC-V: stack-based VM, structured
 * control flow, linear memory, no syscalls — every host interaction is a
 * function import.  So this emitter doesn't reuse the byte-pattern rewrite
 * trick (there are no `svc`/`syscall` instructions to patch); it builds a
 * fresh WASM module that calls WASI's `fd_write` for stdout.
 *
 * v0 scope: walk the ELF's .rodata for BCPL-string-shaped runs ("\<len\>data")
 * and emit a single `_start` that prints each string via fd_write.  Numeric
 * computation, branches, and user functions arrive in v1 when we lower WIR
 * → WASM (structured-control-flow recovery — the relooper problem).
 *
 * Invocation: `nal --wasm input.elf output.wasm`.
 *
 * Output is a valid WASM 1.0 module verified by hand-decoding the section
 * sizes; runtime test on wasmtime/wasmer/node.js requires those installed.
 */
module wasm;

import std.array : appender, Appender;
import std.bitmanip : nativeToLittleEndian;
import std.exception : enforce;
import std.file : write;
import std.stdio : writefln;

import nal : ElfView, LoadSeg, findRodata;

// ---------------------------------------------------------------------------
// LEB128 encoding (WASM uses unsigned LEB128 for sizes / indices and signed
// LEB128 for i32 / i64 constants).
// ---------------------------------------------------------------------------

void emitULEB(ref Appender!(ubyte[]) a, ulong v) {
    while (true) {
        ubyte b = cast(ubyte)(v & 0x7F);
        v >>= 7;
        if (v != 0) b |= 0x80;
        a.put(b);
        if (v == 0) break;
    }
}

void emitSLEB(ref Appender!(ubyte[]) a, long v) {
    bool more = true;
    while (more) {
        ubyte b = cast(ubyte)(v & 0x7F);
        // arithmetic shift right
        v >>= 7;
        bool sign = (b & 0x40) != 0;
        if ((v == 0 && !sign) || (v == -1 && sign)) {
            more = false;
        } else {
            b |= 0x80;
        }
        a.put(b);
    }
}

void emitByte(ref Appender!(ubyte[]) a, ubyte b) { a.put(b); }

void emitBytes(ref Appender!(ubyte[]) a, const(ubyte)[] bs) { a.put(bs); }

void emitSection(ref Appender!(ubyte[]) module_, ubyte sectionId, const(ubyte)[] content) {
    module_.put(sectionId);
    emitULEB(module_, content.length);
    module_.put(content);
}

// ---------------------------------------------------------------------------
// WASM type/value/section constants
// ---------------------------------------------------------------------------

enum WASM_MAGIC = 0x6D736100u;     // "\0asm"
enum WASM_VER   = 0x00000001u;

enum SEC_TYPE      = 1;
enum SEC_IMPORT    = 2;
enum SEC_FUNCTION  = 3;
enum SEC_MEMORY    = 5;
enum SEC_EXPORT    = 7;
enum SEC_CODE      = 10;
enum SEC_DATA      = 11;

enum VAL_I32       = 0x7F;
enum VAL_I64       = 0x7E;

enum FUNC_TYPE     = 0x60;
enum LIMITS_MIN    = 0x00;

enum IMPORT_FUNC   = 0x00;
enum EXPORT_FUNC   = 0x00;
enum EXPORT_MEM    = 0x02;

// Opcodes used here
enum OP_END         = 0x0B;
enum OP_CALL        = 0x10;
enum OP_DROP        = 0x1A;
enum OP_I32_LOAD    = 0x28;
enum OP_I32_STORE   = 0x36;
enum OP_I32_CONST   = 0x41;

// ---------------------------------------------------------------------------
// String collector: pull BCPL strings out of the ELF's .rodata.  Each BCPL
// string is `<lenByte><data>`; we walk by lengths.
// ---------------------------------------------------------------------------

struct WasmString { uint dataOffset; uint length; }

WasmString[] collectStrings(in ubyte[] rodata) {
    WasmString[] r;
    uint offset = 0;
    while (offset < rodata.length) {
        ubyte len = rodata[offset];
        if (len == 0) { ++offset; continue; }
        if (offset + 1 + len > rodata.length) break;
        WasmString s;
        s.dataOffset = offset + 1;
        s.length = len;
        r ~= s;
        offset += 1 + len;
    }
    return r;
}

// ---------------------------------------------------------------------------
// Build the WASM module
// ---------------------------------------------------------------------------

void writeWasm(string outPath, ElfView elf) {
    auto rod = findRodata(elf);
    enforce(rod !is null, "elf: no .rodata to convert");

    auto strings = collectStrings(rod.bytes);
    enforce(strings.length > 0, "wasm: no BCPL strings found in .rodata");

    // Memory layout (in the WASM linear memory):
    //   offset 0..7   : iovec[0]  ({i32 base; i32 len})
    //   offset 8..N   : concatenated string bytes, packed in order
    //   offset N+4    : nWritten output slot (4 bytes)
    //
    // We emit one fd_write call per string.  For each:
    //   i32.store (i32.const 0)  (i32.const stringBaseInMem)   ; iov.base
    //   i32.store (i32.const 4)  (i32.const stringLen)         ; iov.len
    //   call $fd_write (1, 0, 1, &nWritten)
    //   drop

    auto module_ = appender!(ubyte[])();

    // ---- Magic + version --------------------------------------------------
    foreach (b; nativeToLittleEndian(WASM_MAGIC)) module_.put(b);
    foreach (b; nativeToLittleEndian(WASM_VER))   module_.put(b);

    // ---- Type section: two types -----------------------------------------
    //   type 0: (i32 i32 i32 i32) -> (i32)        ; fd_write
    //   type 1: () -> ()                           ; _start
    {
        auto sec = appender!(ubyte[])();
        emitULEB(sec, 2);                       // num types

        // type 0
        emitByte(sec, FUNC_TYPE);
        emitULEB(sec, 4);                       // 4 params
        emitByte(sec, VAL_I32);
        emitByte(sec, VAL_I32);
        emitByte(sec, VAL_I32);
        emitByte(sec, VAL_I32);
        emitULEB(sec, 1);                       // 1 result
        emitByte(sec, VAL_I32);

        // type 1
        emitByte(sec, FUNC_TYPE);
        emitULEB(sec, 0);                       // no params
        emitULEB(sec, 0);                       // no results

        emitSection(module_, SEC_TYPE, sec.data);
    }

    // ---- Import section: wasi_snapshot_preview1.fd_write ------------------
    {
        auto sec = appender!(ubyte[])();
        emitULEB(sec, 1);                       // num imports
        auto modName = "wasi_snapshot_preview1";
        emitULEB(sec, modName.length);
        sec.put(cast(ubyte[]) modName);
        auto fnName = "fd_write";
        emitULEB(sec, fnName.length);
        sec.put(cast(ubyte[]) fnName);
        emitByte(sec, IMPORT_FUNC);
        emitULEB(sec, 0);                       // type idx 0 (fd_write sig)
        emitSection(module_, SEC_IMPORT, sec.data);
    }

    // ---- Function section: one function (type 1) -------------------------
    {
        auto sec = appender!(ubyte[])();
        emitULEB(sec, 1);                       // num functions
        emitULEB(sec, 1);                       // function 1 uses type 1
        emitSection(module_, SEC_FUNCTION, sec.data);
    }

    // ---- Memory section: one memory (1 page = 64 KiB) --------------------
    {
        auto sec = appender!(ubyte[])();
        emitULEB(sec, 1);                       // num memories
        emitByte(sec, LIMITS_MIN);
        emitULEB(sec, 1);                       // min 1 page
        emitSection(module_, SEC_MEMORY, sec.data);
    }

    // ---- Export section: memory + _start ---------------------------------
    {
        auto sec = appender!(ubyte[])();
        emitULEB(sec, 2);                       // num exports

        auto memName = "memory";
        emitULEB(sec, memName.length);
        sec.put(cast(ubyte[]) memName);
        emitByte(sec, EXPORT_MEM);
        emitULEB(sec, 0);                       // memory idx 0

        auto startName = "_start";
        emitULEB(sec, startName.length);
        sec.put(cast(ubyte[]) startName);
        emitByte(sec, EXPORT_FUNC);
        emitULEB(sec, 1);                       // function idx 1 (after imports)

        emitSection(module_, SEC_EXPORT, sec.data);
    }

    // ---- Code section: the _start body ----------------------------------
    {
        // Pack string bytes starting at memory offset 8.
        uint stringBase = 8;
        uint[] stringOffsets;
        uint totalStrBytes = 0;
        foreach (s; strings) {
            stringOffsets ~= stringBase + totalStrBytes;
            totalStrBytes += s.length;
        }
        uint nWrittenAddr = stringBase + totalStrBytes;

        auto body_ = appender!(ubyte[])();
        emitULEB(body_, 0);                     // local var count = 0

        foreach (idx, s; strings) {
            // i32.store (offset=0): store stringOffsets[idx] at addr 0
            emitByte(body_, OP_I32_CONST); emitSLEB(body_, 0);
            emitByte(body_, OP_I32_CONST); emitSLEB(body_, stringOffsets[idx]);
            emitByte(body_, OP_I32_STORE);
            emitULEB(body_, 2);                  // align 4 (log2)
            emitULEB(body_, 0);                  // offset 0
            // i32.store: store s.length at addr 4
            emitByte(body_, OP_I32_CONST); emitSLEB(body_, 4);
            emitByte(body_, OP_I32_CONST); emitSLEB(body_, s.length);
            emitByte(body_, OP_I32_STORE);
            emitULEB(body_, 2);
            emitULEB(body_, 0);
            // call fd_write(1=stdout, 0=iovs, 1=iovs_count, nWrittenAddr)
            emitByte(body_, OP_I32_CONST); emitSLEB(body_, 1);
            emitByte(body_, OP_I32_CONST); emitSLEB(body_, 0);
            emitByte(body_, OP_I32_CONST); emitSLEB(body_, 1);
            emitByte(body_, OP_I32_CONST); emitSLEB(body_, nWrittenAddr);
            emitByte(body_, OP_CALL); emitULEB(body_, 0);    // fd_write
            emitByte(body_, OP_DROP);
        }
        emitByte(body_, OP_END);                 // end of function

        auto sec = appender!(ubyte[])();
        emitULEB(sec, 1);                        // num function bodies
        emitULEB(sec, body_.data.length);        // body size
        sec.put(body_.data);
        emitSection(module_, SEC_CODE, sec.data);
    }

    // ---- Data section: packed string bytes -------------------------------
    {
        auto sec = appender!(ubyte[])();
        emitULEB(sec, 1);                        // num segments
        emitULEB(sec, 0);                        // memory idx 0 (active mode 0)
        // offset expression: i32.const 8 ; end
        emitByte(sec, OP_I32_CONST); emitSLEB(sec, 8);
        emitByte(sec, OP_END);
        // packed bytes
        uint totalStrBytes = 0;
        foreach (s; strings) totalStrBytes += s.length;
        emitULEB(sec, totalStrBytes);
        foreach (s; strings) {
            sec.put(rod.bytes[s.dataOffset .. s.dataOffset + s.length]);
        }
        emitSection(module_, SEC_DATA, sec.data);
    }

    .write(outPath, module_.data);

    writefln("nal (wasm): wrote %s", outPath);
    writefln("  input:    %d PT_LOAD, %d B .rodata", elf.loads.length, rod.bytes.length);
    writefln("  strings:  %d packed at mem[8..]", strings.length);
    writefln("  imports:  wasi_snapshot_preview1.fd_write");
    writefln("  exports:  memory, _start");
    writefln("  module:   %d bytes total", module_.data.length);
}
