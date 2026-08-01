# Hofos
Hofos is a lightweight backend originally designed for BCPL that supports a wide range of targets and reliable targets.\
The support range includes PDP-10, PDP-11, VAX, IBM 7094 and various others.\
Optimizations are slower than LLVM or GCC, but are still better than that of other lightweight backends such as QBE or Cranelift.\
A fact was I used Claude Code (primarily the latest Opus models, but partially Fable) to generate the codebase, which was incredibly efficient.
## Building
To build Hofos, you must either have a working installation of the BCPL Cintcode System or use the bundled compiler in /build. It is recommended to regenerate a lot of the compiler artifacts, as they may be outdated or missing.\
## Source tree quirks
`cg.b` is for x86, emitting an ELF directly. `cg-x86-linux` and `cg-x86-windows` use the newer assembler (`ac`) and linker (`fl`) to target differently - a newer innovation that is still in progress.\
If you see a file starting with `hofos-` and ending with `.b`, then you can simply compile that. Examples include `ac`, `fl` and the various compiler drivers. 
### libhofos
If you want to use the compiler as a library, you must compile `libhofos.b` with the -shared flag. After doing this, you must run this command from /bin: 
```
nal --so libhofos.elf -out libhofos.so
```
You can then load from other programs.
## IRs
Hofos has two IRs: The forward-facing frontend IR, known as HANGMAN (or just Hangman) - this you can understand via running -fshow-hm. The internal optimization Braun et al. SSA, known as VRSA (Virtual Register Static Assignment). This can be understood via examining a dump from vrsadump file. 
## Tools
`cog` generates a BCPL header file containing global slots for your files. `nadb` processes `adb` (Absolute Debugger) commands to help debug code. Yacc does the obvious (note: this one is more difficult to recompile, as it is archaic 1985 source code; not Bison).
## Frontends
haxMax is a frontend for Maxima (an implementation of the CAS language; embeds both SBCL and Hofos via libhofos and sbcl.o), hij is a Julia frontend, Histic is a C frontend (K&R), cawk (Compiled AWK) is an AWK and Ofden is a D frontend.
## JIT
If you examine `hofos-jit.b`, you will find a simple Just-In-Time compiler. This is not recommended for use, as it does not handle global state (falls back on a virtual machine for that) and cannot recompile at runtime for JIT performance.
