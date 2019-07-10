#!/bin/sh
ansible-playbook adding_nodes_to_cluster.yml -i ip.txt --private-key ./keys/id_rsa 
