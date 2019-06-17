function main() {
  user="duboc_au"
  gateway="ssh.imtbs-tsp.eu"
  for i in {2..254}; do
      result=$(dig -x 157.159.15.$i +nocomments +noquestion +noauthority +noadditional +nostats | grep PTR | awk '{print $5}')
      if [ -z $result ]; then continue; fi # if result is None
      hostname=$(ssh -i $PWD/keys/id_rsa -o BatchMode=yes -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ConnectTimeout=2 $user@157.159.15.$i hostname)
      if [ -z $hostname ]; then continue; fi # if hostname is None
      echo "157.159.15.$i --> $hostname --> $result"
      ram=$(ssh -i $PWD/keys/id_rsa -o BatchMode=yes -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ConnectTimeout=2 $user@157.159.15.$i free | tail -n 2 | head -n 1 | awk '{print $2}')
      cpu=$(ssh -i $PWD/keys/id_rsa -o BatchMode=yes -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ConnectTimeout=2 $user@157.159.15.$i echo $(( $(lscpu | grep Proces | awk '{print $2}') * $(lscpu | grep Thread | cut -d':' -f2 | awk '{print $1}') )) )
  done
}

function select_ip() {
  #all_ips=$(curl -s https://nmap2.priv.hackademint.org/ip | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}")
  all_ips=$(pvecm status | grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}")
  for i  in {90..254}; do
    t=1
    for ip in $all_ips; do
      if  [ "172.16.0.$i" == "$ip" ]; then
        t=0
      fi
    done
    if [ $t -eq 1 ]; then
      result="172.16.0.$i"
      return
    fi
  done
  result="error"
}
