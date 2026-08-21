#!/bin/bash
# Build Mcre (with w24), compile a program through xtensa.mcre, hexdump .text.
cd /mnt/c/Hofos/deprecated
C=/mnt/c/Hofos/build/hofos-x86-linux
M=/mnt/c/Hofos/build/hofos-mcre-xt          # persist off tmpfs
echo "=== build hofos-mcre (w24 added) ==="
"$C" -fno-whole-dce hofos-mcre.b -out "$M" >/dev/shm/mx.log 2>&1
[ -s "$M" ] || { echo MCRE_BUILD_FAIL; tail -5 /dev/shm/mx.log; exit 1; }
chmod +x "$M"
cd /mnt/c/Hofos/build/petest
printf 'FUNC start 0\n  CONST t1 6\n  CONST t2 7\n  MUL t3 t1 t2\n  RET t3\nENDFUNC\n' > /dev/shm/xt.hm
echo "=== parse xtensa.mcre (errors only) ==="
"$M" xtensa.mcre -dump 2>&1 | egrep -i 'error|unknown|bad' | head
echo "=== compile xt.hm via xtensa template ==="
"$M" xtensa.mcre /dev/shm/xt.hm -out /mnt/c/Hofos/build/xt.elf 2>&1 | tail -12
echo "=== hexdump .text (skip 84-byte header) ==="
if [ -s /mnt/c/Hofos/build/xt.elf ]; then
  od -An -tx1 -j84 /mnt/c/Hofos/build/xt.elf | head -12
else echo "  (no elf)"; fi
