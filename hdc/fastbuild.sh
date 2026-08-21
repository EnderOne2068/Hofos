#!/bin/bash
# Fast HDC rebuild: link the precompiled dparse lib instead of recompiling it.
# Arg $1 = a .d file to compile with the freshly-built hdc (optional).
LDC=/mnt/c/Hofos/ldc2-1.42.0-linux-x86_64/bin/ldc2
DP=/mnt/c/Users/leos_/AppData/Local/Packages/Claude_pzs8sxrjxfjjc/LocalCache/Local/dub/packages/libdparse/0.25.1/libdparse/src
objcopy -L _start -L main /mnt/c/Hofos/build/libhofos-native.o /dev/shm/libhofos-lib.o
cd /mnt/c/Hofos/hdc
s=$(date +%s)
"$LDC" -of=/dev/shm/hdc -I="$DP" \
  source/app.d source/codegen.d source/hofos.d \
  libdparse.a /dev/shm/libhofos-lib.o 2>&1 | head -20
echo "hdc build $(( $(date +%s)-s ))s"
[ -x /dev/shm/hdc ] || { echo "HDC BUILD FAILED"; exit 1; }
if [ -n "$1" ]; then
  echo "=== hdc $1 ==="
  /dev/shm/hdc "$1" -o /dev/shm/out.elf 2>&1 | tail -8
  if [ -s /dev/shm/out.elf ]; then
    chmod +x /dev/shm/out.elf
    echo "--- run (args: X Y Z) ---"; /dev/shm/out.elf X Y Z; echo "  exit=$?"
  else echo "  (no elf)"; fi
fi
