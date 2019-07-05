# HA_DISI_QEMU

## Objectif

Déployer des VMs sur toutes les machines du 157.159.0.0/16 sur lesquels on peut se ssh avec nos creds LDAP DISI

## Qemu

### Download

[https://data.priv.hackademint.org](https://data.priv.hackademint.org)

### Création d'une VM modèle

Cette commande permet de lancer une machine virtuelle avec l'accélération KVM, une mémoire de 16G de RAM et 2 coeurs. La VM va booter directement sur l'iso. Ici, on a utilisé
une netinstall (il faut adapter le nom bien sûr !). Les options `-nic` permettent d'avoir internet : QEMU va créer un sous-réseau et un serveur DHCP, ainsi il n'y a besoin de 
rien configurer pour l'installation. Cependant, on modifiera cette option après pour configurer la machine en IP statique. Pour finir, l'option `-vga cirrus` permet
d'avoir une fenêtre graphique. On modifiera ceci aussi après pour avoir une sortie en console dans un `screen`.

```bash
#! /bin/sh
qemu-system-x86_64 \
    -cpu host \
    -enable-kvm \
    -m 16384 -smp 2 \
    -boot d \
    -drive file=base.qcow2,if=ide,index=0,media=disk,format=qcow2 \
    -drive file=debian-9.9.0-amd64-netinst.iso,index=1,media=cdrom \
    -net nic \
    -net user \
    -vga cirrus -balloon virtio \
```

### Premier démarrage de la VM modèle après l'installation

Voici la commande à éxecuter pour le **PREMIER démarrage**. C'est une petite variante de la commande ci-dessus. Cela permet de voir les différentes options de QEMU. On a ajouté une option commençant par `-object rng-random` qui permettrait d'accélerer le démarrage de Debian en fournissant à la VM le générateur aléatoire de nombre de l'hôte (et donc pas d'émulation). On connecte aussi la VM sur le `virbr0` qui est le bridge par défaut mis en place sur les machines de la DISI. On supprime le disque d'installation. Attention à bien se connecter sur la machine de la DISI avec le X-forwarding!

```bash
#! /bin/sh
qemu-system-x86_64 \
    -cpu host \
    -machine type=q35,accel=kvm \
    -m 8192 -smp 2 \
    -object rng-random,id=rng0,filename=/dev/urandom -device virtio-rng-pci,rng=rng0 \
    -net nic -net bridge,br=virbr0  \
    -drive file=base.qcow2,if=ide,index=0,media=disk,format=qcow2 \
    -balloon virtio \
    -vga cirrus \
    #-nographic\
```

Une fois connectée, on effectue les manipulations suivantes :
* on passe en root : `su`
* on modifie le fichier `/etc/network/interfaces` pour renommer l'interface réseau (ce n'est pas la même qu'à l'installation, le nom a changé !) et on met la VM en IP statique. Le bridge est en `192.168.122.0/24`. Par convention, on prendre `192.168.122.2. **On n'ajoute PAS encore le vmbr120** (on le fera après).
* on modifie `/etc/default/grub`pour activer la redirection console (et arrêter de faire un X-forwarding). Pour cela, il suffit de modifier la ligne avec `GRUB_CMDLINE_LINUX_DEFAULT` en y ajoutant `console=ttyS0 console=tty1`. Le premier `console` permet d'activer la sortie série. La seconde permet d'avoir la sortie de la VM dans la fenêtre qemu normalement. 
* installation d'openvpn avec les identifiants générés sur le `vpn-interco`
* on ajoute nos outils favoris (`vim`, `netcat`, ...)
* [ On installe Proxmox en suivant ce tuto](https://pve.proxmox.com/wiki/Install_Proxmox_VE_on_Debian_Stretch) 
* on éteint la VM


### Création des VMs à partir du modèle de base 

Nous allons créer des images disques basés sur l'image modèle. Nous utilisons la possibilité de faire des snapshots de l'image de base. Ainsi, nous allons créer une nouvelle image disque qui ne contiendra uniquement les différences par rapport à l'image de base. En d'autres termes, nous allons créer des images `vmX.qcow2` basé sur l'image `base.qcow2`. Les images `vmX.qcow2` ne feront que quelques Mo et contiendront uniquement les modifications/différences par rapport à l'image de base. Il existe des commandes pour faire un "merge" des différences avec l'image de base, mais ce n'est pas le but de la manoeuvre aujourd'hui :-)

Création de l'image `vmX.qcow2` basé sur `base.qcow2` :

```bash
qemu-img create -f qcow2 -b base.qcow2 vmX.qcow2
```

où `X` est un nombre qui permet d'identifier la VM.

Voici la nouvelle commande QEMU. **Il faut adapter la RAM, le nombre de coeurs et le nom du disque de la VM**. Nous demandons à QEMU de démarrer sur l'image dérivée et non sur l'image de base.

```bash
#! /bin/sh
qemu-system-x86_64 \
    -cpu host \
    -machine type=q35,accel=kvm \
    -m RAM -smp NB_COEUR \
    -object rng-random,id=rng0,filename=/dev/urandom -device virtio-rng-pci,rng=rng0 \
    -net nic -net bridge,br=virbr0  \
    -drive file=vmX.qcow2,if=ide,index=0,media=disk,format=qcow2 \
    -balloon virtio \
    -nographic\
