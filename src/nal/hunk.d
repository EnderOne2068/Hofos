/*
 * hunk.d — NAL back end: convert a Hofos m68k ELF32 (big-endian, EM_68K) into an
 * AmigaOS "Hunk" executable (`nal --hunk in.elf -out out`).
 *
 * The Hofos m68k backend emits a Linux/m68k ELF32: absolute addresses baked in
 * (patched via cg_*_off tables), and I/O via `trap #0` Linux syscalls.  AmigaDOS
 * instead loads hunks at arbitrary addresses (so absolute refs need HUNK_RELOC32)
 * and enters the program as a subroutine that returns its exit code in d0.  So we:
 *   1. read the ELF32-BE LOAD segments (.text = code hunk, .bss = bss hunk;
 *      .rodata, if present, = a data hunk);
 *   2. find every 32-bit big-endian word inside .text that points into a loaded
 *      segment, rewrite it to an OFFSET within its target hunk, and record a
 *      HUNK_RELOC32 entry (AmigaDOS adds the hunk's load address back at load time);
 *   3. rewrite `_start`'s Linux exit tail (move.l d0,d1 / moveq #1,d0 / trap #0)
 *      into `rts` so the program returns start()'s result in d0 to the caller.
 *
 * Everything is big-endian (m68k and the Hunk format both are).
 */
module hunk;

import std.file : read, write;
import std.exception : enforce;
import std.array : Appender, appender;
import std.stdio : writefln;

// ---- Hunk block ids --------------------------------------------------------
enum : uint {
    HUNK_CODE    = 0x3E9,
    HUNK_DATA    = 0x3EA,
    HUNK_BSS     = 0x3EB,
    HUNK_RELOC32 = 0x3EC,
    HUNK_END     = 0x3F2,
    HUNK_HEADER  = 0x3F3,
}

// ---- big-endian readers over a raw byte slice ------------------------------
uint be16(const(ubyte)[] b, size_t o) { return (b[o] << 8) | b[o + 1]; }
uint be32(const(ubyte)[] b, size_t o) {
    return (cast(uint) b[o] << 24) | (cast(uint) b[o + 1] << 16)
         | (cast(uint) b[o + 2] << 8) | cast(uint) b[o + 3];
}
void put32(ref Appender!(ubyte[]) a, uint v) {
    a.put(cast(ubyte)(v >> 24)); a.put(cast(ubyte)(v >> 16));
    a.put(cast(ubyte)(v >> 8));  a.put(cast(ubyte) v);
}
void wr32be(ubyte[] b, size_t o, uint v) {
    b[o] = cast(ubyte)(v >> 24); b[o + 1] = cast(ubyte)(v >> 16);
    b[o + 2] = cast(ubyte)(v >> 8); b[o + 3] = cast(ubyte) v;
}

struct Seg { uint vaddr; uint filesz; uint memsz; uint flags; ubyte[] bytes; }

// read `<elf>.hrl` — one decimal .text offset per line (the exact absolute-address
// sites cg-m68k recorded).  Returns [] if absent.
size_t[] readHrel(string path) {
    import std.file : exists, read;
    import std.string : splitLines, strip;
    import std.conv : to;
    if (!exists(path)) return [];
    size_t[] r;
    foreach (line; (cast(string) read(path)).splitLines) {
        auto s = line.strip;
        if (s.length) r ~= to!size_t(s);
    }
    return r;
}

// A LOAD segment classified by role.
struct M68kElf { uint entry; Seg text; Seg data; Seg bss; bool hasData; bool hasBss; }

