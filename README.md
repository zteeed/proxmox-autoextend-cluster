# HA_DISI_QEMU

## Objectif

Déployer des VMs sur toutes les machines du 157.159.0.0/16 sur lesquels on peut se ssh avec nos creds LDAP DISI

## Qemu

### Download

[https://data.priv.hackademint.org](https://data.priv.hackademint.org)

### Créer des VMs

```bash
#! /bin/sh
qemu-system-x86_64 \
    -cpu host \
    -enable-kvm \
    -m 16384 -smp 2 \
    -boot d \
    -drive file=vm1.qcow2,if=ide,index=0,media=disk,format=qcow2 \
    -drive file=debian-9.9.0-amd64-netinst.iso,index=1,media=cdrom \
    -net nic \
           -net user \
    -vga cirrus -balloon virtio \
```

### Démarrer la VM

```bash
#! /bin/sh
qemu-system-x86_64 \
    -cpu host \
    -machine type=q35,accel=kvm \
    -m 8192 -smp 2 \
    -object rng-random,id=rng0,filename=/dev/urandom -device virtio-rng-pci,rng=rng0 \
    -net nic -net bridge,br=virbr0  \
    -drive file=vm1.qcow2,if=ide,index=0,media=disk,format=qcow2 \
    -balloon virtio \
    -nographic\
    #-vga cirrus \
```
