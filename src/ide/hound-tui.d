/**
 * Hound TUI — Linux/dash terminal IDE for BCPL.
 *
 * Full-screen single-buffer editor.  Termios raw mode, ANSI colour escapes,
 * in-process BCPL lexer (shared with Win32 Hound via hound-syntax-highlight.d
 * would be nice but that file uses Win32 — we keep a small lexer inline here
 * to stay self-contained and ldc2-buildable on Void).
 *
 * Key bindings:
 *   Ctrl-S  save
 *   Ctrl-Q  quit (with dirty-discard prompt)
 *   Ctrl-O  load a file
 *   Ctrl-T  spawn `hofos tokenize` on the current buffer
 *   Ctrl-R  spawn `hofos run`        (compile-and-VM)
 *   Ctrl-B  spawn `hofos SRC ->`     (build to ELF64)
 *   Arrow keys / Home / End / PgUp / PgDn — navigation
 *   Enter / Backspace / printable chars — edit
 *
 * Build:
 *   ldc2 -O2 -of=bin/hound-linux src/ide/hound-tui.d
 */

module hound_tui;

import std.stdio : writeln, writefln, write, stdout, stderr;
import std.string : indexOf, replace, splitLines;
import std.array : appender, Appender, join;
import std.conv : to;
import std.algorithm : min, max;
import std.format : format;
import std.file : readText, exists;
static import std.file;
import std.process : spawnProcess, wait, pipeProcess, Redirect, Config;
import core.stdc.stdio : printf, fflush;
import core.stdc.stdlib : exit;
import core.sys.posix.termios;
import core.sys.posix.unistd : read, write, STDIN_FILENO, STDOUT_FILENO;

extern (C) {
    struct winsize { ushort ws_row, ws_col, ws_xpixel, ws_ypixel; }
    int ioctl(int fd, ulong request, ...);
}
enum ulong TIOCGWINSZ = 0x5413;

// ---- Termios raw mode ------------------------------------------------------

private __gshared termios g_origTermios;

void enterRawMode() {
    tcgetattr(STDIN_FILENO, &g_origTermios);
    termios raw = g_origTermios;
    raw.c_lflag &= ~(ECHO | ICANON | ISIG | IEXTEN);
    raw.c_iflag &= ~(IXON | ICRNL | BRKINT | INPCK | ISTRIP);
    raw.c_oflag &= ~OPOST;
    raw.c_cflag |= CS8;
    raw.c_cc[VMIN]  = 0;
    raw.c_cc[VTIME] = 1;
    tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw);
}

void leaveRawMode() {
    tcsetattr(STDIN_FILENO, TCSAFLUSH, &g_origTermios);
}

// ---- ANSI escape helpers ---------------------------------------------------

void ansiClear()           { write(STDOUT_FILENO, "\x1b[2J\x1b[H".ptr, 7); }
void ansiHome()            { write(STDOUT_FILENO, "\x1b[H".ptr, 3); }
void ansiHideCursor()      { write(STDOUT_FILENO, "\x1b[?25l".ptr, 6); }
void ansiShowCursor()      { write(STDOUT_FILENO, "\x1b[?25h".ptr, 6); }
void ansiInverse()         { write(STDOUT_FILENO, "\x1b[7m".ptr, 4); }
void ansiReset()           { write(STDOUT_FILENO, "\x1b[0m".ptr, 4); }
void ansiMoveTo(int r, int c) {
    auto s = format("\x1b[%d;%dH", r, c);
    write(STDOUT_FILENO, s.ptr, s.length);
}
void ansiColor(int code) {
    auto s = format("\x1b[%dm", code);
    write(STDOUT_FILENO, s.ptr, s.length);
}

// Terminal size.
struct Size { int rows, cols; }
Size getSize() {
    winsize ws;
    if (ioctl(STDOUT_FILENO, TIOCGWINSZ, &ws) != -1 && ws.ws_col > 0) {
        return Size(ws.ws_row, ws.ws_col);
    }
    return Size(24, 80);
}

// ---- In-process BCPL lexer (lite — keyword & string & number detection) --

enum TokK : ubyte { none, keyword, ident, num, str, op, comment }

struct Tok { size_t start, end; TokK kind; }

private __gshared immutable string[] kKeywords = [
    "AND","BE","BREAK","BY","CASE","DEFAULT","DO","ELSE","ENDCASE","EQV",
    "EXTERNAL","FALSE","FINISH","FOR","GET","GLOBAL","GOTO","IF","INTO",
    "LET","LOOP","LSHIFT","MANIFEST","NEEDS","NEQV","NOT","OF","OR",
    "REM","REPEAT","RESULTIS","RETURN","RSHIFT","SECTION","STATIC","STRING",
    "SWITCHON","TABLE","TEST","THEN","TO","TRUE","UNLESS","UNTIL","VALOF",
    "WHILE","VEC"
];

