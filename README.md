This repo contains code to deploy a [Slurm](https://slurm.schedmd.com/) cluster on [Azure](https://azure.microsoft.com/en-us/).

# Step 1: Build a new cluster-bootstrap zip:
During the provisioning process of the head node VM, the VM will download a bootrap zip, extract it, and execute the cluster-bootstrap.sh script from within it. The script sets up the head node, mostly by running Ansible playbooks.

This cluster-bootstrap zip must be created and made available for the VM to download prior to launching a cluster.

  1. Create the zip:
```
zip cluster-bootstrap.zip \
  scripts/cluster-bootstrap.sh \
  ansible/cluster-headvm-config.yaml \
  ansible/cluster-computevm-config.yaml
```
  2. Upload the zip to an Azure Storage Account.
  3. Optional: Create a SAS key to access the file.
  4. Add that URL to the variable clusterBootrapZipURI in arm/clusterDeployment/template.json.

# Step 2: Build a new VM image
  1. Install the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/)
  2. Install [Hashicorp Packer](https://www.packer.io/)
  3. `cd packer/`
  4. Edit debian-slurm-azure.pkr.hcl as needed.
  5. `packer init debian-slurm-azure.pkr.hcl`
  6. `packer build debian-slurm-azure.pkr.hcl`
  7. Set the variable imgRefComputeGallery in arm/clusterDeployment/template.json to where the new image version is located.
  8. Set the parameter virtualMachineSourceIsMarketplace in arm/clusterDeployment/parameters.json to false.

# Step 3: Deploy a new cluster:
  1. Install the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/)
  2. Create a VM image and cluster-bootstrap zip.
  3. `cd arm/clusterDeployment`
  4. Edit parameters.json as needed.
  5. `az group create --location "East US 2" --name "TestRG"`
  6. `az deployment group create --resource-group 'TestRG' --template-file template.json --parameters '@parameters.json'`

The template will have the head node VM's public DNS name in the "outputs" section of the resulting JSON output. You can SSH to it and run `sinfo` to see your new cluster.

# Remove the cluster:
This will remove all cluster node VMs, their storage, all data, and all networking that was deployed with the cluster.

  1. `az group delete --name "TestRG"`

# Troubleshooting
If the cluster fails to deploy, carefully read the error Azure returns for the deployment.
If the cluster deploys but fails to start:
  1. Log into the cluster head node VM to troubleshoot:
      1. SSH to the head node
      2. Become root: `sudo -i`
  2. Review the the bootstrap script logs:
      1. Go to the Azure agent's download direcotry: `cd /var/lib/waagent/custom-script/download/0`
      2. Examine logs
      3. Optional: re-run the bootstrap: `bash ./scripts/cluster-bootstrap.sh`
  3. Verify that Slurm services are running on the head node:
      1. `systemctl munge status`
      2. `systemctl status mariadb`
      3. `systemctl status slurmdbd`
      4. `systemctl status lrumctld`
  4. Check the Slurm logs in /var/log or the system journal e.g. `journalctl -u mariadb`.
  5. SSH to a compute node from the head node VM:
      1. `ssh -i /home/deploy_user/.ssh/id_rsa deploy_user@test-cluster-computevm0-5556odnrx44oa`
      2. Become root: `sudo -i`
      3. Verify munge is running `systemctl status munge`
      4. Verify Slurm is running `systemctl status slurmd`
      5. Check the Slurm log in /var/log.

# Making changes to this code:

## Run arm-ttk
  1. Clone the [ARM Template Toolkit](https://github.com/Azure/arm-ttk)
  2. Install [PowerShell](https://docs.microsoft.com/en-us/powershell/)
  3. `pwsh`
  4. `cd arm-ttk`
  5. `Test-AzTemplate -TemplatePath ../../azure-slurm/arm/clusterDeployment/template.json`

## Run the Ansible linter
  1. Install [Ansible Lint](https://ansible-lint.readthedocs.io/en/latest/)
  2. `ansible-lint lint ansible/*.yaml`

## Run Packer validate
  1. Install [Hashicorp Packer](https://www.packer.io/)
  2. `cd packer`
  3. `packer validate debian-slurm-azure.pkr.hcl`