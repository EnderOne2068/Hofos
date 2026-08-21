/**
 * pe_aarch64.d — ELF64 (AArch64 Linux) → PE32+ (Windows ARM64).
 *
 * Full parity with the x86-64 path (nal.d writePE): all five syscalls used by
 * the Hofos AArch64 backend are translated to kernel32 calls, argv is plumbed
 * via GetCommandLineA, and the stack is committed at 16 MB for the compiler's
 * large frames.
 *
 * Design — single DISPATCH helper, switch on x8.
 *   The AArch64 backend always materialises the Linux syscall number in x8 and
 *   the args in x0..x5 immediately before `svc #0`.  Rather than match each
 *   multi-instruction sequence (fragile), we rewrite EVERY `svc #0` to branch
 *   into one DISPATCH helper that reads x8 and routes:
 *       x8=64 write  -> WriteFile      x8=63 read   -> ReadFile
 *       x8=56 openat -> CreateFileA    x8=57 close  -> CloseHandle
 *       x8=93 exit   -> ExitProcess
 *   Linux AArch64 syscall args (x0..x5) map directly onto the Windows AAPCS64
 *   call args (x0..x7, no shadow space), so the dispatcher mostly just loads
 *   the IAT entry and calls.
 *
 *   x30 (link register) handling — the one subtlety AArch64 has that x64 (which
 *   uses a stack return address) does not:
 *     - A leaf I/O helper ends `svc #0; ret`.  We rewrite `svc` to `b DISPATCH`
 *       (B, NOT BL): B leaves x30 untouched, so DISPATCH tail-returns straight
 *       to the helper's caller.  The dead `ret` after it is never reached.
 *     - The inline `writes(STRLIT)` intrinsic and the _start exit sequence are
 *       NOT followed by `ret`, so we rewrite `svc` to `bl DISPATCH` and let it
 *       return to the next instruction.  Clobbering x30 is safe there: the
 *       enclosing user function reloads x30 from its frame in its epilogue, and
 *       exit never returns.
 *   DISPATCH itself saves x29/x30 across its kernel32 calls and `ret`s to
 *   whatever x30 held on entry (the B/BL target).
 *
 * IAT slot order MUST match HelperRel.iatIdx and the x86-64 path:
 *   0 GetStdHandle, 1 WriteFile, 2 ExitProcess, 3 ReadFile,
 *   4 CreateFileA, 5 CloseHandle, 6 GetCommandLineA.
 */
module pe_aarch64;

import std.array : appender, Appender;
import std.bitmanip : nativeToLittleEndian;
import std.exception : enforce;
import std.file : write;
import std.stdio : stderr, writefln;

import nal : ElfView, LoadSeg, findText, findRodata, findData, findBss,
             alignUp, patchU32, patchU64, writeCStr, padTo;

enum IMG_BASE_A64    = 0x400000UL;
enum FILE_ALIGN_A64  = 0x200u;
enum SECT_ALIGN_A64  = 0x1000u;

enum IMAGE_FILE_MACHINE_ARM64 = 0xAA64u;

enum A64_SVC0 = 0xD4000001u;   // svc #0
enum A64_RET  = 0xD65F03C0u;   // ret

// ---------------------------------------------------------------------------
// Little-endian instruction read/write
// ---------------------------------------------------------------------------

uint readInsn(in ubyte[] code, size_t i) {
    return code[i] | (cast(uint) code[i+1] << 8)
         | (cast(uint) code[i+2] << 16) | (cast(uint) code[i+3] << 24);
}

void writeInsn(ubyte[] code, size_t i, uint v) {
    code[i+0] = cast(ubyte)(v & 0xFF);
    code[i+1] = cast(ubyte)((v >> 8)  & 0xFF);
    code[i+2] = cast(ubyte)((v >> 16) & 0xFF);
    code[i+3] = cast(ubyte)((v >> 24) & 0xFF);
}

// ---------------------------------------------------------------------------
// AArch64 instruction encoders (only the forms DISPATCH needs)
// ---------------------------------------------------------------------------

