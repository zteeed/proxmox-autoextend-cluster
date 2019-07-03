#!/bin/sh

if [ $# -ne 2 ]; then
        exit 1
fi
new_hostname=$1
new_ip=$2
sshpass -p hackademint scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ./update_config_vm.sh moog@192.168.122.2:~
sshpass -p hackademint ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no moog@192.168.122.2 << EOF
(sleep 1; echo hackademint) | socat - EXEC:'su -c update_config_vm.sh $new_hostname $new_ip',pty
EOF
