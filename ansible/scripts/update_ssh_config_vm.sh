#!/bin/sh

# bypass the host checking on the node that will add this vm to the cluster via pvecm
sed -i 's|#   StrictHostKeyChecking ask|    StrictHostKeyChecking no|g' /etc/ssh/ssh_config

# update sshd config to permit root login (pvecm add issue)
sed -i "s|#PermitRootLogin prohibit-password|PermitRootLogin yes|g" /etc/ssh/sshd_config

# restart ssh service
/etc/init.d/ssh restart
