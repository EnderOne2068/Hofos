/**
 * NAL — the Hofos linker.  ELF64 -> PE32+.
 *
 * v2 strategy: keep the ELF .text bytes intact (so all of the codegen's jump
 * offsets keep their meaning) but rewrite Linux syscall patterns in-place to
 * Win32-equivalent code of exactly the same length.  Each rewritten span
 * `call`s a small helper that we splice into .text at the end; the helper
 * does the GetStdHandle / WriteFile / ReadFile / ExitProcess work via the
 * PE32+ IAT.
 *
 * Recognised patterns (produced by Hofos cg.b):
 *
 *   WRITE  (42 bytes): mov rax,1; mov rdi,1; mov rsi,imm64; mov rdx,imm64; syscall
 *                      -> mov r8,rdx; mov rdx,rsi; sub rsp,40; call HELP_WRITE;
 *                         add rsp,40; NOP × 23   (also 42 bytes)
 *
 *   EXIT   (15 bytes): mov rax,60; xor edi,edi; syscall
 *                      -> xor ecx,ecx; sub rsp,40; call HELP_EXIT; NOP × 4
 *
 *   READ   (13 bytes): the __read helper body
 *                      push rbp; mov rbp,rsp; mov eax,0(SYS_read); syscall; leave; ret
 *                      -> push rbp; mov rbp,rsp; call HELP_READ; leave; ret; NOP × 2
 *                      HELP_READ branches on fd: 0 => GetStdHandle(STD_INPUT),
 *                      nonzero => a CreateFile HANDLE; then ReadFile.  So
 *                      rdch/readline/readn work on native Windows for both
 *                      console stdin and opened files.
 *
 *   OPEN   (17 bytes): __open body (SYS_open, O_RDONLY)
 *                      -> thunk -> HELP_OPEN = CreateFileA(path, GENERIC_READ,
 *                      FILE_SHARE_READ, OPEN_EXISTING).  Returns the HANDLE.
 *
 *   CLOSE  (13 bytes): __close body (SYS_close)
 *                      -> thunk -> HELP_CLOSE = CloseHandle(handle).
 *
 * The helpers live just past the user's code; they're reachable from any
 * rewrite site by a 32-bit `call rel32` (E8 disp32).  The kernel32 import
 * table carries 6 names: GetStdHandle, WriteFile, ExitProcess, ReadFile,
 * CreateFileA, CloseHandle (IAT slot order MUST match HelperRel.iatIdx 0..5).
 * File I/O is read-only (matches the runtime's O_RDONLY open); writing files
 * would need an O_WRONLY|O_CREAT open path added across cg.b + the runtime.
 *
 * Usage:  nal input.elf output.exe
 * Build:  dmd -m64 -of=C:\Hofos\bin\nal.exe nal.d kernel32.lib
 */

module nal;

import std.stdio;
import std.file;
import std.bitmanip : nativeToLittleEndian, peek;
import std.system : Endian;
import std.array : appender, Appender;
import std.exception : enforce;

// ============================================================================
// ELF64 minimal types
// ============================================================================

struct Elf64Header {
    ubyte[16] ident;
    ushort type;
    ushort machine;
    uint   version_;
    ulong  entry;
    ulong  phoff;
    ulong  shoff;
    uint   flags;
    ushort ehsize;
    ushort phentsize;
    ushort phnum;
    ushort shentsize;
    ushort shnum;
    ushort shstrndx;
}

struct Elf64Phdr {
    uint   p_type;
    uint   p_flags;
    ulong  p_offset;
    ulong  p_vaddr;
    ulong  p_paddr;
    ulong  p_filesz;
    ulong  p_memsz;
    ulong  p_align;
}

enum PT_LOAD = 1u;
enum PF_X = 1u, PF_W = 2u, PF_R = 4u;

struct LoadSeg {
    ulong  vaddr;
    uint   flags;
    ubyte[] bytes;
    ulong  memsz;     // p_memsz; > bytes.length means tail is zero-init (.bss)
}

struct ElfView {
    Elf64Header hdr;
    Elf64Phdr[] phs;
    LoadSeg[]   loads;
    ulong       entry;
    ubyte[]     embed;   // bundled extra inputs (PE only); see mergeInputs/writePE
}

ElfView readElf(string path) {
    auto raw = cast(ubyte[]) read(path);
    enforce(raw.length >= Elf64Header.sizeof, "elf: file too short");
    enforce(raw[0..4] == [0x7Fu, cast(ubyte)'E', cast(ubyte)'L', cast(ubyte)'F'],
            "elf: bad magic");
    enforce(raw[4] == 2, "elf: not ELFCLASS64");
    enforce(raw[5] == 1, "elf: not little-endian");

    ElfView v;
    v.hdr = *cast(Elf64Header*) raw.ptr;
    v.entry = v.hdr.entry;

    v.phs.length = v.hdr.phnum;
    foreach (i; 0 .. v.hdr.phnum) {
        auto off = v.hdr.phoff + i * v.hdr.phentsize;
        v.phs[i] = *cast(Elf64Phdr*) (raw.ptr + off);
    }

    foreach (ph; v.phs) {
        if (ph.p_type == PT_LOAD) {
            LoadSeg s;
            s.vaddr = ph.p_vaddr;
            s.flags = ph.p_flags;
            s.bytes = raw[cast(size_t) ph.p_offset
                          .. cast(size_t) (ph.p_offset + ph.p_filesz)].dup;
            s.memsz = ph.p_memsz;
            v.loads ~= s;
        }
    }
    enforce(v.loads.length > 0, "elf: no PT_LOAD segments");
    return v;
}

LoadSeg* findText(ref ElfView v) {
    foreach (ref s; v.loads) if (s.flags & PF_X) return &s;
    return null;
}

LoadSeg* findRodata(ref ElfView v) {
    foreach (ref s; v.loads) {
        if ((s.flags & PF_R) && !(s.flags & PF_W) && !(s.flags & PF_X))
            return &s;
    }
    return null;
}

/// .bss-equivalent: writable PT_LOAD with no file backing.  Hofos emits one
/// for the getvec heap at fixed VA 0x500000 (size 1 MB) so it maps cleanly
/// onto a Windows PE uninit-data section.
LoadSeg* findBss(ref ElfView v) {
    foreach (ref s; v.loads) {
        if ((s.flags & PF_R) && (s.flags & PF_W) && s.bytes.length == 0
            && s.memsz > 0)
            return &s;
    }
    return null;
}

/// Initialized data: a writable PT_LOAD that DOES have file bytes (unlike the
/// zero-init .bss, which has none).  Hofos emits one for its mutable globals.
/// NAL previously ignored it, so the PE (a) ran with zeroed globals and, worse,
/// (b) had a VA hole where the data segment should be — and the Windows image
/// loader rejects an image with a gap between one section's end and the next
/// section's VirtualAddress ("%1 is not a valid Win32 application").  We now map
/// it as an initialised, writable section and stretch VirtualSizes to close all
/// gaps (see writePE).
LoadSeg* findData(ref ElfView v) {
    foreach (ref s; v.loads) {
        if ((s.flags & PF_R) && (s.flags & PF_W) && s.bytes.length > 0)
            return &s;
    }
    return null;
}

/// Bundle additional input ELFs into the first one's output so a single file
/// contains them all.  The FIRST input is the entry and runs completely
/// UNCHANGED — its .text/.rodata/.idata/.bss are untouched; the extra inputs go
/// into a dedicated read-only `.embed` section placed ABOVE the .bss heap
/// (writePE), so they never collide with the program's own layout.
///
/// Each extra input contributes its .text + .rodata bytes (kept adjacent). They
/// are bundled READ-ONLY: making them executable and resolving cross-file CALLs
/// needs a symbol table + relocations, which Hofos ELF *executables* don't carry,
/// so true multi-object linking awaits relocatable-object output.  This still
/// means `nal a.elf b.elf -out x.exe` no longer drops b — x runs a and embeds b.
ElfView mergeInputs(string[] paths) {
    auto v = readElf(paths[0]);
    foreach (extra; paths[1 .. $]) {
        auto e2 = readElf(extra);
        if (auto t2 = findText(e2))   v.embed ~= t2.bytes;
        if (auto r2 = findRodata(e2)) v.embed ~= r2.bytes;
    }
    return v;
}

// ============================================================================
// Linux→Win32 byte-level rewriting
// ============================================================================

/// Match the 42-byte WRITE syscall pattern at offset `i` in `code`.
/// Returns true and fills `bufVA`/`len` if matched.
bool matchWritePattern(in ubyte[] code, size_t i, out ulong bufVA, out ulong len) {
    if (i + 42 > code.length) return false;
    // 0:  48 B8 01 00 00 00 00 00 00 00     mov rax, 1
    if (code[i+0]!=0x48 || code[i+1]!=0xB8) return false;
    if (code[i+2]!=0x01) return false;
    foreach (j; 3 .. 10) if (code[i+j] != 0) return false;
    // 10: 48 BF 01 00 00 00 00 00 00 00     mov rdi, 1
    if (code[i+10]!=0x48 || code[i+11]!=0xBF) return false;
    if (code[i+12]!=0x01) return false;
    foreach (j; 13 .. 20) if (code[i+j] != 0) return false;
    // 20: 48 BE imm64                       mov rsi, bufVA
    if (code[i+20]!=0x48 || code[i+21]!=0xBE) return false;
    bufVA = code[i+22..i+30].peek!(ulong, Endian.littleEndian);
    // 30: 48 BA imm64                       mov rdx, len
    if (code[i+30]!=0x48 || code[i+31]!=0xBA) return false;
    len = code[i+32..i+40].peek!(ulong, Endian.littleEndian);
    // 40: 0F 05                             syscall
    if (code[i+40]!=0x0F || code[i+41]!=0x05) return false;
    return true;
}

/// Exit-pattern shape. Both are 15 bytes long.
enum ExitForm { none, prelude, simple }

/// Match the 15-byte EXIT syscall pattern at offset `i`.
///   prelude: 48 89 C7 (mov rdi,rax) 48 B8 3C 00..00 (mov rax,60) 0F 05 (syscall)
///            — return value is in rax (forward it to ExitProcess).
///   simple:  48 B8 3C 00..00 (mov rax,60) 48 31 FF (xor rdi,rdi) 0F 05 (syscall)
///            — exit-zero idiom; zero ecx ourselves.
/// Match the 38-byte `wrch` helper that Hofos's codegen splices into .text:
/// it writes one byte (from `dil`) via syscall #1 from a stack slot.  Layout:
///
///   55                    push rbp                       [0]
///   48 89 E5              mov  rbp, rsp                  [1..3]
///   48 83 EC 10           sub  rsp, 16                   [4..7]
///   40 88 7D FF           mov  [rbp-1], dil              [8..11]
///   B8 01 00 00 00        mov  eax, 1                    [12..16]
///   BF 01 00 00 00        mov  edi, 1                    [17..21]
///   48 8D 75 FF           lea  rsi, [rbp-1]              [22..25]
///   BA 01 00 00 00        mov  edx, 1                    [26..30]
///   0F 05                 syscall                        [31..32]
///   48 89 EC              mov  rsp, rbp                  [33..35]
///   5D                    pop  rbp                       [36]
///   C3                    ret                            [37]
bool matchWrchHelper(in ubyte[] code, size_t i) {
    if (i + 38 > code.length) return false;
    static immutable ubyte[38] sig = [
        0x55, 0x48, 0x89, 0xE5, 0x48, 0x83, 0xEC, 0x10,
        0x40, 0x88, 0x7D, 0xFF, 0xB8, 0x01, 0x00, 0x00,
        0x00, 0xBF, 0x01, 0x00, 0x00, 0x00, 0x48, 0x8D,
        0x75, 0xFF, 0xBA, 0x01, 0x00, 0x00, 0x00, 0x0F,
        0x05, 0x48, 0x89, 0xEC, 0x5D, 0xC3 ];
    foreach (j; 0 .. 38) if (code[i+j] != sig[j]) return false;
    return true;
}

/// Replace the 38-byte wrch helper with a Win64 version that calls HELP_WRITE
/// with the stack byte (length=1).  The replacement is exactly 38 bytes so
/// it occupies the same .text slot — call-disp32s in user code still resolve.
///
///   55                push rbp                        [0]
///   48 89 E5          mov  rbp, rsp                   [1..3]
///   48 83 EC 10       sub  rsp, 16                    [4..7]
///   40 88 7D FF       mov  [rbp-1], dil               [8..11]
///   48 8D 55 FF       lea  rdx, [rbp-1]               [12..15]
///   41 B8 01 00 00 00 mov  r8d, 1                     [16..21]
///   48 83 EC 28       sub  rsp, 40                    [22..25]
///   E8 disp32         call HELP_WRITE                 [26..30]
///   48 83 C4 28       add  rsp, 40                    [31..34]
///   C9                leave                           [35]
///   C3                ret                             [36]
///   90                nop                             [37]
void writeWrchRewrite(ubyte[] code, size_t i, int callDisp) {
    static immutable ubyte[26] head = [
        0x55, 0x48, 0x89, 0xE5, 0x48, 0x83, 0xEC, 0x10,
        0x40, 0x88, 0x7D, 0xFF, 0x48, 0x8D, 0x55, 0xFF,
        0x41, 0xB8, 0x01, 0x00, 0x00, 0x00, 0x48, 0x83,
        0xEC, 0x28 ];
    static immutable ubyte[7]  tail = [
        0x48, 0x83, 0xC4, 0x28, 0xC9, 0xC3, 0x90 ];
    foreach (j; 0 .. 26) code[i+j] = head[j];
    code[i+26] = 0xE8;
    foreach (k, b; nativeToLittleEndian(callDisp)) code[i+27+k] = b;
    foreach (j; 0 .. 7) code[i+31+j] = tail[j];
}

