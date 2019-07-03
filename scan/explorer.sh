function main() {
  user="duboc_au"
  gateway="ssh.imtbs-tsp.eu"
  echo '' > ./result.txt
  for i in {2..254}; do
      result=$(dig -x 157.159.15.$i +nocomments +noquestion +noauthority +noadditional +nostats | grep PTR | awk '{print $5}')
      if [ -z $result ]; then continue; fi # if result is None
      hostname=$(ssh -i $PWD/keys/id_rsa -o BatchMode=yes -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ConnectTimeout=2 $user@157.159.15.$i hostname)
      if [ -z $hostname ]; then continue; fi # if hostname is None
      echo "157.159.15.$i --> $hostname --> $result" >> ./result.txt
  done
}

main
