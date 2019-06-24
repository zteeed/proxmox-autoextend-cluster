#!/bin/sh
ansible-playbook deploy.yml -i ip.txt --private-key ./keys/id_rsa 
