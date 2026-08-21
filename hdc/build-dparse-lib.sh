#!/bin/bash
# One-time: precompile all of libdparse into a static lib so subsequent HDC
# rebuilds only recompile app.d/codegen.d/hofos.d (~10s instead of ~120s).
LDC=/mnt/c/Hofos/ldc2-1.42.0-linux-x86_64/bin/ldc2
DP=/mnt/c/Users/leos_/AppData/Local/Packages/Claude_pzs8sxrjxfjjc/LocalCache/Local/dub/packages/libdparse/0.25.1/libdparse/src
OUT=/mnt/c/Hofos/hdc/libdparse.a
s=$(date +%s)
"$LDC" -lib -oq -of="$OUT" -I="$DP" -O2 \
  $(find "$DP/dparse" "$DP/std" "$DP/stdx" -name '*.d' 2>/dev/null) 2>&1 | head -20
echo "lib rc=? $(( $(date +%s)-s ))s"
ls -la "$OUT" 2>/dev/null && echo "DPARSE LIB BUILT" || echo "no lib"
