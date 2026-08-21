#!/bin/bash
# Smoke-test the HDC-produced self-contained Hofos ELF.
E=/dev/shm/hofos.elf
chmod +x "$E" 2>/dev/null
echo "=== file ==="; file "$E" 2>/dev/null | head -1
echo "=== run with no args (entry=start, argv not wired -> expect usage/err) ==="
timeout 15 "$E"; echo "  exit=$?"
echo "=== run with --help ==="
timeout 15 "$E" --help; echo "  exit=$?"
echo "=== compile a tiny BCPL program? (probably needs argv, may no-op) ==="
printf 'GET "libhdr"\nLET start() = 42\n' > /dev/shm/t.b
timeout 15 "$E" /dev/shm/t.b -o /dev/shm/t.elf 2>&1 | head -5; echo "  exit=$?"
ls -l /dev/shm/t.elf 2>/dev/null && echo "  (t.elf produced)" || echo "  (no t.elf)"
