#!/bin/bash
# n=$(pvecm status | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | tail -n 1 | cut -d'.' -f4)
if [ ! -f "./num.txt" ]; then
  ./reset.sh
fi
n=$(head -n 1 ./num.txt)
echo "172.16.0.$n"
echo "$(( $n + 1))" > ./num.txt
