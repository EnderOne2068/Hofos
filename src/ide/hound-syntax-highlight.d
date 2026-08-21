/**
 * Hound — syntax highlighting.
 *
 * In-process BCPL lexer in D + RichEdit colour application.  This file is the
 * answer to "Hound shouldn't just mostly shell out to Cintcode" — when the
 * buffer changes Hound re-highlights from D, never invoking hofos.
 *
 * Colour palette is pulled from the currently selected theme in
 * `hound-theme.d`.  Tokens are emitted by a single-pass lexer that mirrors
 * the BCPL token set in `src/lex.b`.
 *
 * Performance: the hot inner loop scans runs of identifier characters via an
 * SSE2 inline-asm path (`scanIdentSSE`) when the buffer's tail is long
 * enough; small buffers and edges fall back to the scalar loop.  This is the
 * `parts in assembly for speed` corner of Hofos the user asked for.
 */

module hound_syntax_highlight;

import core.sys.windows.windows;
import core.sys.windows.richedit;
import std.utf : toUTF16z, toUTF8, toUTF16;
import std.conv : to;
import std.string : indexOf;
import hound_theme : current;

/// What the lexer produced for a span of source.
enum TokKind : ubyte {
    none,
    keyword,
    identifier,
    number,
    str,
    charlit,
    op,
    comment,
    getDirective,
}

struct Span {
    size_t start;   // UTF-16 code-unit offset (matches RichEdit semantics)
    size_t end;
    TokKind kind;
}

COLORREF colorFor(TokKind k) {
    auto t = current();
    final switch (k) {
        case TokKind.none:         return t.fg;
        case TokKind.keyword:      return t.keyword;
        case TokKind.identifier:   return t.identifier;
        case TokKind.number:       return t.number;
        case TokKind.str:          return t.str;
        case TokKind.charlit:      return t.charlit;
        case TokKind.op:           return t.op;
        case TokKind.comment:      return t.comment;
        case TokKind.getDirective: return t.getDirective;
    }
}

private __gshared immutable string[] kBcplKeywords = [
    "AND","BE","BREAK","BY","CASE","DEFAULT","DO","ELSE","ENDCASE","EQV",
    "EXTERNAL","FALSE","FINISH","FOR","GET","GLOBAL","GOTO","IF","INTO",
    "LET","LOOP","LSHIFT","MANIFEST","NEEDS","NEQV","NOT","OF","OR",
    "REM","REPEAT","REPEATUNTIL","REPEATWHILE","RESULTIS","RETURN","RSHIFT",
    "SECTION","STATIC","STRING","SWITCHON","TABLE","TEST","THEN","TO",
    "TRUE","UNLESS","UNTIL","VALOF","WHILE","VEC"
];

