#!/bin/bash
# Assess the Mcre backend-generator: rebuild it, dump the AArch64 template + selftest.
cd /mnt/c/Hofos/deprecated
C=/mnt/c/Hofos/build/hofos-x86-linux
echo "=== build hofos-mcre (asm path) ==="
s=$(date +%s)
timeout 400 "$C" -fno-whole-dce hofos-mcre.b -out /dev/shm/hofos-mcre > /dev/shm/mcre.log 2>&1
echo "  rc=$? $(( $(date +%s)-s ))s"
egrep -i '\berror\b|unresolved|reserved|unknown' /dev/shm/mcre.log | head -6
[ -s /dev/shm/hofos-mcre ] || { echo "MCRE BUILD FAILED"; tail -5 /dev/shm/mcre.log; exit 1; }
chmod +x /dev/shm/hofos-mcre
echo "=== dump AArch64 template + selftest ==="
cd /mnt/c/Hofos/build/petest
timeout 60 /dev/shm/hofos-mcre aarch64.mcre -dump 2>&1 | head -40