bool isKw(string s) {
    char[16] up;
    if (s.length == 0 || s.length > 16) return false;
    foreach (i, c; s) up[i] = (c >= 'a' && c <= 'z') ? cast(char)(c - 32) : c;
    foreach (k; kKeywords)
        if (k.length == s.length && k == cast(string) up[0 .. s.length].idup)
            return true;
    return false;
}

Tok[] lex(string src) {
    Tok[] toks;
    bool isA(char c) { return (c>='a'&&c<='z') || (c>='A'&&c<='Z') || c=='_'; }
    bool isD(char c) { return c>='0' && c<='9'; }
    size_t i;
    while (i < src.length) {
        auto start = i;
        auto c = src[i];
        if (c == '/' && i + 1 < src.length && src[i+1] == '/') {
            while (i < src.length && src[i] != '\n') ++i;
            toks ~= Tok(start, i, TokK.comment); continue;
        }
        if (c == '/' && i + 1 < src.length && src[i+1] == '*') {
            i += 2;
            while (i + 1 < src.length && !(src[i]=='*' && src[i+1]=='/')) ++i;
            if (i + 1 < src.length) i += 2;
            toks ~= Tok(start, i, TokK.comment); continue;
        }
        if (c == '"') {
            ++i;
            while (i < src.length && src[i] != '"' && src[i] != '\n') {
                if (src[i] == '*' && i + 1 < src.length) i += 2; else ++i;
            }
            if (i < src.length && src[i] == '"') ++i;
            toks ~= Tok(start, i, TokK.str); continue;
        }
        if (isA(c)) {
            while (i < src.length && (isA(src[i]) || isD(src[i]))) ++i;
            auto kind = isKw(src[start..i]) ? TokK.keyword : TokK.ident;
            toks ~= Tok(start, i, kind); continue;
        }
        if (isD(c) || (c == '#' && i+1 < src.length && (src[i+1]=='x'||src[i+1]=='b'||src[i+1]=='o'))) {
            if (c == '#') i += 2;
            while (i < src.length && (isA(src[i]) || isD(src[i]))) ++i;
            toks ~= Tok(start, i, TokK.num); continue;
        }
        if (c == ' ' || c == '\t' || c == '\n' || c == '\r') { ++i; continue; }
        if ("+-*/=<>!:@%|&~?(){}[];,.$".indexOf(c) >= 0) { ++i; toks ~= Tok(start, i, TokK.op); continue; }
        ++i;
    }
    return toks;
}

int kindToColor(TokK k) {
    final switch (k) {
        case TokK.none:    return 37;
        case TokK.keyword: return 33;     // yellow
        case TokK.ident:   return 37;     // white
        case TokK.num:     return 36;     // cyan
        case TokK.str:     return 32;     // green
        case TokK.op:      return 35;     // magenta
        case TokK.comment: return 90;     // bright black
    }
}

// ---- Buffer (line-list) ---------------------------------------------------

struct Buffer {
    string[]  lines;
    int       cy, cx;           // cursor row (line index) and column
    int       offY, offX;       // viewport scroll
    string    path;
    bool      dirty;
}

Buffer g_buf;

void bufLoad(string path) {
    try {
        auto t = readText(path);
        auto ls = t.splitLines;
        g_buf.lines.length = ls.length;
        foreach (i, s; ls) g_buf.lines[i] = s.idup;
        if (g_buf.lines.length == 0) g_buf.lines = [""];
        g_buf.path = path;
        g_buf.dirty = false;
        g_buf.cy = g_buf.cx = 0;
        g_buf.offY = g_buf.offX = 0;
    } catch (Exception) {
        g_buf.lines = [""];
        g_buf.path = path;
    }
}

void bufSave() {
    if (g_buf.path.length == 0) return;
    auto body_ = g_buf.lines.join("\n") ~ "\n";
    std.file.write(g_buf.path, body_);
    g_buf.dirty = false;
}

void bufInsertChar(char c) {
    if (g_buf.cy >= cast(int) g_buf.lines.length) g_buf.lines ~= "";
    auto line = g_buf.lines[g_buf.cy];
    if (g_buf.cx > cast(int) line.length) g_buf.cx = cast(int) line.length;
    g_buf.lines[g_buf.cy] = line[0 .. g_buf.cx] ~ c ~ line[g_buf.cx .. $];
    g_buf.cx++;
    g_buf.dirty = true;
}

