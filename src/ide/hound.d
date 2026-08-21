/**
 * Hound — Hofos's GUI BCPL editor.
 *
 * Win32 native (no third-party deps).  Four D modules:
 *   hound.d                       this file — window, menus, dispatch, file I/O
 *   hound-theme.d                 colour palette + theme list (Light/Dark/...)
 *   hound-syntax-highlight.d      in-process BCPL lexer + RichEdit colouring
 *   hound-debug.d                 in-process Outline/Tokens views; IR/Trace caches
 *
 * Layout
 *   +-------------------------------+-----------------+
 *   |  RichEdit editor              |  debug pane     |
 *   |                               |  (mode picker)  |
 *   +-------------------------------+-----------------+
 *   |  output pane (hofos stdout)                      |
 *   +-------------------------------------------------+
 *   |  status bar                                     |
 *   +-------------------------------------------------+
 *
 * Menus:
 *   File / Edit       (standard)
 *   View / Theme      pick from Light, Dark, Solarized Dark, Monokai, High Contrast
 *   View / Pane mode  Outline | Tokens | IR | Trace
 *   Build             Tokenize / Parse / IR / Run / Compile (shells out to hofos)
 *   Debug             Toggle trace, jump-to-line from trace, step through trace
 */

module hound;

import core.sys.windows.windows;
import core.sys.windows.commctrl;
import core.sys.windows.commdlg;
import core.sys.windows.richedit;
import core.sys.windows.shellapi;
import std.utf : toUTF16z, toUTF8, toUTF16;
import std.conv : to;
import std.string : fromStringz, toStringz, splitLines;
import std.file : read, exists;
static import std.file;
import std.path : baseName;
import std.process : pipeProcess, wait, Redirect, Config;
import std.array : appender, join;

import hound_syntax_highlight : applyHighlight = apply, lexBcpl;
import hound_debug : Mode, modeName, renderFor, setIR, setTrace;
import hound_theme : current, setTheme, kThemes, themeCount;

extern (Windows) {
    HWND CreateStatusWindowW(int style, LPCWSTR text, HWND parent, uint id);
}

// ---- Constants -------------------------------------------------------------

enum CLASS_NAME = "Hound_MainWindow"w;

enum : uint {
    IDM_FILE_NEW      = 1001, IDM_FILE_OPEN  = 1002,
    IDM_FILE_SAVE     = 1003, IDM_FILE_SAVEAS= 1004, IDM_FILE_EXIT = 1009,

    IDM_EDIT_UNDO     = 1100, IDM_EDIT_CUT   = 1101,
    IDM_EDIT_COPY     = 1102, IDM_EDIT_PASTE = 1103, IDM_EDIT_SELALL = 1104,

    IDM_VIEW_REHIGHLIGHT     = 1150,
    IDM_VIEW_REFRESH_PANE    = 1151,

    IDM_VIEW_MODE_BASE = 1160,   // + Mode index → mode-pick id
    IDM_THEME_BASE     = 1180,   // + theme idx → theme-pick id

    IDM_BUILD_TOKENIZE = 1200, IDM_BUILD_PARSE = 1201, IDM_BUILD_IR = 1202,
    IDM_BUILD_RUN      = 1203, IDM_BUILD_COMPILE = 1204,

    IDM_DEBUG_STEP_TRACE = 1240,
    IDM_DEBUG_CLEAR      = 1241,

    IDM_HELP_ABOUT     = 1300,

    ID_EDIT_CTRL      = 200, ID_DEBUG_PANE = 201,
    ID_OUTPUT_PANE    = 202, ID_STATUS_BAR = 203,
}

enum int STATUS_HEIGHT = 22;
enum int OUTPUT_HEIGHT = 180;
enum int DEBUG_WIDTH   = 320;

// ---- Module state ----------------------------------------------------------