uint movz(int rd, uint imm16, int shift)  { return 0xD2800000u | ((shift/16) << 21) | ((imm16 & 0xFFFF) << 5) | (rd & 31); }
uint movn(int rd, uint imm16, int shift)  { return 0x92800000u | ((shift/16) << 21) | ((imm16 & 0xFFFF) << 5) | (rd & 31); }
uint movRR(int rd, int rm)                { return 0xAA0003E0u | (rm << 16) | (rd & 31); } // orr rd,xzr,rm
uint cmpImm(int rn, uint imm12)           { return 0xF100001Fu | ((imm12 & 0xFFF) << 10) | (rn << 5); }
uint addImm(int rd, int rn, uint imm12)   { return 0x91000000u | ((imm12 & 0xFFF) << 10) | (rn << 5) | (rd & 31); }
uint strU(int rt, int rn, uint byteOff)   { return 0xF9000000u | (((byteOff/8) & 0xFFF) << 10) | (rn << 5) | (rt & 31); }
uint ldrU(int rt, int rn, uint byteOff)   { return 0xF9400000u | (((byteOff/8) & 0xFFF) << 10) | (rn << 5) | (rt & 31); }
uint ldrUW(int rt, int rn, uint byteOff)  { return 0xB9400000u | (((byteOff/4) & 0xFFF) << 10) | (rn << 5) | (rt & 31); }
uint stpPre(int t, int t2, int rn, int byteOff)  { return 0xA9800000u | ((cast(uint)(byteOff/8) & 0x7F) << 15) | (t2 << 10) | (rn << 5) | (t & 31); }
uint ldpPost(int t, int t2, int rn, int byteOff) { return 0xA8C00000u | ((cast(uint)(byteOff/8) & 0x7F) << 15) | (t2 << 10) | (rn << 5) | (t & 31); }
uint blr(int rn)                          { return 0xD63F0000u | (rn << 5); }

// ---------------------------------------------------------------------------
// Helper builder with named labels + branch fixups
// ---------------------------------------------------------------------------

struct HelperRel {
    size_t off;        // byte offset within the helpers area
    int    iatIdx;     // 0..6 (see header)
    bool   isAdrp;     // true = ADRP hi21 reloc; false = LDR-imm12 lo12
}

struct A64Builder {
    Appender!(ubyte[]) b;
    HelperRel[] relocs;
    size_t[string] labels;
    struct Fix { size_t off; string target; char kind; } // 'b','c'(cond),'l'(bl)
    Fix[] fixes;

    void emit(uint w) {
        ubyte[4] bs = nativeToLittleEndian(w);
        b.put(bs[]);
    }
    void label(string n)        { labels[n] = b.data.length; }
    size_t here()               { return b.data.length; }
    void br(string t)           { fixes ~= Fix(b.data.length, t, 'b'); emit(0x14000000u); }
    void bcond(uint cond, string t) { fixes ~= Fix(b.data.length, t, 'c'); emit(0x54000000u | (cond & 0xF)); }
    void bl(string t)           { fixes ~= Fix(b.data.length, t, 'l'); emit(0x94000000u); }
    // adrp x10, IAT(idx)@page ; ldr x10,[x10, lo12] — patched once IAT RVA known.
    void iatLoadX10(int idx) {
        relocs ~= HelperRel(b.data.length, idx, true);  emit(0x9000000Au);   // adrp x10, 0
        relocs ~= HelperRel(b.data.length, idx, false); emit(0xF940014Au);   // ldr  x10, [x10]
    }
    void callIatX10(int idx) { iatLoadX10(idx); emit(blr(10)); }

    ubyte[] finish() {
        auto data = b.data;
        foreach (f; fixes) {
            enforce(f.target in labels, "a64 helper: unresolved label " ~ f.target);
            long delta = (cast(long) labels[f.target] - cast(long) f.off) / 4;
            uint ins = readInsn(data, f.off);
            final switch (f.kind) {
                case 'b': case 'l': ins |= (cast(uint) delta & 0x3FFFFFFu); break;
                case 'c': ins |= ((cast(uint) delta & 0x7FFFFu) << 5);      break;
            }
            writeInsn(data, f.off, ins);
        }
        return data;
    }
}