/// Replace a small syscall-helper body (__read / __open / __close)
/// with a thunk that calls the matching Win32 helper.  The System V args
/// (rdi/rsi/rdx) are still intact at the call.  `slotLen` is the original
/// helper's byte length (13 for read/close, 17 for open) so the thunk occupies
/// the same .text slot — caller disp32s still resolve.
///
///   55              push rbp            [0]
///   48 89 E5        mov  rbp, rsp       [1..3]
///   E8 disp32       call HELPER         [4..8]   (disp32 at [5..8])
///   C9              leave               [9]
///   C3              ret                 [10]
///   90 ...          nop pad to slotLen  [11..]
void writeCallThunk(ubyte[] code, size_t i, int callDisp, size_t slotLen) {
    code[i+0] = 0x55;
    code[i+1] = 0x48; code[i+2] = 0x89; code[i+3] = 0xE5;
    code[i+4] = 0xE8;
    foreach (k, b; nativeToLittleEndian(callDisp)) code[i+5+k] = b;
    code[i+9]  = 0xC9;
    code[i+10] = 0xC3;
    foreach (j; 11 .. slotLen) code[i+j] = 0x90;
}

/// Match the 13-byte __read helper:
///   55 48 89 E5  B8 00 00 00 00  0F 05  C9 C3
///   push rbp; mov rbp,rsp; mov eax,0(SYS_read); syscall; leave; ret
/// The `B8 00000000` (mov eax,0) + `0F 05` (syscall) is unique to read.
bool matchReadHelper(in ubyte[] code, size_t i) {
    if (i + 13 > code.length) return false;
    static immutable ubyte[13] sig = [
        0x55, 0x48, 0x89, 0xE5, 0xB8, 0x00, 0x00, 0x00,
        0x00, 0x0F, 0x05, 0xC9, 0xC3 ];
    foreach (j; 0 .. 13) if (code[i+j] != sig[j]) return false;
    return true;
}

/// Match the 13-byte __close helper (SYS_close = 3):
///   55 48 89 E5  B8 03 00 00 00  0F 05  C9 C3
bool matchCloseHelper(in ubyte[] code, size_t i) {
    if (i + 13 > code.length) return false;
    static immutable ubyte[13] sig = [
        0x55, 0x48, 0x89, 0xE5, 0xB8, 0x03, 0x00, 0x00,
        0x00, 0x0F, 0x05, 0xC9, 0xC3 ];
    foreach (j; 0 .. 13) if (code[i+j] != sig[j]) return false;
    return true;
}

/// Match the 17-byte __open helper (SYS_open = 2, flags/mode zeroed):
///   55 48 89 E5  31 F6  31 D2  B8 02 00 00 00  0F 05  C9 C3
bool matchOpenHelper(in ubyte[] code, size_t i) {
    if (i + 17 > code.length) return false;
    static immutable ubyte[17] sig = [
        0x55, 0x48, 0x89, 0xE5, 0x31, 0xF6, 0x31, 0xD2,
        0xB8, 0x02, 0x00, 0x00, 0x00, 0x0F, 0x05, 0xC9, 0xC3 ];
    foreach (j; 0 .. 17) if (code[i+j] != sig[j]) return false;
    return true;
}

/// Match the 13-byte __write helper (SYS_write = 1):
///   55 48 89 E5  B8 01 00 00 00  0F 05  C9 C3
bool matchWriteSyscallHelper(in ubyte[] code, size_t i) {
    if (i + 13 > code.length) return false;
    static immutable ubyte[13] sig = [
        0x55, 0x48, 0x89, 0xE5, 0xB8, 0x01, 0x00, 0x00,
        0x00, 0x0F, 0x05, 0xC9, 0xC3 ];
    foreach (j; 0 .. 13) if (code[i+j] != sig[j]) return false;
    return true;
}

/// Match the 23-byte __create helper (open for write, SYS_open = 2):
///   55 48 89 E5  BE 41 02 00 00 (mov esi,577)  BA .. .. .. .. (mov edx,MODE)
///   B8 02 00 00 00  0F 05  C9 C3
/// The mode immediate (bytes 10..13) is IGNORED: cg.b emits 0644 or 0755 there
/// (0755 makes output runnable), and the Unix mode is irrelevant to CreateFileA
/// anyway.  Hard-coding it once silently broke the whole Windows write path.
bool matchCreateHelper(in ubyte[] code, size_t i) {
    if (i + 23 > code.length) return false;
    static immutable ubyte[23] sig = [
        0x55, 0x48, 0x89, 0xE5, 0xBE, 0x41, 0x02, 0x00, 0x00,
        0xBA, 0xA4, 0x01, 0x00, 0x00, 0xB8, 0x02, 0x00, 0x00, 0x00,
        0x0F, 0x05, 0xC9, 0xC3 ];
    foreach (j; 0 .. 23) {
        if (j >= 10 && j <= 13) continue;   // mode immediate varies (0644 / 0755)
        if (code[i+j] != sig[j]) return false;
    }
    return true;
}

/// Match the 26-byte __syscall6 helper (raw Linux syscall passthrough):
///   55 48 89 E5  48 89 F8 (mov rax,rdi=num)  48 89 F7  48 89 D6  48 89 CA
///   4D 89 C2  4D 89 C8  0F 05 (syscall)  C9 C3
/// Executing a Linux `syscall` on Windows faults, so NAL turns this helper into
/// a thunk that calls HELP_SYSCALL6, a Win32 dispatch on the syscall number.
bool matchSyscall6Helper(in ubyte[] code, size_t i) {
    if (i + 26 > code.length) return false;
    static immutable ubyte[26] sig = [
        0x55, 0x48,0x89,0xE5, 0x48,0x89,0xF8, 0x48,0x89,0xF7,
        0x48,0x89,0xD6, 0x48,0x89,0xCA, 0x4D,0x89,0xC2, 0x4D,0x89,0xC8,
        0x0F,0x05, 0xC9, 0xC3 ];
    foreach (j; 0 .. 26) if (code[i+j] != sig[j]) return false;
    return true;
}

ExitForm matchExitPattern(in ubyte[] code, size_t i) {
    if (i + 15 > code.length) return ExitForm.none;
    if (code[i+0]==0x48 && code[i+1]==0x89 && code[i+2]==0xC7 &&
        code[i+3]==0x48 && code[i+4]==0xB8 && code[i+5]==0x3C) {
        bool zeros = true;
        foreach (j; 6 .. 13) if (code[i+j] != 0) { zeros = false; break; }
        if (zeros && code[i+13]==0x0F && code[i+14]==0x05) return ExitForm.prelude;
    }
    if (code[i+0]==0x48 && code[i+1]==0xB8 && code[i+2]==0x3C) {
        bool zeros = true;
        foreach (j; 3 .. 10) if (code[i+j] != 0) { zeros = false; break; }
        if (zeros && code[i+10]==0x48 && code[i+11]==0x31 && code[i+12]==0xFF
            && code[i+13]==0x0F && code[i+14]==0x05) return ExitForm.simple;
    }
    return ExitForm.none;
}

/// Write the Win32 WRITE-rewrite at `code[i..i+42]`.
/// The original 42 bytes loaded rsi=buf and rdx=len; we destroyed those
/// loads, so we re-emit the buf/len immediates ourselves before the helper
/// call.  Layout (42 bytes total):
///
///     48 BA imm64          mov rdx, bufVA       (10 bytes)
///     41 B8 imm32          mov r8d, len          (6 bytes)
///     48 83 EC 28          sub rsp, 40           (4 bytes)
///     E8 disp32            call helper           (5 bytes)
///     48 83 C4 28          add rsp, 40           (4 bytes)
///     90 × 13              pad                  (13 bytes)
void writeWriteRewrite(ubyte[] code, size_t i, int callDisp, ulong bufVA, ulong len) {
    size_t p = i;
    code[p++] = 0x48; code[p++] = 0xBA;
    foreach (b; nativeToLittleEndian(bufVA))            code[p++] = b;
    code[p++] = 0x41; code[p++] = 0xB8;
    foreach (b; nativeToLittleEndian(cast(uint) len))    code[p++] = b;
    code[p++] = 0x48; code[p++] = 0x83; code[p++] = 0xEC; code[p++] = 0x28;
    code[p++] = 0xE8;
    foreach (b; nativeToLittleEndian(callDisp))         code[p++] = b;
    code[p++] = 0x48; code[p++] = 0x83; code[p++] = 0xC4; code[p++] = 0x28;
    while (p < i + 42) code[p++] = 0x90;
}

/// Write the Win32 EXIT-rewrite at `code[i..i+15]`.
/// For the prelude form we copy eax (the return value of `start`) into ecx
/// because the original `mov rdi, rax` is being overwritten — we have to
/// stage the exit code ourselves.
/// For the simple form we zero ecx (matching the original `xor rdi, rdi`).
void writeExitRewrite(ubyte[] code, size_t i, int callDisp, ExitForm form) {
    size_t p = i;
    if (form == ExitForm.prelude) {
        // 89 C1   mov ecx, eax    (forward start's return value)
        code[p++] = 0x89; code[p++] = 0xC1;
    } else {
        // 31 C9   xor ecx, ecx    (exit 0)
        code[p++] = 0x31; code[p++] = 0xC9;
    }
    // 48 83 EC 28   sub rsp, 40
    code[p++] = 0x48; code[p++] = 0x83; code[p++] = 0xEC; code[p++] = 0x28;
    // E8 disp32     call exit helper
    code[p++] = 0xE8;
    auto d = nativeToLittleEndian(callDisp);
    foreach (b; d) code[p++] = b;
    while (p < i + 15) code[p++] = 0x90;
}

// ============================================================================
// Helper code (Win32-side: GetStdHandle + WriteFile / ExitProcess)
// ============================================================================
//
// HELP_WRITE  takes rdx = buf, r8 = len; calls Win32 APIs and returns.
//
//   push rbp                            55
//   mov rbp, rsp                        48 89 E5
//   sub rsp, 64                         48 83 EC 40
//   mov [rbp-8], rdx                    48 89 55 F8
//   mov [rbp-16], r8                    4C 89 45 F0
//   mov ecx, -11                        B9 F5 FF FF FF
//   call [rip + GetStdHandle_IAT]       FF 15 disp32      <- patch1
//   mov rcx, rax                        48 89 C1
//   mov rdx, [rbp-8]                    48 8B 55 F8
//   mov r8,  [rbp-16]                   4C 8B 45 F0
//   lea r9, [rbp-24]                    4C 8D 4D E8
//   mov qword [rsp+32], 0               48 C7 44 24 20 00 00 00 00
//   call [rip + WriteFile_IAT]          FF 15 disp32      <- patch2
//   leave                               C9
//   ret                                 C3
//
// HELP_EXIT  enters with ecx = exit code:
//
//   sub rsp, 40                         48 83 EC 28
//   call [rip + ExitProcess_IAT]        FF 15 disp32      <- patch3
//   int3                                CC

struct HelperRel {
    size_t off;        // offset in helper bytes where the disp32 starts
    int    iatIdx;     // 0 = GetStdHandle, 1 = WriteFile, 2 = ExitProcess
}

