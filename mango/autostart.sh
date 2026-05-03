#!/bin/bash

swaync >/dev/null 2>&1 &
awww-daemon >/dev/null 2>&1 &
qs >/dev/null 2>&1 &
syncthingtray-qt6 --wait >/dev/null 2>&1 &

for i in {1..9}; do
  mmsg -t $i
  mmsg -l "T"
done
mmsg -t 1
