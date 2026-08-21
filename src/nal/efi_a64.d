/**
 * efi_a64.d — ELF64 (AArch64) → UEFI Application (PE32+ EFI_APPLICATION, 0xAA64).
 *
 * AArch64 port of efi.d.  The runtime lives in src/rt/efirt_a64.fasm (assembled flat
 * to efi-rt-a64.bin, embedded as `efiRtBlob`), placed in a .efi PE section exposing a
 * fixed 8-byte-slot dispatch table.  NAL finds the program's `svc #0` syscall sites in
 * .text and redirects each to the matching slot.
 *
 * KEY DIFFERENCE FROM x86: the Linux syscall ABI and AAPCS64 share x0-x5, so a shim
 * needs no register shuffling — but `svc` doesn't touch x30 while `bl` does, so the
 * rewrite depends on the enclosing frame:
 *   - write INTRINSIC (inline; enclosing user fn saved x30 in its prologue): svc -> `bl efi_write`.
 *   - leaf helpers read/close/write-syscall (`movz x8,#N; svc; ret`, NO prologue): svc -> `b <slot>`
 *     (tail-branch: the shim's `ret` returns to the helper's caller; x30 untouched; the trailing
 *     `ret` becomes dead).
 *   - open/create helpers (`mov x1,x0; movimm x0,AT_FDCWD; ...; movz x8,#56; svc; ret`): the whole
 *     body is replaced by `b <slot>` at the entry so the shim receives the ORIGINAL x0=path.
 *   - wrch (`... add x1,sp; movz x2,#1; svc; add sp,#16; ret`, no prologue): 3-word tail rewrite
 *     `add sp,#16; b efi_write; ret` — stack restored before the tail-branch, x30 preserved.
 *   - EXIT (`bl start; movz x8,#93; svc`): svc -> `b efi_exit` (x0 = status).
 *
 * blob+0 efi_main (PE entry), +8 exit, +16 write, +24 read, +32 open, +40 close,
 * +48 create, +56 wrch, +64 patch_table[heap_slot_va, start_va].
 *
 * Invocation: `nal --efi in.elf out.efi` auto-dispatches here when e_machine == EM_AARCH64.
 */
module efi_a64;

import std.array : appender, Appender;
import std.bitmanip : nativeToLittleEndian;
import std.exception : enforce;
import std.file : write;
import std.format : format;
import std.stdio : writefln;

import nal : ElfView, findText, findRodata, findBss, alignUp, patchU32, patchU64, padTo;
import efi_blob_a64 : efiRtBlobA64B64;
import std.base64 : Base64;

// The runtime blob is carried as a base64 string in efi_blob_a64.d (a *source*
// module) rather than an import()'d .bin — an active corruptor on this machine
// zeroes stray .bin/.fasm files, and a source module fails loudly (not silently)
// if tampered with.

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

enum EFI_IMG_BASE   = 0x400000UL;
enum EFI_FILE_ALIGN = 0x200u;
// SectionAlignment deliberately sub-page (== FileAlignment): the runtime blob is a
// single RWX section (code + writable state intermixed), and ARM EDK2 enforces W^X
// on page-aligned images — writing `systab` would fault.  EDK2 skips image memory
// protection entirely when SectionAlignment is not page-aligned, leaving it RWX
// (the same trick gnu-efi relies on).  All section RVAs stay 0x200-aligned.
enum EFI_SECT_ALIGN = 0x200u;
enum SUBSYSTEM_EFI_APP = 10;

// AArch64 instruction encodings we match / emit.
enum uint I_SVC0    = 0xD4000001;   // svc #0
enum uint I_RET     = 0xD65F03C0;   // ret
enum uint I_NOP     = 0xD503201F;   // nop
enum uint MZ_X8_64  = 0xD2800808;   // movz x8,#64  (SYS_write)
enum uint MZ_X8_63  = 0xD28007E8;   // movz x8,#63  (SYS_read)
enum uint MZ_X8_57  = 0xD2800728;   // movz x8,#57  (SYS_close)
enum uint MZ_X8_56  = 0xD2800708;   // movz x8,#56  (SYS_openat)
enum uint MZ_X8_93  = 0xD2800BA8;   // movz x8,#93  (SYS_exit)
enum uint MZ_X0_1   = 0xD2800020;   // movz x0,#1
enum uint MZ_X2_0   = 0xD2800002;   // movz x2,#0   (open O_RDONLY flags)
enum uint ADD_X1_SP = 0x910003E1;   // add x1,sp,#0
enum uint ADD_SP16  = 0x910043FF;   // add sp,sp,#16
enum uint MOV_X1_X0 = 0xAA0003E1;   // mov x1,x0

