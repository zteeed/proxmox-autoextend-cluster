#!/bin/sh
ansible-playbook test.yml -i ip.txt --private-key ../keys/id_rsa 
