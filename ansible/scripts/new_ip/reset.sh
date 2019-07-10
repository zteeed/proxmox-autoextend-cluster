#!/bin/bash
path=$(dirname "${BASH_SOURCE[0]}")
num=$(pvecm status | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | tail -n 1 | cut -d'.' -f4)
num=$(( num + 1))
file="$path/num.txt"
echo $num > $file
