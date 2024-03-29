#!/bin/sh

# update ip for vmbr120 (bridge for HackademINT VLAN)
new_ip=$(cat ./config* | tail -n 1)
cat << EOF >> /etc/network/interfaces

auto vmbr120
iface vmbr120 inet static
        address $new_ip/24
        gateway 172.16.0.1
        bridge_ports tap0.120
        bridge_stp off
        bridge_fd 0
# HackademINT VLAN : 172.16.0.0/24
EOF

# raise up the interface
#ifup vmbr120

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
mv /var/lib/rrdcached/db/pve2-node/proxmox-vm /var/lib/rrdcached/db/pve2-node/$new_hostname
mv /var/lib/rrdcached/db/pve2-storage/proxmox-vm /var/lib/rrdcached/db/pve2-storage/$new_hostname

# yes my lord ! More work ? Alright...
reboot