/// Returns (helperBytes, [relocs]) where relocs say which IAT slot each call
/// uses.  The disp32 fields are zero — caller patches once IAT RVA is known.
ubyte[] buildHelpers(out HelperRel[] relocs, out size_t helpWriteOff,
                     out size_t helpExitOff, out size_t helpReadOff,
                     out size_t helpOpenOff, out size_t helpCloseOff,
                     out size_t helpCreateOff, out size_t helpFwriteOff,
                     out size_t helpSyscall6Off, out size_t helpArgsOff) {
    auto b = appender!(ubyte[])();
    // ---- HELP_WRITE ----
    helpWriteOff = b.data.length;
    b.put(cast(ubyte) 0x55);
    b.put(cast(ubyte) 0x48); b.put(cast(ubyte) 0x89); b.put(cast(ubyte) 0xE5);
    b.put(cast(ubyte) 0x48); b.put(cast(ubyte) 0x83); b.put(cast(ubyte) 0xEC); b.put(cast(ubyte) 0x40);
    b.put(cast(ubyte) 0x48); b.put(cast(ubyte) 0x89); b.put(cast(ubyte) 0x55); b.put(cast(ubyte) 0xF8);
    b.put(cast(ubyte) 0x4C); b.put(cast(ubyte) 0x89); b.put(cast(ubyte) 0x45); b.put(cast(ubyte) 0xF0);
    b.put(cast(ubyte) 0xB9);
    foreach (x; nativeToLittleEndian(cast(uint) 0xFFFFFFF5)) b.put(x);
    b.put(cast(ubyte) 0xFF); b.put(cast(ubyte) 0x15);
    relocs ~= HelperRel(b.data.length, 0);
    foreach (_; 0 .. 4) b.put(cast(ubyte) 0);
    b.put(cast(ubyte) 0x48); b.put(cast(ubyte) 0x89); b.put(cast(ubyte) 0xC1);
    b.put(cast(ubyte) 0x48); b.put(cast(ubyte) 0x8B); b.put(cast(ubyte) 0x55); b.put(cast(ubyte) 0xF8);
    b.put(cast(ubyte) 0x4C); b.put(cast(ubyte) 0x8B); b.put(cast(ubyte) 0x45); b.put(cast(ubyte) 0xF0);
    b.put(cast(ubyte) 0x4C); b.put(cast(ubyte) 0x8D); b.put(cast(ubyte) 0x4D); b.put(cast(ubyte) 0xE8);
    b.put(cast(ubyte) 0x48); b.put(cast(ubyte) 0xC7); b.put(cast(ubyte) 0x44); b.put(cast(ubyte) 0x24); b.put(cast(ubyte) 0x20);
    foreach (_; 0 .. 4) b.put(cast(ubyte) 0);
    b.put(cast(ubyte) 0xFF); b.put(cast(ubyte) 0x15);
    relocs ~= HelperRel(b.data.length, 1);
    foreach (_; 0 .. 4) b.put(cast(ubyte) 0);
    b.put(cast(ubyte) 0xC9);
    b.put(cast(ubyte) 0xC3);

    // ---- HELP_EXIT ----
    helpExitOff = b.data.length;
    b.put(cast(ubyte) 0x48); b.put(cast(ubyte) 0x83); b.put(cast(ubyte) 0xEC); b.put(cast(ubyte) 0x28);
    b.put(cast(ubyte) 0xFF); b.put(cast(ubyte) 0x15);
    relocs ~= HelperRel(b.data.length, 2);
    foreach (_; 0 .. 4) b.put(cast(ubyte) 0);
    b.put(cast(ubyte) 0xCC);

    // ---- HELP_READ ----
    // Entered with rsi = buf, rdx = len (System V args 2,3 from __read's
    // caller; fd in rdi is ignored — we always read STD_INPUT_HANDLE).
    // Returns the byte count in eax (0 at EOF), matching read(2) semantics.
    //
    //   push rbp                            55
    //   mov rbp, rsp                        48 89 E5
    //   sub rsp, 64                         48 83 EC 40
    //   mov [rbp-8], rsi                    48 89 75 F8     ; save buf
    //   mov [rbp-16], rdx                   48 89 55 F0     ; save len
    //   mov dword [rbp-24], 0               C7 45 E8 00..   ; bytesRead = 0
    //   mov ecx, -10 (STD_INPUT_HANDLE)     B9 F6 FF FF FF
    //   call [rip + GetStdHandle_IAT]       FF 15 disp32    <- reloc idx 0
    //   mov rcx, rax                        48 89 C1        ; hFile
    //   mov rdx, [rbp-8]                     48 8B 55 F8     ; lpBuffer
    //   mov r8,  [rbp-16]                   4C 8B 45 F0     ; nNumberOfBytesToRead
    //   lea r9,  [rbp-24]                   4C 8D 4D E8     ; lpNumberOfBytesRead
    //   mov qword [rsp+32], 0               48 C7 44 24 20 00.. ; lpOverlapped = NULL
    //   call [rip + ReadFile_IAT]           FF 15 disp32    <- reloc idx 3
    //   mov eax, [rbp-24]                   8B 45 E8        ; return bytesRead
    //   leave                               C9
    //   ret                                 C3
    helpReadOff = b.data.length;
    b.put(cast(ubyte) 0x55);
    b.put(cast(ubyte) 0x48); b.put(cast(ubyte) 0x89); b.put(cast(ubyte) 0xE5);
    b.put(cast(ubyte) 0x48); b.put(cast(ubyte) 0x83); b.put(cast(ubyte) 0xEC); b.put(cast(ubyte) 0x40);
    b.put(cast(ubyte) 0x48); b.put(cast(ubyte) 0x89); b.put(cast(ubyte) 0x75); b.put(cast(ubyte) 0xF8);
    b.put(cast(ubyte) 0x48); b.put(cast(ubyte) 0x89); b.put(cast(ubyte) 0x55); b.put(cast(ubyte) 0xF0);
    b.put(cast(ubyte) 0xC7); b.put(cast(ubyte) 0x45); b.put(cast(ubyte) 0xE8);
    foreach (_; 0 .. 4) b.put(cast(ubyte) 0);
    // fd is in rdi: 0 => stdin (GetStdHandle), nonzero => a CreateFile HANDLE.
    b.put(cast(ubyte) 0x48); b.put(cast(ubyte) 0x85); b.put(cast(ubyte) 0xFF);   // test rdi, rdi
    b.put(cast(ubyte) 0x75); b.put(cast(ubyte) 0x10);                            // jnz +16 -> use handle
    b.put(cast(ubyte) 0xB9);
    foreach (x; nativeToLittleEndian(cast(uint) 0xFFFFFFF6)) b.put(x);   // mov ecx, STD_INPUT_HANDLE (-10)
    b.put(cast(ubyte) 0xFF); b.put(cast(ubyte) 0x15);
    relocs ~= HelperRel(b.data.length, 0);                              // GetStdHandle
    foreach (_; 0 .. 4) b.put(cast(ubyte) 0);
    b.put(cast(ubyte) 0x48); b.put(cast(ubyte) 0x89); b.put(cast(ubyte) 0xC1);   // mov rcx, rax
    b.put(cast(ubyte) 0xEB); b.put(cast(ubyte) 0x03);                            // jmp +3 -> common
    b.put(cast(ubyte) 0x48); b.put(cast(ubyte) 0x89); b.put(cast(ubyte) 0xF9);   // mov rcx, rdi (handle)
    b.put(cast(ubyte) 0x48); b.put(cast(ubyte) 0x8B); b.put(cast(ubyte) 0x55); b.put(cast(ubyte) 0xF8);
    b.put(cast(ubyte) 0x4C); b.put(cast(ubyte) 0x8B); b.put(cast(ubyte) 0x45); b.put(cast(ubyte) 0xF0);
    b.put(cast(ubyte) 0x4C); b.put(cast(ubyte) 0x8D); b.put(cast(ubyte) 0x4D); b.put(cast(ubyte) 0xE8);
    b.put(cast(ubyte) 0x48); b.put(cast(ubyte) 0xC7); b.put(cast(ubyte) 0x44); b.put(cast(ubyte) 0x24); b.put(cast(ubyte) 0x20);
    foreach (_; 0 .. 4) b.put(cast(ubyte) 0);
    b.put(cast(ubyte) 0xFF); b.put(cast(ubyte) 0x15);
    relocs ~= HelperRel(b.data.length, 3);                              // ReadFile
    foreach (_; 0 .. 4) b.put(cast(ubyte) 0);
    b.put(cast(ubyte) 0x8B); b.put(cast(ubyte) 0x45); b.put(cast(ubyte) 0xE8);
    b.put(cast(ubyte) 0xC9);
    b.put(cast(ubyte) 0xC3);

    // ---- HELP_OPEN ----
    // __open(rdi = C-string path) -> CreateFileA(path, GENERIC_READ,
    // FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL).
    // Returns the HANDLE in rax (a positive value; INVALID_HANDLE_VALUE = -1
    // on failure, which the rt.h wrappers treat as "fd < 0" = error).
    //
    //   push rbp                            55
    //   mov rbp, rsp                        48 89 E5
    //   sub rsp, 64                         48 83 EC 40
    //   mov rcx, rdi                        48 89 F9        ; lpFileName
    //   mov edx, 0x80000000                 BA 00 00 00 80  ; GENERIC_READ
    //   mov r8d, 1                          41 B8 01 00 00 00 ; FILE_SHARE_READ
    //   xor r9d, r9d                        45 31 C9        ; lpSecurityAttributes
    //   mov qword [rsp+32], 3               48 C7 44 24 20 03.. ; OPEN_EXISTING
    //   mov qword [rsp+40], 0x80            48 C7 44 24 28 80.. ; FILE_ATTRIBUTE_NORMAL
    //   mov qword [rsp+48], 0               48 C7 44 24 30 00.. ; hTemplateFile
    //   call [rip + CreateFileA_IAT]        FF 15 disp32    <- reloc idx 4
    //   leave / ret
    helpOpenOff = b.data.length;
    b.put(cast(ubyte) 0x55);
    b.put(cast(ubyte) 0x48); b.put(cast(ubyte) 0x89); b.put(cast(ubyte) 0xE5);
    b.put(cast(ubyte) 0x48); b.put(cast(ubyte) 0x83); b.put(cast(ubyte) 0xEC); b.put(cast(ubyte) 0x40);
    b.put(cast(ubyte) 0x48); b.put(cast(ubyte) 0x89); b.put(cast(ubyte) 0xF9);
    b.put(cast(ubyte) 0xBA);
    foreach (x; nativeToLittleEndian(cast(uint) 0x80000000)) b.put(x);   // GENERIC_READ
    b.put(cast(ubyte) 0x41); b.put(cast(ubyte) 0xB8);
    foreach (x; nativeToLittleEndian(cast(uint) 1)) b.put(x);            // FILE_SHARE_READ
    b.put(cast(ubyte) 0x45); b.put(cast(ubyte) 0x31); b.put(cast(ubyte) 0xC9);
    b.put(cast(ubyte) 0x48); b.put(cast(ubyte) 0xC7); b.put(cast(ubyte) 0x44); b.put(cast(ubyte) 0x24); b.put(cast(ubyte) 0x20);
    foreach (x; nativeToLittleEndian(cast(uint) 3)) b.put(x);            // OPEN_EXISTING
    b.put(cast(ubyte) 0x48); b.put(cast(ubyte) 0xC7); b.put(cast(ubyte) 0x44); b.put(cast(ubyte) 0x24); b.put(cast(ubyte) 0x28);
    foreach (x; nativeToLittleEndian(cast(uint) 0x80)) b.put(x);         // FILE_ATTRIBUTE_NORMAL
    b.put(cast(ubyte) 0x48); b.put(cast(ubyte) 0xC7); b.put(cast(ubyte) 0x44); b.put(cast(ubyte) 0x24); b.put(cast(ubyte) 0x30);
    foreach (_; 0 .. 4) b.put(cast(ubyte) 0);                            // hTemplateFile = NULL
    b.put(cast(ubyte) 0xFF); b.put(cast(ubyte) 0x15);
    relocs ~= HelperRel(b.data.length, 4);                              // CreateFileA
    foreach (_; 0 .. 4) b.put(cast(ubyte) 0);
    b.put(cast(ubyte) 0xC9);
    b.put(cast(ubyte) 0xC3);

    // ---- HELP_CLOSE ----
    // __close(rdi = HANDLE) -> CloseHandle(handle).
    //   push rbp; mov rbp,rsp; sub rsp,32; mov rcx,rdi;
    //   call [rip + CloseHandle_IAT]; leave; ret
    helpCloseOff = b.data.length;
    b.put(cast(ubyte) 0x55);
    b.put(cast(ubyte) 0x48); b.put(cast(ubyte) 0x89); b.put(cast(ubyte) 0xE5);
    b.put(cast(ubyte) 0x48); b.put(cast(ubyte) 0x83); b.put(cast(ubyte) 0xEC); b.put(cast(ubyte) 0x20);
    b.put(cast(ubyte) 0x48); b.put(cast(ubyte) 0x89); b.put(cast(ubyte) 0xF9);
    b.put(cast(ubyte) 0xFF); b.put(cast(ubyte) 0x15);
    relocs ~= HelperRel(b.data.length, 5);                              // CloseHandle
    foreach (_; 0 .. 4) b.put(cast(ubyte) 0);
    b.put(cast(ubyte) 0xC9);
    b.put(cast(ubyte) 0xC3);

    // ---- HELP_CREATE ----
    // __create(rdi = path) -> CreateFileA(path, GENERIC_WRITE, 0, NULL,
    // CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL).  Returns the HANDLE.
    // Same shape as HELP_OPEN but GENERIC_WRITE (0x40000000) + CREATE_ALWAYS (2).
    helpCreateOff = b.data.length;
    b.put(cast(ubyte) 0x55);
    b.put(cast(ubyte) 0x48); b.put(cast(ubyte) 0x89); b.put(cast(ubyte) 0xE5);
    b.put(cast(ubyte) 0x48); b.put(cast(ubyte) 0x83); b.put(cast(ubyte) 0xEC); b.put(cast(ubyte) 0x40);
    b.put(cast(ubyte) 0x48); b.put(cast(ubyte) 0x89); b.put(cast(ubyte) 0xF9);   // mov rcx, rdi
    b.put(cast(ubyte) 0xBA);
    foreach (x; nativeToLittleEndian(cast(uint) 0x40000000)) b.put(x);  // GENERIC_WRITE
    b.put(cast(ubyte) 0x45); b.put(cast(ubyte) 0x31); b.put(cast(ubyte) 0xC0);   // xor r8d,r8d (no share)
    b.put(cast(ubyte) 0x45); b.put(cast(ubyte) 0x31); b.put(cast(ubyte) 0xC9);   // xor r9d,r9d (NULL)
    b.put(cast(ubyte) 0x48); b.put(cast(ubyte) 0xC7); b.put(cast(ubyte) 0x44); b.put(cast(ubyte) 0x24); b.put(cast(ubyte) 0x20);
    foreach (x; nativeToLittleEndian(cast(uint) 2)) b.put(x);           // CREATE_ALWAYS
    b.put(cast(ubyte) 0x48); b.put(cast(ubyte) 0xC7); b.put(cast(ubyte) 0x44); b.put(cast(ubyte) 0x24); b.put(cast(ubyte) 0x28);
    foreach (x; nativeToLittleEndian(cast(uint) 0x80)) b.put(x);        // FILE_ATTRIBUTE_NORMAL
    b.put(cast(ubyte) 0x48); b.put(cast(ubyte) 0xC7); b.put(cast(ubyte) 0x44); b.put(cast(ubyte) 0x24); b.put(cast(ubyte) 0x30);
    foreach (_; 0 .. 4) b.put(cast(ubyte) 0);                           // hTemplateFile = NULL
    b.put(cast(ubyte) 0xFF); b.put(cast(ubyte) 0x15);
    relocs ~= HelperRel(b.data.length, 4);                              // CreateFileA
    foreach (_; 0 .. 4) b.put(cast(ubyte) 0);
    b.put(cast(ubyte) 0xC9);
    b.put(cast(ubyte) 0xC3);

    // ---- HELP_FWRITE ----
    // __write(rdi=fd, rsi=buf, rdx=len) -> WriteFile.  fd==1 => STD_OUTPUT,
    // else fd is a CreateFile HANDLE.  Returns the byte count in eax.
    helpFwriteOff = b.data.length;
    b.put(cast(ubyte) 0x55);
    b.put(cast(ubyte) 0x48); b.put(cast(ubyte) 0x89); b.put(cast(ubyte) 0xE5);
    b.put(cast(ubyte) 0x48); b.put(cast(ubyte) 0x83); b.put(cast(ubyte) 0xEC); b.put(cast(ubyte) 0x40);
    b.put(cast(ubyte) 0x48); b.put(cast(ubyte) 0x89); b.put(cast(ubyte) 0x75); b.put(cast(ubyte) 0xF8);   // [rbp-8]=buf
    b.put(cast(ubyte) 0x48); b.put(cast(ubyte) 0x89); b.put(cast(ubyte) 0x55); b.put(cast(ubyte) 0xF0);   // [rbp-16]=len
    b.put(cast(ubyte) 0xC7); b.put(cast(ubyte) 0x45); b.put(cast(ubyte) 0xE8);
    foreach (_; 0 .. 4) b.put(cast(ubyte) 0);                           // [rbp-24]=0 (bytesWritten)
    b.put(cast(ubyte) 0x48); b.put(cast(ubyte) 0x89); b.put(cast(ubyte) 0xF9);   // mov rcx, rdi (assume handle)
    b.put(cast(ubyte) 0x48); b.put(cast(ubyte) 0x83); b.put(cast(ubyte) 0xFF); b.put(cast(ubyte) 0x01);   // cmp rdi, 1
    b.put(cast(ubyte) 0x75); b.put(cast(ubyte) 0x0E);                   // jne +14 -> use handle
    b.put(cast(ubyte) 0xB9);
    foreach (x; nativeToLittleEndian(cast(uint) 0xFFFFFFF5)) b.put(x);  // mov ecx, STD_OUTPUT_HANDLE (-11)
    b.put(cast(ubyte) 0xFF); b.put(cast(ubyte) 0x15);
    relocs ~= HelperRel(b.data.length, 0);                              // GetStdHandle
    foreach (_; 0 .. 4) b.put(cast(ubyte) 0);
    b.put(cast(ubyte) 0x48); b.put(cast(ubyte) 0x89); b.put(cast(ubyte) 0xC1);   // mov rcx, rax
    b.put(cast(ubyte) 0x48); b.put(cast(ubyte) 0x8B); b.put(cast(ubyte) 0x55); b.put(cast(ubyte) 0xF8);   // rdx=buf
    b.put(cast(ubyte) 0x4C); b.put(cast(ubyte) 0x8B); b.put(cast(ubyte) 0x45); b.put(cast(ubyte) 0xF0);   // r8=len
    b.put(cast(ubyte) 0x4C); b.put(cast(ubyte) 0x8D); b.put(cast(ubyte) 0x4D); b.put(cast(ubyte) 0xE8);   // r9=&bytesWritten
    b.put(cast(ubyte) 0x48); b.put(cast(ubyte) 0xC7); b.put(cast(ubyte) 0x44); b.put(cast(ubyte) 0x24); b.put(cast(ubyte) 0x20);
    foreach (_; 0 .. 4) b.put(cast(ubyte) 0);                           // lpOverlapped = NULL
    b.put(cast(ubyte) 0xFF); b.put(cast(ubyte) 0x15);
    relocs ~= HelperRel(b.data.length, 1);                              // WriteFile
    foreach (_; 0 .. 4) b.put(cast(ubyte) 0);
    b.put(cast(ubyte) 0x8B); b.put(cast(ubyte) 0x45); b.put(cast(ubyte) 0xE8);   // mov eax, [rbp-24]
    b.put(cast(ubyte) 0xC9);
    b.put(cast(ubyte) 0xC3);

    // ---- HELP_SYSCALL6 (Win32 dispatch for the raw-syscall passthrough) ----
    // Entry (from the rewritten thunk's `call`): rdi = syscall number, rsi =
    // arg0, ... (System V).  Dispatch on the number; unsupported numbers return
    // -1 (errno-style) instead of faulting on a Linux `syscall` instruction.
    //   cmp rdi,60 / cmp rdi,231 -> ExitProcess(arg0);  default -> mov rax,-1; ret
    helpSyscall6Off = b.data.length;
    {
        // Dispatch on rdi = syscall number.  Args follow the System V CALL ABI of
        // __syscall6(num, a0..a5): rsi=a0, rdx=a1, rcx=a2, r8=a3, r9=a4.  Each
        // case is `cmp rdi,N ; jne over ; <handler ends in ret> ; over:` with the
        // jne backpatched, so cases compose without hand-counted offsets — adding a
        // syscall is now one emitCase().  Unsupported numbers fall to `mov rax,-1`.
        void op(ubyte[] bytes...) { foreach (x; bytes) b.put(x); }
        void callIat(int idx) {                            // call [rip + IAT slot idx]
            op(0xFF, 0x15); relocs ~= HelperRel(b.data.length, idx); op(0,0,0,0);
        }
        void emitCase(int num, void delegate() body_) {
            op(0x48, 0x81, 0xFF,                           // cmp rdi, imm32
               cast(ubyte)(num), cast(ubyte)(num>>8), cast(ubyte)(num>>16), cast(ubyte)(num>>24));
            op(0x0F, 0x85);                                // jne rel32 (over handler)
            auto jne = b.data.length; op(0,0,0,0);
            body_();
            patchU32(b.data, jne, cast(uint) cast(int)(b.data.length - (jne + 4)));
        }
        // exit_group(60) / exit(231) -> ExitProcess(arg0)   [noreturn]
        void emitExit() { op(0x48,0x83,0xEC,0x28,          // sub rsp,0x28
                             0x48,0x89,0xF1);              // mov rcx, rsi (code)
                          callIat(2); op(0xCC); }          // ExitProcess; int3
        emitCase(60,  &emitExit);
        emitCase(231, &emitExit);
        // getpid(39) -> GetCurrentProcessId
        emitCase(39, () { op(0x48,0x83,0xEC,0x28); callIat(7);
                          op(0x48,0x83,0xC4,0x28, 0xC3); });            // ret (rax=eax)
        // lseek(8): fd=rsi, off=rdx, whence=rcx -> SetFilePointerEx(fd,off,&new,whence)
        emitCase(8, () { op(0x48,0x83,0xEC,0x38,           // sub rsp,0x38 (shadow + newpos@+0x20)
                            0x49,0x89,0xC9,                // mov r9, rcx  (whence; SEEK_*==FILE_*)
                            0x48,0x89,0xF1,                // mov rcx, rsi (handle)
                            0x4C,0x8D,0x44,0x24,0x20);     // lea r8, [rsp+0x20] (&newpos)  rdx=off kept
                         callIat(8);                       // SetFilePointerEx
                         op(0x48,0x8B,0x44,0x24,0x20,      // mov rax, [rsp+0x20] (new position)
                            0x48,0x83,0xC4,0x38, 0xC3); });
        // unlink(87): path=rsi -> DeleteFileA(path);  BOOL!=0 -> 0, 0 -> -1
        emitCase(87, () { op(0x48,0x83,0xEC,0x28, 0x48,0x89,0xF1); callIat(9);
                          op(0x83,0xF8,0x01, 0x48,0x19,0xC0,           // cmp eax,1; sbb rax,rax
                             0x48,0x83,0xC4,0x28, 0xC3); });
        // mkdir(83): path=rsi (mode ignored) -> CreateDirectoryA(path, NULL)
        emitCase(83, () { op(0x48,0x83,0xEC,0x28, 0x48,0x89,0xF1, 0x31,0xD2); callIat(10);
                          op(0x83,0xF8,0x01, 0x48,0x19,0xC0,
                             0x48,0x83,0xC4,0x28, 0xC3); });
        // rename(82): old=rsi, new=rdx -> MoveFileExA(old,new,MOVEFILE_REPLACE_EXISTING=1)
        emitCase(82, () { op(0x48,0x83,0xEC,0x28,          // sub rsp,0x28
                             0x48,0x89,0xF1,               // mov rcx, rsi (old)  [rdx=new kept]
                             0x41,0xB8,0x01,0x00,0x00,0x00); // mov r8d, 1
                          callIat(11);                     // MoveFileExA
                          op(0x83,0xF8,0x01, 0x48,0x19,0xC0,  // cmp eax,1; sbb rax,rax (BOOL->0/-1)
                             0x48,0x83,0xC4,0x28, 0xC3); });
        // nanosleep(35): req=rsi -> [sec@0, nsec@8].  Sleep(sec*1000 + nsec/1000000).
        // SELF-ALIGN the stack (Hofos's codegen doesn't guarantee 16-byte alignment,
        // and Sleep faults on a misaligned rsp — unlike most kernel32 calls):
        //   push rbp; mov rbp,rsp; and rsp,-16; sub rsp,0x20  (16-aligned + shadow).
        emitCase(35, () { op(0x55, 0x48,0x89,0xE5,           // push rbp; mov rbp,rsp
                             0x48,0x83,0xE4,0xF0,             // and rsp,-16 (align)
                             0x48,0x83,0xEC,0x20,             // sub rsp,0x20 (shadow)
                             0x4C,0x8B,0x06,                  // mov r8, [rsi]        (tv_sec)
                             0x4D,0x69,0xC0,0xE8,0x03,0x00,0x00, // imul r8, r8, 1000
                             0x48,0x8B,0x46,0x08,             // mov rax, [rsi+8]     (tv_nsec)
                             0x48,0x31,0xD2,                  // xor rdx, rdx
                             0x48,0xC7,0xC1,0x40,0x42,0x0F,0x00, // mov rcx, 1000000
                             0x48,0xF7,0xF1,                  // div rcx  (rax = nsec/1e6)
                             0x4C,0x01,0xC0,                  // add rax, r8  (total ms)
                             0x48,0x89,0xC1);                 // mov rcx, rax (Sleep arg)
                          callIat(12);                        // Sleep(ms)
                          op(0x31,0xC0, 0x48,0x89,0xEC, 0x5D, 0xC3); }); // xor eax,eax; mov rsp,rbp; pop rbp; ret
        op(0x48,0xC7,0xC0,0xFF,0xFF,0xFF,0xFF, 0xC3);      // default: mov rax,-1; ret
    }

    // ---- HELP_ARGS (Windows argv setup) ----
    // The ELF _start prelude reads argc/argv from the Linux stack ([rsp],[rsp+8]);
    // Windows has no such vector.  NAL rewrites that read to `call HELP_ARGS`,
    // which fetches GetCommandLineA() and returns rdi = -1 (sentinel "PE argv")
    // and rsi = the raw command-line C-string.  The runtime's rdargs sees
    // __argc == -1 and parses __argv (the string) into args.
    //   push rbp; mov rbp,rsp; and rsp,-16; sub rsp,0x20   (align + shadow)
    //   call [rip+GetCommandLineA]  <- reloc idx 6
    //   mov rsp,rbp; pop rbp; or rdi,-1; mov rsi,rax; ret
    helpArgsOff = b.data.length;
    {
        ubyte[] pre = [0x55, 0x48,0x89,0xE5, 0x48,0x83,0xE4,0xF0, 0x48,0x83,0xEC,0x20, 0xFF,0x15];
        foreach (x; pre) b.put(x);
        relocs ~= HelperRel(b.data.length, 6);          // GetCommandLineA
        foreach (_; 0 .. 4) b.put(cast(ubyte) 0);
        ubyte[] post = [0x48,0x89,0xEC, 0x5D, 0x48,0x83,0xCF,0xFF, 0x48,0x89,0xC6, 0xC3];
        foreach (x; post) b.put(x);
    }

    return b.data;
}

