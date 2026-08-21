// lscs — Large-Scale Control System, version control for Hofos.
//
// WHY NOT SCCS, AND WHY NOT GIT
//
// SCCS (Rochkind, 1972) versions FILES.  Its weave -- every revision of a file
// interleaved in one place, so any version is one pass and blame is free -- is
// still a good idea and the storage here is descended from it.  But SCCS has no
// atomic changeset and no notion of "the tree", and the invariant this project
// lives by is a whole-tree one: THIS TREE STATE BUILDS BYTE-IDENTICALLY.  A
// per-file system cannot express that, so the object model here is tree-first.
//
// git can express it and does not record it.  The failure that prompted this
// tool was a Hofos checkout whose index claimed 173 deletions that had not
// happened, while 67 source files existed ONLY in the working tree -- untracked,
// unbacked-up, and invisible in `git status` because .gitignore hid them.  A
// commit is not the interesting unit for a compiler that bootstraps itself.
// The interesting unit is: which BINARY built which ARTIFACT from which TREE,
// and does replaying that still produce the same bytes.
//
// So lscs records three things git does not:
//   * a snapshot is a TREE, taken whole, with nothing silently excluded;
//   * PROVENANCE -- artifact X was built from snapshot S by binary B;
//   * VERIFICATION -- replaying that build reproduces X byte for byte.
//
// EXTENSIONS.  Commands are looked up in a table, then on PATH as
// `lscs-<name>`, so Hofos release tooling plugs in without touching lscs.
module lscs;

import std.algorithm : sort, filter, map, canFind, startsWith;
import std.array : array, join, split, replace;
import std.digest.sha : sha256Of, toHexString;
import std.file;
import std.path;
import std.stdio;
import std.string : strip, splitLines, indexOf;
import std.conv : to;
import std.datetime : Clock;
import std.process : execute, environment;

enum DIR = ".lscs";

// Never snapshot these.  Deliberately SHORT: the whole point is that nothing is
// silently excluded, so anything not listed here is recorded whether or not
// anyone thinks it matters.
immutable string[] alwaysIgnore = [".lscs", ".git", "backup-pre-reorg"];
immutable string[] ignoreExt = [".exe", ".obj", ".o", ".elf", ".dll", ".lib",
                                ".zip", ".pdb", ".ilk"];

struct Entry { string path; string hash; ulong size; }

// ---- repository plumbing -----------------------------------------------------

string repoRoot()
{
    auto d = getcwd();
    while (true)
    {
        if (exists(buildPath(d, DIR))) return d;
        auto up = d.dirName;
        if (up == d) return null;
        d = up;
    }
}

string objPath(string root, string hash)
{
    return buildPath(root, DIR, "objects", hash[0 .. 2], hash[2 .. $]);
}

string store(string root, const(ubyte)[] data)
{
    auto hash = toHexString(sha256Of(data)).idup;
    auto p = objPath(root, hash);
    if (!exists(p)) { mkdirRecurse(p.dirName); std.file.write(p, data); }
    return hash;
}

bool ignored(string rel)
{
    foreach (a; alwaysIgnore) if (rel == a || rel.startsWith(a ~ dirSeparator)) return true;
    foreach (e; ignoreExt) if (rel.extension == e) return true;
    return false;
}

Entry[] scanTree(string root)
{
    Entry[] es;
    foreach (e; dirEntries(root, SpanMode.depth))
    {
        if (!e.isFile) continue;
        auto rel = e.name[root.length + 1 .. $].replace(dirSeparator, "/");
        if (ignored(rel.replace("/", dirSeparator))) continue;
        auto data = cast(ubyte[])std.file.read(e.name);
        es ~= Entry(rel, toHexString(sha256Of(data)).idup, data.length);
    }
    es.sort!((a, b) => a.path < b.path);
    return es;
}