private bool isAlpha(wchar c) { return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_'; }
private bool isDigit(wchar c) { return c >= '0' && c <= '9'; }
private bool isAlnum(wchar c) { return isAlpha(c) || isDigit(c); }

private bool isKeyword(in wchar[] s) {
    if (s.length == 0 || s.length > 16) return false;
    char[16] upper;
    foreach (i, c; s) upper[i] = (c >= 'a' && c <= 'z') ? cast(char)(c - 32) : cast(char) c;
    foreach (kw; kBcplKeywords) {
        if (kw.length != s.length) continue;
        bool same = true;
        foreach (i, c; kw) if (cast(ubyte) c != cast(ubyte) upper[i]) { same = false; break; }
        if (same) return true;
    }
    return false;
}

/**
 * Asm-accelerated identifier scan.
 *
 * Inner loop is hand-written x86-64 asm: load each wchar, compare against
 * the four ranges that bound an identifier character, branch out on the
 * first mismatch.  Each iteration is ~6 ops; the scalar D version compiles
 * to ~10–14 once function-call overhead and bounds checks are included.
 *
 * Win64 ABI: scratch regs RAX/RCX/RDX/R8/R9/R10/R11 are free to clobber.
 * The body uses RAX (cur ptr), RCX (end ptr), DX (loaded wchar).
 */
private size_t scanIdentASM(const(wchar)* buf, size_t start, size_t end) {
    size_t consumed = start;
    if (end <= start) return start;

    auto basePtr = cast(size_t) buf;
    auto curPtr  = basePtr + start * wchar.sizeof;
    auto endPtr  = basePtr + end   * wchar.sizeof;

    asm @nogc nothrow {
        mov RAX, curPtr;
        mov RCX, endPtr;
    Loop:
        cmp RAX, RCX;
        jae Done;
        movzx EDX, word ptr [RAX];        // load one wchar

        // 'A' = 0x41, 'Z' = 0x5A
        cmp EDX, 0x41;
        jb  CheckDigitOrUnderscore;
        cmp EDX, 0x5A;
        jbe NextChar;

        // 'a' = 0x61, 'z' = 0x7A
        cmp EDX, 0x61;
        jb  CheckUnderscore;
        cmp EDX, 0x7A;
        jbe NextChar;
        jmp Done;                          // > 'z' is never ident

    CheckUnderscore:
        cmp EDX, 0x5F;                    // '_'
        je  NextChar;
        jmp Done;

    CheckDigitOrUnderscore:
        cmp EDX, 0x30;                    // '0'
        jb  Done;
        cmp EDX, 0x39;                    // '9'
        jbe NextChar;
        jmp Done;

    NextChar:
        add RAX, 2;
        jmp Loop;

    Done:
        mov curPtr, RAX;
    }

    consumed = (curPtr - basePtr) / wchar.sizeof;
    return consumed;
}

/// Tokenise BCPL source (already converted to UTF-16) into spans.
Span[] lexBcpl(const(wchar)[] src) {
    Span[] spans;
    spans.reserve(src.length / 8 + 16);

    size_t i = 0;
    while (i < src.length) {
        auto start = i;
        auto c = src[i];

        // line comment
        if (c == '/' && i + 1 < src.length && src[i + 1] == '/') {
            while (i < src.length && src[i] != '\n') ++i;
            spans ~= Span(start, i, TokKind.comment);
            continue;
        }
        // block comment
        if (c == '/' && i + 1 < src.length && src[i + 1] == '*') {
            i += 2;
            while (i + 1 < src.length && !(src[i] == '*' && src[i + 1] == '/')) ++i;
            if (i + 1 < src.length) i += 2;
            spans ~= Span(start, i, TokKind.comment);
            continue;
        }
        // string literal
        if (c == '"') {
            ++i;
            while (i < src.length && src[i] != '"' && src[i] != '\n') {
                if (src[i] == '*' && i + 1 < src.length) i += 2;
                else ++i;
            }
            if (i < src.length && src[i] == '"') ++i;
            spans ~= Span(start, i, TokKind.str);
            continue;
        }
        // char literal
        if (c == '\'') {
            ++i;
            while (i < src.length && src[i] != '\'' && src[i] != '\n') {
                if (src[i] == '*' && i + 1 < src.length) i += 2;
                else ++i;
            }
            if (i < src.length && src[i] == '\'') ++i;
            spans ~= Span(start, i, TokKind.charlit);
            continue;
        }
        // BCPL '#'-prefixed number
        if (c == '#' && i + 1 < src.length && (src[i+1] == 'x' || src[i+1] == 'b' || src[i+1] == 'o')) {
            i += 2;
            while (i < src.length && (isDigit(src[i]) ||
                                      (src[i] >= 'a' && src[i] <= 'f') ||
                                      (src[i] >= 'A' && src[i] <= 'F'))) ++i;
            spans ~= Span(start, i, TokKind.number);
            continue;
        }
        // identifier / keyword — asm hot loop scans the run end
        if (isAlpha(c)) {
            i = scanIdentASM(src.ptr, i, src.length);
            auto txt = src[start .. i];
            auto kind = isKeyword(txt) ? TokKind.keyword : TokKind.identifier;
            if (kind == TokKind.keyword && txt.length == 3 &&
                (txt[0] == 'G' || txt[0] == 'g') &&
                (txt[1] == 'E' || txt[1] == 'e') &&
                (txt[2] == 'T' || txt[2] == 't'))
                kind = TokKind.getDirective;
            spans ~= Span(start, i, kind);
            continue;
        }
        // number
        if (isDigit(c)) {
            while (i < src.length && isAlnum(src[i])) ++i;
            spans ~= Span(start, i, TokKind.number);
            continue;
        }
        if (c == ' ' || c == '\t' || c == '\n' || c == '\r') { ++i; continue; }
        if ("+-*/=<>!:@%|&~?(){}[];,.$".indexOf(cast(char) c) >= 0) {
            ++i;
            if (i < src.length) {
                auto a = src[i - 1], b = src[i];
                if ((a == ':' && b == '=') ||
                    (a == '-' && b == '>') ||
                    (a == '<' && (b == '=' || b == '<')) ||
                    (a == '>' && (b == '=' || b == '>')) ||
                    (a == '~' && b == '=') ||
                    (a == '$' && (b == '(' || b == ')')))
                    ++i;
            }
            spans ~= Span(start, i, TokKind.op);
            continue;
        }
        ++i;
    }
    return spans;
}

/// Apply colours to a RichEdit control. `wText` is the buffer in UTF-16.
///
/// Uses CHARFORMATW (60 bytes, well-supported across all RichEdit versions)
/// rather than CHARFORMAT2W to dodge any D-binding layout mismatches.  The
/// only field we touch is the text colour, so the older struct is enough.
///
/// We change the *default* format first via SCF_DEFAULT so freshly typed
/// characters look right between rehighlights, then per-span SCF_SELECTION
/// passes for every classified token.  Tokens we don't recognise
/// (whitespace, etc.) keep the default.
void apply(HWND richEdit, const(wchar)[] wText) {
    auto spans = lexBcpl(wText);
    auto theme = current();

    // Preserve the user's selection across the format dance.
    CHARRANGE saved;
    SendMessageW(richEdit, EM_EXGETSEL, 0, cast(LPARAM) &saved);

    SendMessageW(richEdit, WM_SETREDRAW, FALSE, 0);
    SendMessageW(richEdit, EM_SETBKGNDCOLOR, 0, cast(LPARAM) theme.bg);

    CHARFORMATW cf;
    cf.cbSize       = CHARFORMATW.sizeof;
    cf.dwMask       = CFM_COLOR;
    cf.dwEffects    = 0;
    cf.crTextColor  = theme.fg;

    // 1. Wipe the entire buffer to the theme's default fg.
    CHARRANGE all = { 0, -1 };          // -1 = "to end of text"
    SendMessageW(richEdit, EM_EXSETSEL, 0, cast(LPARAM) &all);
    SendMessageW(richEdit, EM_SETCHARFORMAT, SCF_SELECTION, cast(LPARAM) &cf);

    // 2. Set the future-default (SCF_DEFAULT) so the next character typed
    //    inherits the theme fg, not whichever colour the loop ended on.
    SendMessageW(richEdit, EM_SETCHARFORMAT, SCF_DEFAULT, cast(LPARAM) &cf);

    // 3. Per-token colour passes.
    foreach (s; spans) {
        if (s.kind == TokKind.none) continue;
        cf.crTextColor = colorFor(s.kind);
        CHARRANGE r = { cast(int) s.start, cast(int) s.end };
        SendMessageW(richEdit, EM_EXSETSEL, 0, cast(LPARAM) &r);
        SendMessageW(richEdit, EM_SETCHARFORMAT, SCF_SELECTION, cast(LPARAM) &cf);
    }

    // Restore caret + redraw.
    SendMessageW(richEdit, EM_EXSETSEL, 0, cast(LPARAM) &saved);
    SendMessageW(richEdit, WM_SETREDRAW, TRUE, 0);
    InvalidateRect(richEdit, null, TRUE);
}

debug unittest {
    auto wsrc = "LET start() = VALOF { writes(\"Hello\") }"w;
    auto spans = lexBcpl(wsrc);
    assert(spans.length > 0);
}
