#!/bin/sh
ansible-playbook shutdown.yml -i ip.txt --private-key ./keys/id_rsa 
