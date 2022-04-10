#!/bin/bash

# Bootstrap the cluster by running the Ansible playbooks and performing other work to bring
# the cluster up.

cat clusterParametersSingleQuotes.json | tr "'" '"' > clusterParameters.json

ansible-playbook -i 127.0.0.1, --limit 127.0.0.1 --connection=local ./ansible/cluster-headvm-config.yaml

sleep 5

ansible-playbook -i ./ansible/compute_hosts ./ansible/cluster-computevm-config.yaml