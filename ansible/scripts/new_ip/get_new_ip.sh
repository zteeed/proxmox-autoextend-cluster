#!/bin/bash
# n=$(pvecm status | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | tail -n 1 | cut -d'.' -f4)
path=$(dirname "${BASH_SOURCE[0]}")
file="$path/num.txt"
if [ ! -f $file ]; then
  $path/reset.sh
fi
n=$(head -n 1 $file)
echo "172.16.0.$n"
echo "$(( $n + 1))" > $file
