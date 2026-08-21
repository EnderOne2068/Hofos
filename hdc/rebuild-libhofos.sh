#!/bin/bash
# Rebuild libhofos-native.o with the raised CG_MAX_RELOCS. Run in Kali WSL.
set -e
cd /mnt/c/Hofos/deprecated
C=/mnt/c/Hofos/build/hofos-x86-linux
W=/dev/shm
s=$(date +%s)
timeout 700 "$C" -fno-whole-dce libhofos.b -out $W/libhofos-native.o > $W/lhb.log 2>&1
rc=$?
echo "build rc=$rc  $(( $(date +%s)-s ))s"
egrep -i '\berror\b|reserved|unknown|unresolved|too many' $W/lhb.log | head -8
tail -3 $W/lhb.log
if [ -s $W/libhofos-native.o ]; then
  cp -f $W/libhofos-native.o /mnt/c/Hofos/build/libhofos-native.o
  ls -l /mnt/c/Hofos/build/libhofos-native.o | awk '{print "  installed:",$5,"bytes"}'
else
  echo "BUILD_FAILED (no output object)"; exit 1
fi
