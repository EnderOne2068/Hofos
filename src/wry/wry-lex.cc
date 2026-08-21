#include "wry.h"

/* The lexer: character scanning, keywords, string literals, and the source
 * STACK that macro expansion splices into. */
int Lexer::cur()  { if (pos >= len) return -1; return (int)(unsigned char)src[pos]; }
int Lexer::la1()  { if (pos + 1 >= len) return -1; return (int)(unsigned char)src[pos + 1]; }
void Lexer::adv() { if (pos < len) { if (src[pos] == '\n') line = line + 1; pos = pos + 1; } }

void Lexer::init(char *s, int n)
{
    src = s; len = n; pos = 0; line = 1; tok = T_EOF; num = 0;
    name[0] = 0; nstk = 0;
    next();
}

/* Splice `s` in as the current source; the caller's position is restored when
 * this one is exhausted. */
void Lexer::push_source(char *s, int n)
{
    if (nstk >= MAXEXPAND) return;             /* runaway recursive expansion */
    stk_src[nstk] = src; stk_len[nstk] = len;
    /* Resume at TOKPOS, not POS.  By the time a macro is expanded the following
     * token has already been read into `tok`, so `pos` is past it; resuming
     * there would SWALLOW that token — the `}` closing the enclosing block, in
     * the case that caught this.  Saving tokpos makes the pop re-lex it. */
    stk_pos[nstk] = tokpos; stk_line[nstk] = line;
    nstk = nstk + 1;
    src = s; len = n; pos = 0;
}

void Lexer::skipspace()
{
    while (pos < len) {
        int c = cur();
        if (c == ' ' || c == '\t' || c == '\r' || c == '\n') { adv(); continue; }
        /* Rust line comment */
        if (c == '/' && la1() == '/') { while (pos < len && cur() != '\n') adv(); continue; }
        /* Rust block comment (not nested — that is a later refinement) */
        if (c == '/' && la1() == '*') {
            adv(); adv();
            while (pos < len && !(cur() == '*' && la1() == '/')) adv();
            if (pos < len) { adv(); adv(); }
            continue;
        }
        break;
    }
}

int Lexer::keyword(char *s)
{
    if (strcmp(s, "fn") == 0)       return T_FN;
    if (strcmp(s, "let") == 0)      return T_LET;
    if (strcmp(s, "mut") == 0)      return T_MUT;
    if (strcmp(s, "if") == 0)       return T_IF;
    if (strcmp(s, "else") == 0)     return T_ELSE;
    if (strcmp(s, "while") == 0)    return T_WHILE;
    if (strcmp(s, "loop") == 0)     return T_LOOP;
    if (strcmp(s, "break") == 0)    return T_BREAK;
    if (strcmp(s, "continue") == 0) return T_CONTINUE;
    if (strcmp(s, "return") == 0)   return T_RETURN;
    if (strcmp(s, "for") == 0)      return T_FOR;
    if (strcmp(s, "in") == 0)       return T_IN;
    if (strcmp(s, "struct") == 0)   return T_STRUCT;
    if (strcmp(s, "enum") == 0)     return T_ENUM;
    if (strcmp(s, "match") == 0)    return T_MATCH;
    if (strcmp(s, "impl") == 0)     return T_IMPL;
    if (strcmp(s, "trait") == 0)    return T_TRAIT;
    if (strcmp(s, "self") == 0)     return T_SELF;
    return T_IDENT;
}

