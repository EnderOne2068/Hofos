#!/bin/bash
# Relink HDC against the freshly-rebuilt libhofos, then compile hofos.d with it.
LDC=/mnt/c/Hofos/ldc2-1.42.0-linux-x86_64/bin/ldc2
DP=/mnt/c/Users/leos_/AppData/Local/Packages/Claude_pzs8sxrjxfjjc/LocalCache/Local/dub/packages/libdparse/0.25.1/libdparse/src
objcopy -L _start -L main /mnt/c/Hofos/build/libhofos-native.o /dev/shm/libhofos-lib.o
cd /mnt/c/Hofos/hdc
echo "=== building hdc ==="
"$LDC" -of=/dev/shm/hdc -I="$DP" \
  source/app.d source/codegen.d source/hofos.d \
  $(find "$DP/dparse" "$DP/std" "$DP/stdx" -name '*.d' 2>/dev/null) \
  /dev/shm/libhofos-lib.o 2>&1 | head -20
[ -x /dev/shm/hdc ] || { echo "HDC BUILD FAILED"; exit 1; }
echo "hdc built."
echo "=== running hdc on hofos.d ==="
s=$(date +%s)
timeout 900 /dev/shm/hdc /mnt/c/Hofos/build/hofos.d -o /dev/shm/hofos.elf 2>&1 | tail -25
echo "hdc rc=? $(( $(date +%s)-s ))s"
if [ -s /dev/shm/hofos.elf ]; then
  echo "ELF EMITTED"
  cp -f /dev/shm/hofos.elf /mnt/c/Hofos/build/hofos-self.elf   # persist off tmpfs
  ls -la /mnt/c/Hofos/build/hofos-self.elf | awk '{print "  persisted:",$5,"bytes"}'
  echo "=== SMOKE TEST (same session) ==="
  chmod +x /dev/shm/hofos.elf
  echo "--- no args (entry=start; argv unwired -> expect usage/err, NOT a crash) ---"
  timeout 15 /dev/shm/hofos.elf; echo "  exit=$?"
else
  echo "no elf"
fi
