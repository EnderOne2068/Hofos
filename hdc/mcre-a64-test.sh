#!/bin/bash
# End-to-end test of the expanded AArch64 Mcre backend: compile a HANGMAN program
# through the template to an ELF, run it under qemu-aarch64, check the exit code.
cd /mnt/c/Hofos/deprecated
C=/mnt/c/Hofos/build/hofos-x86-linux
"$C" -fno-whole-dce hofos-mcre.b -out /dev/shm/hofos-mcre >/dev/shm/m.log 2>&1
[ -s /dev/shm/hofos-mcre ] || { echo MCRE_BUILD_FAIL; tail -4 /dev/shm/m.log; exit 1; }
chmod +x /dev/shm/hofos-mcre
cd /mnt/c/Hofos/build/petest
printf 'FUNC start 0\n  CONST t1 42\n  RET t1\nENDFUNC\n' > /dev/shm/t42.hm
echo "=== template parse (errors only) ==="
/dev/shm/hofos-mcre aarch64.mcre -dump 2>&1 | egrep -i 'error|unknown|bad enc|no such' | head
echo "=== compile t42.hm via aarch64 template -> ELF ==="
/dev/shm/hofos-mcre aarch64.mcre /dev/shm/t42.hm -out /dev/shm/t42.elf 2>&1 | tail -10
ls -l /dev/shm/t42.elf 2>/dev/null | awk '{print "  elf:",$5,"bytes"}'
echo "=== disassemble .text (sanity) ==="
which aarch64-linux-gnu-objdump >/dev/null 2>&1 && aarch64-linux-gnu-objdump -d /dev/shm/t42.elf 2>/dev/null | head -20
echo "=== run under qemu-aarch64 (expect exit 42) ==="
Q=$(command -v qemu-aarch64 || command -v qemu-aarch64-static)
echo "  qemu: ${Q:-NOT FOUND}"
[ -n "$Q" ] && { "$Q" /dev/shm/t42.elf; echo "  exit=$?"; }
