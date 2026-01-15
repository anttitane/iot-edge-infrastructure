# iot-edge-infrastructure
Infrastructure-as-code (IaC) for a single Azure IoT Hub and its supporting resources (resource group).

## Required tools
- Terraform (tested with v1.6+)
- Azure CLI (2.59.0+), with the `azure-iot` extension for device operations
- PowerShell 7+ on Windows or Bash on Linux/macOS for the helper scripts
- Git (to clone and keep backend/tfvars examples in sync)

## Backend setup (Azure Storage)
Remote state lets you use the same repo across multiple machines without clashing local state files. Create the backend once, then point Terraform to it via your `backend-*.hcl` file.

You need an Azure subscription and `az` CLI. Example (adjust names/regions):

```sh
az login
az group create -n tfstate-rg -l westeurope
az storage account create -n <tfstate-storage-account> -g tfstate-rg -l westeurope --sku Standard_LRS --kind StorageV2
az storage container create -n tfstate --account-name <tfstate-storage-account>
```

After the backend exists:
- Copy the backend template and fill in your state storage details: `cp backend-dev.example.hcl backend-dev.hcl` (or create another env-specific file)
- Initialize Terraform with your backend config (use reconfigure when switching backends): `terraform init -reconfigure -backend-config=backend-dev.hcl`

## What you run
- Install IoT CLI extension (used for manual connection-string retrieval, not for Terraform): `az extension add --name azure-iot`
- Copy the example tfvars and customize: `cp environments/dev.tfvars.example environments/dev.tfvars`
- Plan against your env variables: `terraform plan -var-file="environments/dev.tfvars"`
- Apply when ready: `terraform apply -var-file="environments/dev.tfvars"`

## Edge devices (managed outside Terraform)
Device identities are operational objects; keep them out of Terraform state. Use the provided scripts after the IoT Hub exists:

- PowerShell (Windows): `./scripts/create-edge-devices.ps1 -HubName "<hub-name>" -DeviceListPath "devices.txt" [-PrintConnectionStrings] [-PruneNotInList]`
- Bash (Linux/macOS): `./scripts/create-edge-devices.sh -h <hub-name> -f devices.txt [--print-connection-strings] [--prune]`

Create a plain text list of device IDs (one per line, `#` for comments). The scripts will create/update Edge-enabled identities and optionally print connection strings.
Start from the example and edit locally: `cp devices.example.txt devices.txt` (device lists are gitignored by default).
Note: the square brackets in the examples mean the flags are optional—omit the brackets when running (e.g., `-PrintConnectionStrings -PruneNotInList`).
If the PowerShell script reports an azure-iot extension install error, run `az extension add --name azure-iot --yes --debug` manually, then retry.

## Files of interest
- `main.tf`, `modules/iot-hub/`: define the resource group and IoT Hub.
- `environments/dev.tfvars.example`: template for project/environment/region settings.
- `environments/dev.tfvars`: your local copy of tfvars (kept out of git by default).
- `backend-dev.example.hcl`: template for remote state settings. Create your own `backend-*.hcl` locally and keep it out of git.
- `scripts/create-edge-devices.ps1`, `scripts/create-edge-devices.sh`: helper scripts to create Edge device identities via Azure CLI (outside Terraform).
