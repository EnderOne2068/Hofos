/**
 * efi.d — ELF64 (x86-64) → UEFI Application (PE32+ EFI_APPLICATION).
 *
 * The entire EFI runtime lives in src/rt/efi-rt.fasm (assembled flat to
 * efi-rt.bin, embedded here as `efiRtBlob`).  That blob is placed in a dedicated
 * .efi PE section and exposes a fixed dispatch table; NAL rewrites the program's
 * Linux-syscall sites in .text to call/jmp the matching slot:
 *
 *   blob+0   efi_main    PE entry: save ST/ImageHandle, watchdog off, AllocatePool
 *                        a 64 MB heap + redirect the getvec bump slot, acquire the
 *                        SimpleFileSystem root, synthesise argv from LoadOptions,
 *                        then jump to the ELF _start.
 *   blob+8   efi_exit    BootServices->Exit(ImageHandle, status, 0, NULL).
 *   blob+16  efi_write   write(rdi=fd, rsi=buf, rdx=count): fd<3 ConOut else file.
 *   blob+24  efi_read    read (rdi=fd, rsi=buf, rdx=count): fd<3 ConIn  else file.
 *   blob+32  efi_open    open (rdi=path) -> fd  (O_RDONLY).
 *   blob+40  efi_close   close(rdi=fd).
 *   blob+48  efi_create  open (rdi=path) for write -> fd (CREATE|WRITE).
 *   blob+56  efi_wrch    putchar(dil) to ConOut (1-byte console fast path).
 *   blob+64  patch_table two absolute qwords NAL fills: heap_slot_va
 *                        (= cg_heap_vaddr) and start_va (= the ELF _start / textVA).
 *
 * All I/O shims use Linux syscall register semantics, so a rewritten site just
 * loads its args and `call`s the slot.  There are NO hand-encoded machine-code
 * byte arrays for the runtime in this file — only the tiny rel32 site patches.
 *
 * vaddr PRESERVATION: the codegen bakes ABSOLUTE addresses (rodata strings, .bss
 * globals); each PE section is placed at RVA = vaddr - ImageBase, and the .efi
 * blob sits ABOVE everything, so nothing the program baked ever moves.
 *
 * RELOCS_STRIPPED at ImageBase 0x400000; .bss memsz capped (globals only) — the
 * real heap is the runtime AllocatePool region.
 *
 * Invocation: `nal --efi input.elf output.efi`.
 */
module efi;

import std.array : appender, Appender;
import std.bitmanip : nativeToLittleEndian;
import std.exception : enforce;
import std.file : write;
import std.format : format;
import std.stdio : writefln;

import nal : ElfView, LoadSeg, findText, findRodata, findBss,
             matchWritePattern, matchExitPattern, matchWrchHelper, matchReadHelper,
             matchOpenHelper, matchCloseHelper, matchWriteSyscallHelper, matchCreateHelper,
             ExitForm, alignUp, patchU32, patchU64, padTo;

static immutable ubyte[] efiRtBlob = cast(immutable(ubyte)[]) import("efi-rt.bin");

// Fixed dispatch-slot / patch-table offsets within the blob.
enum EFI_RT_MAIN   = 0;
enum EFI_RT_EXIT   = 8;
enum EFI_RT_WRITE  = 16;
enum EFI_RT_READ   = 24;
enum EFI_RT_OPEN   = 32;
enum EFI_RT_CLOSE  = 40;
enum EFI_RT_CREATE = 48;
enum EFI_RT_WRCH   = 56;
enum EFI_RT_PATCH  = 64;          // patch_table: [heap_slot_va, start_va]

enum EFI_IMG_BASE  = 0x400000UL;
enum EFI_FILE_ALIGN = 0x200u;
enum EFI_SECT_ALIGN = 0x1000u;

enum SUBSYSTEM_EFI_APP = 10;

// ---------------------------------------------------------------------------
// Syscall-site rewrites: replace each matched helper with arg setup + a `call`
// to its dispatch slot (or `jmp efi_exit`).  The helper bodies are in the blob.
// ---------------------------------------------------------------------------

