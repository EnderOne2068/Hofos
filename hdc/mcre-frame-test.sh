#!/bin/bash
# Verify the generic frame-size fix: x86 still RUNS correctly (regression), and
# Xtensa's prologue/epilogue immediates are now right.
cd /mnt/c/Hofos/deprecated
C=/mnt/c/Hofos/build/hofos-x86-linux
M=/mnt/c/Hofos/build/hofos-mcre-xt
echo "=== build hofos-mcre ==="
"$C" -fno-whole-dce hofos-mcre.b -out "$M" >/dev/shm/mf.log 2>&1
[ -s "$M" ] || { echo MCRE_BUILD_FAIL; tail -6 /dev/shm/mf.log; exit 1; }
chmod +x "$M"
cd /mnt/c/Hofos/build/petest
printf 'FUNC start 0\n  CONST t1 6\n  CONST t2 7\n  ADD t3 t1 t2\n  RET t3\nENDFUNC\n' > /dev/shm/add.hm
echo "=== X86 REGRESSION: compile via x86-64.mcre, run (expect exit 13) ==="
"$M" x86-64.mcre /dev/shm/add.hm -out /dev/shm/x86add.elf 2>&1 | tail -2
chmod +x /dev/shm/x86add.elf 2>/dev/null
/dev/shm/x86add.elf; echo "  x86 exit=$?  (want 13)"
echo "=== XTENSA: compile via xtensa.mcre, hexdump (frame=32 -> prologue -32=E0, epilogue +32=20) ==="
"$M" xtensa.mcre /dev/shm/add.hm -out /mnt/c/Hofos/build/xtadd.elf 2>&1 | tail -2
od -An -tx1 -j84 /mnt/c/Hofos/build/xtadd.elf 2>/dev/null | head -6