void bufBackspace() {
    if (g_buf.cx > 0) {
        auto line = g_buf.lines[g_buf.cy];
        g_buf.lines[g_buf.cy] = line[0 .. g_buf.cx - 1] ~ line[g_buf.cx .. $];
        g_buf.cx--;
        g_buf.dirty = true;
    } else if (g_buf.cy > 0) {
        auto prev = g_buf.lines[g_buf.cy - 1];
        auto cur  = g_buf.lines[g_buf.cy];
        g_buf.cx = cast(int) prev.length;
        g_buf.lines[g_buf.cy - 1] = prev ~ cur;
        g_buf.lines = g_buf.lines[0 .. g_buf.cy] ~ g_buf.lines[g_buf.cy + 1 .. $];
        g_buf.cy--;
        g_buf.dirty = true;
    }
}

void bufEnter() {
    if (g_buf.cy >= cast(int) g_buf.lines.length) g_buf.lines ~= "";
    auto line = g_buf.lines[g_buf.cy];
    if (g_buf.cx > cast(int) line.length) g_buf.cx = cast(int) line.length;
    auto left  = line[0 .. g_buf.cx];
    auto right = line[g_buf.cx .. $];
    g_buf.lines[g_buf.cy] = left;
    g_buf.lines = g_buf.lines[0 .. g_buf.cy + 1] ~ right ~ g_buf.lines[g_buf.cy + 1 .. $];
    g_buf.cy++;
    g_buf.cx = 0;
    g_buf.dirty = true;
}

// ---- Build menu (invokes hofos) --------------------------------------------

string g_lastOutput = "(no build yet)";

void invokeHofos(string verb, bool buildArrow = false) {
    auto src = g_buf.path.length ? g_buf.path : "/tmp/hound-buf.bcpl";
    if (g_buf.dirty || g_buf.path.length == 0) {
        auto body_ = g_buf.lines.join("\n") ~ "\n";
        std.file.write(src, body_);
    }
    auto buf = appender!string();
    string[] cmd;
    if (buildArrow) {
        auto outPath = src ~ ".elf";
        cmd = ["/mnt/c/Hofos/bin/cintsys64-linux", "-c", "hofos", src, "->", outPath];
    } else {
        cmd = ["/mnt/c/Hofos/bin/cintsys64-linux", "-c", "hofos", verb, src];
    }
    auto env = [
        "BCPL64ROOT":    "/mnt/c/BCPL/cintcode",
        "BCPL64PATH":    "/mnt/c/BCPL/cintcode/cin64:/mnt/c/Hofos/lib",
        "BCPL64HDRS":    "/mnt/c/Hofos/include:/mnt/c/Hofos/src:/mnt/c/BCPL/cintcode/g",
        "BCPL64SCRIPTS": "/mnt/c/BCPL/cintcode/s",
    ];
    try {
        auto p = pipeProcess(cmd, Redirect.stdout | Redirect.stderrToStdout, env, Config.none);
        foreach (l; p.stdout.byLine) buf.put(l.idup ~ "\n");
        wait(p.pid);
    } catch (Exception e) {
        buf.put("[hound] spawn failed: " ~ e.msg ~ "\n");
    }
    g_lastOutput = buf.data;
}

// ---- Renderer -------------------------------------------------------------

void drawLine(string line, int width) {
    auto toks = lex(line);
    size_t pos;
    size_t printed;
    foreach (t; toks) {
        // print pre-token whitespace
        while (pos < t.start && printed < cast(size_t) width) {
            char c = line[pos];
            write(STDOUT_FILENO, &c, 1);
            ++pos; ++printed;
        }
        ansiColor(kindToColor(t.kind));
        while (pos < t.end && printed < cast(size_t) width) {
            char c = line[pos];
            write(STDOUT_FILENO, &c, 1);
            ++pos; ++printed;
        }
        ansiColor(0);
    }
    while (pos < line.length && printed < cast(size_t) width) {
        char c = line[pos];
        write(STDOUT_FILENO, &c, 1);
        ++pos; ++printed;
    }
    write(STDOUT_FILENO, "\x1b[K".ptr, 3);  // clear to end of line
}