// writes("literal") intrinsic, 42-byte slot.  efi_write(rdi=fd, rsi=buf, rdx=len);
// console write is write(1, buf, len).  callDisp is rel to the byte after the call
// (siteVA + 29).
void writeEfiWriteRewrite(ubyte[] code, size_t i, int callDisp, ulong bufVA, ulong len) {
    size_t p = i;
    code[p++] = 0xBF;                                          // mov edi, 1
    foreach (b; nativeToLittleEndian(cast(uint) 1))     code[p++] = b;
    code[p++] = 0x48; code[p++] = 0xBE;                        // movabs rsi, bufVA
    foreach (b; nativeToLittleEndian(bufVA))            code[p++] = b;
    code[p++] = 0xBA;                                          // mov edx, len
    foreach (b; nativeToLittleEndian(cast(uint) len))   code[p++] = b;
    code[p++] = 0x48; code[p++] = 0x83; code[p++] = 0xEC; code[p++] = 0x28;  // sub rsp,0x28
    code[p++] = 0xE8;                                          // call rel32
    foreach (b; nativeToLittleEndian(callDisp))         code[p++] = b;
    code[p++] = 0x48; code[p++] = 0x83; code[p++] = 0xC4; code[p++] = 0x28;  // add rsp,0x28
    while (p < i + 42) code[p++] = 0x90;
}

// wrch helper, 38-byte slot.  Char is already in rdi (dil): just call efi_wrch.
// callDisp is rel to siteVA + 13.
void writeEfiWrchRewrite(ubyte[] code, size_t i, int callDisp) {
    size_t p = i;
    code[p++] = 0x55;                                          // push rbp
    code[p++] = 0x48; code[p++] = 0x89; code[p++] = 0xE5;      // mov rbp, rsp
    code[p++] = 0x48; code[p++] = 0x83; code[p++] = 0xEC; code[p++] = 0x20;  // sub rsp,0x20
    code[p++] = 0xE8;                                          // call efi_wrch
    foreach (b; nativeToLittleEndian(callDisp)) code[p++] = b;
    code[p++] = 0xC9;                                          // leave
    code[p++] = 0xC3;                                          // ret
    while (p < i + 38) code[p++] = 0x90;
}

// 13-byte leaf helpers (read/write-syscall/close): keep the frame, swap the
// `mov eax,nr; syscall` for a `call <slot>`.  The args (rdi/rsi/rdx) are already
// set by the helper's caller.  callDisp is rel to siteVA + 9.
void writeEfiLeafRewrite(ubyte[] code, size_t i, int callDisp) {
    code[i+0] = 0x55; code[i+1] = 0x48; code[i+2] = 0x89; code[i+3] = 0xE5;  // push rbp; mov rbp,rsp
    code[i+4] = 0xE8;                                          // call <slot>
    foreach (k, b; nativeToLittleEndian(callDisp)) code[i+5+k] = b;
    code[i+9]  = 0xC9;                                         // leave
    code[i+10] = 0xC3;                                         // ret
    code[i+11] = 0x90; code[i+12] = 0x90;
}

// 17-byte __open helper.  callDisp rel to siteVA + 9.
void writeEfiOpenRewrite(ubyte[] code, size_t i, int callDisp) {
    code[i+0] = 0x55; code[i+1] = 0x48; code[i+2] = 0x89; code[i+3] = 0xE5;
    code[i+4] = 0xE8;                                          // call efi_open
    foreach (k, b; nativeToLittleEndian(callDisp)) code[i+5+k] = b;
    foreach (j; 9 .. 15) code[i+j] = 0x90;
    code[i+15] = 0xC9; code[i+16] = 0xC3;                      // leave; ret
}

