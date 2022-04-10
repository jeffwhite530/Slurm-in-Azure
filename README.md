This repo contains code to deploy a Slurm cluster on Azure.

# Deploying a new cluster:
  - `cd headnodeVM`
  - `az group create --location "East US 2" --name "TestRG"`
  - `az deployment group create --resource-group 'TestRG' --template-file template.json --parameters '@parameters.json'`

# Removing the cluster:
  - `az group delete --name "TestRG"`

# Building a new bootstrap zip:
```
zip cluster-bootstrap.zip \
  scripts/cluster-bootstrap.sh \
  ansible/cluster-headvm-config.yaml \
  ansible/cluster-computevm-config.yaml
```

# Manually install Ansible:
```
apt update && apt install -y gnupg2
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
echo 'deb http://ppa.launchpad.net/ansible/ansible/ubuntu focal main' > /etc/apt/sources.list.d/ansible.list
apt update && apt install -y ansible

ansible-playbook -i 127.0.0.1, --limit 127.0.0.1 --connection=local /tmp/slurm-image.yaml
```