private uint rd32(const(ubyte)[] c, size_t o) {
    return c[o] | (cast(uint)c[o+1]<<8) | (cast(uint)c[o+2]<<16) | (cast(uint)c[o+3]<<24);
}
private void wr32(ubyte[] c, size_t o, uint v) {
    c[o]=cast(ubyte)v; c[o+1]=cast(ubyte)(v>>8); c[o+2]=cast(ubyte)(v>>16); c[o+3]=cast(ubyte)(v>>24);
}
private uint encB (long fromVA, long toVA) { return 0x14000000u | (cast(uint)((toVA-fromVA)>>2) & 0x03FFFFFFu); }
private uint encBL(long fromVA, long toVA) { return 0x94000000u | (cast(uint)((toVA-fromVA)>>2) & 0x03FFFFFFu); }

void writeEfiA64(string outPath, ElfView elf) {
    auto txt = findText(elf);
    auto rod = findRodata(elf);
    auto bss = findBss(elf);
    enforce(txt !is null, "elf: no executable PT_LOAD");

    ubyte[] code = txt.bytes.dup;
    auto userCodeLen = code.length;
    auto textVA = txt.vaddr;

    // ---- Rebase into ARM `virt` RAM ----------------------------------------
    // qemu virt has RAM at 0x40000000; the ELF's ~0x40x000 vaddrs land in the
    // device/MMIO hole, so a RELOCS_STRIPPED image cannot be loaded there.  Shift
    // the whole fixed image up by REBASE and patch every baked absolute-address
    // movz/movk(4) chain in .text.  a64_mov_imm64 ALWAYS emits exactly four words
    // (movz Xd,#h0 ; movk Xd,#h1,lsl16 ; movk Xd,#h2,lsl32 ; movk Xd,#h3,lsl48),
    // an unambiguous signature, so this needs no ELF reloc info.
    enum REBASE = 0x40000000UL;
    bool hasRdata = rod !is null && rod.bytes.length > 0;
    bool hasBss   = bss !is null && bss.memsz > 0;
    uint nRebased;
    {
        ulong lo = textVA;
        ulong hi = hasBss  ? (bss.vaddr + 0x10000)
                 : hasRdata ? (rod.vaddr + rod.bytes.length)
                 : (textVA + txt.bytes.length);
        for (size_t i = 0; i + 16 <= userCodeLen; i += 4) {
            uint w0 = rd32(code,i), w1 = rd32(code,i+4), w2 = rd32(code,i+8), w3 = rd32(code,i+12);
            if ((w0 & 0xFFE00000) != 0xD2800000) continue;         // movz Xd,#h0,lsl0
            uint rd = w0 & 0x1F;
            if ((w1 & 0xFFE0001F) != (0xF2A00000 | rd)) continue;  // movk Xd,#h1,lsl16
            if ((w2 & 0xFFE0001F) != (0xF2C00000 | rd)) continue;  // movk Xd,#h2,lsl32
            if ((w3 & 0xFFE0001F) != (0xF2E00000 | rd)) continue;  // movk Xd,#h3,lsl48
            ulong val = ((w0>>5)&0xFFFF)
                      | ((cast(ulong)((w1>>5)&0xFFFF))<<16)
                      | ((cast(ulong)((w2>>5)&0xFFFF))<<32)
                      | ((cast(ulong)((w3>>5)&0xFFFF))<<48);
            if (val < lo || val >= hi) continue;
            ulong nv = val + REBASE;
            wr32(code,i,    0xD2800000u | (cast(uint)((nv     )&0xFFFF)<<5) | rd);
            wr32(code,i+4,  0xF2A00000u | (cast(uint)((nv>>16 )&0xFFFF)<<5) | rd);
            wr32(code,i+8,  0xF2C00000u | (cast(uint)((nv>>32 )&0xFFFF)<<5) | rd);
            wr32(code,i+12, 0xF2E00000u | (cast(uint)((nv>>48 )&0xFFFF)<<5) | rd);
            ++nRebased;
            i += 12;
        }
    }
    textVA += REBASE;
    ulong rodVA = hasRdata ? rod.vaddr + REBASE : 0;
    ulong bssVA = hasBss   ? bss.vaddr + REBASE : 0;

    // ---- Place the .efi blob ABOVE every preserved (shifted) ELF vaddr ------
    ulong BASE = EFI_IMG_BASE + REBASE;
    enum EFI_BSS_CAP = 0x10000;
    auto bssMemsz = hasBss ? (bss.memsz < EFI_BSS_CAP ? bss.memsz : cast(ulong) EFI_BSS_CAP) : 0;

    ulong topVA = textVA + txt.bytes.length;
    if (hasRdata) { auto t = rodVA + rod.bytes.length; if (t > topVA) topVA = t; }
    if (hasBss)   { auto t = bssVA + bssMemsz;         if (t > topVA) topVA = t; }
    auto efiVA  = (topVA + (EFI_SECT_ALIGN - 1)) & ~cast(ulong)(EFI_SECT_ALIGN - 1);
    auto blobVA = efiVA;

    auto efiBlob = Base64.decode(efiRtBlobA64B64);
    void patchU64In(ubyte[] arr, size_t off, ulong v) {
        ubyte[8] b = nativeToLittleEndian(v);
        foreach (i; 0 .. 8) arr[off + i] = b[i];
    }
    patchU64In(efiBlob, EFI_RT_PATCH + 0, hasBss ? bssVA : efiVA);   // heap_slot_va
    patchU64In(efiBlob, EFI_RT_PATCH + 8, textVA);                    // start_va = _start

    // ---- Scan .text (word-aligned) for `svc #0` and rewrite each site -------
    long slotVA(ulong slot) { return cast(long)(blobVA + slot); }
    uint nWrite, nRead, nClose, nOpen, nCreate, nWrch, nExit, nStub, nUnknown;

    for (size_t i = 0; i + 4 <= userCodeLen; i += 4) {
        if (rd32(code, i) != I_SVC0) continue;
        uint pm1 = (i >= 4)  ? rd32(code, i-4)  : 0;    // word before svc
        uint pp1 = (i+8 <= userCodeLen) ? rd32(code, i+4) : 0;  // word after svc

        // 1) EXIT: movz x8,#93 ; svc
        if (pm1 == MZ_X8_93) {
            wr32(code, i, encB(cast(long)(textVA+i), slotVA(EFI_RT_EXIT)));
            ++nExit; continue;
        }
        // 2) READ leaf: movz x8,#63 ; svc ; ret
        if (pm1 == MZ_X8_63 && pp1 == I_RET) {
            wr32(code, i, encB(cast(long)(textVA+i), slotVA(EFI_RT_READ)));
            ++nRead; continue;
        }
        // 3) CLOSE leaf: movz x8,#57 ; svc ; ret
        if (pm1 == MZ_X8_57 && pp1 == I_RET) {
            wr32(code, i, encB(cast(long)(textVA+i), slotVA(EFI_RT_CLOSE)));
            ++nClose; continue;
        }
        // 4) OPEN/CREATE: mov x1,x0 (i-32) ; ... ; movz x2,flags (i-12) ; movz x8,#56 (i-4) ; svc ; ret
        if (pm1 == MZ_X8_56 && pp1 == I_RET && i >= 32 && rd32(code, i-32) == MOV_X1_X0) {
            uint flags = rd32(code, i-12);
            ulong slot = (flags == MZ_X2_0) ? EFI_RT_OPEN : EFI_RT_CREATE;
            // Replace the whole body [mov x1,x0 .. svc] with `b <slot>` so the shim
            // gets the ORIGINAL x0 = path; NOP the rest; leave the trailing ret dead.
            wr32(code, i-32, encB(cast(long)(textVA+i-32), slotVA(slot)));
            for (size_t k = i-28; k <= i; k += 4) wr32(code, k, I_NOP);
            if (slot == EFI_RT_OPEN) ++nOpen; else ++nCreate;
            continue;
        }
        // 5) WRITE syscall-helper leaf: movz x8,#64 ; svc ; ret
        if (pm1 == MZ_X8_64 && pp1 == I_RET) {
            wr32(code, i, encB(cast(long)(textVA+i), slotVA(EFI_RT_WRITE)));
            ++nWrite; continue;
        }
        // 6) wrch: movz x8,#64 (i-16) ; movz x0,#1 ; add x1,sp (i-8) ; movz x2,#1 (i-4) ;
        //         svc ; add sp,#16 (i+4) ; ret.  Tail rewrite: add sp,#16 ; b efi_write ; ret.
        if (i >= 16 && (i+8) <= userCodeLen &&
            rd32(code, i-16) == MZ_X8_64 && rd32(code, i-8) == ADD_X1_SP && pp1 == ADD_SP16) {
            wr32(code, i,   ADD_SP16);                                          // restore stack first
            wr32(code, i+4, encB(cast(long)(textVA+i+4), slotVA(EFI_RT_WRITE)));// then tail-branch
            ++nWrch; continue;
        }
        // 7) write INTRINSIC: movz x8,#64 (i-28) ; movz x0,#1 (i-24) ; movimm x1 (4w) ;
        //         movz x2,#len (i-4) ; svc.  Enclosing user fn saved x30 -> `bl efi_write`.
        if (i >= 28 && rd32(code, i-28) == MZ_X8_64 && rd32(code, i-24) == MZ_X0_1) {
            wr32(code, i, encBL(cast(long)(textVA+i), slotVA(EFI_RT_WRITE)));
            ++nWrite; continue;
        }
        // 8) generic syscall wrapper: mov x1,x2; mov x2,x3; mov x3,x4; mov x4,x5; svc; ret
        //    (dynamic syscall nr in x8 — no static EFI mapping).  Stub the svc to
        //    `movn x0,#0` (x0 = -1 / ENOSYS) so a stray call returns an error instead of
        //    executing an illegal svc under EFI.  Hofos's own I/O uses the specific helpers
        //    above, so self-host never exercises this path.
        if (i >= 16 && pp1 == I_RET &&
            rd32(code,i-16)==0xAA0203E1 && rd32(code,i-12)==0xAA0303E2 &&
            rd32(code,i-8)==0xAA0403E3  && rd32(code,i-4)==0xAA0503E4) {
            wr32(code, i, 0x92800000u);          // movn x0, #0  => x0 = -1
            ++nStub; continue;
        }
        // Unmatched svc — report context so it can be classified/handled.
        writefln("  [unmatched svc @ .text+0x%x  prev4: %08x %08x %08x %08x  next: %08x]",
                 i,
                 i>=16?rd32(code,i-16):0, i>=12?rd32(code,i-12):0,
                 i>=8?rd32(code,i-8):0,   i>=4?rd32(code,i-4):0,
                 (i+8<=userCodeLen)?rd32(code,i+4):0);
        ++nUnknown;
    }
    auto sitesRewritten = nWrite + nRead + nClose + nOpen + nCreate + nWrch + nExit;

    auto efiSecBytes = efiBlob;

    // ---- Build PE32+ EFI image (machine 0xAA64) -----------------------------
    uint nSections = 1 + (hasRdata ? 1 : 0) + (hasBss ? 1 : 0) + 1;

    auto buf = appender!(ubyte[])();
    buf.put(cast(ubyte[]) "MZ");
    foreach (_; 0 .. 58) buf.put(cast(ubyte) 0);
    void put32u(ref Appender!(ubyte[]) a, uint v) { ubyte[4] b = nativeToLittleEndian(v); a.put(b[]); }
    void put16u(ref Appender!(ubyte[]) a, ushort v){ ubyte[2] b = nativeToLittleEndian(v); a.put(b[]); }
    put32u(buf, 0x80);
    while (buf.data.length < 0x80) buf.put(cast(ubyte) 0);

    buf.put(cast(ubyte[]) "PE\0\0");
    put16u(buf, 0xAA64);                            // IMAGE_FILE_MACHINE_ARM64
    put16u(buf, cast(ushort) nSections);
    put32u(buf, 0); put32u(buf, 0); put32u(buf, 0);
    put16u(buf, 240);
    put16u(buf, 0x0023);                            // EXEC | LARGE_ADDR | RELOCS_STRIPPED

    auto optHdrOffset = buf.data.length;
    foreach (_; 0 .. 240) buf.put(cast(ubyte) 0);
    auto secHdrOffset = buf.data.length;
    foreach (_; 0 .. 40 * nSections) buf.put(cast(ubyte) 0);

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
        writeSec(secOff, ".rdata", cast(uint) rod.bytes.length, cast(uint)(rodVA - BASE),
                 alignUp(cast(uint) rod.bytes.length, EFI_FILE_ALIGN), cast(uint) rdataFileOff, 0x40000040);
        secOff += 40;
    }
    if (hasBss) {
        writeSec(secOff, ".bss", cast(uint) bssMemsz, cast(uint)(bssVA - BASE), 0, 0, 0xC0000080);
        secOff += 40;
    }
    writeSec(secOff, ".efi", cast(uint) efiSecBytes.length, efiRva, efiRaw, cast(uint) efiFileOff, 0xE0000020);

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

    writefln("nal (efi/aarch64): wrote %s", outPath);
    writefln("  rewrote:  %d svc sites (write %d, read %d, close %d, open %d, create %d, wrch %d, exit %d, stub %d)%s",
             sitesRewritten + nStub, nWrite, nRead, nClose, nOpen, nCreate, nWrch, nExit, nStub,
             nUnknown ? format("  [!! %d UNMATCHED svc]", nUnknown) : "");
    writefln("  runtime:  efi-rt-a64 blob @ 0x%x (%d bytes)", efiVA, efiSecBytes.length);
    writefln("  rebased:  %d baked movz/movk address chains by +0x%x into ARM RAM", nRebased, REBASE);
    writefln("  layout:   ImageBase=0x%x  .text@0x%x  %s%s.efi@0x%x",
             BASE, textVA, hasRdata ? format(".rdata@0x%x ", rodVA) : "",
             hasBss ? format(".bss@0x%x ", bssVA) : "", efiVA);
}
