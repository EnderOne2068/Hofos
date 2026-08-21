// ne.d — MZ (.EXE) -> NE (New Executable) converter for NAL.
//
// NE is the 16-bit segmented executable format of Windows 1.x-3.x and OS/2 1.x.
// This takes a DOS MZ .EXE produced by Hofos's 8086 backend (one 64 KB segment,
// far-call segment relocations) and repackages it as a structurally valid NE:
//   * a minimal MZ stub whose e_lfanew (0x3C) points at the NE header,
//   * an NE header + a one-entry segment table (our code+data as segment 1),
//   * resident/non-resident name, module-reference, imported-name and entry
//     tables (no imports: the payload calls INT 21h directly),
//   * per-segment NE relocation records built from the MZ segment fixups: each
//     far-call seg word becomes an INTERNALREF *base* (selector) fixup targeting
//     segment 1, exactly as the MZ reloc targeted the DOS load segment.
//
// HONEST SCOPE: this is a FORMAT conversion.  The result is a well-formed NE
// container (a parser sees "NE", one CODE segment, N base relocations), but the
// payload is DOS INT 21h code, so it is not a runnable Windows/OS-2 program (that
// needs KERNEL/USER/GDI imports and a WinMain, not INT 21h).  The conversion is
// the linker capability; a Windows runtime is a separate matter.

module ne;

import std.array : Appender, appender;
import std.stdio : stderr;
import std.file : write;

private void putU16(ref Appender!(ubyte[]) a, uint v) {
    a.put(cast(ubyte)(v & 0xFF));
    a.put(cast(ubyte)((v >> 8) & 0xFF));
}
private void putU32(ref Appender!(ubyte[]) a, uint v) {
    a.put(cast(ubyte)(v & 0xFF));        a.put(cast(ubyte)((v >> 8) & 0xFF));
    a.put(cast(ubyte)((v >> 16) & 0xFF)); a.put(cast(ubyte)((v >> 24) & 0xFF));
}
private uint rdU16(const(ubyte)[] b, size_t o) {
    return b[o] | (cast(uint)b[o + 1] << 8);
}

struct MzImage {
    ubyte[] seg;        // the one segment's file image (code + rodata)
    uint[]  relocOffs;  // segment-relative offsets of the seg words to fix up
    uint    entryIp;    // entry offset within the segment
    uint    ss, sp;     // initial stack (segment ignored: our SS = seg 1)
    uint    minAllocParas;
}

// Parse an MZ .EXE (as emitted by cg-8086.b: e_cs = e_ss = 0, one segment).
MzImage parseMz(const(ubyte)[] mz) {
    if (mz.length < 0x40 || mz[0] != 'M' || mz[1] != 'Z')
        throw new Exception("input is not an MZ .EXE");
    MzImage m;
    uint crlc     = rdU16(mz, 6);
    uint cparhdr  = rdU16(mz, 8);
    m.minAllocParas = rdU16(mz, 0x0A);
    m.ss          = rdU16(mz, 0x0E);
    m.sp          = rdU16(mz, 0x10);
    m.entryIp     = rdU16(mz, 0x14);
    uint lfarlc   = rdU16(mz, 0x18);
    uint hdrBytes = cparhdr * 16;
    // relocation table: e_crlc entries of {offset, segment}; our segments are 0.
    for (uint i = 0; i < crlc; i++) {
        uint o = rdU16(mz, lfarlc + i * 4);
        uint s = rdU16(mz, lfarlc + i * 4 + 2);
        m.relocOffs ~= s * 16 + o;
    }
    m.seg = mz[hdrBytes .. $].dup;
    return m;
}

