#!/bin/bash
# One full cycle: rebuild libhofos (new runtime leaves + heap), relink HDC, run on hofos.d.
echo "########## STAGE 1: rebuild libhofos ##########"
bash /mnt/c/Hofos/hdc/rebuild-libhofos.sh
[ -s /mnt/c/Hofos/build/libhofos-native.o ] || { echo "STAGE1 FAILED"; exit 1; }
echo
echo "########## STAGE 2: relink HDC + compile hofos.d ##########"
bash /mnt/c/Hofos/hdc/run-on-hofos.sh
