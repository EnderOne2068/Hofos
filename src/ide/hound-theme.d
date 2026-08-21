/**
 * Hound — themes.
 *
 * A Theme is a flat struct of `COLORREF` values that drive both the
 * RichEdit syntax colours and the plain-EDIT panes (outline / output).
 * The current theme is module-global and Hound queries it on every
 * re-highlight.
 *
 * Adding a theme: append to `kThemes` below and it shows up in the menu.
 *
 * NB: `COLORREF` on Win32 is 0x00BBGGRR (BGR with high byte zero).
 */

module hound_theme;

import core.sys.windows.windows;

struct Theme {
    string   name;
    COLORREF bg;            // editor background
    COLORREF fg;            // default text
    COLORREF keyword;
    COLORREF identifier;
    COLORREF number;
    COLORREF str;
    COLORREF charlit;
    COLORREF op;
    COLORREF comment;
    COLORREF getDirective;
    COLORREF paneBg;        // outline + debug pane bg
    COLORREF paneFg;
    COLORREF outputBg;
    COLORREF outputFg;
}

// Each literal is 0x00BBGGRR — easiest to think of it as #RGB swapped.
__gshared immutable Theme[] kThemes = [
    Theme(
        "Light",
        bg:           0x00FFFFFF, fg:           0x00202020,
        keyword:      0x00CC6600, identifier:   0x00202020,
        number:       0x000080A0, str:          0x00008844,
        charlit:      0x00008844, op:           0x00882288,
        comment:      0x00808080, getDirective: 0x000000CC,
        paneBg:       0x00F4F4F4, paneFg:       0x00202020,
        outputBg:     0x00FAFAFA, outputFg:     0x00303030,
    ),
    Theme(
        "Dark",
        bg:           0x001F1F1F, fg:           0x00E4E4E4,
        keyword:      0x00E1A969, identifier:   0x00DCDCDC,
        number:       0x008CB8FF, str:          0x008AD188,
        charlit:      0x008AD188, op:           0x00D982D9,
        comment:      0x00787878, getDirective: 0x008080FF,
        paneBg:       0x00161616, paneFg:       0x00C8C8C8,
        outputBg:     0x00141414, outputFg:     0x00B4B4B4,
    ),
    Theme(
        "Solarized Dark",
        bg:           0x00362b00, fg:           0x00969483,
        keyword:      0x000089b5, identifier:   0x00969483,
        number:       0x002f8fd3, str:          0x0098a12a,
        charlit:      0x0098a12a, op:           0x00c4716c,
        comment:      0x00756e58, getDirective: 0x00164bcb,
        paneBg:       0x00423607, paneFg:       0x00839496,
        outputBg:     0x002b2102, outputFg:     0x0093a1a1,
    ),
    Theme(
        "Monokai",
        bg:           0x00272822, fg:           0x00F8F8F2,
        keyword:      0x009359F9, identifier:   0x00F8F8F2,
        number:       0x00FA9C56, str:          0x0079DCE6,
        charlit:      0x0079DCE6, op:           0x00F36CF9,
        comment:      0x00688374, getDirective: 0x004781FD,
        paneBg:       0x001E1F1A, paneFg:       0x00CFCFC2,
        outputBg:     0x001A1B16, outputFg:     0x00B4B4A6,
    ),
    Theme(
        "High Contrast",
        bg:           0x00000000, fg:           0x00FFFFFF,
        keyword:      0x0000FFFF, identifier:   0x00FFFFFF,
        number:       0x0000FF80, str:          0x0080FF80,
        charlit:      0x0080FF80, op:           0x00FF80FF,
        comment:      0x00808080, getDirective: 0x000000FF,
        paneBg:       0x00000000, paneFg:       0x00C0C0C0,
        outputBg:     0x00000000, outputFg:     0x00C0C0C0,
    ),
];

__gshared size_t g_themeIdx = 0;

ref immutable(Theme) current() { return kThemes[g_themeIdx]; }

void setTheme(size_t idx) {
    if (idx < kThemes.length) g_themeIdx = idx;
}

size_t themeCount() { return kThemes.length; }