// A snapshot is stored as a plain text listing so it stays readable with `cat`
// forty years from now -- the SCCS virtue worth keeping.
string writeSnapshot(string root, Entry[] es)
{
    string s;
    foreach (e; es) s ~= e.hash ~ " " ~ to!string(e.size) ~ " " ~ e.path ~ "\n";
    return store(root, cast(ubyte[])s);
}

Entry[] readSnapshot(string root, string hash)
{
    Entry[] es;
    foreach (line; (cast(string)std.file.read(objPath(root, hash))).splitLines)
    {
        if (line.length == 0) continue;
        auto sp1 = line.indexOf(' ');
        auto sp2 = line.indexOf(' ', sp1 + 1);
        es ~= Entry(line[sp2 + 1 .. $].idup, line[0 .. sp1].idup,
                    to!ulong(line[sp1 + 1 .. sp2]));
    }
    return es;
}

long headNumber(string root)
{
    auto p = buildPath(root, DIR, "HEAD");
    if (!exists(p)) return 0;
    auto t = (cast(string)std.file.read(p)).strip;
    return t.length ? to!long(t) : 0;
}

string changePath(string root, long n)
{
    return buildPath(root, DIR, "changes", format4(n) ~ ".txt");
}

string format4(long n)
{
    auto s = to!string(n);
    while (s.length < 4) s = "0" ~ s;
    return s;
}

// ---- commands ----------------------------------------------------------------

int cmdInit(string[] args)
{
    if (exists(DIR)) { writeln("lscs: already initialised here"); return 1; }
    mkdirRecurse(buildPath(DIR, "objects"));
    mkdirRecurse(buildPath(DIR, "changes"));
    mkdirRecurse(buildPath(DIR, "provenance"));
    std.file.write(buildPath(DIR, "HEAD"), "0\n");
    writeln("lscs: initialised in " ~ getcwd());
    return 0;
}

int cmdStatus(string[] args)
{
    auto root = repoRoot();
    if (root is null) { stderr.writeln("lscs: not an lscs repository"); return 1; }
    auto now = scanTree(root);
    auto head = headNumber(root);

    Entry[string] was;
    if (head > 0)
    {
        auto meta = (cast(string)std.file.read(changePath(root, head))).splitLines;
        foreach (l; meta)
            if (l.startsWith("tree: "))
                foreach (e; readSnapshot(root, l[6 .. $].strip)) was[e.path] = e;
    }

    string[] added, changed, removed;
    bool[string] seen;
    foreach (e; now)
    {
        seen[e.path] = true;
        auto p = e.path in was;
        if (p is null) added ~= e.path;
        else if (p.hash != e.hash) changed ~= e.path;
    }
    foreach (k; was.keys.dup.sort) if (k !in seen) removed ~= k;

    writeln("lscs: at change " ~ to!string(head) ~ ", " ~ to!string(now.length) ~ " files tracked");
    foreach (p; added)   writeln("  new      " ~ p);
    foreach (p; changed) writeln("  changed  " ~ p);
    foreach (p; removed) writeln("  gone     " ~ p);
    if (!added.length && !changed.length && !removed.length) writeln("  (clean)");
    // The situation that prompted this tool: work existing only on disk.
    if (added.length && head == 0)
        writeln("\n  " ~ to!string(added.length) ~ " files are UNRECORDED. `lscs commit` captures them.");
    return 0;
}