// 23-byte __create helper.  callDisp rel to siteVA + 9.
void writeEfiCreateRewrite(ubyte[] code, size_t i, int callDisp) {
    code[i+0] = 0x55; code[i+1] = 0x48; code[i+2] = 0x89; code[i+3] = 0xE5;
    code[i+4] = 0xE8;                                          // call efi_create
    foreach (k, b; nativeToLittleEndian(callDisp)) code[i+5+k] = b;
    foreach (j; 9 .. 21) code[i+j] = 0x90;
    code[i+21] = 0xC9; code[i+22] = 0xC3;                      // leave; ret
}

// EXIT, 15-byte slot: jmp efi_exit (status already in rax).  jmpDisp rel to siteVA + 5.
void writeEfiExitRewrite(ubyte[] code, size_t i, int jmpDisp) {
    code[i + 0] = 0xE9;                 // jmp rel32
    foreach (k, b; nativeToLittleEndian(jmpDisp)) code[i + 1 + k] = b;
    foreach (j; 5 .. 15) code[i + j] = 0x90;
}

// ---------------------------------------------------------------------------
// PE32+ EFI writer.
// ---------------------------------------------------------------------------

void writeEfi(string outPath, ElfView elf) {
    auto txt = findText(elf);
    auto rod = findRodata(elf);
    auto bss = findBss(elf);
    enforce(txt !is null, "elf: no executable PT_LOAD");

    // ---- Find and classify the syscall sites in .text -------------------
    ubyte[] code = txt.bytes.dup;
    auto userCodeLen = code.length;

    enum SiteKind : ubyte { writeImm, exit, wrch, read, writeSc, close, open, create }
    struct Site { size_t off; SiteKind kind; ulong bufVA; ulong len; }
    Site[] sites;
    for (size_t i = 0; i < userCodeLen; ) {
        ulong bv, ln;
        if (matchWritePattern(code, i, bv, ln)) { sites ~= Site(i, SiteKind.writeImm, bv, ln); i += 42; continue; }
        if (matchWrchHelper(code, i))           { sites ~= Site(i, SiteKind.wrch,    0, 0);   i += 38; continue; }
        if (matchReadHelper(code, i))           { sites ~= Site(i, SiteKind.read,    0, 0);   i += 13; continue; }
        if (matchWriteSyscallHelper(code, i))   { sites ~= Site(i, SiteKind.writeSc, 0, 0);   i += 13; continue; }
        if (matchCloseHelper(code, i))          { sites ~= Site(i, SiteKind.close,   0, 0);   i += 13; continue; }
        if (matchOpenHelper(code, i))           { sites ~= Site(i, SiteKind.open,    0, 0);   i += 17; continue; }
        if (matchCreateHelper(code, i))         { sites ~= Site(i, SiteKind.create,  0, 0);   i += 23; continue; }
        if (matchExitPattern(code, i) != ExitForm.none) { sites ~= Site(i, SiteKind.exit, 0, 0); i += 15; continue; }
        ++i;
    }

    // ---- Place the .efi blob ABOVE every preserved ELF vaddr ------------
    enum BASE = EFI_IMG_BASE;
    enum EFI_BSS_CAP = 0x10000;             // 64 KB (globals only; real heap is AllocatePool'd)
    auto textVA = txt.vaddr;
    bool hasRdata = rod !is null && rod.bytes.length > 0;
    bool hasBss   = bss !is null && bss.memsz > 0;
    auto bssMemsz = hasBss ? (bss.memsz < EFI_BSS_CAP ? bss.memsz : cast(ulong) EFI_BSS_CAP) : 0;

    ulong topVA = textVA + txt.bytes.length;
    if (hasRdata) { auto t = rod.vaddr + rod.bytes.length; if (t > topVA) topVA = t; }
    if (hasBss)   { auto t = bss.vaddr + bssMemsz;         if (t > topVA) topVA = t; }
    auto efiVA = (topVA + (EFI_SECT_ALIGN - 1)) & ~cast(ulong)(EFI_SECT_ALIGN - 1);

    auto efiBlob = efiRtBlob.dup;
    auto blobVA  = efiVA;

    void patchU64In(ubyte[] arr, size_t off, ulong v) {
        ubyte[8] b = nativeToLittleEndian(v);
        foreach (i; 0 .. 8) arr[off + i] = b[i];
    }
    patchU64In(efiBlob, EFI_RT_PATCH + 0, hasBss ? bss.vaddr : efiVA);   // heap_slot_va
    patchU64In(efiBlob, EFI_RT_PATCH + 8, textVA);                       // start_va

    // ---- Rewrite each .text site to call/jmp its dispatch slot ----------
    foreach (s; sites) {
        auto siteVA = textVA + s.off;
        int disp(ulong slot, ulong pcAfter) {
            return cast(int)(cast(long)(blobVA + slot) - cast(long)(siteVA + pcAfter));
        }
        final switch (s.kind) {
        case SiteKind.writeImm: writeEfiWriteRewrite (code, s.off, disp(EFI_RT_WRITE, 29), s.bufVA, s.len); break;
        case SiteKind.wrch:     writeEfiWrchRewrite  (code, s.off, disp(EFI_RT_WRCH, 13));  break;
        case SiteKind.read:     writeEfiLeafRewrite  (code, s.off, disp(EFI_RT_READ, 9));    break;
        case SiteKind.writeSc:  writeEfiLeafRewrite  (code, s.off, disp(EFI_RT_WRITE, 9));   break;
        case SiteKind.close:    writeEfiLeafRewrite  (code, s.off, disp(EFI_RT_CLOSE, 9));   break;
        case SiteKind.open:     writeEfiOpenRewrite  (code, s.off, disp(EFI_RT_OPEN, 9));    break;
        case SiteKind.create:   writeEfiCreateRewrite(code, s.off, disp(EFI_RT_CREATE, 9));  break;
        case SiteKind.exit:     writeEfiExitRewrite  (code, s.off, disp(EFI_RT_EXIT, 5));    break;
        }
    }

    auto efiSecBytes = efiBlob;          // self-contained: code + slots + buffers

    // ---- Build PE32+ EFI image -------------------------------------------
    uint nSections = 1 + (hasRdata ? 1 : 0) + (hasBss ? 1 : 0) + 1;  // text + rdata? + bss? + efi

    auto buf = appender!(ubyte[])();
    buf.put(cast(ubyte[]) "MZ");
    foreach (_; 0 .. 58) buf.put(cast(ubyte) 0);
    void put32u(ref Appender!(ubyte[]) a, uint v) { ubyte[4] b = nativeToLittleEndian(v); a.put(b[]); }
    void put16u(ref Appender!(ubyte[]) a, ushort v){ ubyte[2] b = nativeToLittleEndian(v); a.put(b[]); }
    put32u(buf, 0x80);
    while (buf.data.length < 0x80) buf.put(cast(ubyte) 0);

    buf.put(cast(ubyte[]) "PE\0\0");
    put16u(buf, 0x8664);
    put16u(buf, cast(ushort) nSections);
    put32u(buf, 0); put32u(buf, 0); put32u(buf, 0);
    put16u(buf, 240);
    put16u(buf, 0x0023);                            // EXEC | LARGE_ADDR | RELOCS_STRIPPED

    auto optHdrOffset = buf.data.length;
    foreach (_; 0 .. 240) buf.put(cast(ubyte) 0);
    auto secHdrOffset = buf.data.length;
    foreach (_; 0 .. 40 * nSections) buf.put(cast(ubyte) 0);

    // ---- Section raw data (file order: text, rdata, efi; bss has none) ----
    auto textFileOff = alignUp(cast(uint) buf.data.length, EFI_FILE_ALIGN);
    padTo(buf, textFileOff);
    auto textStart = buf.data.length;
    buf.put(code);
    padTo(buf, alignUp(cast(uint) buf.data.length, EFI_FILE_ALIGN));

    size_t rdataFileOff = 0;
    if (hasRdata) {
        rdataFileOff = buf.data.length;
        buf.put(rod.bytes);
        padTo(buf, alignUp(cast(uint) buf.data.length, EFI_FILE_ALIGN));
    }

    auto efiFileOff = buf.data.length;
    buf.put(efiSecBytes);
    padTo(buf, alignUp(cast(uint) buf.data.length, EFI_FILE_ALIGN));

    auto data = buf.data;

    // ---- Section headers (RVA = vaddr - ImageBase, preserving ELF layout) --
    void writeSec(size_t off, string name, uint vsize, uint rva,
                  uint rawSize, uint rawPtr, uint chars) {
        ubyte[8] nm;
        foreach (i, c; name) if (i < 8) nm[i] = c;
        foreach (i; 0 .. 8) data[off + i] = nm[i];
        patchU32(data, off +  8, vsize);
        patchU32(data, off + 12, rva);
        patchU32(data, off + 16, rawSize);
        patchU32(data, off + 20, rawPtr);
        patchU32(data, off + 36, chars);
    }
    uint textRva = cast(uint)(textVA - BASE);
    uint efiRva  = cast(uint)(efiVA - BASE);
    uint textRaw = alignUp(cast(uint) code.length, EFI_FILE_ALIGN);
    uint efiRaw  = alignUp(cast(uint) efiSecBytes.length, EFI_FILE_ALIGN);
    size_t secOff = secHdrOffset;
    writeSec(secOff, ".text", cast(uint) code.length, textRva, textRaw, cast(uint) textStart, 0x60000020);
    secOff += 40;
    if (hasRdata) {
        writeSec(secOff, ".rdata", cast(uint) rod.bytes.length, cast(uint)(rod.vaddr - BASE),
                 alignUp(cast(uint) rod.bytes.length, EFI_FILE_ALIGN), cast(uint) rdataFileOff, 0x40000040);
        secOff += 40;
    }
    if (hasBss) {
        writeSec(secOff, ".bss", cast(uint) bssMemsz, cast(uint)(bss.vaddr - BASE), 0, 0, 0xC0000080);
        secOff += 40;
    }
    writeSec(secOff, ".efi", cast(uint) efiSecBytes.length, efiRva, efiRaw, cast(uint) efiFileOff, 0xE0000020);

    // ---- Optional header --------------------------------------------------
    void w32(size_t o, uint  v) { patchU32(data, optHdrOffset + o, v); }
    void w64(size_t o, ulong v) { patchU64(data, optHdrOffset + o, v); }
    data[optHdrOffset + 0] = 0x0B;
    data[optHdrOffset + 1] = 0x02;
    data[optHdrOffset + 2] = 14;
    w32( 4, textRaw);
    w32( 8, efiRaw);
    w32(12, cast(uint) bssMemsz);
    w32(16, cast(uint)(blobVA - BASE));             // entry = efi_main (blob+0)
    w32(20, textRva);
    w64(24, BASE);
    w32(32, EFI_SECT_ALIGN);
    w32(36, EFI_FILE_ALIGN);
    data[optHdrOffset + 40] = 6;
    data[optHdrOffset + 48] = 0;
    w32(56, alignUp(efiRva + cast(uint) efiSecBytes.length, EFI_SECT_ALIGN));   // SizeOfImage
    w32(60, alignUp(cast(uint) textStart, EFI_FILE_ALIGN));                     // SizeOfHeaders
    data[optHdrOffset + 68] = SUBSYSTEM_EFI_APP;
    w64(72, 0x100000); w64(80, 0x1000);
    w64(88, 0x100000); w64(96, 0x1000);
    w32(108, 16);

    .write(outPath, data);

    writefln("nal (efi): wrote %s", outPath);
    writefln("  rewrote:  %d syscall sites in .text", sites.length);
    writefln("  runtime:  efi-rt blob @ 0x%x (entry/exit/console+file I/O via FASM)", efiVA);
    writefln("  layout:   ImageBase=0x%x  .text@0x%x  %s%s.efi@0x%x (preserved ELF vaddrs)",
             BASE, textVA, hasRdata ? format(".rdata@0x%x ", rod.vaddr) : "",
             hasBss ? format(".bss@0x%x ", bss.vaddr) : "", efiVA);
}