void Lexer::next()
{
    int c;
    /* Exhausting a macro expansion returns to the text that invoked it; only a
     * truly empty stack is end-of-input. */
    while (1) {
        skipspace();
        if (pos < len) break;
        if (nstk == 0) { tokpos = pos; tok = T_EOF; return; }
        nstk = nstk - 1;
        src = stk_src[nstk]; len = stk_len[nstk];
        pos = stk_pos[nstk]; line = stk_line[nstk];
    }
    tokpos = pos;                            /* start of THIS token */
    c = cur();

    if ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_') {
        int k = 0;
        while (pos < len) {
            c = cur();
            if ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') ||
                (c >= '0' && c <= '9') || c == '_') {
                if (k < NAMELEN - 1) { name[k] = (char)c; k = k + 1; }
                adv();
            } else break;
        }
        name[k] = 0;
        tok = keyword(name);
        return;
    }

    if (c >= '0' && c <= '9') {
        long v = 0;
        while (pos < len) {
            c = cur();
            if (c >= '0' && c <= '9') { v = v * 10 + (c - '0'); adv(); }
            else if (c == '_') adv();            /* Rust digit separator */
            else break;
        }
        num = v; tok = T_NUM;
        return;
    }

    adv();
    switch (c) {
    case '(': tok = T_LP;     return;
    case ')': tok = T_RP;     return;
    case '{': tok = T_LBRACE; return;
    case '}': tok = T_RBRACE; return;
    case '$': tok = T_DOLLAR; return;   /* macro_rules capture marker */
    case '"': {
        /* A string literal.  Only the escapes a format macro actually needs are
         * recognised; an unknown one is kept verbatim rather than silently
         * dropped, so a typo shows up in the output instead of vanishing. */
        int n = 0;
        while (pos < len && cur() != '"') {
            int c = cur();
            if (c == '\\') {
                adv();
                c = cur();
                if (c == 'n')      c = 10;      /* numeric, not a char escape:
                                                 * this file is also a promise to
                                                 * Histic, and 10/9/13 need no
                                                 * escape handling in its lexer */
                else if (c == 't') c = 9;
                else if (c == 'r') c = 13;
                else if (c == '0') c = 0;
                /* a backslash or quote falls through as itself */
            }
            if (n < MAXSTR - 1) { str[n] = (char)c; n = n + 1; }
            adv();
        }
        if (pos < len) adv();               /* closing quote */
        str[n] = 0; strlen_ = n;
        tok = T_STR;
        return;
    }
    case ',': tok = T_COMMA;  return;
    case ';': tok = T_SEMI;   return;
    case '.':                                /* `..` range, `.` field access */
        if (cur() == '.') { adv(); tok = T_DOTDOT; return; }
        tok = T_DOT; return;
    case ':':
        /* `::` is a path separator (Enum::Variant), `:` a type annotation. */
        if (cur() == ':') { adv(); tok = T_COLONCOLON; return; }
        tok = T_COLON;  return;
    case '+': tok = T_PLUS;   return;
    case '*': tok = T_STAR;   return;
    case '/': tok = T_SLASH;  return;
    case '%': tok = T_PCT;    return;
    case '-':
        if (cur() == '>') { adv(); tok = T_ARROW; return; }
        tok = T_MINUS; return;
    case '=':
        if (cur() == '=') { adv(); tok = T_EQ; return; }
        /* `=>` is ONE token now.  macro_rules used to read `=` then `>`; that
         * worked, but a match arm needs to tell `=>` from `>=` and from a
         * comparison, and two tokens cannot do it without lookahead. */
        if (cur() == '>') { adv(); tok = T_FATARROW; return; }
        tok = T_ASSIGN; return;
        tok = T_ASSIGN; return;
    case '!':
        if (cur() == '=') { adv(); tok = T_NE; return; }
        tok = T_BANG; return;
    case '<':
        if (cur() == '=') { adv(); tok = T_LE; return; }
        tok = T_LT; return;
    case '>':
        if (cur() == '=') { adv(); tok = T_GE; return; }
        tok = T_GT; return;
    case '&':
        if (cur() == '&') { adv(); tok = T_ANDAND; return; }
        tok = T_NOT; return;
    case '|':
        if (cur() == '|') { adv(); tok = T_OROR; return; }
        /* A LONE `|` opens a closure.  It is unambiguous: `|` is not a binary
         * operator here (precof gives it no precedence), so it can only start
         * one. */
        tok = T_PIPE; return;
    }
    tok = T_EOF;
}