__gshared {
    HINSTANCE g_hInstance;
    HWND      g_mainWnd;
    HWND      g_editCtrl;
    HWND      g_debugPane;
    HWND      g_outputPane;
    HWND      g_statusBar;
    HMENU     g_menu;
    HMENU     g_viewMenu;
    HMENU     g_themeMenu;
    HMENU     g_modeMenu;
    HFONT     g_monoFont;
    HMODULE   g_richedit;
    HBRUSH    g_paneBrush;
    HBRUSH    g_outputBrush;
    string    g_currentFile;
    bool      g_dirty;
    bool      g_inHighlight;
    Mode      g_paneMode;
    int       g_traceCursor = -1;
}

// ---- Helpers ---------------------------------------------------------------

void msgBox(string text, string title = "Hound", uint flags = MB_OK | MB_ICONINFORMATION) {
    MessageBoxW(g_mainWnd, text.toUTF16z, title.toUTF16z, flags);
}

void refreshTitle() {
    auto name = g_currentFile.length ? baseName(g_currentFile) : "untitled";
    auto title = (g_dirty ? "* " : "") ~ name ~ " - Hound";
    SetWindowTextW(g_mainWnd, title.toUTF16z);
    if (g_statusBar) {
        auto status = g_currentFile.length ? g_currentFile : "no file";
        if (g_dirty) status ~= "  [modified]";
        status ~= "    theme=" ~ current().name ~ "    pane=" ~ modeName(g_paneMode);
        SendMessageW(g_statusBar, SB_SETTEXTW, 0, cast(LPARAM) status.toUTF16z);
    }
}

wstring getEditTextW() {
    auto len = GetWindowTextLengthW(g_editCtrl);
    if (len <= 0) return ""w;
    auto buf = new wchar[len + 1];
    GetWindowTextW(g_editCtrl, buf.ptr, len + 1);
    return buf[0 .. len].idup;
}

string getEditText() { return getEditTextW().to!string; }

void setEditText(string s) {
    g_inHighlight = true;
    scope (exit) g_inHighlight = false;
    SetWindowTextW(g_editCtrl, s.toUTF16z);
    g_dirty = false;
    refreshTitle();
    rehighlight();
    refreshPane();
}

void outputAppend(string s) {
    auto len = GetWindowTextLengthW(g_outputPane);
    SendMessageW(g_outputPane, EM_SETSEL, len, len);
    SendMessageW(g_outputPane, EM_REPLACESEL, 0, cast(LPARAM) s.toUTF16z);
}

void rehighlight() {
    if (!g_editCtrl) return;
    auto w = getEditTextW();
    if (w.length == 0) return;
    applyHighlight(g_editCtrl, w);
}

void refreshPane() {
    if (!g_debugPane) return;
    auto w = getEditTextW();
    auto text = renderFor(g_paneMode, w);
    SetWindowTextW(g_debugPane, text.toUTF16z);
}

// ---- Theme application -----------------------------------------------------

void rebuildBrushes() {
    if (g_paneBrush)   DeleteObject(g_paneBrush);
    if (g_outputBrush) DeleteObject(g_outputBrush);
    g_paneBrush   = CreateSolidBrush(current().paneBg);
    g_outputBrush = CreateSolidBrush(current().outputBg);
}

void applyTheme() {
    rebuildBrushes();
    rehighlight();
    if (g_debugPane)  InvalidateRect(g_debugPane,  null, TRUE);
    if (g_outputPane) InvalidateRect(g_outputPane, null, TRUE);
    refreshTitle();
}

// ---- File ops --------------------------------------------------------------

bool confirmDiscard() {
    if (!g_dirty) return true;
    auto r = MessageBoxW(g_mainWnd, "Discard unsaved changes?"w.ptr,
                         "Hound"w.ptr, MB_OKCANCEL | MB_ICONWARNING);
    return r == IDOK;
}

void fileNew() {
    if (!confirmDiscard()) return;
    setEditText("");
    g_currentFile = "";
    refreshTitle();
}

