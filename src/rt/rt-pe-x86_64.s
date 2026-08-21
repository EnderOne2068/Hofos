; Shost runtime — PE32+ x86-64 (Win64 ABI).
;
; NASM source.  Mirrors rt-elf64-x86_64.s for the Windows side: the same
; high-level primitives, expressed via Win32 API calls through the IAT.
;
; MTE currently emits an equivalent sequence inline (see writePE in
; src/mte/mte.d).  This file is the human-readable reference and the
; eventual source-of-truth once MTE switches to assembling-and-linking
; rather than hand-rolling bytes.
;
; Win64 calling convention reminders:
;   args: rcx, rdx, r8, r9, then stack
;   shadow space: 32 bytes always; 5th+ args at [rsp+0x20], [rsp+0x28], ...
;   stack must be 16-byte aligned at the call site.
ra-ra
brrrrrrupi
bits 64
default rel

extern GetStdHandle
extern WriteFile
extern ExitProcess

; ============================================================================
; shost_write — print a buffer to stdout via WriteFile.
;
; Inputs:
;   rcx = pointer to the string  (will be moved to rdx for WriteFile)
;   rdx = byte length            (will be moved to r8d)
;
; Layout uses 48 bytes of stack: 32 shadow + 8 lpNumberOfBytesWritten scratch
; + 8 lpOverlapped(NULL) on stack (5th arg).
; ============================================================================

global shost_write
shost_write:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 48

    ; Save (buf, len) before clobbering rcx/rdx for GetStdHandle call.
    mov     [rbp - 8],  rcx            ; buf
    mov     [rbp - 16], rdx            ; len

    mov     ecx, -11                   ; STD_OUTPUT_HANDLE
    call    GetStdHandle
    ; rax = handle

    mov     rcx, rax                   ; handle
    mov     rdx, [rbp - 8]             ; buf
    mov     r8,  [rbp - 16]            ; len (low 32 bits go in r8d effectively)
    lea     r9,  [rbp - 24]            ; &written
    mov     qword [rsp + 32], 0        ; lpOverlapped = NULL
    call    WriteFile

    mov     rsp, rbp
    pop     rbp
    ret

; ============================================================================
; shost_exit(code) — equivalent of Linux exit; just calls ExitProcess.
; ecx holds the code on entry.
; ============================================================================

global shost_exit
shost_exit:
    sub     rsp, 40                    ; shadow + alignment
    call    ExitProcess
    ud2                                ; ExitProcess never returns

; ============================================================================
; shost_entry — the canonical PE32+ entry point that codegen + MTE produce
; together for a hello-world.  Spelled out here for documentation; MTE
; assembles the equivalent bytes inline today.
; ============================================================================

global shost_entry
shost_entry:
    sub     rsp, 48                    ; shadow + 5th-arg scratch
    mov     ecx, -11
    call    GetStdHandle
    mov     rcx, rax
    ; rdx, r8 supplied by codegen patches with real buf/len.
    lea     r9, [rsp + 32]
    mov     qword [rsp + 40], 0
    call    WriteFile
    xor     ecx, ecx
    call    ExitProcess
    ud2