enum IAT_GETSTD = 0, IAT_WRITE = 1, IAT_EXIT = 2, IAT_READ = 3,
     IAT_CREATE = 4, IAT_CLOSE = 5, IAT_CMDLINE = 6;

// Frame layout for DISPATCH (64 bytes):
//   [sp+0]  x29   [sp+8]  x30
//   [sp+16] arg0  [sp+24] arg1  [sp+32] arg2  [sp+40] arg3
//   [sp+48] handle   [sp+56] read/write out DWORD
ubyte[] buildHelpersAarch64(out HelperRel[] relocs,
                            out size_t dispatchOff, out size_t helpArgsOff)
{
    A64Builder a;

    // ===== DISPATCH ========================================================
    dispatchOff = a.here();
    a.label("dispatch");
    a.emit(stpPre(29, 30, 31, -64));     // stp x29,x30,[sp,#-64]!
    a.emit(addImm(29, 31, 0));           // mov x29, sp
    a.emit(strU(0, 31, 16));             // save arg0
    a.emit(strU(1, 31, 24));             // save arg1
    a.emit(strU(2, 31, 32));             // save arg2
    a.emit(strU(3, 31, 40));             // save arg3
    a.emit(cmpImm(8, 64)); a.bcond(0, "d_write");   // EQ
    a.emit(cmpImm(8, 63)); a.bcond(0, "d_read");
    a.emit(cmpImm(8, 56)); a.bcond(0, "d_openat");
    a.emit(cmpImm(8, 57)); a.bcond(0, "d_close");
    // else: treat as exit(93) / unknown -> ExitProcess(arg0)
    a.label("d_exit");
    a.emit(ldrU(0, 31, 16));             // x0 = code
    a.callIatX10(IAT_EXIT);              // ExitProcess(code) — no return
    a.br("d_ret");                       // (safety)

    // ----- d_write: WriteFile(handle, buf, len, &written, NULL) -----------
    a.label("d_write");
    a.emit(ldrU(0, 31, 16));             // fd
    a.emit(cmpImm(0, 1));
    a.bcond(1, "d_write_fd");            // NE -> fd is a handle
    a.emit(movn(0, 10, 0));              // STD_OUTPUT_HANDLE = ~10 = -11
    a.callIatX10(IAT_GETSTD);            // x0 = handle
    a.emit(strU(0, 31, 48));
    a.br("d_write_go");
    a.label("d_write_fd");
    a.emit(ldrU(0, 31, 16)); a.emit(strU(0, 31, 48));
    a.label("d_write_go");
    a.emit(ldrU(0, 31, 48));             // handle
    a.emit(ldrU(1, 31, 24));             // buf
    a.emit(ldrU(2, 31, 32));             // len
    a.emit(addImm(3, 31, 56));           // &written
    a.emit(movz(4, 0, 0));               // overlapped = NULL
    a.callIatX10(IAT_WRITE);
    a.br("d_ret");

    // ----- d_read: ReadFile(handle, buf, len, &read, NULL); return count --
    a.label("d_read");
    a.emit(ldrU(0, 31, 16));             // fd
    a.emit(cmpImm(0, 0));
    a.bcond(1, "d_read_fd");             // NE -> handle
    a.emit(movn(0, 9, 0));               // STD_INPUT_HANDLE = ~9 = -10
    a.callIatX10(IAT_GETSTD);
    a.emit(strU(0, 31, 48));
    a.br("d_read_go");
    a.label("d_read_fd");
    a.emit(ldrU(0, 31, 16)); a.emit(strU(0, 31, 48));
    a.label("d_read_go");
    a.emit(movz(0, 0, 0)); a.emit(strU(0, 31, 56)); // out count = 0
    a.emit(ldrU(0, 31, 48));             // handle
    a.emit(ldrU(1, 31, 24));             // buf
    a.emit(ldrU(2, 31, 32));             // len
    a.emit(addImm(3, 31, 56));           // &read
    a.emit(movz(4, 0, 0));
    a.callIatX10(IAT_READ);
    a.emit(ldrUW(0, 31, 56));            // return bytesRead (DWORD)
    a.br("d_ret");

    // ----- d_openat: CreateFileA(path, access, share, NULL, disp, 0x80, NULL)
    a.label("d_openat");
    a.emit(ldrU(2, 31, 32));             // flags
    a.emit(cmpImm(2, 0));
    a.bcond(1, "d_open_write");          // NE -> create-for-write
    // O_RDONLY: GENERIC_READ, FILE_SHARE_READ, OPEN_EXISTING
    a.emit(ldrU(0, 31, 24));             // path
    a.emit(movz(1, 0x8000, 16));         // GENERIC_READ = 0x80000000
    a.emit(movz(2, 1, 0));               // FILE_SHARE_READ
    a.emit(movz(4, 3, 0));               // OPEN_EXISTING
    a.br("d_open_go");
    a.label("d_open_write");
    a.emit(ldrU(0, 31, 24));             // path
    a.emit(movz(1, 0x4000, 16));         // GENERIC_WRITE = 0x40000000
    a.emit(movz(2, 0, 0));               // no share
    a.emit(movz(4, 2, 0));               // CREATE_ALWAYS
    a.label("d_open_go");
    a.emit(movz(3, 0, 0));               // lpSecurityAttributes = NULL
    a.emit(movz(5, 0x80, 0));            // FILE_ATTRIBUTE_NORMAL
    a.emit(movz(6, 0, 0));               // hTemplateFile = NULL
    a.callIatX10(IAT_CREATE);            // returns handle in x0
    a.br("d_ret");

    // ----- d_close: CloseHandle(handle) -----------------------------------
    a.label("d_close");
    a.emit(ldrU(0, 31, 16));
    a.callIatX10(IAT_CLOSE);
    a.br("d_ret");

    // ----- common epilogue -------------------------------------------------
    a.label("d_ret");
    a.emit(ldpPost(29, 30, 31, 64));     // ldp x29,x30,[sp],#64
    a.emit(A64_RET);

    // ===== HELP_ARGS =======================================================
    // x0 = -1 (__argc sentinel), x1 = GetCommandLineA().
    helpArgsOff = a.here();
    a.label("help_args");
    a.emit(stpPre(29, 30, 31, -16));
    a.emit(addImm(29, 31, 0));
    a.callIatX10(IAT_CMDLINE);           // x0 = command line
    a.emit(movRR(1, 0));                 // x1 = cmdline
    a.emit(movn(0, 0, 0));               // x0 = ~0 = -1
    a.emit(ldpPost(29, 30, 31, 16));
    a.emit(A64_RET);

    relocs = a.relocs;
    return a.finish();
}