void writeNE(string outPath, const(ubyte)[] mz, string modName = "HOFOS") {
    auto m = parseMz(mz);

    // The seg words currently hold 0 (MZ stored, DOS-relocated).  In NE each
    // fixup location must hold the chain terminator 0xFFFF (single-element
    // chain); the loader then writes segment 1's selector there.
    foreach (off; m.relocOffs) {
        if (off + 1 < m.seg.length) { m.seg[off] = 0xFF; m.seg[off + 1] = 0xFF; }
    }

    // ---- MZ stub: a tiny DOS program (print a line, exit) --------------------
    // Kept independent of the payload; e_lfanew (0x3C) points at the NE header.
    auto file = appender!(ubyte[])();
    const uint NE_OFF = 0x40;                 // NE header right after the 64-byte MZ header
    // MZ header (0x40 bytes)
    file.put(cast(ubyte)'M'); file.put(cast(ubyte)'Z');
    // total stub is header(0x40)+code; we only ship the header + a 14-byte code
    // stub appended AFTER the NE tables would complicate e_lfanew, so keep the
    // stub trivial and inside the header padding: e_lfanew = 0x40 exactly.
    putU16(file, 0x40); // e_cblp bytes on last page (nominal)
    putU16(file, 1);    // e_cp pages
    putU16(file, 0);    // e_crlc
    putU16(file, 4);    // e_cparhdr (0x40 header)
    putU16(file, 0x10); // e_minalloc
    putU16(file, 0xFFFF); // e_maxalloc
    putU16(file, 0);    // e_ss
    putU16(file, 0xB8); // e_sp
    putU16(file, 0);    // e_csum
    putU16(file, 0);    // e_ip
    putU16(file, 0);    // e_cs
    putU16(file, 0x40); // e_lfarlc (no relocs; points past header)
    putU16(file, 0);    // e_ovno
    while (file.data.length < 0x3C) file.put(cast(ubyte)0);
    putU32(file, NE_OFF);  // e_lfanew -> NE header
    // (bytes 0x40.. are the NE header; a real stub would sit between, but with
    //  e_lfanew = 0x40 the NE header begins immediately.)

    // ---- assemble the NE tables (offsets are relative to NE_OFF) -------------
    const uint alignShift = 4;                // 16-byte segment alignment
    const uint segTabOff  = 0x40;             // right after the 64-byte NE header
    const uint nSeg       = 1;

    // resident names: module name (ordinal 0), then a 0-length terminator.
    auto res = appender!(ubyte[])();
    res.put(cast(ubyte)modName.length);
    foreach (ch; modName) res.put(cast(ubyte)ch);
    putU16(res, 0);                            // ordinal of module name = 0
    res.put(cast(ubyte)0);                     // end of resident table

    // module reference + imported names: none.
    // imported names table must still start with a 0 byte.
    ubyte[] imp = [cast(ubyte)0];

    // entry table: empty (entry point comes from ne_csip).
    // non-resident names: description (ordinal 0) + terminator.
    string desc = modName ~ " (Hofos NE)";
    auto nres = appender!(ubyte[])();
    nres.put(cast(ubyte)desc.length);
    foreach (ch; desc) nres.put(cast(ubyte)ch);
    putU16(nres, 0);
    nres.put(cast(ubyte)0);

    uint segTabLen = nSeg * 8;
    uint resOff    = segTabOff + segTabLen;
    uint modOff    = resOff + cast(uint)res.data.length;
    uint impOff    = modOff + 0;               // 0 module refs
    uint entOff    = impOff + cast(uint)imp.length;
    uint entLen    = 0;
    uint tablesEnd = entOff + entLen;          // rel to NE_OFF

    // non-resident table sits (in the file) right after the header tables.
    uint nresFileOff = NE_OFF + tablesEnd;
    uint afterNres   = nresFileOff + cast(uint)nres.data.length;

    // segment data is sector-aligned (per alignShift) after the tables.
    uint segDataFileOff = (afterNres + ((1u << alignShift) - 1)) & ~((1u << alignShift) - 1);
    uint segSector      = segDataFileOff >> alignShift;

    // ---- NE header (0x40 bytes) ---------------------------------------------
    auto ne = appender!(ubyte[])();
    ne.put(cast(ubyte)'N'); ne.put(cast(ubyte)'E');
    ne.put(cast(ubyte)5);   // linker version
    ne.put(cast(ubyte)0);   // linker revision
    putU16(ne, entOff);     // ne_enttab (offset from NE header)
    putU16(ne, entLen);     // ne_cbenttab
    putU32(ne, 0);          // ne_crc
    putU16(ne, 0x0100 | 0x0002 | 0x0001); // ne_flags: NOTWINDOWSAPP? use SINGLEDATA|... see note
    putU16(ne, 0);          // ne_autodata (no automatic data segment)
    putU16(ne, 0);          // ne_heap
    putU16(ne, m.sp);       // ne_stack (initial stack size hint)
    putU32(ne, (1u << 16) | (m.entryIp & 0xFFFF)); // ne_csip: seg 1 : entryIp
    putU32(ne, (1u << 16) | (m.sp & 0xFFFF));       // ne_sssp: seg 1 : sp
    putU16(ne, nSeg);       // ne_cseg
    putU16(ne, 0);          // ne_cmod (module references)
    putU16(ne, cast(uint)nres.data.length);         // ne_cbnrestab
    putU16(ne, segTabOff);  // ne_segtab
    putU16(ne, 0);          // ne_rsrctab (no resources -> = restab)
    putU16(ne, resOff);     // ne_restab
    putU16(ne, modOff);     // ne_modtab
    putU16(ne, impOff);     // ne_imptab
    putU32(ne, nresFileOff);// ne_nrestab (FILE offset)
    putU16(ne, 0);          // ne_cmovent
    putU16(ne, alignShift); // ne_align (sector shift)
    putU16(ne, 0);          // ne_cres
    ne.put(cast(ubyte)2);   // ne_exetyp = 2 (Windows)
    ne.put(cast(ubyte)0);   // ne_flagsothers
    putU16(ne, 0);          // ne_pretthunks
    putU16(ne, 0);          // ne_psegrefbytes
    putU16(ne, 0);          // ne_swaparea
    putU16(ne, 0);          // ne_expver
    assert(ne.data.length == 0x40, "NE header must be 64 bytes");

    // ---- segment table entry (8 bytes) --------------------------------------
    // offset in sectors, length in file, flags, min-alloc (0 => 64K).
    auto seg = appender!(ubyte[])();
    uint segFlags = 0x0000       // CODE (bit0 = 0)
                  | 0x0040       // PRELOAD
                  | (m.relocOffs.length ? 0x0100 : 0); // RELOCINFO
    putU16(seg, segSector);
    putU16(seg, cast(uint)m.seg.length);   // length in file
    putU16(seg, segFlags);
    putU16(seg, 0);                         // min alloc 0 => full 64K

    // ---- lay the file out ----------------------------------------------------
    // header padding already brought us to 0x3C; e_lfanew written; now the NE
    // header + tables begin at NE_OFF = 0x40, which is where we currently are.
    assert(file.data.length == NE_OFF, "NE header must start at e_lfanew");
    file.put(ne.data);        // NE header (0x40)
    file.put(seg.data);       // segment table (8)
    file.put(res.data);       // resident names
    // module ref table: empty
    file.put(imp);            // imported names (1 zero byte)
    // entry table: empty
    file.put(nres.data);      // non-resident names
    while (file.data.length < segDataFileOff) file.put(cast(ubyte)0);
    file.put(m.seg);          // segment 1 data

    // ---- per-segment relocation records -------------------------------------
    // Follows the segment data (the RELOCINFO flag says they are here).
    if (m.relocOffs.length) {
        auto rel = appender!(ubyte[])();
        putU16(rel, cast(uint)m.relocOffs.length);
        foreach (off; m.relocOffs) {
            rel.put(cast(ubyte)2);   // address type 2 = base (16-bit selector)
            rel.put(cast(ubyte)0);   // reloc type 0 = INTERNALREF (this module)
            putU16(rel, off);        // where in the segment to fix up
            rel.put(cast(ubyte)1);   // target segment number (1-based) = our segment
            rel.put(cast(ubyte)0);   // reserved
            putU16(rel, 0);          // target offset (ignored for a base fixup)
        }
        file.put(rel.data);
    }

    write(outPath, file.data);
    stderr.writefln("nal (ne): wrote %s  (NE: 1 CODE segment, %d byte(s), %d base reloc(s), entry seg1:0x%x)",
                    outPath, m.seg.length, m.relocOffs.length, m.entryIp);
}
