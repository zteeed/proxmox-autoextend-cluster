#!/bin/sh

# stop exec if new_hostame and new_ip arguments are not set
if [ $# -ne 2 ]; then
	echo "Usage: $0 <hostname> <ipv4 address>"
        exit 1
fi

# catch args in vars 
new_hostname=$1
new_ip=$2
num="$(echo $new_hostname | tr -dc '0-9')"

# create config file for the update script
cat << EOF > "./config$num.txt"
$new_hostname
$new_ip
EOF

# upload config file + update script in the VM
sshpass -p hackademint scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "./config$num.txt" moog@192.168.122.2:~/
sshpass -p hackademint scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no update_config_vm.sh moog@192.168.122.2:~/
# exec update script in the VM
sshpass -p hackademint ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no moog@192.168.122.2 << EOF
chmod 755 ./update_config_vm.sh
(sleep 1; echo hackademint) | socat - EXEC:"su -c ./update_config_vm.sh",pty
EOF

# wait VM to reboot
echo "$new_hostname is rebooting... please wait... [ 10 seconds ]"
sleep 10 

# create and upload script in the VM to add it in the cluster
cat << EOF > ./pvecm_script.sh
#!/bin/sh
pvecm add --use_ssh=true 172.16.0.1
EOF
sshpass -p hackademint scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "./pvecm_script.sh" moog@192.168.122.2:~/

# execute it
sshpass -p hackademint ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no moog@192.168.122.2 << EOF
chmod 755 ./pvecm_script.sh
(sleep 1; echo hackademint) | socat - EXEC:"su -c ./pvecm_script.sh",pty
EOF

# now our should be in the cluster, well done :)