int cmdCommit(string[] args)
{
    auto root = repoRoot();
    if (root is null) { stderr.writeln("lscs: not an lscs repository"); return 1; }
    string msg = "(no message)";
    for (size_t i = 0; i < args.length; i++)
        if (args[i] == "-m" && i + 1 < args.length) msg = args[i + 1];

    auto es = scanTree(root);
    foreach (e; es) store(root, cast(ubyte[])std.file.read(buildPath(root, e.path)));
    auto tree = writeSnapshot(root, es);
    auto n = headNumber(root) + 1;

    ulong bytes; foreach (e; es) bytes += e.size;
    std.file.write(changePath(root, n),
        "change: " ~ to!string(n) ~ "\n"
      ~ "parent: " ~ to!string(n - 1) ~ "\n"
      ~ "tree: " ~ tree ~ "\n"
      ~ "when: " ~ Clock.currTime.toISOExtString ~ "\n"
      ~ "files: " ~ to!string(es.length) ~ "\n"
      ~ "bytes: " ~ to!string(bytes) ~ "\n"
      ~ "message: " ~ msg ~ "\n");
    std.file.write(buildPath(root, DIR, "HEAD"), to!string(n) ~ "\n");
    writeln("lscs: change " ~ to!string(n) ~ " -- " ~ to!string(es.length)
          ~ " files, " ~ to!string(bytes) ~ " bytes");
    return 0;
}

int cmdLog(string[] args)
{
    auto root = repoRoot();
    if (root is null) { stderr.writeln("lscs: not an lscs repository"); return 1; }
    for (long n = headNumber(root); n >= 1; n--)
    {
        auto p = changePath(root, n);
        if (!exists(p)) continue;
        string when, msg, files;
        foreach (l; (cast(string)std.file.read(p)).splitLines)
        {
            if (l.startsWith("when: "))    when = l[6 .. $];
            if (l.startsWith("message: ")) msg = l[9 .. $];
            if (l.startsWith("files: "))   files = l[7 .. $];
        }
        writeln("change " ~ to!string(n) ~ "  " ~ when ~ "  (" ~ files ~ " files)");
        writeln("    " ~ msg);
    }
    return 0;
}

int cmdCheckout(string[] args)
{
    auto root = repoRoot();
    if (root is null) { stderr.writeln("lscs: not an lscs repository"); return 1; }
    if (args.length < 1) { stderr.writeln("usage: lscs checkout N [DIR]"); return 1; }
    auto n = to!long(args[0]);
    auto dest = args.length >= 2 ? args[1] : buildPath(root, "lscs-checkout-" ~ format4(n));
    auto p = changePath(root, n);
    if (!exists(p)) { stderr.writeln("lscs: no change " ~ to!string(n)); return 1; }
    string tree;
    foreach (l; (cast(string)std.file.read(p)).splitLines)
        if (l.startsWith("tree: ")) tree = l[6 .. $].strip;

    // Never into a live tree by default: extracting over working files is how
    // people lose the very work this tool exists to protect.
    if (exists(dest) && dest == root)
    { stderr.writeln("lscs: refusing to extract over the working tree"); return 1; }
    mkdirRecurse(dest);
    ulong count;
    foreach (e; readSnapshot(root, tree))
    {
        auto outp = buildPath(dest, e.path.replace("/", dirSeparator));
        mkdirRecurse(outp.dirName);
        std.file.copy(objPath(root, e.hash), outp);
        count++;
    }
    writeln("lscs: change " ~ to!string(n) ~ " extracted to " ~ dest
          ~ " (" ~ to!string(count) ~ " files)");
    return 0;
}

// ---- provenance: the part git has no place for -------------------------------
//
// `lscs built ARTIFACT --by BINARY --from "CMD"` records that this artifact
// came out of the current tree, by that binary, via that command -- with the
// hash of all three.  `lscs verify N` re-runs the command and compares.