```
### Ajout de la VM au cluster de Proxmox

Une fois la VM démarrée, voici les instructions à exécuter pour ajouter notre nouveau noeud proxmox au cluster.
* on passe en root : `su`
* modification d'`/etc/network/interfaces` pour ajouter le `vmbr120` (voir le dossier interfaces pour un exemple, attention au choix de l'IP pour éviter tout conflit !)
* `ifup vmbr120`
* modification `/etc/hostname` : il faut changer le nom de la VM
* modification `/etc/hosts` : mettre à jour le nom de la VM
* modification `/etc/mailname` : mettre à jour le nom de la VM
* modification `/etc/postfix/main.cf` : mettre à jour le nom de la VM (variable `myhostname=`)
* modifier les noms des dossier/fichiers suivants (à faire pour les dossiers/fichiers nommés `node` **et** `storage` : `/var/lib/rrdcached/db/pve2-{node,storage}/old-hostname` en `/var/lib/rrdcached/db/pve2-{node,storage}/new-hostname`
* reboot de la VM (pour appliquer tous les changements précédents)
* une fois redémarré, on passe en root : `su`
* on ajoute la VM au cluster : `pvecm add X.X.X.X` où `X.X.X.X` correspond à une IP d'un serveur déjà dans le cluster. Dès lors, on nous demande le mot de passe root de ce serveur. Une fois entré, le serveur est ajouté au cluster :D
 
Au final, `vmX.qcow2` fera environ 25Mo.

### Déploiement de containers sur les nouveaux noeuds

## Nouveau stockage
Pour éviter de consommer de la place inutilement sur les PCs de la DISI, ainsi que pour faire de la HA (High Avaibility), nous utilisons un Network File System (NFS).
Concrètement, il s'agit d'un protcole permettant de monter un dossier à distance. Ce protocole marche aussi bien avec Linux que Windows.

Notre NFS se trouve sur Cody-Maverick (serveur de dév.). Le dossier NFS monté en réseau se trouve à la racine de cody : `/nfs`. Ils possèdent deux disques durs de 750Go en Raid 1, ce qui assure un minimum la pérennité des disques des machines virtuelles.
Ainsi, lorsque nous souhaitons utiliser un container sur une machine de la DISI et/ou faire de la HA, nous créons ce container comme nous le ferions habituellement et nous spécifions
d'enregistrer le disque du container sur le NFS au lieu d'un stockage en local.

## High Avaibility

# Introduction

Nous utilisons des machines des salles B et D pour étendre notre cluster. Ce sont des machines de TPs qui peuvent être utilisés par d'autres étudiants. Elles peuvent donc s'éteindre à n'importe quelle moment de la journée. En cas de coupure d'une machine de TP qui était dans notre cluster, pour éviter de perdre notre container jusqu'à un nouvel allumage de cette dernière,
aucun disque de container n'est sauvegardé sur les machines de la DISI. Ainsi, on ne risque pas de perdre nos données. Cependant, on aimerait bien redéployer le container qui a été sauvagement coupé. Nous utilisons alors une fonctionnalité de Proxmox qui est la **High Avaibility**.

Prenons un exemple pour le cas d'un container sous HA : on dit au cluster Proxmox de surveiller l'état de container. Si pour une raison X ou Y le noeud où se trouve le container meurt tragiquement dans d'atroces souffrances, le cluster va remarquer que le container sur le noeud n'est donc plus fonctionnel. Il s'écoule généralement un petit temps avant que le cluster "prenne une décision" (en effet, peut être une petite déconnexion ? Il vaut mieux attendre et ça va revenir tout seul... ou pas :-( ). Le cluster peut alors décider de migrer le container sur un autre noeud et après de rallumer le container. Comment est-ce possible si le noeud où le container était se trouve éteint ?

Au préalable, on a spécifié à Proxmox de surveiller ce container. On a aussi spécifié où est-ce qu'il fallait redéployer le container en cas de défaillance (on peut spécifier une préférence selon les noeuds aussi). Les autres noeuds contiennent une copie du fichier de configuration du container, et comme le disque se trouve sur Cody (qui tourne toujours), nous n'avons donc pas de problème !

# Mise en pratique et documentation
En pratique, c'est un petit peu plus compliqué. Lorsque nous avons parlé du fait que le "cluster prend une décision", on parle de **quorum**. Proxmox utilise `Corosync` pour faire de la haute disponibilité. Si jamais il y a un problème, il vaut mieux chercher du côté de `Corosync`! Si jamais un container est bloqué pendant une migration, il faut regarder si Corosync ou d'autres services liés à la HA sont bien lancés.

Pour le coup, l'interface Web permet de faire exactement la même chose qu'en ligne de commande.

La haute disponibilité n'est pas compliquée à comprendre en soi. Cepedant, il y a toute une théorie derrière (c'est un métier). 
Voici de la littérature concernant [la haute disponibilité sur Proxmox](https://pve.proxmox.com/wiki/High_Availability).

## Tutorials

- [ansible-ssh-setup-playbook](https://www.hashbangcode.com/article/ansible-ssh-setup-playbook)
- [ansible-pipeline](https://stackoverflow.com/questions/48385059/does-ansible-create-a-separate-ssh-connection-for-each-tasks-inside-a-playbook)
