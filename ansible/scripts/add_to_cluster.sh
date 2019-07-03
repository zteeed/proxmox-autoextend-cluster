#!/bin/sh
sshpass -p hackademint ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no moog@192.168.122.2 << EOF
(sleep 1; echo hackademint) | socat - EXEC:'su -c pvecm add --use_ssh=true 172.16.0.1',pty
EOF