// ============================================================================
// PE32+ writer
// ============================================================================

enum FILE_ALIGN = 0x200u;
enum SECT_ALIGN = 0x1000u;
// Match the ELF's load base so the codegen's hard-coded `mov rdx, imm64`
// string addresses remain valid without per-site translation.
enum IMG_BASE   = 0x400000UL;

T alignUp(T)(T v, T a) { return cast(T) ((v + a - 1) & ~(a - 1)); }

void writeLE(T)(ref Appender!(ubyte[]) a, T v) {
    auto b = nativeToLittleEndian(v);
    a.put(b[]);
}

void writeCStr(ref Appender!(ubyte[]) a, string s) {
    a.put(cast(ubyte[]) s);
    a.put(cast(ubyte) 0);
}

void padTo(ref Appender!(ubyte[]) a, size_t target) {
    while (a.data.length < target) a.put(cast(ubyte) 0);
}

void patchU32(ubyte[] data, size_t off, uint v) {
    auto b = nativeToLittleEndian(v);
    foreach (i, x; b) data[off + i] = x;
}

void patchU64(ubyte[] data, size_t off, ulong v) {
    auto b = nativeToLittleEndian(v);
    foreach (i, x; b) data[off + i] = x;
}

enum DLL_THUNK_SIZE = 30;   // bytes per MS-x64 -> SysV ABI-translation thunk

// Build a PE export directory (.edata) from the (pre-sorted) .hxl exports so
// LoadLibrary + GetProcAddress can resolve them.  `edataRva` is the section RVA
// (needed for the internal RVA fields).  EAT entries point at the ABI thunks
// (thunkBaseRva + i*DLL_THUNK_SIZE), not the raw SysV functions, so Windows
// callers reach them with the right calling convention.
// Names MUST be sorted (the loader binary-searches AddressOfNames) — the caller
// sorts `exps` once and shares that order with buildDllThunks.
ubyte[] buildPeExportTable(HxlExport[] exps, uint edataRva, string dllName, uint thunkBaseRva) {
    uint n = cast(uint) exps.length;
    uint eatOff = 40;
    uint nptOff = eatOff + n * 4;
    uint ordOff = nptOff + n * 4;
    uint strOff = ordOff + n * 2;
    uint[] nameStrOff; nameStrOff.length = n;
    uint cur = strOff;
    foreach (i, e; exps) { nameStrOff[i] = cur; cur += cast(uint)(e.name.length + 1); }
    uint dllNameOff = cur;

    auto a = appender!(ubyte[])();
    writeLE!uint(a, 0);                          // Characteristics
    writeLE!uint(a, 0);                          // TimeDateStamp
    writeLE!uint(a, 0);                          // Major/Minor version
    writeLE!uint(a, edataRva + dllNameOff);      // Name RVA (the DLL's own name)
    writeLE!uint(a, 1);                          // OrdinalBase
    writeLE!uint(a, n);                          // NumberOfFunctions
    writeLE!uint(a, n);                          // NumberOfNames
    writeLE!uint(a, edataRva + eatOff);          // AddressOfFunctions (EAT)
    writeLE!uint(a, edataRva + nptOff);          // AddressOfNames
    writeLE!uint(a, edataRva + ordOff);          // AddressOfNameOrdinals
    foreach (i, e; exps)   writeLE!uint(a, thunkBaseRva + cast(uint)(i * DLL_THUNK_SIZE)); // EAT -> thunk
    foreach (i, e; exps)   writeLE!uint(a, edataRva + nameStrOff[i]);         // name ptrs
    foreach (i, e; exps)   writeLE!ushort(a, cast(ushort) i);                 // ordinals
    foreach (e; exps)      writeCStr(a, e.name);                              // name strings
    writeCStr(a, dllName);
    return a.data;
}