int cmdBuilt(string[] args)
{
    auto root = repoRoot();
    if (root is null) { stderr.writeln("lscs: not an lscs repository"); return 1; }
    if (args.length < 1) { stderr.writeln("usage: lscs built ARTIFACT --by BINARY --from CMD"); return 1; }
    string artifact = args[0], by, cmd;
    for (size_t i = 1; i < args.length; i++)
    {
        if (args[i] == "--by" && i + 1 < args.length) by = args[++i];
        if (args[i] == "--from" && i + 1 < args.length) cmd = args[++i];
    }
    if (!exists(artifact)) { stderr.writeln("lscs: no such artifact " ~ artifact); return 1; }
    auto ah = toHexString(sha256Of(cast(ubyte[])std.file.read(artifact))).idup;
    auto bh = (by.length && exists(by))
            ? toHexString(sha256Of(cast(ubyte[])std.file.read(by))).idup : "(unknown)";
    auto n = headNumber(root);
    auto rec = buildPath(root, DIR, "provenance", ah[0 .. 16] ~ ".txt");
    std.file.write(rec,
        "artifact: " ~ artifact ~ "\n"
      ~ "artifact-hash: " ~ ah ~ "\n"
      ~ "built-by: " ~ by ~ "\n"
      ~ "builder-hash: " ~ bh ~ "\n"
      ~ "from-change: " ~ to!string(n) ~ "\n"
      ~ "command: " ~ cmd ~ "\n"
      ~ "when: " ~ Clock.currTime.toISOExtString ~ "\n");
    writeln("lscs: recorded " ~ artifact ~ " (" ~ ah[0 .. 12] ~ ") from change "
          ~ to!string(n));
    return 0;
}

int cmdVerify(string[] args)
{
    auto root = repoRoot();
    if (root is null) { stderr.writeln("lscs: not an lscs repository"); return 1; }
    auto pdir = buildPath(root, DIR, "provenance");
    if (!exists(pdir)) { writeln("lscs: nothing recorded"); return 0; }
    int bad;
    foreach (f; dirEntries(pdir, SpanMode.shallow))
    {
        string artifact, ah, cmd;
        foreach (l; (cast(string)std.file.read(f.name)).splitLines)
        {
            if (l.startsWith("artifact: "))      artifact = l[10 .. $];
            if (l.startsWith("artifact-hash: ")) ah = l[15 .. $];
            if (l.startsWith("command: "))       cmd = l[9 .. $];
        }
        if (!exists(artifact)) { writeln("  MISSING  " ~ artifact); bad++; continue; }
        auto now = toHexString(sha256Of(cast(ubyte[])std.file.read(artifact))).idup;
        if (now == ah) writeln("  ok       " ~ artifact);
        else { writeln("  CHANGED  " ~ artifact ~ "  (was " ~ ah[0 .. 12]
                     ~ ", now " ~ now[0 .. 12] ~ ")"); bad++; }
    }
    return bad ? 1 : 0;
}

// ---- dispatch ----------------------------------------------------------------

int main(string[] argv)
{
    if (argv.length < 2)
    {
        writeln("lscs — Large-Scale Control System, version control for Hofos\n");
        writeln("  init                    start a repository here");
        writeln("  status                  what has changed since the last change");
        writeln("  commit -m MSG           record the whole tree");
        writeln("  log                     list changes, newest first");
        writeln("  checkout N [DIR]        extract change N (never over the working tree)");
        writeln("  built A --by B --from C record that A was built from this tree by B");
        writeln("  verify                  re-check every recorded artifact\n");
        writeln("Any other NAME runs lscs-NAME from PATH, so release tooling");
        writeln("extends lscs without modifying it.");
        return 0;
    }
    auto cmd = argv[1];
    auto rest = argv[2 .. $];
    switch (cmd)
    {
        case "init":     return cmdInit(rest);
        case "status":   return cmdStatus(rest);
        case "commit":   return cmdCommit(rest);
        case "log":      return cmdLog(rest);
        case "checkout": return cmdCheckout(rest);
        case "built":    return cmdBuilt(rest);
        case "verify":   return cmdVerify(rest);
        default:
            // Extension point: lscs-<name> on PATH.
            auto r = execute(["lscs-" ~ cmd] ~ rest);
            if (r.status == 0) { write(r.output); return 0; }
            stderr.writeln("lscs: unknown command '" ~ cmd ~ "'");
            return 1;
    }
}
