#!/bin/bash
# Rebuild Histic (K&R/C89 C -> WIR -> native) on Kali. cg.b was restored.
cd /mnt/c/Hofos/deprecated
C=/mnt/c/Hofos/build/hofos-x86-linux
s=$(date +%s)
timeout 1500 "$C" -fno-whole-dce hofos-histic-x86-linux.b -out /mnt/c/Hofos/build/histic-new > /dev/shm/hb.log 2>&1
echo "build rc=$?  $(( $(date +%s)-s ))s"
egrep -i '\berror\b|unresolved|reserved|unknown|missing' /dev/shm/hb.log | head -8
tail -3 /dev/shm/hb.log
ls -l /mnt/c/Hofos/build/histic-new 2>/dev/null | awk '{print "  histic-new:",$5,"bytes"}'
