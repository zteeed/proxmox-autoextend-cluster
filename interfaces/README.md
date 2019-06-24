* `example_interfaces` est un modèle du fichier `/etc/network/interfaces` sur la machine cliente
* `interfaces_vpn_interco` est un modèle du fichier `/etc/network/interfaces` sur le serveur `vpn-interco`

Pour rappel, voici la configuration de la VM `vpn-interco` qui se trouve actuellement (24.06.2019) sur lovni :

```
#Tunnel couche 2 en mode server
#A utiliser pour connecter les proxmox des salles B et D.
#
#Besoin d'un certificat par user (et non d'un secret comme en mode p2p)
agent: 1
bootdisk: scsi0
cores: 1
ide2: local:iso/debian-9.9.0-amd64-netinst.iso,media=cdrom
memory: 512
name: vpn-interco.hackademint.org
net0: virtio=1A:59:7F:D4:35:AF,bridge=vmbr10
net1: virtio=F2:9D:82:75:E7:2C,bridge=vmbr120
net2: virtio=6E:C0:38:47:78:9B,bridge=vmbr0
net3: virtio=F6:03:0A:FD:E5:07,bridge=vmbr0
numa: 0
onboot: 1
ostype: l26
scsi0: stockage:113/vm-113-disk-0.qcow2,size=32G
scsihw: virtio-scsi-pci
smbios1: uuid=a04862f3-75ec-4144-9530-ed52adfd4cfc
sockets: 1
vmgenid: 79d8fc3e-a5c9-402b-ad7e-775839f76711
```  