void fileOpen() {
    if (!confirmDiscard()) return;
    wchar[260] buf = 0;
    OPENFILENAMEW ofn;
    ofn.lStructSize = OPENFILENAMEW.sizeof;
    ofn.hwndOwner   = g_mainWnd;
    ofn.lpstrFilter = "BCPL (*.bcpl;*.b;*.h)\0*.bcpl;*.b;*.h\0All files (*.*)\0*.*\0\0"w.ptr;
    ofn.lpstrFile   = buf.ptr;
    ofn.nMaxFile    = cast(uint) buf.length;
    ofn.Flags       = OFN_PATHMUSTEXIST | OFN_FILEMUSTEXIST | OFN_HIDEREADONLY;
    if (!GetOpenFileNameW(&ofn)) return;
    loadFile(buf[].fromStringz.to!string);
}

void loadFile(string path) {
    try {
        auto bytes = cast(ubyte[]) read(path);
        if (bytes.length >= 3 && bytes[0..3] == [0xEFu, 0xBBu, 0xBFu]) bytes = bytes[3..$];
        setEditText(cast(string) bytes.idup);
        g_currentFile = path;
        refreshTitle();
    } catch (Exception e) {
        msgBox("Open failed: " ~ e.msg, "Hound", MB_OK | MB_ICONERROR);
    }
}

void fileSave() {
    if (g_currentFile.length == 0) { fileSaveAs(); return; }
    try {
        std.file.write(g_currentFile, getEditText());
        g_dirty = false; refreshTitle();
    } catch (Exception e) {
        msgBox("Save failed: " ~ e.msg, "Hound", MB_OK | MB_ICONERROR);
    }
}

void fileSaveAs() {
    wchar[260] buf = 0;
    if (g_currentFile.length) {
        auto src = g_currentFile.toUTF16;
        auto take = src.length > buf.length - 1 ? buf.length - 1 : src.length;
        buf[0 .. take] = src[0 .. take];
    }
    OPENFILENAMEW ofn;
    ofn.lStructSize = OPENFILENAMEW.sizeof;
    ofn.hwndOwner   = g_mainWnd;
    ofn.lpstrFilter = "BCPL (*.bcpl;*.b;*.h)\0*.bcpl;*.b;*.h\0All files (*.*)\0*.*\0\0"w.ptr;
    ofn.lpstrFile   = buf.ptr;
    ofn.nMaxFile    = cast(uint) buf.length;
    ofn.lpstrDefExt = "bcpl"w.ptr;
    ofn.Flags       = OFN_OVERWRITEPROMPT | OFN_HIDEREADONLY;
    if (!GetSaveFileNameW(&ofn)) return;
    g_currentFile = buf[].fromStringz.to!string;
    fileSave();
}

// ---- Build menu ------------------------------------------------------------

enum CINTSYS = `C:\Hofos\bin\cintsys64.exe`;

string runHofos(string[] words, bool collect = false) {
    auto srcPath = g_currentFile;
    if (srcPath.length == 0 || g_dirty) {
        srcPath = `C:\Hofos\build\hound-buf.bcpl`;
        try std.file.write(srcPath, getEditText());
        catch (Exception e) { outputAppend("[hound] scratch write failed: " ~ e.msg ~ "\r\n"); return ""; }
        outputAppend("[hound] using scratch: " ~ srcPath ~ "\r\n");
    }

    auto cmd = [CINTSYS, "-c", "hofos"] ~ words ~ srcPath;
    auto line = appender!string();
    line.put("$ hofos ");
    foreach (w; words) { line.put(w); line.put(" "); }
    line.put(srcPath);
    line.put("\r\n");
    outputAppend(line.data);

    auto env = [
        "BCPL64ROOT":    `C:\BCPL\cintcode`,
        "BCPL64PATH":    `C:\BCPL\cintcode\cin64;C:\Hofos\lib`,
        "BCPL64HDRS":    `C:\Hofos\include;C:\Hofos\src;C:\BCPL\cintcode\g`,
        "BCPL64SCRIPTS": `C:\BCPL\cintcode\s`,
    ];

    auto collected = appender!string();
    try {
        auto pipes = pipeProcess(cmd, Redirect.stdout | Redirect.stderrToStdout,
                                 env, Config.none);
        foreach (l; pipes.stdout.byLine) {
            auto s = l.idup ~ "\r\n";
            outputAppend(s);
            if (collect) collected.put(s);
        }
        auto status = wait(pipes.pid);
        outputAppend("[exit " ~ status.to!string ~ "]\r\n\r\n");
    } catch (Exception e) {
        outputAppend("[hound] spawn failed: " ~ e.msg ~ "\r\n");
    }
    return collected.data;
}

