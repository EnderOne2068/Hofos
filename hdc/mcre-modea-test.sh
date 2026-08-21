#!/bin/bash
# Generate the Xtensa backend AS HANGMAN (Mcre mode A) — the migration-proof
# deliverable — and inspect it.  This is the artifact that survives BCPL->D.
cd /mnt/c/Hofos/deprecated
C=/mnt/c/Hofos/build/hofos-x86-linux
M=/mnt/c/Hofos/build/hofos-mcre-xt
"$C" -fno-whole-dce hofos-mcre.b -out "$M" >/dev/shm/ma.log 2>&1
[ -s "$M" ] || { echo MCRE_BUILD_FAIL; tail -6 /dev/shm/ma.log; exit 1; }
chmod +x "$M"
cd /mnt/c/Hofos/build/petest
echo "=== mode A: generate xtensa-as.hm (backend as HANGMAN) ==="
"$M" xtensa.mcre -out /mnt/c/Hofos/build/xtensa-as.hm 2>&1 | egrep -i 'error|unknown|wrote|enc functions' | head
echo "=== size + shape of generated HANGMAN backend ==="
wc -l /mnt/c/Hofos/build/xtensa-as.hm 2>/dev/null
echo "--- first 25 lines ---"
head -25 /mnt/c/Hofos/build/xtensa-as.hm 2>/dev/null
echo "--- FUNC list (the backend's entry points) ---"
grep -E '^FUNC ' /mnt/c/Hofos/build/xtensa-as.hm 2>/dev/null | head -30
