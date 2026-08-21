#!/bin/bash
H=/mnt/c/Hofos/build/histic-new
printf 'int main(){ return 42; }\n' > /dev/shm/h.c
"$H" /dev/shm/h.c -out /dev/shm/h.elf 2>&1 | tail -3
chmod +x /dev/shm/h.elf 2>/dev/null
if [ -x /dev/shm/h.elf ]; then /dev/shm/h.elf; echo "  histic program exit=$? (want 42)"; else echo "  no elf produced"; fi
