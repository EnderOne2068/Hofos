#!/bin/bash
LDC=/mnt/c/Hofos/ldc2-1.42.0-linux-x86_64/bin/ldc2
# Localize libhofos's own _start (and any main) so the D runtime's entry wins.
objcopy -L _start -L main /mnt/c/Hofos/build/libhofos-native.o /dev/shm/libhofos-lib.o 2>&1 | head -2
cd /mnt/c/Hofos/hdc
"$LDC" -of=/dev/shm/hdc-proof source/proof.d source/hofos.d /dev/shm/libhofos-lib.o 2>&1 | head -10
echo "rc=$?"
if [ -x /dev/shm/hdc-proof ]; then
  echo "BUILT. Running HDC proof:"
  /dev/shm/hdc-proof /dev/shm/p.elf
  chmod +x /dev/shm/p.elf 2>/dev/null
  echo "--- run the emitted ELF ---"
  /dev/shm/p.elf; echo "exit=$?"
else
  echo "not built"
fi
