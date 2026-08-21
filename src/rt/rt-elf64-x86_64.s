; Shost runtime — ELF64 x86-64 (Linux SysV ABI).
;
; NASM source.  Hand-written so the codegen has a canonical sequence to either
; emit verbatim (via cg_emit_template) or link in via MTE.  Each routine here
; is also documented as "the asm equivalent of the BCPL primitive that uses it".
;
; The codegen in src/cg.b currently inlines the bytes of the shost_write /
; shost_exit sequences directly.  If you change anything here, regenerate
; include/rt-elf64.bin via:
;
;   nasm -f bin -O0 src\rt\rt-elf64-x86_64.s -o include\rt-elf64.bin
;
; and update cg.b's CG_RT_* MANIFEST values to match.

bits 64
default rel

; ============================================================================
; shost_write — equivalent to BCPL `writes(strptr, len)` on Linux.
;
; Inputs  (chosen so codegen can stage them with three mov-immediate emits):
;   rsi = pointer to the string in .rodata (vaddr)
;   rdx = byte length
;
; The codegen wraps these mov-imm prologues around this canonical 7-byte tail.
; ============================================================================

global shost_write
shost_write:
    mov     rax, 1                     ; SYS_write
    mov     rdi, 1                     ; fd = stdout
    syscall
    ret

; ============================================================================
; shost_exit(code) — Linux exit syscall.
; rdi already holds the code on entry.
; ============================================================================

global shost_exit
shost_exit:
    mov     rax, 60                    ; SYS_exit
    syscall
    ; never reached
    ud2

; ============================================================================
; shost_strlen — measures a 0-terminated C string at rdi.  Used by the future
; native libhdr implementation of `writef("%s", p)` etc.
; Result in rax.
; ============================================================================

global shost_strlen
shost_strlen:
    xor     rax, rax
.loop:
    cmp     byte [rdi + rax], 0
    je      .done
    inc     rax
    jmp     .loop
.done:
    ret

; ============================================================================
; shost_memcpy — 64-bit aligned (or unaligned) memcpy.  Replaces the BCPL
; word-copy loop emitted by lower.b for vector init in v0.
;
; Win64-style: rcx = dst, rdx = src, r8 = n bytes.   (matches BCPL caller
; preference of using rdx/rsi/r8 as scratch).
; ============================================================================

global shost_memcpy
shost_memcpy:
    mov     rax, rcx                   ; preserve dst for return
.cleanup:
    test    r8, r8
    jz      .done

    ; bulk 8-byte
.bulk:
    cmp     r8, 8
    jb      .tail
    mov     r9, [rdx]
    mov     [rcx], r9
    add     rdx, 8
    add     rcx, 8
    sub     r8, 8
    jmp     .bulk

.tail:
    test    r8, r8
    jz      .done
    mov     r9b, [rdx]
    mov     [rcx], r9b
    inc     rdx
    inc     rcx
    dec     r8
    jmp     .tail

.done:
    ret
