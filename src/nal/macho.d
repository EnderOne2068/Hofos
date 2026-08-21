/**
 * macho.d — ELF64 -> Mach-O emitter for NAL (endian-parametric, multi-arch).
 *
 * Mirrors what writePE does for Windows: reads an Hofos-produced ELF, finds the
 * .text / .rodata / .bss PT_LOADs, and wraps them in a minimal Mach-O 64
 * executable.  The container is now driven by a per-target MachArch descriptor
 * (cpu ids, byte order, LC_UNIXTHREAD register file), selected from the ELF's
 * e_machine, so one code path emits:
 *   - x86-64  macOS (little-endian, EM_X86_64)   — Intel Macs
 *   - arm64   macOS (little-endian, EM_AARCH64)  — Apple Silicon
 *   - ppc64   macOS (BIG-endian,    EM_PPC64)    — classic Mac OS X (G5)
 * All header/load-command fields are written in the target's byte order via
 * w16/w32/w64(..., endian) — the "endian-parametric container" foundation.
 * (A future PDP-endian ISA would add the 2-3-0-1 word swap to the 32-bit path.)
 *
 * Linux -> macOS SYSCALL translation is implemented for x86-64 (BSD class
 * `num | 0x2000000`, same `0F 05`).  arm64/ppc use a different syscall ABI
 * (svc #0x80 with the number in x16 / `sc` with r0); those site rewrites are a
 * separate pass — for now those targets get a faithful container with the Linux
 * syscalls left in place (structurally valid; syscall pass pending).
 */
module macho;

import std.algorithm.comparison : max;
import std.array : appender, Appender;
import std.bitmanip : nativeToLittleEndian, peek;
import std.exception : enforce;
import std.file : write;
import std.stdio : writefln;
import std.system : Endian;

// Re-use the ELF reader + syscall-site matchers from nal.d
import nal : ElfView, LoadSeg, findText, findRodata, findBss,
             matchWritePattern, matchExitPattern, matchWrchHelper, ExitForm,
             matchReadHelper, matchCloseHelper, matchOpenHelper,
             matchCreateHelper, matchWriteSyscallHelper,
             alignUp, patchU32, patchU64;

enum MH_MAGIC_64       = 0xFEEDFACFu;      // stored in the TARGET's byte order (BE
                                           // Mach-O => bytes FE ED FA CF; LE => CF FA ED FE)
enum CPU_TYPE_X86_64   = 0x01000007u;
enum CPU_TYPE_ARM64    = 0x0100000Cu;      // Apple Silicon
enum CPU_TYPE_POWERPC64= 0x01000012u;      // classic Mac OS X (big-endian G5)
enum MH_EXECUTE        = 0x2u;
enum MH_DYLIB          = 0x6u;
enum MH_NOUNDEFS       = 0x1u;
enum MH_PIE            = 0x200000u;

enum LC_SEGMENT_64     = 0x19u;
enum LC_UNIXTHREAD     = 0x5u;
enum LC_MAIN           = 0x80000028u;      // (LC_REQ_DYLD bit set)

enum VM_PROT_READ      = 0x1u;
enum VM_PROT_WRITE     = 0x2u;
enum VM_PROT_EXECUTE   = 0x4u;

enum MACHO_PAGE_SIZE   = 0x1000u;
enum MACHO_LOAD_BASE   = 0x100000000UL;    // x86-64 macOS PIE base (informational)

// ---- endianness-parametric container writers --------------------------------
void w16(ref Appender!(ubyte[]) a, ushort v, Endian e) {
    if (e == Endian.littleEndian) { a.put(cast(ubyte)v); a.put(cast(ubyte)(v>>8)); }
    else                          { a.put(cast(ubyte)(v>>8)); a.put(cast(ubyte)v); }
}
void w32(ref Appender!(ubyte[]) a, uint v, Endian e) {
    if (e == Endian.littleEndian) foreach (k; 0 .. 4) a.put(cast(ubyte)(v >> (8*k)));
    else                          foreach (k; 0 .. 4) a.put(cast(ubyte)(v >> (8*(3-k))));
}
void w64(ref Appender!(ubyte[]) a, ulong v, Endian e) {
    if (e == Endian.littleEndian) foreach (k; 0 .. 8) a.put(cast(ubyte)(v >> (8*k)));
    else                          foreach (k; 0 .. 8) a.put(cast(ubyte)(v >> (8*(7-k))));
}
void put32at(ubyte[] d, size_t o, uint v, Endian e) {
    if (e == Endian.littleEndian) foreach (k; 0 .. 4) d[o+k] = cast(ubyte)(v >> (8*k));
    else                          foreach (k; 0 .. 4) d[o+k] = cast(ubyte)(v >> (8*(3-k)));
}
void put64at(ubyte[] d, size_t o, ulong v, Endian e) {
    if (e == Endian.littleEndian) foreach (k; 0 .. 8) d[o+k] = cast(ubyte)(v >> (8*k));
    else                          foreach (k; 0 .. 8) d[o+k] = cast(ubyte)(v >> (8*(7-k)));
}

