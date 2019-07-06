#!/bin/sh

# this script needs to be run as root
#if [ $EUID -ne 0 ]; then
#        exit 1
#fi

# bypass the host checking on the node that will add this vm to the cluster via pvecm
sed -i 's|#   StrictHostKeyChecking ask|    StrictHostKeyChecking no|g' /etc/ssh/ssh_config

# update ip for vmbr120 (bridge for HackademINT VLAN)
new_ip=$(cat ./config* | tail -n 1)
cat << EOF >> /etc/network/interfaces

# HackademINT VLAN
auto vmbr120
iface vmbr120 inet static
        address $new_ip/24
        gateway 172.16.0.1
        bridge_ports tap0.120
        bridge_stp off
        bridge_fd 0
EOF

# raise up the interface
ifup vmbr120

# update some system vars
new_hostname=$(cat ./config* | head -n 1)
echo $new_hostname > /etc/hostname
hostname --file /etc/hostname
cat << EOF > /etc/hosts
127.0.0.1       localhost
$new_ip     $new_hostname.hackademint.org  $new_hostname

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF
sed -i "s|proxmox-vm|$new_hostname|g" /etc/mailname /etc/postfix/main.cf
mv /var/lib/rrdcached/db/pve2-node/{proxmox-vm,$new_hostname}
mv /var/lib/rrdcached/db/pve2-storage/{proxmox-vm,$new_hostname}

# update sshd config to permit root login (pvecm add issue)
sed -i "s|#PermitRootLogin prohibit-password|PermitRootLogin yes|g" /etc/ssh/sshd_config

# yes my lord ! More work ? Alright...
reboot
