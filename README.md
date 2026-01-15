# iot-edge-infrastructure
Infrastructure-as-code (IaC) for a single Azure IoT Hub and its supporting resources (resource group).

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
- Initialize Terraform with your backend config: `terraform init -backend-config=backend-dev.hcl`

## What you run
- Install IoT CLI extension (used for manual connection-string retrieval, not for Terraform): `az extension add --name azure-iot`
- Copy the example tfvars and customize: `cp environments/dev.tfvars.example environments/dev.tfvars`
- Plan against your env variables: `terraform plan -var-file="environments/dev.tfvars"`
- Apply when ready: `terraform apply -var-file="environments/dev.tfvars"`

## Files of interest
- `main.tf`, `modules/iot-hub/`: define the resource group and IoT Hub.
- `environments/dev.tfvars.example`: template for project/environment/region settings.
- `environments/dev.tfvars`: your local copy of tfvars (kept out of git by default).
- `backend-dev.example.hcl`: template for remote state settings. Create your own `backend-*.hcl` locally and keep it out of git.