// ---------------------------------------------------------------------------
// ADRP / LDR (immediate) reloc patchers
// ---------------------------------------------------------------------------

void patchAdrp(ubyte[] code, size_t off, long pageDelta) {
    uint insn = readInsn(code, off);
    int delta21 = cast(int)(pageDelta & 0x1FFFFF);
    uint immlo = (delta21 & 0x3) << 29;
    uint immhi = ((delta21 >> 2) & 0x7FFFF) << 5;
    insn = (insn & 0x9F00001Fu) | immlo | immhi;
    writeInsn(code, off, insn);
}

void patchLdrImm12(ubyte[] code, size_t off, uint byteOffset) {
    uint insn = readInsn(code, off);
    uint scaled = (byteOffset / 8) & 0xFFF;
    insn = (insn & ~(0xFFFu << 10)) | (scaled << 10);
    writeInsn(code, off, insn);
}

// ---------------------------------------------------------------------------
// PE writer
// ---------------------------------------------------------------------------

void writePEAarch64(string outPath, ElfView elf) {
    auto txt = findText(elf);
    auto rod = findRodata(elf);
    auto dat = findData(elf);
    auto bss = findBss(elf);
    enforce(txt !is null, "elf: no executable PT_LOAD");

    ubyte[] code = txt.bytes.dup;
    auto userCodeLen = code.length;

    // ---- Append helpers (DISPATCH + HELP_ARGS) ---------------------------
    HelperRel[] helperRelocs;
    size_t dispatchOff_in, helpArgsOff_in;
    auto helpers = buildHelpersAarch64(helperRelocs, dispatchOff_in, helpArgsOff_in);
    auto helperBase = code.length;
    code ~= helpers;

    auto dispatchOff = helperBase + dispatchOff_in;
    auto helpArgsOff = helperBase + helpArgsOff_in;

    // ---- Rewrite every `svc #0` to branch into DISPATCH ------------------
    // tail (b) when the next insn is `ret` (leaf I/O helper, preserve x30);
    // call (bl) otherwise (inline writes / exit — x30 clobber is safe).
    int svcSites = 0;
    for (size_t i = 0; i + 4 <= userCodeLen; i += 4) {
        if (readInsn(code, i) != A64_SVC0) continue;
        bool followedByRet = (i + 8 <= userCodeLen) && (readInsn(code, i + 4) == A64_RET);
        long instDelta = (cast(long) dispatchOff - cast(long) i) / 4;
        uint op = (followedByRet ? 0x14000000u : 0x94000000u)   // B : BL
                | (cast(uint) instDelta & 0x3FFFFFFu);
        writeInsn(code, i, op);
        ++svcSites;
    }

    // ---- Rewrite the _start prelude's Linux argc/argv read ---------------
    //   ldr x0,[sp]   (0xF94003E0)  ; argc
    //   add x1,sp,#8  (0x910023E1)  ; &argv[0]
    // -> bl HELP_ARGS ; nop   (x0 = -1 sentinel, x1 = GetCommandLineA()).
    // SCAN the first instructions for the prelude — cg-aarch64.b may emit NOPs as
    // an entry landing pad before it, so it is not necessarily at code[0].  If we
    // assumed code[0] the rewrite would be silently skipped and the Windows binary
    // would read junk argc/argv off the native stack (__argc != -1 → rdargs
    // takes the Linux vector path and crashes).
    bool argvRewritten = false;
    for (size_t p = 0; p + 8 <= userCodeLen && p < 64; p += 4) {
        if (readInsn(code, p) == 0xF94003E0u && readInsn(code, p + 4) == 0x910023E1u) {
            long instDelta = (cast(long) helpArgsOff - cast(long) p) / 4;
            writeInsn(code, p,     0x94000000u | (cast(uint) instDelta & 0x3FFFFFFu)); // bl
            writeInsn(code, p + 4, 0xD503201Fu);                                       // nop
            argvRewritten = true;
            break;
        }
    }

    // ---- Build the PE around the rewritten code --------------------------
    uint nSections = bss !is null ? 4 : 3;
    auto buf = appender!(ubyte[])();

    buf.put(cast(ubyte[]) "MZ");
    foreach (_; 0 .. 58) buf.put(cast(ubyte) 0);
    void put16(ref Appender!(ubyte[]) a, ushort v) { ubyte[2] b = nativeToLittleEndian(v); a.put(b[]); }
    void put32(ref Appender!(ubyte[]) a, uint v)   { ubyte[4] b = nativeToLittleEndian(v); a.put(b[]); }
    put32(buf, 0x80);
    while (buf.data.length < 0x80) buf.put(cast(ubyte) 0);

    buf.put(cast(ubyte[]) "PE\0\0");
    put16(buf, IMAGE_FILE_MACHINE_ARM64);
    put16(buf, cast(ushort) nSections);
    put32(buf, 0);
    put32(buf, 0);
    put32(buf, 0);
    put16(buf, 240);
    put16(buf, 0x0022);                            // EXECUTABLE | LARGE_ADDRESS_AWARE

    auto optHdrOffset = buf.data.length;
    foreach (_; 0 .. 240) buf.put(cast(ubyte) 0);

    auto secHdrOffset = buf.data.length;
    foreach (_; 0 .. 40 * nSections) buf.put(cast(ubyte) 0);

    auto textFileOff = alignUp(cast(uint) buf.data.length, FILE_ALIGN_A64);
    padTo(buf, textFileOff);

    auto textStart = buf.data.length;
    buf.put(code);
    auto textPaddedEnd = alignUp(cast(uint) buf.data.length, FILE_ALIGN_A64);
    padTo(buf, textPaddedEnd);

    auto rdataFileOff = buf.data.length;
    if (dat !is null && dat.bytes.length)      buf.put(dat.bytes);   // initialised .data
    else if (rod !is null && rod.bytes.length) buf.put(rod.bytes);   // pure .rodata
    else buf.put(cast(ubyte) 0);
    auto rdataPaddedEnd = alignUp(cast(uint) buf.data.length, FILE_ALIGN_A64);
    padTo(buf, rdataPaddedEnd);

    auto idataFileOff = buf.data.length;

    auto dirStart = buf.data.length;
    foreach (_; 0 .. 40) buf.put(cast(ubyte) 0);

    auto iltStart = buf.data.length;
    foreach (_; 0 .. 64) buf.put(cast(ubyte) 0);   // 8 entries (7 + null)

    auto iatStart = buf.data.length;
    foreach (_; 0 .. 64) buf.put(cast(ubyte) 0);

    auto hint1Off = buf.data.length; put16(buf, 0); writeCStr(buf, "GetStdHandle");
    auto hint2Off = buf.data.length; put16(buf, 0); writeCStr(buf, "WriteFile");
    auto hint3Off = buf.data.length; put16(buf, 0); writeCStr(buf, "ExitProcess");
    auto hint4Off = buf.data.length; put16(buf, 0); writeCStr(buf, "ReadFile");
    auto hint5Off = buf.data.length; put16(buf, 0); writeCStr(buf, "CreateFileA");
    auto hint6Off = buf.data.length; put16(buf, 0); writeCStr(buf, "CloseHandle");
    auto hint7Off = buf.data.length; put16(buf, 0); writeCStr(buf, "GetCommandLineA");
    auto dllNameOff = buf.data.length; writeCStr(buf, "kernel32.dll");

    auto idataPaddedEnd = alignUp(cast(uint) buf.data.length, FILE_ALIGN_A64);
    padTo(buf, idataPaddedEnd);

    auto textRva = SECT_ALIGN_A64;
    auto textRawSize = cast(uint)(textPaddedEnd - textStart);
    auto rdataSize   = cast(uint)(rdataPaddedEnd - rdataFileOff);
    auto idataSize   = cast(uint)(idataPaddedEnd - idataFileOff);
    // .bss RVA/size come straight from the ELF's zero-init PT_LOAD (pinned by the
    // code's absolute refs).  Compute here so .idata can go ABOVE it.
    uint bssRva = 0, bssVSize = 0;
    if (bss !is null) { bssRva = cast(uint)(bss.vaddr - IMG_BASE_A64); bssVSize = cast(uint) bss.memsz; }
    // The data/rodata section is pinned at its ELF VA (the code references it
    // absolutely — cg-aarch64 emits it R, cg.b x86-64 emits it R W); else park it
    // after .text.  Pin explicitly rather than relying on it happening to fall
    // right after .text.
    auto rdataRva = (dat !is null) ? cast(uint)(dat.vaddr - IMG_BASE_A64)
                  : (rod !is null) ? cast(uint)(rod.vaddr - IMG_BASE_A64)
                  : alignUp(cast(uint)(textRva + textRawSize), SECT_ALIGN_A64);
    // Place .idata ABOVE the .bss heap (free VA) so it can't overlap the pinned
    // .bss, and the section table stays ascending-RVA (.text<.data<.bss<.idata).
    auto idataRva = (bss !is null)
        ? alignUp(cast(uint)(bssRva + bssVSize), SECT_ALIGN_A64)
        : alignUp(cast(uint)(rdataRva + (rdataSize ? rdataSize : 1)), SECT_ALIGN_A64);

    uint rvaOf(size_t fileOff, size_t sectFileStart, uint sectRva) {
        return sectRva + cast(uint)(fileOff - sectFileStart);
    }

    auto hint1Rva = rvaOf(hint1Off, idataFileOff, idataRva);
    auto hint2Rva = rvaOf(hint2Off, idataFileOff, idataRva);
    auto hint3Rva = rvaOf(hint3Off, idataFileOff, idataRva);
    auto hint4Rva = rvaOf(hint4Off, idataFileOff, idataRva);
    auto hint5Rva = rvaOf(hint5Off, idataFileOff, idataRva);
    auto hint6Rva = rvaOf(hint6Off, idataFileOff, idataRva);
    auto hint7Rva = rvaOf(hint7Off, idataFileOff, idataRva);
    auto dllNRva  = rvaOf(dllNameOff, idataFileOff, idataRva);
    auto iltRva   = rvaOf(iltStart, idataFileOff, idataRva);
    auto iatRva   = rvaOf(iatStart, idataFileOff, idataRva);
    auto dirRva   = rvaOf(dirStart, idataFileOff, idataRva);

    auto data = buf.data;

    patchU64(data, iltStart +  0, cast(ulong) hint1Rva);
    patchU64(data, iltStart +  8, cast(ulong) hint2Rva);
    patchU64(data, iltStart + 16, cast(ulong) hint3Rva);
    patchU64(data, iltStart + 24, cast(ulong) hint4Rva);
    patchU64(data, iltStart + 32, cast(ulong) hint5Rva);
    patchU64(data, iltStart + 40, cast(ulong) hint6Rva);
    patchU64(data, iltStart + 48, cast(ulong) hint7Rva);
    patchU64(data, iatStart +  0, cast(ulong) hint1Rva);
    patchU64(data, iatStart +  8, cast(ulong) hint2Rva);
    patchU64(data, iatStart + 16, cast(ulong) hint3Rva);
    patchU64(data, iatStart + 24, cast(ulong) hint4Rva);
    patchU64(data, iatStart + 32, cast(ulong) hint5Rva);
    patchU64(data, iatStart + 40, cast(ulong) hint6Rva);
    patchU64(data, iatStart + 48, cast(ulong) hint7Rva);

    patchU32(data, dirStart +  0, iltRva);
    patchU32(data, dirStart + 12, dllNRva);
    patchU32(data, dirStart + 16, iatRva);

    // Patch ADRP+LDR pairs in the helpers now that the IAT RVA is known.
    foreach (h; helperRelocs) {
        auto absFileOff = textStart + helperBase + h.off;
        auto callRva = textRva + cast(uint)(helperBase + h.off);
        auto iatSlotRva = iatRva + h.iatIdx * 8;
        if (h.isAdrp) {
            long pcPage = callRva & ~0xFFFL;
            long tgtPage = iatSlotRva & ~0xFFFL;
            patchAdrp(data, absFileOff, (tgtPage - pcPage) / 0x1000);
        } else {
            patchLdrImm12(data, absFileOff, iatSlotRva & 0xFFF);
        }
    }

    void writeSec(size_t off, string name, uint rawSize, uint rva, uint rawPtr, uint chars) {
        ubyte[8] nm;
        foreach (i, c; name) if (i < 8) nm[i] = c;
        foreach (i; 0 .. 8) data[off + i] = nm[i];
        patchU32(data, off +  8, rawSize);
        patchU32(data, off + 12, rva);
        patchU32(data, off + 16, rawSize);
        patchU32(data, off + 20, rawPtr);
        patchU32(data, off + 36, chars);
    }
    writeSec(secHdrOffset +  0, ".text",  textRawSize, textRva,  cast(uint) textStart, 0x60000020);
    // Slot 1 carries the initialised DATA segment (writable) when present, else a
    // read-only .rdata (pure rodata or the filler byte).
    writeSec(secHdrOffset + 40, (dat !is null) ? ".data" : ".rdata",
             rdataSize, rdataRva, cast(uint) rdataFileOff,
             (dat !is null) ? 0xC0000040 : 0x40000040);

    // .bss takes slot 2, .idata slot 3 (ascending RVA .text<.data<.bss<.idata).
    if (bss !is null) {
        size_t off = secHdrOffset + 80;
        ubyte[8] nm = [cast(ubyte)'.', cast(ubyte)'b', cast(ubyte)'s', cast(ubyte)'s', 0, 0, 0, 0];
        foreach (i; 0 .. 8) data[off + i] = nm[i];
        patchU32(data, off +  8, bssVSize);
        patchU32(data, off + 12, bssRva);
        patchU32(data, off + 16, 0);
        patchU32(data, off + 20, 0);
        patchU32(data, off + 36, 0xC0000080u);
    }
    size_t idataHdr = (bss !is null) ? (secHdrOffset + 120) : (secHdrOffset + 80);
    writeSec(idataHdr, ".idata", idataSize, idataRva, cast(uint) idataFileOff, 0xC0000040);

    // Close VA gaps (Windows rejects images with holes between sections): stretch
    // each section's VirtualSize up to the next section's VirtualAddress.  Sections
    // are emitted in ascending-RVA slot order, so a straight walk works.
    uint rd32(size_t o) {
        return data[o] | (cast(uint) data[o+1] << 8)
             | (cast(uint) data[o+2] << 16) | (cast(uint) data[o+3] << 24);
    }
    for (uint i = 0; i + 1 < nSections; i++) {
        uint vaThis = rd32(secHdrOffset + 40 * i       + 12);
        uint vaNext = rd32(secHdrOffset + 40 * (i + 1) + 12);
        if (vaNext > vaThis) patchU32(data, secHdrOffset + 40 * i + 8, vaNext - vaThis);
    }

    void w32(size_t o, uint v)  { patchU32(data, optHdrOffset + o, v); }
    void w64(size_t o, ulong v) { patchU64(data, optHdrOffset + o, v); }
    data[optHdrOffset + 0] = 0x0B;
    data[optHdrOffset + 1] = 0x02;
    data[optHdrOffset + 2] = 14;
    w32( 4, textRawSize);
    w32( 8, rdataSize + idataSize);
    w32(12, bssVSize);
    w32(16, textRva);                  // entry = _start prelude at code[0]
    w32(20, textRva);
    w64(24, IMG_BASE_A64);
    w32(32, SECT_ALIGN_A64);
    w32(36, FILE_ALIGN_A64);
    data[optHdrOffset + 40] = 6;
    data[optHdrOffset + 48] = 6;
    {
        uint topRva = alignUp(idataRva + idataSize, SECT_ALIGN_A64);
        if (bss !is null) {
            uint bssTop = alignUp(bssRva + bssVSize, SECT_ALIGN_A64);
            if (bssTop > topRva) topRva = bssTop;
        }
        w32(56, topRva);
    }
    w32(60, alignUp(cast(uint) textStart, FILE_ALIGN_A64));
    data[optHdrOffset + 68] = 3;       // CONSOLE
    // 16 MB stack reserve+commit — Hofos's naive frames are large; Windows must
    // commit the stack up front (no auto-grow like Linux).
    w64(72, 0x1000000); w64(80, 0x1000000);
    w64(88, 0x100000);  w64(96, 0x1000);
    w32(108, 16);

    auto dd = 112;
    w32(dd +  1 * 8 + 0, dirRva); w32(dd +  1 * 8 + 4, 40);
    w32(dd + 12 * 8 + 0, iatRva); w32(dd + 12 * 8 + 4, 64);

    .write(outPath, data);

    writefln("nal (PE/ARM64): wrote %s", outPath);
    writefln("  input:    AArch64 ELF, %d PT_LOAD",        elf.loads.length);
    writefln("  rewrote:  %d svc sites -> DISPATCH",       svcSites);
    writefln("  argv:     %s",                             argvRewritten ? "prelude -> GetCommandLineA" : "(prelude not matched)");
    writefln("  helpers:  %d bytes (DISPATCH + HELP_ARGS)", helpers.length);
    writefln("  imports:  kernel32!GetStdHandle, WriteFile, ExitProcess, ReadFile, CreateFileA, CloseHandle, GetCommandLineA");
}
