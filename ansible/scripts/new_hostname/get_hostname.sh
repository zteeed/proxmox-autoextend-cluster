#!/bin/bash

if [ $# -ne 1 ]; then
        echo "Usage: $0 <ipv4 address>"
        exit 1
fi

ip="$1"
dig -x "$ip" +nocomments +noquestion +noauthority +noadditional +nostats | grep PTR | awk '{print $5}' | cut -d'.' -f1