// Build one MS-x64 -> SysV ABI thunk per (pre-sorted) export.  Windows passes the
// first four integer args in rcx/rdx/r8/r9; Hofos (SysV) expects rdi/rsi/rdx/rcx.
// The thunk shuffles them, preserves rsi/rdi (MS callee-saved), calls the real
// function (rel32), and returns.  Handles up to 4 register args (BCPL exports
// almost never take more).  `thunkRva` is this section's RVA.
ubyte[] buildDllThunks(HxlExport[] exps, uint thunkRva) {
    auto a = appender!(ubyte[])();
    foreach (i, e; exps) {
        uint here = thunkRva + cast(uint)(i * DLL_THUNK_SIZE);
        uint realRva = cast(uint)(e.vaddr - IMG_BASE);
        a.put(cast(ubyte) 0x56);                                   // push rsi
        a.put(cast(ubyte) 0x57);                                   // push rdi
        a.put(cast(ubyte[]) [0x48, 0x89, 0xCF]);                   // mov rdi, rcx  (a1)
        a.put(cast(ubyte[]) [0x48, 0x89, 0xD6]);                   // mov rsi, rdx  (a2)
        a.put(cast(ubyte[]) [0x4C, 0x89, 0xC2]);                   // mov rdx, r8   (a3)
        a.put(cast(ubyte[]) [0x4C, 0x89, 0xC9]);                   // mov rcx, r9   (a4)
        a.put(cast(ubyte[]) [0x48, 0x83, 0xEC, 0x28]);             // sub rsp, 0x28 (shadow+align)
        int rel = cast(int)(cast(long) realRva - cast(long)(here + 23)); // E8 at +18, next at +23
        a.put(cast(ubyte) 0xE8);
        a.put(nativeToLittleEndian(rel)[]);                        // call real func
        a.put(cast(ubyte[]) [0x48, 0x83, 0xC4, 0x28]);             // add rsp, 0x28
        a.put(cast(ubyte) 0x5F);                                   // pop rdi
        a.put(cast(ubyte) 0x5E);                                   // pop rsi
        a.put(cast(ubyte) 0xC3);                                   // ret
    }
    return a.data;
}

// Build a PE base-relocation table (.reloc) from the .hxl absolute-address sites.
// Each site is the VA of an 8-byte movabs immediate -> IMAGE_REL_BASED_DIR64 (10),
// grouped into per-4KB-page blocks.  Lets Windows rebase the DLL (its ImageBase
// 0x400000 collides with the host EXE, so it is ALWAYS relocated).
ubyte[] buildPeBaseRelocs(ulong[] sites) {
    import std.algorithm : sort;
    uint[] rvas;
    foreach (v; sites) rvas ~= cast(uint)(v - IMG_BASE);
    sort(rvas);
    auto a = appender!(ubyte[])();
    size_t i = 0;
    while (i < rvas.length) {
        uint page = rvas[i] & ~0xFFFu;
        size_t start = i;
        while (i < rvas.length && (rvas[i] & ~0xFFFu) == page) i++;
        uint count = cast(uint)(i - start);
        bool pad = (count & 1) != 0;                       // 4-byte-align each block
        writeLE!uint(a, page);
        writeLE!uint(a, 8 + (count + (pad ? 1 : 0)) * 2);  // block size
        foreach (j; start .. i)
            writeLE!ushort(a, cast(ushort)((10 << 12) | (rvas[j] & 0xFFF)));
        if (pad) writeLE!ushort(a, 0);                     // IMAGE_REL_BASED_ABSOLUTE
    }
    return a.data;
}