// One target's Mach-O shape: cpu ids, byte order, and LC_UNIXTHREAD register file.
struct MachArch {
    uint   cputype, cpusubtype;
    Endian endian;
    uint   threadFlavor, threadCount;   // LC_UNIXTHREAD flavor + count (u32 words)
    uint   pcByteOff;                   // byte offset of the entry PC within the state
    bool   pcIs64;                      // PC register width
    bool   x86Rewrite;                  // do the x86 Linux->macOS syscall substitution
    string name;
}
MachArch selectArch(ushort machine) {
    switch (machine) {
        case 62:  return MachArch(CPU_TYPE_X86_64,    3, Endian.littleEndian, 4, 42, 128, true, true,  "x86-64"); // EM_X86_64,  x86_THREAD_STATE64 (RIP @ u64#16)
        case 183: return MachArch(CPU_TYPE_ARM64,     0, Endian.littleEndian, 6, 68, 256, true, false, "arm64");  // EM_AARCH64, ARM_THREAD_STATE64 (pc @ u64#32)
        case 21:  return MachArch(CPU_TYPE_POWERPC64, 0, Endian.bigEndian,    5, 76,   0, true, false, "ppc64");  // EM_PPC64,   PPC_THREAD_STATE64 (srr0 @ 0)
        default:  enforce(false, "macho: no Mach-O mapping for ELF e_machine " ~ machineName(machine)); assert(0);
    }
}
string machineName(ushort m) { import std.conv : to; return m.to!string; }

void padTo(ref Appender!(ubyte[]) a, size_t target) {
    while (a.data.length < target) a.put(cast(ubyte) 0);
}
void writeCStr16(ref Appender!(ubyte[]) a, string name) {
    foreach (i; 0 .. 16) a.put(cast(ubyte)(i < name.length ? name[i] : 0));
}

// ---- endian-aware Mach-O load-command emitters ------------------------------
void segCmd(ref Appender!(ubyte[]) buf, Endian e, string seg, ulong vmaddr, ulong vmsize,
            ulong fileoff, ulong filesize, uint maxprot, uint initprot, uint nsects, uint flags) {
    w32(buf, LC_SEGMENT_64, e);
    w32(buf, 72 + 80 * nsects, e);
    writeCStr16(buf, seg);
    w64(buf, vmaddr, e);  w64(buf, vmsize, e);  w64(buf, fileoff, e);  w64(buf, filesize, e);
    w32(buf, maxprot, e); w32(buf, initprot, e); w32(buf, nsects, e);  w32(buf, flags, e);
}
void sectCmd(ref Appender!(ubyte[]) buf, Endian e, string sect, string seg, ulong addr,
             ulong size, uint offset, uint alignLog2, uint flags) {
    writeCStr16(buf, sect); writeCStr16(buf, seg);
    w64(buf, addr, e); w64(buf, size, e);
    w32(buf, offset, e); w32(buf, alignLog2, e);
    w32(buf, 0, e); w32(buf, 0, e);                     // reloff, nreloc
    w32(buf, flags, e);
    w32(buf, 0, e); w32(buf, 0, e); w32(buf, 0, e);     // reserved1/2/3
}
// LC_UNIXTHREAD: zeroed register file with the entry PC patched in at a.pcByteOff.
void emitThread(ref Appender!(ubyte[]) buf, const ref MachArch a, ulong entry) {
    w32(buf, LC_UNIXTHREAD, a.endian);
    w32(buf, 16 + a.threadCount * 4, a.endian);
    w32(buf, a.threadFlavor, a.endian);
    w32(buf, a.threadCount, a.endian);
    size_t st = buf.data.length;
    foreach (_; 0 .. a.threadCount) w32(buf, 0, a.endian);
    if (a.pcIs64) put64at(buf.data, st + a.pcByteOff, entry, a.endian);
    else          put32at(buf.data, st + a.pcByteOff, cast(uint) entry, a.endian);
}