// ---- parse the ELF32-BE m68k executable ------------------------------------
M68kElf readM68kElf(string path) {
    auto raw = cast(ubyte[]) read(path);
    enforce(raw.length >= 52, "hunk: elf too short");
    enforce(raw[0..4] == [0x7Fu, 'E', 'L', 'F'], "hunk: bad ELF magic");
    enforce(raw[4] == 1, "hunk: not ELFCLASS32 (m68k ELF expected)");
    enforce(raw[5] == 2, "hunk: not big-endian (m68k ELF expected)");
    enforce(be16(raw, 18) == 4, "hunk: not EM_68K");

    M68kElf e;
    e.entry = be32(raw, 24);              // e_entry
    uint phoff = be32(raw, 28);           // e_phoff
    uint phentsize = be16(raw, 42);       // e_phentsize
    uint phnum = be16(raw, 44);           // e_phnum

    foreach (i; 0 .. phnum) {
        size_t o = phoff + i * phentsize;
        uint p_type   = be32(raw, o + 0);
        if (p_type != 1) continue;        // PT_LOAD
        uint p_offset = be32(raw, o + 4);
        uint p_vaddr  = be32(raw, o + 8);
        uint p_filesz = be32(raw, o + 16);
        uint p_memsz  = be32(raw, o + 20);
        uint p_flags  = be32(raw, o + 24);
        Seg s;
        s.vaddr = p_vaddr; s.filesz = p_filesz; s.memsz = p_memsz; s.flags = p_flags;
        s.bytes = raw[p_offset .. p_offset + p_filesz].dup;
        if (p_flags & 1) {                        // PF_X  -> code
            e.text = s;
        } else if ((p_flags & 2) && p_memsz > p_filesz) {   // PF_W, .bss (no/short file backing)
            e.bss = s; e.hasBss = true;
        } else {                                  // read-only data -> .rodata
            e.data = s; e.hasData = true;
        }
    }
    enforce(e.text.memsz > 0, "hunk: no code segment found");
    return e;
}

// round a byte length up to a whole number of 32-bit longwords
uint longwords(uint bytes) { return (bytes + 3) / 4; }

// The Hofos m68k backend reserves a 64 MB .bss heap, but a real m68000 has a
// 24-bit address bus (16 MB total).  Cap the .bss the Hunk requests so AmigaDOS
// can actually allocate it; a Hunk-loaded program never uses the full reservation
// (getvec bumps from the front).  Overridable if a program needs a bigger arena.
enum uint BSS_CAP = 0x100000;   // 1 MiB (globals region ~128 KB + a modest heap)

