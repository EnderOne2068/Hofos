#!/bin/bash
LDC=/mnt/c/Hofos/ldc2-1.42.0-linux-x86_64/bin/ldc2
DP=/mnt/c/Users/leos_/AppData/Local/dub/packages/libdparse/0.25.1/libdparse/src
objcopy -L _start -L main /mnt/c/Hofos/build/libhofos-native.o /dev/shm/libhofos-lib.o
cd /mnt/c/Hofos/hdc
"$LDC" -of=/dev/shm/hdc -I="$DP" \
  source/app.d source/codegen.d source/hofos.d \
  $(find "$DP/dparse" "$DP/std" "$DP/stdx" -name '*.d' 2>/dev/null) \
  /dev/shm/libhofos-lib.o 2>&1 | head -20
echo "rc=$?"
ls -la /dev/shm/hdc 2>/dev/null && echo BUILT || echo "not built"