// ---- x86-64 Linux -> macOS syscall-site rewrites ----------------------------
/// mov rax,1 (Linux write) -> mov rax,0x2000004 (BSD-class write).
void macosWriteRewrite(ubyte[] code, size_t i) {
    auto imm = nativeToLittleEndian(cast(ulong) 0x2000004UL);
    foreach (k; 0 .. 8) code[i + 2 + k] = imm[k];
}
void macosExitRewrite(ubyte[] code, size_t i, ExitForm form) {
    // Linux exit syscall 60; macOS exit = class<<24 | 1 = 0x2000001.  The
    // mov-rax-imm64 starts at +5 (prelude form) or +2 (simple form).
    size_t immStart = (form == ExitForm.prelude) ? (i + 5) : (i + 2);
    auto imm = nativeToLittleEndian(cast(ulong) 0x2000001UL);
    foreach (k; 0 .. 8) code[immStart + k] = imm[k];
}
void macosWrchRewrite(ubyte[] code, size_t i) {
    // 38-byte wrch helper: replace with the same shape but mov eax,0x02000004.
    static immutable ubyte[38] sigShort = [
        0x55, 0x48, 0x89, 0xE5, 0x48, 0x83, 0xEC, 0x10,
        0x40, 0x88, 0x7D, 0xFF,
        0xB8, 0x04, 0x00, 0x00, 0x02,                                    // mov eax, 0x02000004
        0xBF, 0x01, 0x00, 0x00, 0x00,                                    // mov edi, 1
        0x48, 0x8D, 0x75, 0xFF,                                          // lea rsi, [rbp-1]
        0xBA, 0x01, 0x00, 0x00, 0x00,                                    // mov edx, 1
        0x0F, 0x05,                                                      // syscall
        0x48, 0x89, 0xEC, 0x5D, 0xC3 ];
    foreach (k; 0 .. 38) code[i + k] = sigShort[k];
}
// Write a 32-bit LE value at code[off..off+4) (a `mov r32,imm32` immediate).
void macosImm32(ubyte[] code, size_t off, uint v) {
    auto imm = nativeToLittleEndian(v);
    foreach (k; 0 .. 4) code[off + k] = imm[k];
}
void macosReadRewrite  (ubyte[] code, size_t i) { macosImm32(code, i + 5,  0x02000003u); }
void macosCloseRewrite (ubyte[] code, size_t i) { macosImm32(code, i + 5,  0x02000006u); }
void macosFwriteRewrite(ubyte[] code, size_t i) { macosImm32(code, i + 5,  0x02000004u); }
void macosOpenRewrite  (ubyte[] code, size_t i) { macosImm32(code, i + 9,  0x02000005u); }
void macosCreateRewrite(ubyte[] code, size_t i) {
    // macOS open flags: O_WRONLY|O_CREAT|O_TRUNC = 0x601 (vs Linux 0x241).
    macosImm32(code, i + 5,  0x00000601u);
    macosImm32(code, i + 15, 0x02000005u);
}