// ---- the converter ---------------------------------------------------------
void writeHunk(string outPath, string elfPath) {
    auto e = readM68kElf(elfPath);

    // Hunk numbering: 0 = code, then optional data, then bss.
    uint hCode = 0;
    uint hData = e.hasData ? 1 : 0;
    uint hBss  = e.hasBss ? (e.hasData ? 2 : 1) : 0;
    uint nHunks = 1 + (e.hasData ? 1 : 0) + (e.hasBss ? 1 : 0);

    // Work on a mutable copy of the code so we can rewrite reloc words + the exit.
    ubyte[] code = e.text.bytes.dup;

    // (2) rewrite _start's Linux exit tail  22 00 70 01 4E 40  (move.l d0,d1;
    //     moveq #1,d0; trap #0)  ->  4E 75 4E 71 4E 71  (rts; nop; nop).  d0 still
    //     holds start()'s result after the preceding `jsr start`, so AmigaDOS gets it.
    static immutable ubyte[6] exitPat = [0x22, 0x00, 0x70, 0x01, 0x4E, 0x40];
    static immutable ubyte[6] rtsPad  = [0x4E, 0x75, 0x4E, 0x71, 0x4E, 0x71];
    bool exitDone = false;
    for (size_t i = 0; i + 6 <= code.length; i += 2) {
        if (code[i .. i + 6] == exitPat[]) { code[i .. i + 6] = rtsPad[]; exitDone = true; break; }
    }

    // (1) relocations.  cg-m68k writes `<elf>.hrl` — the EXACT .text offsets that
    //     hold a 32-bit absolute address.  For each, rewrite the absolute VA to an
    //     offset within its target hunk (classified by VA range) and record a
    //     HUNK_RELOC32.  A blind byte-scan is unsafe here — the 64 MB heap range
    //     catches constants that aren't addresses and corrupts the program — so the
    //     sidecar is required; we error out clearly if it is missing.
    uint[] relCode, relData, relBss;
    uint bssBytes = e.bss.memsz > BSS_CAP ? BSS_CAP : e.bss.memsz;   // 24-bit-bus cap
    uint tLo = e.text.vaddr,  tHi = e.text.vaddr + e.text.memsz;
    uint dLo = e.data.vaddr,  dHi = e.data.vaddr + e.data.memsz;
    uint bLo = e.bss.vaddr,   bHi = e.bss.vaddr + bssBytes;
    import std.file : exists;
    enforce(exists(elfPath ~ ".hrl"),
            "hunk: reloc sidecar '" ~ elfPath ~ ".hrl' missing — recompile the m68k ELF "
            ~ "with a cg-m68k that emits it (needed to build HUNK_RELOC32 safely)");
    size_t[] sites = readHrel(elfPath ~ ".hrl");
    foreach (o; sites) {
        if (o + 4 > code.length) continue;
        uint v = be32(code, o);
        if (v >= tLo && v < tHi)                       { wr32be(code, o, v - tLo); relCode ~= cast(uint) o; }
        else if (e.hasData && v >= dLo && v < dHi)     { wr32be(code, o, v - dLo); relData ~= cast(uint) o; }
        else if (e.hasBss && v >= bLo && v < bHi)      { wr32be(code, o, v - bLo); relBss  ~= cast(uint) o; }
        // else: value is not inside any loaded segment (e.g. heap addr beyond the
        //   24-bit cap) — leave it (AmigaDOS can't relocate a target it didn't load).
    }

    // ---- emit the hunk file ----
    auto b = appender!(ubyte[])();
    // HUNK_HEADER
    put32(b, HUNK_HEADER);
    put32(b, 0);                    // no resident-library names (empty list terminator)
    put32(b, nHunks);              // table_size
    put32(b, 0);                    // first hunk
    put32(b, nHunks - 1);          // last hunk
    put32(b, longwords(e.text.memsz));           // hunk 0 (code) size in longwords
    if (e.hasData) put32(b, longwords(e.data.memsz));
    if (e.hasBss)  put32(b, longwords(bssBytes));

    // HUNK_CODE (pad code to a longword)
    while (code.length % 4 != 0) code ~= cast(ubyte) 0;
    put32(b, HUNK_CODE);
    put32(b, cast(uint)(code.length / 4));
    foreach (x; code) b.put(x);
    // relocations that live inside the code hunk
    void emitReloc(uint[] rs, uint target) {
        if (rs.length == 0) return;
        put32(b, cast(uint) rs.length);
        put32(b, target);
        foreach (off; rs) put32(b, off);
    }
    if (relCode.length || relData.length || relBss.length) {
        put32(b, HUNK_RELOC32);
        emitReloc(relCode, hCode);
        emitReloc(relData, hData);
        emitReloc(relBss,  hBss);
        put32(b, 0);               // end of reloc table
    }
    put32(b, HUNK_END);

    // HUNK_DATA (.rodata), if any
    if (e.hasData) {
        ubyte[] data = e.data.bytes.dup;
        while (data.length % 4 != 0) data ~= cast(ubyte) 0;
        put32(b, HUNK_DATA);
        put32(b, cast(uint)(data.length / 4));
        foreach (x; data) b.put(x);
        put32(b, HUNK_END);
    }

    // HUNK_BSS
    if (e.hasBss) {
        put32(b, HUNK_BSS);
        put32(b, longwords(bssBytes));
        put32(b, HUNK_END);
    }

    write(outPath, b.data);
    writefln("nal (hunk): wrote %s  (%s hunks, %s relocs, exit-rewrite %s)",
             outPath, nHunks, relCode.length + relData.length + relBss.length,
             exitDone ? "ok" : "NOT FOUND");
}
