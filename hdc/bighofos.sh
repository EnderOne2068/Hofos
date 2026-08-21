#!/bin/bash
cd /mnt/c/Hofos/hdc
s=$(date +%s)
timeout 550 ./hdc /mnt/c/Hofos/build/hofos.d -o /dev/shm/hd.elf > /dev/shm/big.log 2>&1
rc=$?
echo "rc=$rc  time=$(( $(date +%s)-s ))s"
tail -4 /dev/shm/big.log
grep -iE 'error|unresolved' /dev/shm/big.log | sort | uniq -c | sort -rn | head -6
ls -la /dev/shm/hd.elf 2>/dev/null | awk '{print $5" bytes"}' || echo "no output"
