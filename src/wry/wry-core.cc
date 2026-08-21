#include "wry.h"

/* ---- the core:: prelude ---------------------------------------------------
 *
 * Option<T> and Result<T, E> as rustc's core defines them, plus the methods that
 * do not need closures.  Injected ahead of the user's source, so a Wry program
 * gets them without declaring anything — the same way Rust's prelude works.
 *
 * ★ WRITTEN IN RUST AND COMPILED BY WRY ITSELF, not built into the compiler as
 * special cases.  That matters for two reasons: the prelude is a real test of
 * the features it uses (generic enums, payload variants, match, impl blocks), and
 * anything expressible here is expressible in user code too.  A prelude built
 * from compiler intrinsics would prove neither.
 *
 * ★ WHY THIS IS A REIMPLEMENTATION AND NOT rustc's SOURCE.  The installed
 * toolchain (rustc 1.95.0) ships without the `rust-src` component — only compiled
 * .rlib/.rmeta — so core's source is not on disk.  These definitions follow
 * core::option and core::result as rustc defines them (same variants, same method
 * names, same signatures and semantics); they are not copied from the source
 * tree.  Where a method needs machinery Wry lacks it is OMITTED rather than
 * approximated, so nothing here silently differs from real Rust.
 *
 * ★ WHAT IS DELIBERATELY ABSENT, AND WHY:
 *   unwrap_or_else / filter / zip — would work now that closures exist, and are
 *       simply not written yet.
 *   (map / and_then ARE here: closures made them possible.  They are declared
 *       `f: fn` rather than Rust's `impl FnOnce(T) -> U` because under erasure
 *       the argument and return types carry no information — see parse_type.)
 *   ok_or / and / or / xor returning a different Option<U> — need real generic
 *       instantiation to be meaningful.  Under ERASURE they would type-check
 *       against anything, which is worse than not having them.
 *   iterators, Deref, Copy/Clone, PartialEq — need traits as BOUNDS, which is
 *       parse-only today.
 *
 * `unwrap` on the empty case panics, which needs a way to abort: `panic!` is a
 * builtin (see wry-mac.cc) that prints its message and exits non-zero.
 */

static char g_core_prelude[] =
"enum Option<T> {\n"
"    None,\n"
"    Some(T),\n"
"}\n"
"\n"
"enum Result<T, E> {\n"
"    Ok(T),\n"
"    Err(E),\n"
"}\n"
"\n"
"impl<T> Option<T> {\n"
"    fn is_some(self) -> bool {\n"
"        return match self { Option::Some(v) => true, Option::None => false, };\n"
"    }\n"
"    fn is_none(self) -> bool {\n"
"        return match self { Option::Some(v) => false, Option::None => true, };\n"
"    }\n"
"    fn unwrap(self) -> T {\n"
"        return match self {\n"
"            Option::Some(v) => v,\n"
"            Option::None => panic!(\"called `Option::unwrap()` on a `None` value\"),\n"
"        };\n"
"    }\n"
"    fn unwrap_or(self, default: T) -> T {\n"
"        return match self { Option::Some(v) => v, Option::None => default, };\n"
"    }\n"
"    fn map(self, f: fn) -> Option<T> {\n"
"        return match self {\n"
"            Option::Some(v) => Option::Some(f(v)),\n"
"            Option::None => Option::None,\n"
"        };\n"
"    }\n"
"    fn and_then(self, f: fn) -> Option<T> {\n"
"        return match self {\n"
"            Option::Some(v) => f(v),\n"
"            Option::None => Option::None,\n"
"        };\n"
"    }\n"
"}\n"
"\n"
"impl<T, E> Result<T, E> {\n"
"    fn is_ok(self) -> bool {\n"
"        return match self { Result::Ok(v) => true, Result::Err(e) => false, };\n"
"    }\n"
"    fn is_err(self) -> bool {\n"
"        return match self { Result::Ok(v) => false, Result::Err(e) => true, };\n"
"    }\n"
"    fn unwrap(self) -> T {\n"
"        return match self {\n"
"            Result::Ok(v) => v,\n"
"            Result::Err(e) => panic!(\"called `Result::unwrap()` on an `Err` value\"),\n"
"        };\n"
"    }\n"
"    fn unwrap_or(self, default: T) -> T {\n"
"        return match self { Result::Ok(v) => v, Result::Err(e) => default, };\n"
"    }\n"
"    fn map(self, f: fn) -> Result<T, E> {\n"
"        return match self {\n"
"            Result::Ok(v) => Result::Ok(f(v)),\n"
"            Result::Err(e) => Result::Err(e),\n"
"        };\n"
"    }\n"
"    fn and_then(self, f: fn) -> Result<T, E> {\n"
"        return match self {\n"
"            Result::Ok(v) => f(v),\n"
"            Result::Err(e) => Result::Err(e),\n"
"        };\n"
"    }\n"
"}\n";

char *wry_core_prelude() { return g_core_prelude; }
int   wry_core_prelude_len() { return (int)strlen(g_core_prelude); }