void buildTokenize() { runHofos(["tokenize"]); }
void buildParse()    { runHofos(["parse"]); }
void buildIR()       {
    auto s = runHofos(["ir"], true);
    if (s.length) { setIR(s); if (g_paneMode == Mode.ir) refreshPane(); }
}
void buildRun()      {
    auto s = runHofos(["run"], true);
    if (s.length) { setTrace(s); g_traceCursor = 0;
                    if (g_paneMode == Mode.trace) refreshPane(); }
}
void buildCompile()  { runHofos([]); }   // single positional -> implicit ->?

// ---- Debug menu ------------------------------------------------------------

void debugStepTrace() {
    // Bring up trace mode and try to find the next line that mentions "vm:"
    // — Hound's "next step" is one trace line at a time.  We extract the
    // current cursor's trace line into a status message and bump the cursor.
    g_paneMode = Mode.trace;
    refreshPane();

    auto traceText = renderFor(Mode.trace, getEditTextW());
    auto lines = traceText.splitLines;
    if (g_traceCursor < 0 || g_traceCursor >= cast(int) lines.length) {
        msgBox("trace cursor past end; Build > Run to capture again", "Hound");
        return;
    }
    auto line = lines[g_traceCursor].idup;
    ++g_traceCursor;
    if (g_statusBar) {
        SendMessageW(g_statusBar, SB_SETTEXTW, 0, cast(LPARAM)
                     ("trace[" ~ (g_traceCursor - 1).to!string ~ "]: " ~ line).toUTF16z);
    }
}

void debugClear() {
    setIR(""); setTrace(""); g_traceCursor = -1;
    refreshPane();
}

void showAbout() {
    msgBox(
        "Hound - Hofos GUI BCPL editor\n\n" ~
        "Syntax highlighting, outline and token view are in-process D.\n" ~
        "Theme is " ~ current().name ~ " (" ~ themeCount().to!string ~ " available).\n" ~
        "IR / Trace views are populated by Build > IR and Build > Run.",
        "About Hound");
}

// ---- Menu construction -----------------------------------------------------

