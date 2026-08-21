#!/bin/bash
export PATH=/mnt/c/Hofos/ldc2-1.42.0-linux-x86_64/bin:$PATH
DUB=/mnt/c/Hofos/ldc2-1.42.0-linux-x86_64/bin/dub
LDC=/mnt/c/Hofos/ldc2-1.42.0-linux-x86_64/bin/ldc2
chmod +x "$DUB" "$LDC" 2>/dev/null
cd /mnt/c/Hofos/hdc
ls "$DUB" >/dev/null 2>&1 || { echo "no bundled dub"; exit 1; }
"$DUB" build --compiler="$LDC" 2>&1 | tail -20
echo "rc=$?"
ls -la hdc 2>/dev/null && echo BUILT || echo "not built"