void writePE(string outPath, ElfView elf, bool asDll = false, string elfPath = "") {
    auto txt = findText(elf);
    auto rod = findRodata(elf);
    auto dat = findData(elf);
    auto bss = findBss(elf);
    enforce(txt !is null, "elf: no executable PT_LOAD");

    // ---- DLL export table + base relocations (from the -fshared .hxl sidecar) --
    // A DLL is useless without an export directory (GetProcAddress) and a .reloc
    // (its ImageBase 0x400000 always collides with the host EXE, forcing a rebase).
    import std.path : baseName;
    import std.algorithm : sort;
    HxlData hxl;
    bool dllExports = false;
    ubyte[] relocBytes;
    size_t edataSize = 0, relocSize = 0, thunkSize = 0;
    string dllBaseName = baseName(outPath);
    if (asDll && elfPath.length && std.file.exists(elfPath ~ ".hxl")) {
        hxl = parseHxl(elfPath ~ ".hxl");
        if (hxl.ok && hxl.exports.length) {
            dllExports = true;
            sort!((a, b) => a.name < b.name)(hxl.exports);   // sort ONCE; edata + thunks share it
            relocBytes = buildPeBaseRelocs(hxl.relocs);
            relocSize  = relocBytes.length;
            thunkSize  = hxl.exports.length * DLL_THUNK_SIZE;
            edataSize  = buildPeExportTable(hxl.exports, 0, dllBaseName, 0).length; // size is RVA-independent
        }
    }

    // PE sections: .text + .rdata + .idata + (.bss?) + (.embed?) + (.thunk + .edata + .reloc?)
    uint nSections = (bss !is null ? 4 : 3) + (elf.embed.length ? 1 : 0) + (dllExports ? 3 : 0);

    // ---- Build the rewritten code -----------------------------------------
    ubyte[] code = txt.bytes.dup;
    auto userCodeLen = code.length;

    // We don't yet know the helper offsets — we'll splice helpers in after
    // the user code, then patch the call disps in the rewritten sites.
    // First record the rewrite sites (offset, kind).

    enum SiteKind : ubyte { writeImm, exit, wrch, read, open, close, create, fwrite, syscall6 }
    struct Site { size_t off; SiteKind kind; ulong bufVA; ulong len; ExitForm exitForm; }
    Site[] sites;
    for (size_t i = 0; i < userCodeLen; ) {
        ulong bv, ln;
        if (matchWritePattern(code, i, bv, ln)) {
            sites ~= Site(i, SiteKind.writeImm, bv, ln, ExitForm.none);
            i += 42;
            continue;
        }
        if (matchWrchHelper(code, i)) {
            sites ~= Site(i, SiteKind.wrch, 0, 0, ExitForm.none);
            i += 38;
            continue;
        }
        if (matchReadHelper(code, i)) {
            sites ~= Site(i, SiteKind.read, 0, 0, ExitForm.none);
            i += 13;
            continue;
        }
        if (matchOpenHelper(code, i)) {
            sites ~= Site(i, SiteKind.open, 0, 0, ExitForm.none);
            i += 17;
            continue;
        }
        if (matchCloseHelper(code, i)) {
            sites ~= Site(i, SiteKind.close, 0, 0, ExitForm.none);
            i += 13;
            continue;
        }
        if (matchCreateHelper(code, i)) {        // before the 13-byte matchers
            sites ~= Site(i, SiteKind.create, 0, 0, ExitForm.none);
            i += 23;
            continue;
        }
        if (matchWriteSyscallHelper(code, i)) {
            sites ~= Site(i, SiteKind.fwrite, 0, 0, ExitForm.none);
            i += 13;
            continue;
        }
        if (matchSyscall6Helper(code, i)) {
            sites ~= Site(i, SiteKind.syscall6, 0, 0, ExitForm.none);
            i += 26;
            continue;
        }
        auto ef = matchExitPattern(code, i);
        if (ef != ExitForm.none) {
            sites ~= Site(i, SiteKind.exit, 0, 0, ef);
            i += 15;
            continue;
        }
        ++i;
    }

    // Append the helpers immediately after user code.
    HelperRel[] helperRelocs;
    size_t helpWriteOff_inHelpers, helpExitOff_inHelpers, helpReadOff_inHelpers;
    size_t helpOpenOff_inHelpers, helpCloseOff_inHelpers;
    size_t helpCreateOff_inHelpers, helpFwriteOff_inHelpers, helpSyscall6Off_inHelpers, helpArgsOff_inHelpers;
    auto helpers = buildHelpers(helperRelocs, helpWriteOff_inHelpers, helpExitOff_inHelpers,
                                helpReadOff_inHelpers, helpOpenOff_inHelpers, helpCloseOff_inHelpers,
                                helpCreateOff_inHelpers, helpFwriteOff_inHelpers, helpSyscall6Off_inHelpers, helpArgsOff_inHelpers);
    // Where do the helpers live?  Normally appended right after the user code in
    // .text.  BUT the .data/.bss segments are pinned at their ELF vaddrs (the code
    // holds absolute references), and some compilers (e.g. the AArch64 cross-driver)
    // pack .text and .data within ~1 page — appending the ~700-byte helper blob then
    // overflows .text past .data's RVA (two sections claiming the same RVA => the
    // Windows loader maps only up to .data, the helper tail is unmapped, and every
    // syscall silently no-ops).  When the helpers don't fit in the .text→.data gap,
    // give them their OWN executable section above .bss, where there is always room.
    // helperBase is kept as the helpers' RVA measured from textRva so the existing
    // rel32 disp math (which cancels textRva) is unchanged either way.
    enum uint TEXT_RVA = SECT_ALIGN;
    uint helperVSize = cast(uint) helpers.length;
    uint dataGap = (dat !is null) ? (cast(uint)(dat.vaddr - IMG_BASE) - TEXT_RVA)
                 : (rod !is null) ? (cast(uint)(rod.vaddr - IMG_BASE) - TEXT_RVA)
                 : uint.max;
    bool helpersInText = (cast(uint) userCodeLen + helperVSize + 16) <= dataGap;
    uint htextRva = 0;
    size_t helperBase;
    if (helpersInText) {
        helperBase = code.length;
        code ~= helpers;
    } else {
        uint bRva  = (bss !is null) ? cast(uint)(bss.vaddr - IMG_BASE)
                   : (dat !is null) ? cast(uint)(dat.vaddr - IMG_BASE) : TEXT_RVA;
        uint bSize = (bss !is null) ? cast(uint) bss.memsz
                   : (dat !is null) ? cast(uint) dat.memsz : cast(uint) code.length;
        htextRva   = alignUp(bRva + bSize, SECT_ALIGN);
        helperBase = htextRva - TEXT_RVA;         // RVA-offset from textRva
        // helpers are NOT appended to code; emitted as a separate .htext section below.
        nSections++;                               // extra .htext section
    }

    // ---- Windows argv setup: rewrite the _start prelude's Linux argc/argv read.
    // The prelude is: 48 8b 3c 24 (mov rdi,[rsp]) 48 8d 74 24 08 (lea rsi,[rsp+8])
    // = 9 bytes.  Replace with `call HELP_ARGS` (E8 rel32) + 4 NOPs; HELP_ARGS
    // sets rdi=-1 (sentinel) and rsi=GetCommandLineA().
    // NOTE: cg.b now emits a few NOPs as an entry landing pad BEFORE this prelude,
    // so it no longer sits at code[0].  SCAN the first bytes for the pattern — if
    // we assumed code[0] the rewrite is silently skipped and the Windows binary
    // reads junk argc/argv off the native stack (__argc != -1, so rdargs takes
    // the Linux argv-vector path and dereferences garbage → crash).
    {
        size_t p = size_t.max;
        for (size_t i = 0; i + 9 <= userCodeLen && i < 64; i++) {
            if (code[i]  ==0x48 && code[i+1]==0x8B && code[i+2]==0x3C && code[i+3]==0x24 &&
                code[i+4]==0x48 && code[i+5]==0x8D && code[i+6]==0x74 && code[i+7]==0x24 &&
                code[i+8]==0x08) { p = i; break; }
        }
        if (p != size_t.max) {
            size_t helperOff = helperBase + helpArgsOff_inHelpers;
            int disp = cast(int)(cast(long) helperOff - cast(long)(p + 5));
            code[p]   = 0xE8;
            code[p+1] = cast(ubyte)(disp        & 0xFF);
            code[p+2] = cast(ubyte)((disp >>  8) & 0xFF);
            code[p+3] = cast(ubyte)((disp >> 16) & 0xFF);
            code[p+4] = cast(ubyte)((disp >> 24) & 0xFF);
            code[p+5] = 0x90; code[p+6] = 0x90; code[p+7] = 0x90; code[p+8] = 0x90;
        }
    }

    // Patch the call disp32 in each rewrite site so it points at the helper.
    foreach (s; sites) {
        final switch (s.kind) {
        case SiteKind.writeImm: {
            // mov rdx,imm64 (10) + mov r8d,imm32 (6) + sub rsp,40 (4) + E8 (1) = 21
            size_t callDispOff = s.off + 21;
            size_t helperOff   = helperBase + helpWriteOff_inHelpers;
            int disp = cast(int)(cast(long) helperOff - cast(long)(callDispOff + 4));
            writeWriteRewrite(code, s.off, disp, s.bufVA, s.len);
            break;
        }
        case SiteKind.exit: {
            // 2 (mov/xor ecx) + 4 (sub rsp,40) + 1 (E8) = 7 byte prefix before disp32
            size_t callDispOff = s.off + 7;
            size_t helperOff   = helperBase + helpExitOff_inHelpers;
            int disp = cast(int)(cast(long) helperOff - cast(long)(callDispOff + 4));
            writeExitRewrite(code, s.off, disp, s.exitForm);
            break;
        }
        case SiteKind.wrch: {
            // The wrch rewrite emits E8 at offset 26 within the 38-byte slot.
            size_t callDispOff = s.off + 27;
            size_t helperOff   = helperBase + helpWriteOff_inHelpers;
            int disp = cast(int)(cast(long) helperOff - cast(long)(callDispOff + 4));
            writeWrchRewrite(code, s.off, disp);
            break;
        }
        case SiteKind.read: {
            // The thunk emits E8 at offset 4 within the slot, so the disp32
            // starts at off+5 and is relative to off+9.
            size_t callDispOff = s.off + 5;
            size_t helperOff   = helperBase + helpReadOff_inHelpers;
            int disp = cast(int)(cast(long) helperOff - cast(long)(callDispOff + 4));
            writeCallThunk(code, s.off, disp, 13);
            break;
        }
        case SiteKind.open: {
            size_t callDispOff = s.off + 5;
            size_t helperOff   = helperBase + helpOpenOff_inHelpers;
            int disp = cast(int)(cast(long) helperOff - cast(long)(callDispOff + 4));
            writeCallThunk(code, s.off, disp, 17);
            break;
        }
        case SiteKind.close: {
            size_t callDispOff = s.off + 5;
            size_t helperOff   = helperBase + helpCloseOff_inHelpers;
            int disp = cast(int)(cast(long) helperOff - cast(long)(callDispOff + 4));
            writeCallThunk(code, s.off, disp, 13);
            break;
        }
        case SiteKind.create: {
            size_t callDispOff = s.off + 5;
            size_t helperOff   = helperBase + helpCreateOff_inHelpers;
            int disp = cast(int)(cast(long) helperOff - cast(long)(callDispOff + 4));
            writeCallThunk(code, s.off, disp, 23);
            break;
        }
        case SiteKind.fwrite: {
            size_t callDispOff = s.off + 5;
            size_t helperOff   = helperBase + helpFwriteOff_inHelpers;
            int disp = cast(int)(cast(long) helperOff - cast(long)(callDispOff + 4));
            writeCallThunk(code, s.off, disp, 13);
            break;
        }
        case SiteKind.syscall6: {
            // The 26-byte syscall6 helper becomes a thunk: push rbp; mov rbp,rsp;
            // call HELP_SYSCALL6; leave; ret (+NOP fill).  HELP_SYSCALL6 sees the
            // original SysV args (rdi=num, rsi=arg0) since push rbp preserves them.
            size_t callDispOff = s.off + 5;
            size_t helperOff   = helperBase + helpSyscall6Off_inHelpers;
            int disp = cast(int)(cast(long) helperOff - cast(long)(callDispOff + 4));
            writeCallThunk(code, s.off, disp, 26);
            break;
        }
        }
    }

    // ---- Now build the PE around the rewritten code -----------------------
    auto buf = appender!(ubyte[])();

    buf.put(cast(ubyte[]) "MZ");
    foreach (_; 0 .. 58) buf.put(cast(ubyte) 0);
    writeLE!uint(buf, 0x80);
    while (buf.data.length < 0x80) buf.put(cast(ubyte) 0);

    buf.put(cast(ubyte[]) "PE\0\0");

    writeLE!ushort(buf, 0x8664);
    writeLE!ushort(buf, cast(ushort) nSections);
    writeLE!uint(buf, 0);
    writeLE!uint(buf, 0);
    writeLE!uint(buf, 0);
    writeLE!ushort(buf, 240);
    // COFF Characteristics:
    //   0x0002 IMAGE_FILE_EXECUTABLE_IMAGE
    //   0x0020 IMAGE_FILE_LARGE_ADDRESS_AWARE
    //   0x2000 IMAGE_FILE_DLL  (when asDll)
    writeLE!ushort(buf, asDll ? cast(ushort) 0x2022 : cast(ushort) 0x0022);

    auto optHdrOffset = buf.data.length;
    foreach (_; 0 .. 240) buf.put(cast(ubyte) 0);

    auto secHdrOffset = buf.data.length;
    foreach (_; 0 .. 40 * nSections) buf.put(cast(ubyte) 0);

    auto textFileOff = alignUp(cast(uint) buf.data.length, FILE_ALIGN);
    padTo(buf, textFileOff);

    auto textStart = buf.data.length;
    buf.put(code);
    auto textEndRaw = buf.data.length;
    auto textPaddedEnd = alignUp(cast(uint) textEndRaw, FILE_ALIGN);
    padTo(buf, textPaddedEnd);

    // .rdata/.data = the ELF's read-only-or-initialised data segment.  Hofos folds
    // its rodata into the executable PT_LOAD (so findRodata is null) but emits a
    // SEPARATE writable data PT_LOAD for its mutable globals — that is the segment
    // that must land here, with its real bytes, or the program runs with zeroed
    // globals.  Prefer the initialised-data segment; fall back to a pure rodata
    // segment; else a single filler byte (the loader rejects VirtualSize=0).
    auto rdataFileOff = buf.data.length;
    if (dat !is null && dat.bytes.length)      buf.put(dat.bytes);
    else if (rod !is null && rod.bytes.length) buf.put(rod.bytes);
    else buf.put(cast(ubyte) 0);
    auto rdataPaddedEnd = alignUp(cast(uint) buf.data.length, FILE_ALIGN);
    padTo(buf, rdataPaddedEnd);

    // .idata = imports (3 functions in kernel32)
    auto idataFileOff = buf.data.length;

    auto dirStart = buf.data.length;
    foreach (_; 0 .. 40) buf.put(cast(ubyte) 0);   // 2 directory entries

    auto iltStart = buf.data.length;
    foreach (_; 0 .. 128) buf.put(cast(ubyte) 0);  // 16 slots (up to 15 imports + null)

    auto iatStart = buf.data.length;
    foreach (_; 0 .. 128) buf.put(cast(ubyte) 0);

    auto hint1Off  = buf.data.length; writeLE!ushort(buf, 0); writeCStr(buf, "GetStdHandle");
    auto hint2Off  = buf.data.length; writeLE!ushort(buf, 0); writeCStr(buf, "WriteFile");
    auto hint3Off  = buf.data.length; writeLE!ushort(buf, 0); writeCStr(buf, "ExitProcess");
    auto hint4Off  = buf.data.length; writeLE!ushort(buf, 0); writeCStr(buf, "ReadFile");
    auto hint5Off  = buf.data.length; writeLE!ushort(buf, 0); writeCStr(buf, "CreateFileA");
    auto hint6Off  = buf.data.length; writeLE!ushort(buf, 0); writeCStr(buf, "CloseHandle");
    auto hint7Off  = buf.data.length; writeLE!ushort(buf, 0); writeCStr(buf, "GetCommandLineA");
    auto hint8Off  = buf.data.length; writeLE!ushort(buf, 0); writeCStr(buf, "GetCurrentProcessId");
    auto hint9Off  = buf.data.length; writeLE!ushort(buf, 0); writeCStr(buf, "SetFilePointerEx");
    auto hint10Off = buf.data.length; writeLE!ushort(buf, 0); writeCStr(buf, "DeleteFileA");
    auto hint11Off = buf.data.length; writeLE!ushort(buf, 0); writeCStr(buf, "CreateDirectoryA");
    auto hint12Off = buf.data.length; writeLE!ushort(buf, 0); writeCStr(buf, "MoveFileExA");
    auto hint13Off = buf.data.length; writeLE!ushort(buf, 0); writeCStr(buf, "Sleep");
    auto dllNameOff = buf.data.length; writeCStr(buf, "kernel32.dll");

    auto idataPaddedEnd = alignUp(cast(uint) buf.data.length, FILE_ALIGN);
    padTo(buf, idataPaddedEnd);

    // .embed = bundled extra inputs (multi-input link), if any.  Read-only data.
    auto embedFileOff = buf.data.length;
    if (elf.embed.length) buf.put(elf.embed);
    auto embedPaddedEnd = alignUp(cast(uint) buf.data.length, FILE_ALIGN);
    padTo(buf, embedPaddedEnd);

    // .htext = relocated syscall helpers (only when they didn't fit in the .text→.data
    // gap).  Executable; sits above .bss with the file bytes here.
    auto htextFileOff = buf.data.length;
    if (!helpersInText) buf.put(helpers);
    auto htextPaddedEnd = alignUp(cast(uint) buf.data.length, FILE_ALIGN);
    padTo(buf, htextPaddedEnd);

    // .thunk (ABI thunks) + .edata (export table) + .reloc (base relocations) —
    // reserve file space now, fill the real bytes below once their RVAs are known.
    auto thunkFileOff = buf.data.length;
    if (dllExports) { foreach (_; 0 .. thunkSize) buf.put(cast(ubyte) 0);
                      padTo(buf, alignUp(cast(uint) buf.data.length, FILE_ALIGN)); }
    auto edataFileOff = buf.data.length;
    if (dllExports) { foreach (_; 0 .. edataSize) buf.put(cast(ubyte) 0);
                      padTo(buf, alignUp(cast(uint) buf.data.length, FILE_ALIGN)); }
    auto relocFileOff = buf.data.length;
    if (dllExports) { foreach (_; 0 .. relocSize) buf.put(cast(ubyte) 0);
                      padTo(buf, alignUp(cast(uint) buf.data.length, FILE_ALIGN)); }

    // ---- Compute RVAs ----
    auto textRva = SECT_ALIGN;
    auto textRawSize = cast(uint)(textPaddedEnd - textStart);
    auto rdataSize   = cast(uint)(rdataPaddedEnd - rdataFileOff);
    auto idataSize   = cast(uint)(idataPaddedEnd - idataFileOff);
    // Pin the data/rodata section at the ELF-assigned VA when it exists (the code's
    // absolute references depend on it); otherwise park it right after .text.
    auto rdataRva    = (dat !is null) ? cast(uint)(dat.vaddr - IMG_BASE)
                     : (rod !is null) ? cast(uint)(rod.vaddr - IMG_BASE)
                     : alignUp(cast(uint)(textRva + textRawSize), SECT_ALIGN);
    // .bss RVA/size come straight from the ELF's zero-init PT_LOAD; the code's
    // absolute references pin it there, so NAL cannot move it — it must lay .idata
    // AROUND it.  The ELF frequently packs .bss immediately after .rodata, leaving
    // no free page between .rdata and .bss; placing .idata right after .rdata then
    // overlapped .bss (same RVA) and produced an image the Windows loader rejects
    // ("This app can't run on your PC" / "Access is denied") — this is exactly the
    // nadb/yacc failure.  Fix: when a .bss exists, put .idata (and .embed) ABOVE the
    // .bss heap, where the VA space is free.  Without .bss, keep the old placement
    // right after .rdata (forcing a fresh page when .rdata is empty).
    uint bssRva = 0, bssVSize = 0;
    if (bss !is null) {
        bssRva   = cast(uint)(bss.vaddr - IMG_BASE);
        bssVSize = cast(uint) bss.memsz;
    }
    auto idataRva = (bss !is null)
        ? alignUp(cast(uint)(bssRva + bssVSize), SECT_ALIGN)
        : alignUp(cast(uint)(rdataRva + (rdataSize ? rdataSize : 1)), SECT_ALIGN);
    // When the helpers were relocated to their own .htext (just above .bss), push
    // .idata up above .htext so their RVAs don't collide.
    if (!helpersInText) idataRva = alignUp(htextRva + helperVSize, SECT_ALIGN);

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
    auto hint8Rva = rvaOf(hint8Off, idataFileOff, idataRva);
    auto hint9Rva  = rvaOf(hint9Off,  idataFileOff, idataRva);
    auto hint10Rva = rvaOf(hint10Off, idataFileOff, idataRva);
    auto hint11Rva = rvaOf(hint11Off, idataFileOff, idataRva);
    auto hint12Rva = rvaOf(hint12Off, idataFileOff, idataRva);
    auto hint13Rva = rvaOf(hint13Off, idataFileOff, idataRva);
    auto dllNRva  = rvaOf(dllNameOff, idataFileOff, idataRva);
    auto iltRva   = rvaOf(iltStart, idataFileOff, idataRva);
    auto iatRva   = rvaOf(iatStart, idataFileOff, idataRva);
    auto dirRva   = rvaOf(dirStart, idataFileOff, idataRva);

    auto data = buf.data;

    // ILT + IAT entries.  Index order MUST match HelperRel.iatIdx:
    //   0 GetStdHandle, 1 WriteFile, 2 ExitProcess, 3 ReadFile, 4 CreateFileA,
    //   5 CloseHandle, 6 GetCommandLineA, 7 GetCurrentProcessId,
    //   8 SetFilePointerEx (lseek), 9 DeleteFileA (unlink), 10 CreateDirectoryA (mkdir).
    auto hintRvas = [ cast(uint) hint1Rva, hint2Rva, hint3Rva, hint4Rva, hint5Rva, hint6Rva,
                      hint7Rva, hint8Rva, hint9Rva, hint10Rva, hint11Rva, hint12Rva, hint13Rva ];
    foreach (i, hr; hintRvas) {
        patchU64(data, iltStart + i * 8, cast(ulong) hr);
        patchU64(data, iatStart + i * 8, cast(ulong) hr);
    }

    // Import Directory entry
    patchU32(data, dirStart +  0, iltRva);
    patchU32(data, dirStart + 12, dllNRva);
    patchU32(data, dirStart + 16, iatRva);

    // Patch helper IAT-call disp32s now that we know IAT RVA.
    foreach (h; helperRelocs) {
        // helper byte offset within the helpers area; map to absolute file offset.
        // When relocated to .htext the bytes live at htextFileOff, not inside .text;
        // callRvaAfter still works via textRva+helperBase (== htextRva when relocated).
        auto absFileOff = helpersInText ? (textStart + helperBase + h.off)
                                        : (htextFileOff + h.off);
        auto callRvaAfter = textRva + cast(uint)(helperBase + h.off + 4);
        auto iatSlotRva = iatRva + h.iatIdx * 8;
        int disp = cast(int)(cast(long) iatSlotRva - cast(long) callRvaAfter);
        patchU32(data, absFileOff, cast(uint) disp);
    }

    // ---- Section headers ----
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
    writeSec(secHdrOffset +   0, ".text",  textRawSize, textRva,  cast(uint) textStart,    0x60000020);
    // When this slot carries the initialised DATA segment it is writable (.data,
    // R/W); a pure rodata (or the filler byte) stays read-only (.rdata).
    writeSec(secHdrOffset +  40, (dat !is null) ? ".data" : ".rdata",
             rdataSize, rdataRva, cast(uint) rdataFileOff,
             (dat !is null) ? 0xC0000040 : 0x40000040);

    // Section headers MUST be listed in ascending-RVA order or the Windows loader
    // rejects the image.  With a .bss present the RVA order is now
    //   .text < .rdata < .bss < .idata (< .embed),
    // so .bss takes header slot 2 and .idata slot 3.  Without .bss, .idata stays in
    // slot 2 (and .embed in slot 3), as before.
    // ---- Optional .bss section (mirrors the ELF's zero-init PT_LOAD) -------
    // Emitted with VirtualSize=memsz but SizeOfRawData=0 and PointerToRawData=0 so
    // it occupies no file bytes; the loader zero-inits memsz at the section RVA.
    if (bss !is null) {
        // writeSec mirrors RawSize into both fields; use a custom emit so RawSize stays 0.
        ubyte[8] nm = [cast(ubyte)'.', cast(ubyte)'b', cast(ubyte)'s', cast(ubyte)'s', 0, 0, 0, 0];
        size_t off = secHdrOffset + 80;
        foreach (i; 0 .. 8) data[off + i] = nm[i];
        patchU32(data, off +  8, bssVSize);
        patchU32(data, off + 12, bssRva);
        patchU32(data, off + 16, 0);              // SizeOfRawData
        patchU32(data, off + 20, 0);              // PointerToRawData
        patchU32(data, off + 36, 0xC0000080);     // uninit data + R + W
    }
    // Section slots in ascending-RVA order: .text(0) .data(1) [.bss] [.htext] .idata [.embed]
    uint slot = 2;
    if (bss !is null) slot++;                          // .bss already emitted at slot 2
    if (!helpersInText) {                              // .htext = relocated helpers, above .bss
        uint htextSize = cast(uint)(htextPaddedEnd - htextFileOff);
        writeSec(secHdrOffset + 40 * slot, ".htext", htextSize, htextRva,
                 cast(uint) htextFileOff, 0x60000020);  // R + X code
        slot++;
    }
    writeSec(secHdrOffset + 40 * slot, ".idata", idataSize, idataRva, cast(uint) idataFileOff, 0xC0000040);
    slot++;

    // ---- Optional .embed section (bundled extra inputs, above .idata) ----------
    uint embedRva  = 0;
    uint embedSize = cast(uint)(embedPaddedEnd - embedFileOff);
    if (elf.embed.length) {
        embedRva = alignUp(idataRva + idataSize, SECT_ALIGN);   // .idata is the top fixed section
        writeSec(secHdrOffset + 40 * slot, ".embed", embedSize, embedRva,
                 cast(uint) embedFileOff, 0x40000040);  // initialised R/O data
        slot++;
    }

    // ---- Optional .edata + .reloc sections (DLL exports + base relocations) -----
    // Placed ABOVE every other section (highest RVAs) so the ascending-RVA section
    // order and the gap-fill walk below stay valid.
    uint thunkRva = 0, edataRva = 0, relocRva = 0;
    if (dllExports) {
        uint top = alignUp(idataRva + idataSize, SECT_ALIGN);
        if (bss !is null)       { uint t = alignUp(bssRva + bssVSize, SECT_ALIGN); if (t > top) top = t; }
        if (elf.embed.length)   { uint t = alignUp(embedRva + embedSize, SECT_ALIGN); if (t > top) top = t; }
        thunkRva = top;
        edataRva = alignUp(thunkRva + cast(uint) thunkSize, SECT_ALIGN);
        relocRva = alignUp(edataRva + cast(uint) edataSize, SECT_ALIGN);
        writeSec(secHdrOffset + 40 * slot, ".thunk", cast(uint) thunkSize, thunkRva,
                 cast(uint) thunkFileOff, 0x60000020); slot++;   // R + X code
        writeSec(secHdrOffset + 40 * slot, ".edata", cast(uint) edataSize, edataRva,
                 cast(uint) edataFileOff, 0x40000040); slot++;   // init R/O data
        writeSec(secHdrOffset + 40 * slot, ".reloc", cast(uint) relocSize, relocRva,
                 cast(uint) relocFileOff, 0x42000040); slot++;   // init R/O + discardable
        // Now that the RVAs are fixed, materialise the real bytes into the reserved gaps.
        auto thunkBytes = buildDllThunks(hxl.exports, thunkRva);
        auto edataBytes = buildPeExportTable(hxl.exports, edataRva, dllBaseName, thunkRva);
        foreach (k, b; thunkBytes) data[thunkFileOff + k] = b;
        foreach (k, b; edataBytes) data[edataFileOff + k] = b;
        foreach (k, b; relocBytes) data[relocFileOff + k] = b;
    }

    // ---- Gap-free (VA-contiguous) section layout ----------------------------
    // The Windows image loader rejects a PE whose sections leave a VA hole (a gap
    // between one section's end and the next section's VirtualAddress) — the image
    // fails to start as "%1 is not a valid Win32 application".  The ELF's PT_LOADs
    // routinely leave such holes (e.g. a spare page between the data segment and
    // the getvec .bss heap, or between .text and the ELF-pinned data VA).  Close
    // them by stretching each section's VirtualSize up to the next section's
    // VirtualAddress.  VirtualSize may legally exceed SizeOfRawData (the loader
    // zero-fills the tail), so the raw file bytes and every RVA stay unchanged —
    // only the holes become committed zero pages.  Sections were emitted in
    // ascending-RVA slot order, so a straight walk over the slots suffices.
    uint readU32(size_t o) {
        return data[o] | (cast(uint) data[o+1] << 8)
             | (cast(uint) data[o+2] << 16) | (cast(uint) data[o+3] << 24);
    }
    for (uint i = 0; i + 1 < nSections; i++) {
        uint vaThis = readU32(secHdrOffset + 40 * i       + 12);
        uint vaNext = readU32(secHdrOffset + 40 * (i + 1) + 12);
        if (vaNext > vaThis) patchU32(data, secHdrOffset + 40 * i + 8, vaNext - vaThis);
    }

    // ---- Optional header ----
    void w32(size_t o, uint  v) { patchU32(data, optHdrOffset + o, v); }
    void w64(size_t o, ulong v) { patchU64(data, optHdrOffset + o, v); }
    data[optHdrOffset + 0] = 0x0B;
    data[optHdrOffset + 1] = 0x02;
    data[optHdrOffset + 2] = 14;
    w32( 4, textRawSize);
    w32( 8, rdataSize + idataSize);
    w32(12, bssVSize);                       // SizeOfUninitializedData
    // Entry point: for an EXE this is the _start prelude.  For a DLL it would be
    // called as DllMain(DLL_PROCESS_ATTACH) — but _start runs start()+ExitProcess,
    // which would terminate the host process on LoadLibrary.  A DLL with no DllMain
    // sets AddressOfEntryPoint = 0 so the loader never calls it.
    w32(16, dllExports ? 0 : textRva);
    w32(20, textRva);
    w64(24, IMG_BASE);
    w32(32, SECT_ALIGN);
    w32(36, FILE_ALIGN);
    data[optHdrOffset + 40] = 6;
    data[optHdrOffset + 48] = 6;
    // SizeOfImage covers all sections; if .bss is present its top is far higher
    // than .idata's because the heap region lives at VA 0x500000 in Hofos output.
    {
        uint topRva = alignUp(idataRva + idataSize, SECT_ALIGN);
        if (bss !is null) {
            uint bssTop = alignUp(bssRva + bssVSize, SECT_ALIGN);
            if (bssTop > topRva) topRva = bssTop;
        }
        if (elf.embed.length) {
            uint embedTop = alignUp(embedRva + embedSize, SECT_ALIGN);
            if (embedTop > topRva) topRva = embedTop;
        }
        if (dllExports) {
            uint relocTop = alignUp(relocRva + cast(uint) relocSize, SECT_ALIGN);
            if (relocTop > topRva) topRva = relocTop;
        }
        w32(56, topRva);
    }
    w32(60, alignUp(cast(uint) textStart, FILE_ALIGN));
    data[optHdrOffset + 68] = 3;                       // Subsystem = CONSOLE
    // DllCharacteristics: mark DYNAMIC_BASE so the loader relocates via .reloc
    // (a DLL at ImageBase 0x400000 always collides with the host EXE).
    if (dllExports) patchU16(data, optHdrOffset + 70, 0x0040);
    // Stack: reserve AND commit 16 MB.  Hofos's naive codegen gives some
    // functions very large frames (no register allocation; tens of KB), and a
    // single `sub rsp, frame` larger than the committed stack skips Windows'
    // guard page → access violation.  Linux auto-grows the stack; Windows must
    // have it committed up front.  16 MB covers the compiler's frames+recursion.
    w64(72, 0x1000000); w64(80, 0x1000000);
    w64(88, 0x100000); w64(96, 0x1000);
    w32(108, 16);

    auto dd = 112;
    w32(dd +  1 * 8 + 0, dirRva); w32(dd +  1 * 8 + 4, 40);
    w32(dd + 12 * 8 + 0, iatRva); w32(dd + 12 * 8 + 4, 112);  // IAT: 14 entries * 8 (13 imports + null)
    if (dllExports) {
        w32(dd + 0 * 8 + 0, edataRva); w32(dd + 0 * 8 + 4, cast(uint) edataSize);  // Export Directory
        w32(dd + 5 * 8 + 0, relocRva); w32(dd + 5 * 8 + 4, cast(uint) relocSize);  // Base Relocation Directory
    }

    std.file.write(outPath, data);

    writefln("nal: wrote %s", outPath);
    writefln("  input:    entry 0x%x, %d PT_LOAD",   elf.entry, elf.loads.length);
    writefln("  rewrote:  %d syscall sites in .text", sites.length);
    if (rod !is null)
        writefln("  rdata:    %d bytes from ELF .rodata", rod.bytes.length);
    writefln("  helpers:  %d bytes (WRITE EXIT READ OPEN CLOSE CREATE FWRITE; syscall6: exit getpid lseek unlink mkdir)", helpers.length);
    writefln("  imports:  kernel32!GetStdHandle WriteFile ExitProcess ReadFile CreateFileA CloseHandle GetCommandLineA GetCurrentProcessId SetFilePointerEx DeleteFileA CreateDirectoryA MoveFileExA Sleep");
}