HMENU buildMenuBar() {
    auto bar = CreateMenu();

    auto file = CreatePopupMenu();
    AppendMenuW(file, MF_STRING, IDM_FILE_NEW,    "&New\tCtrl+N"w.ptr);
    AppendMenuW(file, MF_STRING, IDM_FILE_OPEN,   "&Open...\tCtrl+O"w.ptr);
    AppendMenuW(file, MF_STRING, IDM_FILE_SAVE,   "&Save\tCtrl+S"w.ptr);
    AppendMenuW(file, MF_STRING, IDM_FILE_SAVEAS, "Save &As..."w.ptr);
    AppendMenuW(file, MF_SEPARATOR, 0, null);
    AppendMenuW(file, MF_STRING, IDM_FILE_EXIT,   "E&xit"w.ptr);
    AppendMenuW(bar, MF_POPUP, cast(UINT_PTR) file, "&File"w.ptr);

    auto edit = CreatePopupMenu();
    AppendMenuW(edit, MF_STRING, IDM_EDIT_UNDO,   "&Undo\tCtrl+Z"w.ptr);
    AppendMenuW(edit, MF_SEPARATOR, 0, null);
    AppendMenuW(edit, MF_STRING, IDM_EDIT_CUT,    "Cu&t\tCtrl+X"w.ptr);
    AppendMenuW(edit, MF_STRING, IDM_EDIT_COPY,   "&Copy\tCtrl+C"w.ptr);
    AppendMenuW(edit, MF_STRING, IDM_EDIT_PASTE,  "&Paste\tCtrl+V"w.ptr);
    AppendMenuW(edit, MF_SEPARATOR, 0, null);
    AppendMenuW(edit, MF_STRING, IDM_EDIT_SELALL, "Select &All\tCtrl+A"w.ptr);
    AppendMenuW(bar, MF_POPUP, cast(UINT_PTR) edit, "&Edit"w.ptr);

    g_viewMenu  = CreatePopupMenu();
    g_themeMenu = CreatePopupMenu();
    g_modeMenu  = CreatePopupMenu();
    for (uint i = 0; i < themeCount(); ++i) {
        auto nm = kThemes[i].name;
        AppendMenuW(g_themeMenu, MF_STRING, IDM_THEME_BASE + i, nm.toUTF16z);
    }
    foreach (m; [Mode.outline, Mode.tokens, Mode.ir, Mode.trace]) {
        AppendMenuW(g_modeMenu, MF_STRING, IDM_VIEW_MODE_BASE + cast(uint) m,
                    modeName(m).toUTF16z);
    }
    AppendMenuW(g_viewMenu, MF_POPUP, cast(UINT_PTR) g_themeMenu, "&Theme"w.ptr);
    AppendMenuW(g_viewMenu, MF_POPUP, cast(UINT_PTR) g_modeMenu,  "&Pane mode"w.ptr);
    AppendMenuW(g_viewMenu, MF_SEPARATOR, 0, null);
    AppendMenuW(g_viewMenu, MF_STRING, IDM_VIEW_REHIGHLIGHT,
                "Re-&highlight\tCtrl+H"w.ptr);
    AppendMenuW(g_viewMenu, MF_STRING, IDM_VIEW_REFRESH_PANE,
                "Refresh pane\tCtrl+L"w.ptr);
    AppendMenuW(bar, MF_POPUP, cast(UINT_PTR) g_viewMenu, "&View"w.ptr);

    auto build = CreatePopupMenu();
    AppendMenuW(build, MF_STRING, IDM_BUILD_TOKENIZE, "&Tokenize\tF6"w.ptr);
    AppendMenuW(build, MF_STRING, IDM_BUILD_PARSE,    "&Parse\tF7"w.ptr);
    AppendMenuW(build, MF_STRING, IDM_BUILD_IR,       "&IR\tF8"w.ptr);
    AppendMenuW(build, MF_STRING, IDM_BUILD_RUN,      "&Run on VM\tF5"w.ptr);
    AppendMenuW(build, MF_SEPARATOR, 0, null);
    AppendMenuW(build, MF_STRING, IDM_BUILD_COMPILE,  "&Compile to ELF64\tF9"w.ptr);
    AppendMenuW(bar, MF_POPUP, cast(UINT_PTR) build, "&Build"w.ptr);

    auto dbg = CreatePopupMenu();
    AppendMenuW(dbg, MF_STRING, IDM_DEBUG_STEP_TRACE,
                "&Step through trace\tF10"w.ptr);
    AppendMenuW(dbg, MF_STRING, IDM_DEBUG_CLEAR,
                "&Clear IR/Trace caches"w.ptr);
    AppendMenuW(bar, MF_POPUP, cast(UINT_PTR) dbg, "&Debug"w.ptr);

    auto help = CreatePopupMenu();
    AppendMenuW(help, MF_STRING, IDM_HELP_ABOUT, "&About..."w.ptr);
    AppendMenuW(bar, MF_POPUP, cast(UINT_PTR) help, "&Help"w.ptr);

    return bar;
}

