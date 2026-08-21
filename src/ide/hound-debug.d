/**
 * Hound — debug / inspection pane.
 *
 * Multiple "modes" the right-hand pane can show.  All of these are computed
 * in-process from D (no shell-out) except the IR view, which prints what
 * hofos produced — that's the only authoritative IR source.
 *
 *   Mode.outline   declarations (LET / MANIFEST / GLOBAL / GET) with line #
 *   Mode.tokens    flat token stream with kind + line
 *   Mode.ir        last "Build > IR" result (cached string)
 *   Mode.trace     last "Build > Run" VM trace
 *
 * Hound holds the current Mode and re-renders this pane on edit changes for
 * the in-process modes; the shelled-out modes refresh only when invoked.
 */

module hound_debug;

import std.utf : toUTF16z, toUTF16;
import std.conv : to;
import std.algorithm : max;
import std.format : format;
import std.array : appender;
import hound_syntax_highlight : lexBcpl, Span, TokKind;

// ---- Mode --------------------------------------------------------------------

enum Mode : ubyte {
    outline = 0,
    tokens  = 1,
    ir      = 2,
    trace   = 3,
}

string modeName(Mode m) {
    final switch (m) {
        case Mode.outline: return "Outline";
        case Mode.tokens:  return "Tokens";
        case Mode.ir:      return "IR";
        case Mode.trace:   return "Trace";
    }
}

// ---- Outline (existing) ------------------------------------------------------

struct OutlineEntry { string kind; string name; size_t line; }

size_t lineAt(const(wchar)[] src, size_t off) {
    size_t line = 1;
    foreach (i; 0 .. off) if (src[i] == '\n') ++line;
    return line;
}

OutlineEntry[] buildOutline(const(wchar)[] src) {
    OutlineEntry[] entries;
    auto spans = lexBcpl(src);

    bool isIntroducer(const(wchar)[] s) {
        return s == "LET" || s == "let" ||
               s == "MANIFEST" || s == "Manifest" || s == "manifest" ||
               s == "GLOBAL"   || s == "Global"   || s == "global"   ||
               s == "STATIC"   || s == "Static"   || s == "static"   ||
               s == "GET"      || s == "get";
    }

    for (size_t i = 0; i < spans.length; ++i) {
        auto sp = spans[i];
        if (sp.kind != TokKind.keyword && sp.kind != TokKind.getDirective) continue;
        auto text = src[sp.start .. sp.end];
        if (!isIntroducer(text)) continue;

        if (sp.kind == TokKind.getDirective) {
            string name = "(unnamed)";
            if (i + 1 < spans.length && spans[i + 1].kind == TokKind.str) {
                auto s = spans[i + 1];
                name = src[s.start .. s.end].to!string;
            }
            entries ~= OutlineEntry("GET", name, lineAt(src, sp.start));
            continue;
        }

        string kind = text.to!string;
        string name = "(unnamed)";
        foreach (j; i + 1 .. spans.length) {
            if (spans[j].kind == TokKind.identifier) {
                name = src[spans[j].start .. spans[j].end].to!string;
                break;
            }
            if (spans[j].kind == TokKind.keyword) {
                auto t = src[spans[j].start .. spans[j].end];
                if (isIntroducer(t)) break;
            }
        }
        entries ~= OutlineEntry(kind, name, lineAt(src, sp.start));
    }
    return entries;
}

string renderOutline(const(wchar)[] src) {
    auto entries = buildOutline(src);
    if (entries.length == 0)
        return "(no LET / MANIFEST / GLOBAL / GET declarations)\r\n";

    auto buf = appender!string();
    buf.put("Outline\r\n");
    buf.put("=======\r\n");
    size_t maxKind;
    foreach (e; entries) maxKind = max(maxKind, e.kind.length);
    foreach (e; entries) {
        buf.put(format("L%4d  %-*s  %s\r\n", e.line, maxKind, e.kind, e.name));
    }
    buf.put("\r\n");
    buf.put(format("%d declarations, %d tokens\r\n",
                   entries.length, lexBcpl(src).length));
    return buf.data;
}

// ---- Tokens view -------------------------------------------------------------

string kindLetter(TokKind k) {
    final switch (k) {
        case TokKind.none:         return "?";
        case TokKind.keyword:      return "K";
        case TokKind.identifier:   return "I";
        case TokKind.number:       return "N";
        case TokKind.str:          return "S";
        case TokKind.charlit:      return "C";
        case TokKind.op:           return "O";
        case TokKind.comment:      return "/";
        case TokKind.getDirective: return "G";
    }
}

string renderTokens(const(wchar)[] src) {
    auto spans = lexBcpl(src);
    auto buf = appender!string();
    buf.put("Token stream\r\n");
    buf.put("============\r\n");
    buf.put("K=keyword  I=ident  N=num  S=str  C=char  O=op  /=comment  G=get\r\n\r\n");
    foreach (s; spans) {
        if (s.kind == TokKind.none) continue;
        auto line = lineAt(src, s.start);
        // Take a short preview, trim newlines so the column layout holds.
        auto raw = src[s.start .. s.end];
        wchar[64] previewBuf;
        size_t pi;
        foreach (c; raw) {
            if (pi >= previewBuf.length - 1) break;
            previewBuf[pi++] = (c == '\n' || c == '\r' || c == '\t') ? cast(wchar)' ' : c;
        }
        auto preview = previewBuf[0 .. pi].to!string;
        buf.put(format("L%4d  %s  %s\r\n", line, kindLetter(s.kind), preview));
    }
    buf.put(format("\r\n%d tokens\r\n", spans.length));
    return buf.data;
}

// ---- IR / Trace caches (set by Build menu actions in hound.d) ----------------

private __gshared string g_irCache   = "(no IR yet — Build > IR to populate)\r\n";
private __gshared string g_traceCache = "(no trace yet — Build > Run to populate)\r\n";

void setIR(string s)    { g_irCache    = s.length ? s : g_irCache; }
void setTrace(string s) { g_traceCache = s.length ? s : g_traceCache; }

string renderIR()    { return g_irCache; }
string renderTrace() { return g_traceCache; }

// ---- Mode dispatch -----------------------------------------------------------

string renderFor(Mode m, const(wchar)[] src) {
    final switch (m) {
        case Mode.outline: return renderOutline(src);
        case Mode.tokens:  return renderTokens(src);
        case Mode.ir:      return renderIR();
        case Mode.trace:   return renderTrace();
    }
}