// Parse a decimal or 0x-hex unsigned integer (for --bss / --entry).
uint parseNum(string s) {
    import std.conv : to;
    if (s.length > 2 && s[0] == '0' && (s[1] == 'x' || s[1] == 'X'))
        return to!uint(s[2 .. $], 16);
    return to!uint(s);
}

// Wrap a raw bare-metal .bin (text++rodata, no header — as emitted by Hofos's VAX/PDP-7
// .bin targets) in a Unix-style a.out (OMAGIC 0407, 32-byte exec header).  Runtime-agnostic
// format conversion so the image is loadable by a.out-aware tools / VAX operating systems.
// OMAGIC is impure (text writable) so rodata rides at the end of a_text; a_data=0; a_bss=heap.
void writeVaxAout(string outPath, const(ubyte)[] bin, uint bss, uint entry) {
    auto data = appender!(ubyte[])();
    void put32(uint v) { data.put(nativeToLittleEndian(v)[]); }
    put32(0x107);                 // a_magic = 0407 (OMAGIC)
    put32(cast(uint) bin.length); // a_text  (code + rodata)
    put32(0);                     // a_data
    put32(bss);                   // a_bss   (globals + bump heap)
    put32(0);                     // a_syms
    put32(entry);                 // a_entry
    put32(0);                     // a_trsize
    put32(0);                     // a_drsize
    data.put(bin);
    std.file.write(outPath, data.data);
}

// ============================================================================
// Shared-library support — reads Hofos's `<in>.hxl` sidecar (compile -fshared):
//   HXL1 <textbase> / EXPORTS n + "name vaddr" lines / RELOCS m + "vaddr" lines.
// Builds a functional export table + base relocations so other languages can
// dlopen/dlsym (--so) or LoadLibrary/GetProcAddress (--dll) the result.
// ============================================================================

struct HxlExport { string name; ulong vaddr; }
struct HxlData   { ulong textBase; HxlExport[] exports; ulong[] relocs; bool ok; }

HxlData parseHxl(string path) {
    import std.string : strip, split;
    import std.conv : to;
    HxlData h;
    if (!std.file.exists(path)) return h;
    enum Mode { none, exp, rel }
    Mode mode = Mode.none;
    foreach (rawLine; File(path).byLine) {
        auto parts = rawLine.idup.strip.split;
        if (parts.length == 0) continue;
        if (parts[0] == "HXL1")         { if (parts.length >= 2) h.textBase = parts[1].to!ulong; }
        else if (parts[0] == "EXPORTS") mode = Mode.exp;
        else if (parts[0] == "RELOCS")  mode = Mode.rel;
        else if (mode == Mode.exp && parts.length >= 2)
            h.exports ~= HxlExport(parts[0].idup, parts[1].to!ulong);
        else if (mode == Mode.rel && parts.length >= 1)
            h.relocs ~= parts[0].to!ulong;
    }
    h.ok = true;
    return h;
}

// Read the 8-byte LE value at virtual address `va` from the loaded segments.
ulong readVA(ref ElfView elf, ulong va) {
    foreach (ref s; elf.loads)
        if (va >= s.vaddr && va + 8 <= s.vaddr + s.bytes.length) {
            ulong v = 0;
            size_t o = cast(size_t)(va - s.vaddr);
            foreach (j; 0 .. 8) v |= (cast(ulong) s.bytes[o + j]) << (8 * j);
            return v;
        }
    return 0;
}

void patchU16(ubyte[] d, size_t off, ushort v) {
    auto b = nativeToLittleEndian(v);
    d[off] = b[0]; d[off + 1] = b[1];
}

// Write an Elf64_Phdr (56 bytes) at `off`.
void writePhdr(ubyte[] d, size_t off, uint type, uint flags,
               ulong foff, ulong vaddr, ulong filesz, ulong memsz, ulong algn) {
    patchU32(d, off + 0,  type);
    patchU32(d, off + 4,  flags);
    patchU64(d, off + 8,  foff);
    patchU64(d, off + 16, vaddr);
    patchU64(d, off + 24, vaddr);      // p_paddr = p_vaddr
    patchU64(d, off + 32, filesz);
    patchU64(d, off + 40, memsz);
    patchU64(d, off + 48, algn);
}

// Turn a Hofos executable ELF into a functional ET_DYN shared object.
// The RELATIVE dynamic-relocation type is architecture-specific: at load the
// loader stores (load_base + r_addend) at r_offset.  Map e_machine -> R_*_RELATIVE
// so `nal --so` produces a valid .so for ANY target ELF, not just x86-64.
ulong relativeRelocType(ushort m) {
    switch (m) {
        case 62:   return 8;     // EM_X86_64     R_X86_64_RELATIVE
        case 183:  return 1027;  // EM_AARCH64    R_AARCH64_RELATIVE
        case 243:  return 3;     // EM_RISCV      R_RISCV_RELATIVE
        case 258:  return 3;     // EM_LOONGARCH  R_LARCH_RELATIVE
        case 22:   return 12;    // EM_S390       R_390_RELATIVE
        case 21:   return 22;    // EM_PPC64      R_PPC64_RELATIVE
        case 20:   return 22;    // EM_PPC        R_PPC_RELATIVE
        case 43:   return 22;    // EM_SPARCV9    R_SPARC_RELATIVE
        case 2:    return 22;    // EM_SPARC      R_SPARC_RELATIVE
        case 4:    return 22;    // EM_68K        R_68K_RELATIVE
        case 8:    return 3;     // EM_MIPS       R_MIPS_REL32 (best-effort)
        default:   return 8;
    }
}