// ---- Window procedure ------------------------------------------------------

void layoutChildren() {
    RECT rc; GetClientRect(g_mainWnd, &rc);
    int w = rc.right - rc.left;
    int h = rc.bottom - rc.top;

    int outH  = OUTPUT_HEIGHT;
    int statH = STATUS_HEIGHT;
    int topH  = h - statH - outH;
    if (topH < 60) topH = 60;
    int debugW = DEBUG_WIDTH;
    int editW = w - debugW;
    if (editW < 200) editW = 200;

    MoveWindow(g_editCtrl,    0,        0,         editW,    topH,   TRUE);
    MoveWindow(g_debugPane,   editW,    0,         debugW,   topH,   TRUE);
    MoveWindow(g_outputPane,  0,        topH,      w,        outH,   TRUE);
    MoveWindow(g_statusBar,   0,        topH+outH, w,        statH,  TRUE);
}

extern (Windows) LRESULT WndProc(HWND hWnd, uint msg, WPARAM wp, LPARAM lp) nothrow {
    try switch (msg) {
        case WM_CREATE:
            g_richedit = LoadLibraryW("Msftedit.dll"w.ptr);

            g_editCtrl = CreateWindowExW(
                WS_EX_CLIENTEDGE,
                "RICHEDIT50W"w.ptr, ""w.ptr,
                WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_HSCROLL |
                    ES_MULTILINE | ES_AUTOVSCROLL | ES_AUTOHSCROLL | ES_NOHIDESEL,
                0, 0, 100, 100,
                hWnd, cast(HMENU) ID_EDIT_CTRL, g_hInstance, null);
            SendMessageW(g_editCtrl, EM_SETEVENTMASK, 0, ENM_CHANGE);

            g_debugPane = CreateWindowExW(
                WS_EX_CLIENTEDGE,
                "EDIT"w.ptr, ""w.ptr,
                WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_HSCROLL |
                    ES_MULTILINE | ES_READONLY | ES_AUTOVSCROLL,
                0, 0, 100, 100,
                hWnd, cast(HMENU) ID_DEBUG_PANE, g_hInstance, null);

            g_outputPane = CreateWindowExW(
                WS_EX_CLIENTEDGE,
                "EDIT"w.ptr, ""w.ptr,
                WS_CHILD | WS_VISIBLE | WS_VSCROLL | WS_HSCROLL |
                    ES_MULTILINE | ES_AUTOVSCROLL | ES_READONLY,
                0, 0, 100, 100,
                hWnd, cast(HMENU) ID_OUTPUT_PANE, g_hInstance, null);

            g_statusBar = CreateStatusWindowW(WS_CHILD | WS_VISIBLE,
                                              "ready"w.ptr, hWnd, ID_STATUS_BAR);

            g_monoFont = CreateFontW(
                -14, 0, 0, 0, FW_NORMAL, FALSE, FALSE, FALSE,
                ANSI_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
                5, FF_MODERN | FIXED_PITCH,
                "Consolas"w.ptr);
            SendMessageW(g_editCtrl,   WM_SETFONT, cast(WPARAM) g_monoFont, 1);
            SendMessageW(g_debugPane,  WM_SETFONT, cast(WPARAM) g_monoFont, 1);
            SendMessageW(g_outputPane, WM_SETFONT, cast(WPARAM) g_monoFont, 1);

            DragAcceptFiles(hWnd, TRUE);
            rebuildBrushes();
            return 0;

        case WM_SIZE:
            layoutChildren();
            return 0;

        case WM_SETFOCUS:
            SetFocus(g_editCtrl);
            return 0;

        case WM_DROPFILES: {
            HDROP h = cast(HDROP) wp;
            wchar[260] fn = 0;
            DragQueryFileW(h, 0, fn.ptr, cast(uint) fn.length);
            DragFinish(h);
            if (confirmDiscard()) loadFile(fn[].fromStringz.to!string);
            return 0;
        }

        case WM_CTLCOLOREDIT:
        case WM_CTLCOLORSTATIC: {
            auto hdc = cast(HDC) wp;
            auto child = cast(HWND) lp;
            if (child == g_debugPane) {
                SetBkColor(hdc, current().paneBg);
                SetTextColor(hdc, current().paneFg);
                return cast(LRESULT) g_paneBrush;
            }
            if (child == g_outputPane) {
                SetBkColor(hdc, current().outputBg);
                SetTextColor(hdc, current().outputFg);
                return cast(LRESULT) g_outputBrush;
            }
            break;
        }

        case WM_COMMAND: {
            auto id   = LOWORD(wp);
            auto code = HIWORD(wp);

            if (cast(HWND) lp == g_editCtrl && code == EN_CHANGE) {
                if (!g_inHighlight) {
                    if (!g_dirty) { g_dirty = true; refreshTitle(); }
                    g_inHighlight = true;
                    rehighlight();
                    refreshPane();
                    g_inHighlight = false;
                }
                return 0;
            }

            // theme picks
            if (id >= IDM_THEME_BASE && id < IDM_THEME_BASE + themeCount()) {
                setTheme(id - IDM_THEME_BASE);
                applyTheme();
                return 0;
            }
            // mode picks
            if (id >= IDM_VIEW_MODE_BASE && id < IDM_VIEW_MODE_BASE + 4) {
                g_paneMode = cast(Mode)(id - IDM_VIEW_MODE_BASE);
                refreshPane();
                refreshTitle();
                return 0;
            }

            switch (id) {
                case IDM_FILE_NEW:     fileNew();    break;
                case IDM_FILE_OPEN:    fileOpen();   break;
                case IDM_FILE_SAVE:    fileSave();   break;
                case IDM_FILE_SAVEAS:  fileSaveAs(); break;
                case IDM_FILE_EXIT:    PostMessageW(hWnd, WM_CLOSE, 0, 0); break;

                case IDM_EDIT_UNDO:    SendMessageW(g_editCtrl, EM_UNDO,  0, 0); break;
                case IDM_EDIT_CUT:     SendMessageW(g_editCtrl, WM_CUT,   0, 0); break;
                case IDM_EDIT_COPY:    SendMessageW(g_editCtrl, WM_COPY,  0, 0); break;
                case IDM_EDIT_PASTE:   SendMessageW(g_editCtrl, WM_PASTE, 0, 0); break;
                case IDM_EDIT_SELALL:  SendMessageW(g_editCtrl, EM_SETSEL, 0, -1); break;

                case IDM_VIEW_REHIGHLIGHT:    rehighlight(); break;
                case IDM_VIEW_REFRESH_PANE:   refreshPane(); break;

                case IDM_BUILD_TOKENIZE: buildTokenize(); break;
                case IDM_BUILD_PARSE:    buildParse();    break;
                case IDM_BUILD_IR:       buildIR();       break;
                case IDM_BUILD_RUN:      buildRun();      break;
                case IDM_BUILD_COMPILE:  buildCompile();  break;

                case IDM_DEBUG_STEP_TRACE: debugStepTrace(); break;
                case IDM_DEBUG_CLEAR:      debugClear();     break;

                case IDM_HELP_ABOUT:   showAbout(); break;
                default: break;
            }
            return 0;
        }

        case WM_CLOSE:
            if (!confirmDiscard()) return 0;
            DestroyWindow(hWnd);
            return 0;

        case WM_DESTROY:
            if (g_monoFont)     DeleteObject(g_monoFont);
            if (g_paneBrush)    DeleteObject(g_paneBrush);
            if (g_outputBrush)  DeleteObject(g_outputBrush);
            if (g_richedit)     FreeLibrary(g_richedit);
            PostQuitMessage(0);
            return 0;

        default: break;
    } catch (Exception e) {
        try { msgBox("internal: " ~ e.msg, "Hound", MB_OK | MB_ICONERROR); } catch (Exception) {}
    }
    return DefWindowProcW(hWnd, msg, wp, lp);
}