/// Top-level: read ELF, byte-rewrite syscall sites (x86-64 only) for macOS, then
/// wrap in a Mach-O of the ELF's architecture (x86-64/arm64 LE, ppc64 BE).
void writeMachO(string outPath, ElfView elf, bool asDylib = false) {
    auto txt = findText(elf);
    auto rod = findRodata(elf);
    auto bss = findBss(elf);
    enforce(txt !is null, "elf: no executable PT_LOAD");

    auto arch = selectArch(elf.hdr.machine);
    auto e    = arch.endian;

    // ---- Byte-rewrite syscall sites for macOS (x86-64 only) ----------------
    ubyte[] code = txt.bytes.dup;
    uint nRewrites = 0;
    if (arch.x86Rewrite) {
        for (size_t i = 0; i < code.length; ) {
            ulong bv, ln;
            if (matchWritePattern(code, i, bv, ln)) { macosWriteRewrite(code, i);  ++nRewrites; i += 42; continue; }
            if (matchWrchHelper(code, i))           { macosWrchRewrite(code, i);   ++nRewrites; i += 38; continue; }
            if (matchCreateHelper(code, i))         { macosCreateRewrite(code, i); ++nRewrites; i += 23; continue; }
            if (matchOpenHelper(code, i))           { macosOpenRewrite(code, i);   ++nRewrites; i += 17; continue; }
            if (matchReadHelper(code, i))           { macosReadRewrite(code, i);   ++nRewrites; i += 13; continue; }
            if (matchCloseHelper(code, i))          { macosCloseRewrite(code, i);  ++nRewrites; i += 13; continue; }
            if (matchWriteSyscallHelper(code, i))   { macosFwriteRewrite(code, i); ++nRewrites; i += 13; continue; }
            auto ef = matchExitPattern(code, i);
            if (ef != ExitForm.none)                { macosExitRewrite(code, i, ef); ++nRewrites; i += 15; continue; }
            ++i;
        }
    }

    // ---- Layout: __PAGEZERO + __TEXT [+ __DATA_CONST] [+ __DATA] + thread ----
    ulong textVAddr   = txt.vaddr;
    ulong rodataVAddr = (rod !is null) ? rod.vaddr : 0;
    ulong bssVAddr    = (bss !is null) ? bss.vaddr : 0;
    ulong bssSize     = (bss !is null) ? bss.memsz : 0;
    ulong rodataSize  = (rod !is null) ? rod.bytes.length : 0;

    uint nCommands = 2;                        // __PAGEZERO + __TEXT
    if (rod !is null) ++nCommands;
    if (bss !is null) ++nCommands;
    ++nCommands;                               // LC_UNIXTHREAD

    uint cmdSize = 72;                          // __PAGEZERO
    cmdSize += 72 + 80;                         // __TEXT + __text
    if (rod !is null) cmdSize += 72 + 80;
    if (bss !is null) cmdSize += 72 + 80;
    cmdSize += 16 + arch.threadCount * 4;       // LC_UNIXTHREAD

    uint  hdrSize     = 32 + cmdSize;
    uint  textFileOff = alignUp(hdrSize, MACHO_PAGE_SIZE);
    ulong textVMSize  = alignUp(cast(uint) code.length, MACHO_PAGE_SIZE);

    auto buf = appender!(ubyte[])();

    // ---- Mach-O header (target byte order) ---------------------------------
    w32(buf, MH_MAGIC_64, e);
    w32(buf, arch.cputype, e);
    w32(buf, arch.cpusubtype, e);
    w32(buf, asDylib ? MH_DYLIB : MH_EXECUTE, e);
    w32(buf, nCommands, e);
    w32(buf, cmdSize, e);
    w32(buf, MH_NOUNDEFS, e);                   // not MH_PIE — fixed addresses
    w32(buf, 0, e);                             // reserved

    segCmd(buf, e, "__PAGEZERO", 0, textVAddr, 0, 0, 0, 0, 0, 0);

    segCmd(buf, e, "__TEXT", textVAddr, textVMSize, textFileOff, code.length,
           VM_PROT_READ | VM_PROT_EXECUTE, VM_PROT_READ | VM_PROT_EXECUTE, 1, 0);
    sectCmd(buf, e, "__text", "__TEXT", textVAddr, code.length, textFileOff, 4, 0x80000400);

    uint nextFileOff = cast(uint)(textFileOff + textVMSize);

    if (rod !is null) {
        ulong rodataVMSize = alignUp(cast(uint) rodataSize, MACHO_PAGE_SIZE);
        if (rodataVMSize == 0) rodataVMSize = MACHO_PAGE_SIZE;
        segCmd(buf, e, "__DATA_CONST", rodataVAddr, rodataVMSize, nextFileOff, rodataSize,
               VM_PROT_READ, VM_PROT_READ, 1, 0);
        sectCmd(buf, e, "__const", "__DATA_CONST", rodataVAddr, rodataSize, nextFileOff, 3, 0);
        nextFileOff = cast(uint)(nextFileOff + rodataVMSize);
    }

    if (bss !is null) {
        segCmd(buf, e, "__DATA", bssVAddr, bssSize, 0, 0,
               VM_PROT_READ | VM_PROT_WRITE, VM_PROT_READ | VM_PROT_WRITE, 1, 0);
        sectCmd(buf, e, "__bss", "__DATA", bssVAddr, bssSize, 0, 4, 1);   // S_ZEROFILL
    }

    emitThread(buf, arch, elf.entry);

    // ---- Pad to text file offset, then code + rodata -----------------------
    padTo(buf, textFileOff);
    buf.put(code);
    if (rod !is null && rodataSize > 0) {
        padTo(buf, textFileOff + textVMSize);
        buf.put(rod.bytes);
    }

    .write(outPath, buf.data);

    writefln("nal (macho): wrote %s  [%s, %s]", outPath, arch.name,
             e == Endian.littleEndian ? "little-endian" : "big-endian");
    writefln("  input:    entry 0x%x, %d PT_LOAD", elf.entry, elf.loads.length);
    if (arch.x86Rewrite)
        writefln("  rewrote:  %d syscall sites for macOS BSD class", nRewrites);
    else
        writefln("  syscalls: %s Linux->macOS translation is a separate pass (not yet applied)", arch.name);
    writefln("  text:     0x%x VA, %d bytes", textVAddr, code.length);
    if (rod !is null) writefln("  rodata:   0x%x VA, %d bytes", rodataVAddr, rodataSize);
    if (bss !is null) writefln("  bss:      0x%x VA, %d bytes (zero-init)", bssVAddr, bssSize);
}
