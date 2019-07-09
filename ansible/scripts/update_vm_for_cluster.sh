#!/bin/sh

# stop exec if new_hostame and new_ip arguments are not set
if [ $# -ne 2 ]; then
	echo "Usage: $0 <hostname> <ipv4 address>"
        exit 1
fi

# catch args in vars 
new_hostname=$1
new_ip=$2
num="$(echo $new_hostname | cut -d'-' -f1 | tr -dc '0-9')"
path=$(dirname "${BASH_SOURCE[0]}")

# update ssh + sshd config file + restart ssh service on the VM
sshpass -p hackademint scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "$path/update_ssh_config_vm.sh" moog@192.168.122.2:~/
sshpass -p hackademint ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no moog@192.168.122.2 << EOF
chmod 755 ./update_ssh_config_vm.sh
(sleep 1; echo hackademint) | socat - EXEC:"su -c ./update_ssh_config_vm.sh",pty
EOF

# create config file for the update script
cat << EOF > "$path/config$num.txt"
$new_hostname
$new_ip
EOF

# upload config file + update script in the VM
sshpass -p hackademint scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "$path/config$num.txt" root@192.168.122.2:~/
sshpass -p hackademint scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "$path/update_config_vm.sh" root@192.168.122.2:~/
# exec update script in the VM
sshpass -p hackademint ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.2 << EOF
chmod 755 ./update_config_vm.sh
./update_config_vm.sh
EOF

# wait VM to reboot
echo "$new_hostname is rebooting... please wait... [ 10 seconds ]"
sleep 10 

# create and upload script in the VM to add it in the cluster + going back to old version of ssh and sshd config
cat << EOF > $path/pvecm_script.sh
#!/bin/sh
pvecm add --use_ssh=true 172.16.0.1
sleep 5
sed -i 's|    StrictHostKeyChecking no|#   StrictHostKeyChecking ask|g' /etc/ssh/ssh_config
sed -i "s|PermitRootLogin yes|#PermitRootLogin prohibit-password|g" /etc/ssh/sshd_config
/etc/init.d/ssh restart
EOF
sshpass -p hackademint scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no "$path/pvecm_script.sh" root@192.168.122.2:~/

# execute it
sshpass -p hackademint ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@192.168.122.2 << EOF
chmod 755 ./pvecm_script.sh
./pvecm_script.sh
EOF

# now our should be in the cluster, well done :)