// ---- Accelerator table -----------------------------------------------------

ACCEL[] buildAccels() {
    ACCEL[] a;
    void add(ushort cmd, byte vk, byte fv = FCONTROL | FVIRTKEY) {
        ACCEL x; x.fVirt = fv; x.key = vk; x.cmd = cmd; a ~= x;
    }
    add(IDM_FILE_NEW,            'N');
    add(IDM_FILE_OPEN,           'O');
    add(IDM_FILE_SAVE,           'S');
    add(IDM_EDIT_SELALL,         'A');
    add(IDM_VIEW_REHIGHLIGHT,    'H');
    add(IDM_VIEW_REFRESH_PANE,   'L');
    add(IDM_BUILD_RUN,           VK_F5, FVIRTKEY);
    add(IDM_BUILD_TOKENIZE,      VK_F6, FVIRTKEY);
    add(IDM_BUILD_PARSE,         VK_F7, FVIRTKEY);
    add(IDM_BUILD_IR,            VK_F8, FVIRTKEY);
    add(IDM_BUILD_COMPILE,       VK_F9, FVIRTKEY);
    add(IDM_DEBUG_STEP_TRACE,    VK_F10, FVIRTKEY);
    return a;
}

// ---- Entry -----------------------------------------------------------------

int main(string[] args) {
    g_hInstance = GetModuleHandleW(null);

    INITCOMMONCONTROLSEX icc;
    icc.dwSize = INITCOMMONCONTROLSEX.sizeof;
    icc.dwICC  = ICC_BAR_CLASSES;
    InitCommonControlsEx(&icc);

    WNDCLASSEXW wc;
    wc.cbSize        = WNDCLASSEXW.sizeof;
    wc.style         = CS_HREDRAW | CS_VREDRAW;
    wc.lpfnWndProc   = &WndProc;
    wc.hInstance     = g_hInstance;
    wc.hCursor       = LoadCursorW(null, IDC_ARROW);
    wc.hbrBackground = cast(HBRUSH)(COLOR_BTNFACE + 1);
    wc.lpszClassName = CLASS_NAME.ptr;
    wc.hIcon         = LoadIconW(null, IDI_APPLICATION);
    wc.hIconSm       = wc.hIcon;
    if (!RegisterClassExW(&wc)) {
        MessageBoxW(null, "RegisterClassEx failed"w.ptr, "Hound"w.ptr, MB_ICONERROR);
        return 1;
    }

    g_menu = buildMenuBar();

    g_mainWnd = CreateWindowExW(
        0, CLASS_NAME.ptr,
        "untitled - Hound"w.ptr,
        WS_OVERLAPPEDWINDOW,
        CW_USEDEFAULT, CW_USEDEFAULT, 1180, 760,
        null, g_menu, g_hInstance, null);
    if (!g_mainWnd) {
        MessageBoxW(null, "CreateWindow failed"w.ptr, "Hound"w.ptr, MB_ICONERROR);
        return 1;
    }

    // Default to Dark.
    setTheme(1);

    if (args.length > 1) loadFile(args[1]);

    ShowWindow(g_mainWnd, SW_SHOW);
    UpdateWindow(g_mainWnd);
    refreshTitle();
    applyTheme();
    refreshPane();

    auto accels = buildAccels();
    HACCEL hAccel = CreateAcceleratorTableW(accels.ptr, cast(int) accels.length);

    MSG msg;
    while (GetMessageW(&msg, null, 0, 0) > 0) {
        if (hAccel && TranslateAcceleratorW(g_mainWnd, hAccel, &msg)) continue;
        TranslateMessage(&msg);
        DispatchMessageW(&msg);
    }
    return cast(int) msg.wParam;
}
