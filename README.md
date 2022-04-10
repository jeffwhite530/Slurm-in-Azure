This repo contains code to deploy a Slurm cluster on Azure.

# Deploying a new cluster:
  - Install the Azure CLI
  - `cd arm/clusterDeployment`
  - Edit parameters.json as needed.
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
Then upload the zip to the Storage Account, create a SAS key to access it, and add that URL to the variable clusterBootrapZipURI in arm/clusterDeployment/template.json.

# Running arm-ttk
  - Clone https://github.com/Azure/arm-ttk
  - Install PowerShell
  - `pwsh`
  - `cd arm-ttk`
  - `Test-AzTemplate -TemplatePath ../../azure-slurm/arm/clusterDeployment/template.json`

# Running the Ansible linter
  - `ansible-lint lint ansible/*.yaml`