void writeSo(string outPath, string elfPath, ref ElfView elf) {
    auto hxl = parseHxl(elfPath ~ ".hxl");
    enforce(hxl.ok && hxl.exports.length > 0,
            "nal --so: missing/empty `" ~ elfPath ~ ".hxl` (compile with -fshared)");

    ubyte[] raw = cast(ubyte[]) read(elfPath);

    ulong maxVEnd = 0;
    foreach (ph; elf.phs)
        if (ph.p_type == PT_LOAD && ph.p_vaddr + ph.p_memsz > maxVEnd)
            maxVEnd = ph.p_vaddr + ph.p_memsz;
    ulong regVaddr   = alignUp(maxVEnd, 0x1000UL);
    ulong regFileOff = alignUp(cast(ulong) raw.length, 0x1000UL);

    uint nsym = cast(uint)(hxl.exports.length + 1);       // + null sym

    // .dynstr (index 0 = "")
    auto dynstr = appender!(ubyte[])();
    dynstr.put(cast(ubyte) 0);
    uint[] nameOff; nameOff.length = hxl.exports.length;
    foreach (i, e; hxl.exports) {
        nameOff[i] = cast(uint) dynstr.data.length;
        dynstr.put(cast(ubyte[]) e.name);
        dynstr.put(cast(ubyte) 0);
    }
    ulong strSz  = dynstr.data.length;
    ulong strOff = 0;
    ulong symOff = alignUp(strOff + strSz, 8);
    ulong symSz  = cast(ulong) nsym * 24;
    ulong hashOff = alignUp(symOff + symSz, 8);
    ulong hashSz  = (2 + 1 + nsym) * 4UL;                 // nbucket,nchain + bucket[1] + chain[nsym]
    ulong relaOff = alignUp(hashOff + hashSz, 8);
    ulong relaSz  = cast(ulong) hxl.relocs.length * 24;
    ulong dynOff  = alignUp(relaOff + relaSz, 8);
    ulong dynSz   = 12 * 16UL;                            // 12 Elf64_Dyn entries
    ulong regLen  = dynOff + dynSz;

    ulong strVA = regVaddr + strOff, symVA = regVaddr + symOff, hashVA = regVaddr + hashOff;
    ulong relaVA = regVaddr + relaOff, dynVA = regVaddr + dynOff;

    auto reg = appender!(ubyte[])();
    void regPad(ulong t) { while (reg.data.length < t) reg.put(cast(ubyte) 0); }

    reg.put(dynstr.data);                                 // .dynstr
    regPad(symOff);                                       // .dynsym
    foreach (_; 0 .. 24) reg.put(cast(ubyte) 0);          //   null sym
    foreach (i, e; hxl.exports) {
        writeLE!uint  (reg, nameOff[i]);                  //   st_name
        reg.put(cast(ubyte) 0x12);                        //   st_info = STB_GLOBAL|STT_FUNC
        reg.put(cast(ubyte) 0);                           //   st_other
        writeLE!ushort(reg, cast(ushort) 1);              //   st_shndx (defined)
        writeLE!ulong (reg, e.vaddr);                     //   st_value
        writeLE!ulong (reg, 0UL);                         //   st_size
    }
    regPad(hashOff);                                      // .hash (1 bucket -> linear chain)
    writeLE!uint(reg, 1u);
    writeLE!uint(reg, nsym);
    writeLE!uint(reg, (nsym > 1) ? 1u : 0u);              //   bucket[0]
    writeLE!uint(reg, 0u);                                //   chain[0]
    foreach (i; 1 .. nsym)
        writeLE!uint(reg, (i + 1 < nsym) ? cast(uint)(i + 1) : 0u);
    regPad(relaOff);                                      // .rela.dyn (arch-specific R_*_RELATIVE)
    ulong relType = relativeRelocType(elf.hdr.machine);
    foreach (site; hxl.relocs) {
        writeLE!ulong(reg, site);                         //   r_offset
        writeLE!ulong(reg, relType);                      //   r_info = <arch>_RELATIVE
        writeLE!long (reg, cast(long) readVA(elf, site)); //   r_addend = link-time absolute value
    }
    regPad(dynOff);                                       // .dynamic
    void dyn(long tag, ulong val) { writeLE!long(reg, tag); writeLE!ulong(reg, val); }
    dyn(4,  hashVA); dyn(5,  strVA); dyn(6, symVA);
    dyn(10, strSz);  dyn(11, 24);
    dyn(7,  relaVA); dyn(8,  relaSz); dyn(9, 24);
    dyn(0x6ffffff9, hxl.relocs.length);                   // DT_RELACOUNT
    dyn(22, 0);                                           // DT_TEXTREL (relocs in RX .text)
    dyn(30, 4);                                           // DT_FLAGS = DF_TEXTREL
    dyn(0,  0);                                           // DT_NULL

    auto outp = appender!(ubyte[])();
    outp.put(raw);
    while (outp.data.length < regFileOff) outp.put(cast(ubyte) 0);
    outp.put(reg.data);
    ubyte[] outb = outp.data;

    outb[16] = 3; outb[17] = 0;                           // e_type = ET_DYN
    ushort oldPhnum = elf.hdr.phnum;
    patchU16(outb, 56, cast(ushort)(oldPhnum + 3));       // e_phnum += 3
    size_t phent = elf.hdr.phentsize;
    size_t ph3   = cast(size_t) elf.hdr.phoff + cast(size_t) oldPhnum * phent;
    writePhdr(outb, ph3,             PT_LOAD, PF_R, regFileOff, regVaddr, regLen, regLen, 0x1000);
    writePhdr(outb, ph3 + phent,     2u, PF_R | PF_W, regFileOff + dynOff, dynVA, dynSz, dynSz, 8);
    // PT_GNU_STACK (RW, no X) — without it the loader requests an executable
    // stack for the .so and dlopen fails on hardened kernels.
    writePhdr(outb, ph3 + 2 * phent, 0x6474e551u, PF_R | PF_W, 0, 0, 0, 0, 0);

    std.file.write(outPath, outb);
    stderr.writefln("nal (so): wrote %s  (ET_DYN, %d exports, %d relocs)",
                    outPath, hxl.exports.length, hxl.relocs.length);
}

int main(string[] args) {
    bool wantMacho = false;
    bool wantWasm  = false;
    bool wantEfi   = false;
    bool wantDll   = false;
    bool wantSo    = false;
    bool wantDylib = false;
    bool wantVaxAout = false;
    bool wantNe   = false;
    bool wantHunk = false;
    uint vaxBss   = 0x80000;   // 512K default (matches Hofos VAX_HEAP_SIZE)
    uint vaxEntry = 0;
    // CLI:  nal [flags] file1.elf [file2.elf ...] -out OUTPUT
    string[] inputs;
    string outFile = null;
    bool sawOutFlag = false;
    for (size_t k = 1; k < args.length; k++) {
        string a = args[k];
        if (a == "--macho")       wantMacho = true;
        else if (a == "--wasm")   wantWasm  = true;
        else if (a == "--efi")    wantEfi   = true;
        else if (a == "--dll")    wantDll   = true;
        else if (a == "--so")     wantSo    = true;
        else if (a == "--dylib")  wantDylib = true;
        else if (a == "--vax-aout") wantVaxAout = true;   // wrap a raw .bin in VAX a.out 0407
        else if (a == "--ne")     wantNe = true;          // convert a DOS MZ .EXE -> NE container
        else if (a == "--hunk")   wantHunk = true;        // convert a m68k ELF32-BE -> AmigaOS Hunk
        else if (a == "--bss")   { if (k + 1 < args.length) vaxBss   = parseNum(args[++k]); }
        else if (a == "--entry") { if (k + 1 < args.length) vaxEntry = parseNum(args[++k]); }
        else if (a == "-out") { sawOutFlag = true; if (k + 1 < args.length) outFile = args[++k]; }
        else inputs ~= a;          // everything else is an input file
    }
    if (inputs.length == 0) {
        stderr.writeln("\x1b[1;31mNAL: Fatal Error: No Input Files.\x1b[0m");
        return 2;
    }
    // AUTO-DETECT format: an ELF input goes through the ELF->PE/Mach-O/... pipeline
    // (machine from e_machine); a NON-ELF input is a bare-metal .bin -> wrap in a.out.
    // No flag needed (--vax-aout still accepted as an explicit override).
    {
        import std.file : read;
        auto probe = cast(ubyte[]) read(inputs[0]);
        bool isElf = probe.length >= 4 && probe[0] == 0x7F &&
                     probe[1] == 'E' && probe[2] == 'L' && probe[3] == 'F';
        // --ne: convert a DOS MZ .EXE (from the 8086 backend) into an NE container.
        if (wantNe) {
            import ne : writeNE;
            string outp = outFile;
            if (outp is null) {
                outp = inputs[0];
                if (outp.length > 4 && outp[$ - 4 .. $] == ".EXE") outp = outp[0 .. $ - 4];
                else if (outp.length > 4 && outp[$ - 4 .. $] == ".exe") outp = outp[0 .. $ - 4];
                outp ~= ".NE.EXE";
            }
            writeNE(outp, probe);
            return 0;
        }
        // --hunk: a Hofos m68k ELF32-BE -> AmigaOS Hunk executable.  Handled here
        // (before the ELF64-LE readElf) because hunk.d has its own ELF32-BE parser.
        if (wantHunk) {
            import hunk : writeHunk;
            string outp = outFile;
            if (outp is null) {
                outp = inputs[0];
                if (outp.length > 4 && outp[$ - 4 .. $] == ".elf") outp = outp[0 .. $ - 4];
                outp ~= ".hunk";
            }
            writeHunk(outp, inputs[0]);
            return 0;
        }
        if (!isElf || wantVaxAout) {
            string outp = outFile;
            if (outp is null) {
                outp = inputs[0];
                if (outp.length > 4 && outp[$ - 4 .. $] == ".bin") outp = outp[0 .. $ - 4];
                outp ~= ".aout";
            }
            writeVaxAout(outp, probe, vaxBss, vaxEntry);
            stderr.writefln("nal (a.out): wrote %s  (raw .bin detected -> VAX a.out 0407: a_text=%d a_bss=0x%x entry=0x%x)",
                            outp, probe.length, vaxBss, vaxEntry);
            return 0;
        }
    }
    // -out must carry an OUTPUT filename when given (don't silently drop a
    // trailing `-out`).
    if (sawOutFlag && outFile is null) {
        stderr.writeln("\x1b[1;31mNAL: Fatal Error: -out requires an OUTPUT filename.\x1b[0m");
        stderr.writeln("  usage: nal file1.elf [file2.elf ...] -out OUTPUT");
        return 2;
    }
    // Bundling several inputs (`nal a.elf b.elf -out x.exe`) requires an explicit
    // -out: the output name can't be inferred unambiguously from multiple inputs.
    if (inputs.length > 1 && outFile is null) {
        stderr.writeln("\x1b[1;31mNAL: Fatal Error: -out OUTPUT is required when bundling multiple inputs.\x1b[0m");
        stderr.writeln("  usage: nal file1.elf file2.elf [...] -out OUTPUT");
        return 2;
    }
    if (outFile is null) {         // single input, no -out: derive OUTPUT from it
        outFile = inputs[0];
        if (outFile.length > 4 && outFile[$ - 4 .. $] == ".elf") outFile = outFile[0 .. $ - 4];
        outFile ~= ".exe";
    }
    if (inputs.length > 1)
        stderr.writefln("NAL: bundling %d inputs; %s is the entry (others embedded read-only)",
                        inputs.length, inputs[0]);
    string[] rest = [inputs[0], outFile];
    try {
        auto elf = mergeInputs(inputs);
        if (wantEfi) {
            if (elf.hdr.machine == 183) {          // EM_AARCH64 -> AArch64 UEFI app
                import efi_a64 : writeEfiA64;
                writeEfiA64(rest[1], elf);
            } else {
                import efi : writeEfi;
                writeEfi(rest[1], elf);
            }
        } else if (wantWasm) {
            import wasm : writeWasm;
            writeWasm(rest[1], elf);
        } else if (wantDylib) {
            import macho : writeMachO;
            // Mach-O 64 with MH_DYLIB filetype.  Symbol export tables
            // (LC_SYMTAB / LC_DYSYMTAB / LC_ID_DYLIB) are not yet emitted —
            // dynamic linking against this dylib isn't functional yet, but
            // `file` reports the correct type.
            writeMachO(rest[1], elf, true);
            stderr.writefln("nal (dylib): wrote %s  (MH_DYLIB, LC_SYMTAB pending)", rest[1]);
        } else if (wantMacho) {
            import macho : writeMachO;
            writeMachO(rest[1], elf);
        } else if (wantSo) {
            // With a `<in>.hxl` sidecar (compile -fshared) build a REAL shared
            // object: .dynsym/.hash/.rela.dyn/.dynamic exports + base relocations
            // so dlopen/dlsym work.  Without it, fall back to the old e_type flip.
            if (std.file.exists(rest[0] ~ ".hxl")) {
                writeSo(rest[1], rest[0], elf);
            } else {
                auto raw = cast(ubyte[]) read(rest[0]);
                if (raw.length >= 18 && raw[0] == 0x7F && raw[1] == 'E' &&
                    raw[2] == 'L' && raw[3] == 'F') { raw[16] = 3; raw[17] = 0; }
                std.file.write(rest[1], raw);
                stderr.writefln("nal (so): wrote %s  (ET_DYN, no .hxl -> symbols/PLT pending)", rest[1]);
            }
        } else if (wantDll) {
            // PE32+ with IMAGE_FILE_DLL set + export table + base relocs (from <in>.hxl).
            writePE(rest[1], elf, true, rest[0]);
        } else if (elf.hdr.machine == 183) {       // EM_AARCH64 -> Windows ARM64 PE
            import pe_aarch64 : writePEAarch64;
            writePEAarch64(rest[1], elf);
        } else {
            writePE(rest[1], elf);
        }
        return 0;
    } catch (Exception e) {
        stderr.writefln("nal: %s", e.msg);
        return 1;
    }
}
