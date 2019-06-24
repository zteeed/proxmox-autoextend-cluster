Il s'agit de la configuration du VPN pour :
* le serveur (`server.conf`)
* les clients (`client.conf`)

OpenVPN est configuré pour opérer au niveau des couches 2 et 3, ce qui permet d'avoir le cluster fonctionnel.

# Visionnage des logs

Les logs sur le `vpn-interco` sont disponibles dans `/var/log/openvpn.log` (voir dans le fichier de config `server.conf`)

# Génération d'une clé pour les clients

L'image de base contient des identifiants VPN. Si jamais il y a besoin de refaire des identifiants, voici la méthode :

```bash
root@vpn-interco:~# cd /etc/openvpn/easy-rsa/
root@vpn-interco:/etc/openvpn/easy-rsa# ls
build-ca     build-key-pass    build-req-pass  list-crl           openssl.cnf  vars
build-dh     build-key-pkcs12  clean-all       openssl-0.9.6.cnf  pkitool      whichopensslcnf
build-inter  build-key-server  inherit-inter   openssl-0.9.8.cnf  revoke-full
build-key    build-req         keys            openssl-1.0.0.cnf  sign-req
root@vpn-interco:/etc/openvpn/easy-rsa# source vars 
NOTE: If you run ./clean-all, I will be doing a rm -rf on /etc/openvpn/easy-rsa/keys
root@vpn-interco:/etc/openvpn/easy-rsa# ./build-key client
```

Il suffit alors d'exporter les identifiants générés sur la machine cliente. **Mettez les dans le dossier clientconf s'il vous plaît avec un dossier pour le client généré !**. Vous devez exporter les fichiers suivants (exemple avec les identifiants de moog) :
```bash
root@vpn-interco:/etc/openvpn/clientconf/moog# ls
ca.crt  client.conf  moog.crt  moog.key  moog.zip  ta.key
```

`moog.zip` contient tous les autres fichiers (plus facile pour l'export).