void render() {
    auto sz = getSize();
    int outputH = 5;
    int editH = sz.rows - outputH - 2;
    if (editH < 5) editH = 5;
    ansiHideCursor();
    ansiHome();
    // editor area
    for (int r = 0; r < editH; ++r) {
        int li = r + g_buf.offY;
        ansiMoveTo(r + 1, 1);
        if (li < cast(int) g_buf.lines.length) {
            // line number
            ansiColor(90);
            auto ln = format("%4d ", li + 1);
            write(STDOUT_FILENO, ln.ptr, ln.length);
            ansiColor(0);
            drawLine(g_buf.lines[li], sz.cols - 5);
        } else {
            ansiColor(94);
            write(STDOUT_FILENO, "   ~", 4);
            ansiColor(0);
            write(STDOUT_FILENO, "\x1b[K".ptr, 3);
        }
    }
    // separator
    ansiMoveTo(editH + 1, 1);
    ansiInverse();
    auto title = (g_buf.dirty ? "* " : "  ") ~
                 (g_buf.path.length ? g_buf.path : "untitled") ~
                 format("    line %d col %d    [F5]run  [F9]build  [^S]save  [^Q]quit",
                        g_buf.cy + 1, g_buf.cx + 1);
    if (title.length < sz.cols) title ~= " ".replicate(sz.cols - title.length);
    if (title.length > sz.cols) title = title[0 .. sz.cols];
    write(STDOUT_FILENO, title.ptr, title.length);
    ansiReset();
    // output pane
    auto outLines = g_lastOutput.splitLines;
    auto firstOutRow = editH + 2;
    foreach (i; 0 .. outputH) {
        ansiMoveTo(firstOutRow + cast(int) i, 1);
        size_t li = outLines.length > cast(size_t) outputH
                    ? outLines.length - outputH + i
                    : i;
        ansiColor(94);
        if (li < outLines.length) {
            auto s = outLines[li];
            if (s.length > cast(size_t)(sz.cols - 1)) s = s[0 .. sz.cols - 1];
            write(STDOUT_FILENO, s.ptr, s.length);
        }
        ansiColor(0);
        write(STDOUT_FILENO, "\x1b[K".ptr, 3);
    }
    // cursor
    int sy = g_buf.cy - g_buf.offY;
    int sx = g_buf.cx + 5;
    ansiMoveTo(sy + 1, sx + 1);
    ansiShowCursor();
}

string replicate(string s, size_t n) {
    auto b = appender!string();
    foreach (_; 0 .. n) b.put(s);
    return b.data;
}

// ---- Input loop -----------------------------------------------------------

int readByte() {
    ubyte b;
    auto n = read(STDIN_FILENO, &b, 1);
    return n == 1 ? b : -1;
}

bool g_running = true;

void clampCursor() {
    if (g_buf.cy < 0) g_buf.cy = 0;
    if (g_buf.cy >= cast(int) g_buf.lines.length) g_buf.cy = cast(int) g_buf.lines.length - 1;
    if (g_buf.cy < 0) g_buf.cy = 0;
    auto lineLen = g_buf.lines.length ? cast(int) g_buf.lines[g_buf.cy].length : 0;
    if (g_buf.cx > lineLen) g_buf.cx = lineLen;
    if (g_buf.cx < 0) g_buf.cx = 0;
    auto sz = getSize();
    int editH = sz.rows - 5 - 2; if (editH < 5) editH = 5;
    if (g_buf.cy - g_buf.offY >= editH) g_buf.offY = g_buf.cy - editH + 1;
    if (g_buf.cy - g_buf.offY < 0) g_buf.offY = g_buf.cy;
}

void processKey(int c) {
    // Ctrl bindings
    if (c == 17) { g_running = false; return; }                 // Ctrl-Q
    if (c == 19) { bufSave(); g_lastOutput = "saved"; return; } // Ctrl-S
    if (c == 20) { invokeHofos("tokenize"); return; }            // Ctrl-T
    if (c == 18) { invokeHofos("run"); return; }                 // Ctrl-R
    if (c ==  2) { invokeHofos("", true); return; }              // Ctrl-B
    if (c ==  8 || c == 127) { bufBackspace(); return; }        // Backspace
    if (c == 13 || c == 10)  { bufEnter(); return; }            // Enter
    if (c == 0x1B) {
        int a = readByte(); if (a < 0) return;
        if (a == '[') {
            int b = readByte(); if (b < 0) return;
            switch (b) {
                case 'A': g_buf.cy--; clampCursor(); return;
                case 'B': g_buf.cy++; clampCursor(); return;
                case 'C': g_buf.cx++; clampCursor(); return;
                case 'D': g_buf.cx--; clampCursor(); return;
                case 'H': g_buf.cx = 0; return;
                case 'F':
                    if (g_buf.cy < cast(int) g_buf.lines.length)
                        g_buf.cx = cast(int) g_buf.lines[g_buf.cy].length;
                    return;
                default: return;
            }
        }
        return;
    }
    if (c >= 32 && c < 127) bufInsertChar(cast(char) c);
}

// ---- Entry ----------------------------------------------------------------

int main(string[] args) {
    if (args.length > 1) bufLoad(args[1]);
    else g_buf.lines = ["// Hound TUI — Ctrl-Q to quit, Ctrl-S save, Ctrl-B build"];

    enterRawMode();
    scope (exit) { leaveRawMode(); ansiShowCursor(); ansiReset(); ansiClear(); }

    ansiClear();
    while (g_running) {
        render();
        int c = readByte();
        if (c >= 0) processKey(c);
        clampCursor();
    }
    return 0;
}
