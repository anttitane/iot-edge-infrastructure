# iot-edge-infrastructure
Infrastructure-as-code (IaC) for a single Azure IoT Hub and its supporting resources (resource group).

Optional Cosmos DB (free tier by default) with IoT Hub routing directly to a Cosmos SQL container.

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

Cosmos settings (defaults provided; only `cosmos_account_name` is required):
- `cosmos_account_name` (must be globally unique)
- Optional: `cosmos_sql_db_name`, `cosmos_sql_container_name`, `cosmos_partition_key_path`, `cosmos_container_throughput`, `cosmos_default_ttl_seconds`, `cosmos_consistency_level`, `cosmos_enable_free_tier`, `enable_cosmos_routing`, `cosmos_route_condition`, `cosmos_endpoint_name`, `cosmos_route_name`

Free-tier guardrails (Cosmos and IoT Hub):
- Cosmos free tier: enabled by default (`cosmos_enable_free_tier = true`) and throughput validation caps `cosmos_container_throughput` to 1–1000 RU/s. Set `cosmos_default_ttl_seconds` (e.g., 604800 for 7 days) to auto-expire old documents and keep RU/storage low.
- Partition key path must use a valid JSON property path with no hyphens; use underscores instead (e.g., `/iothub_connection_device_id`).
- Only one Cosmos free-tier account is allowed per subscription. If another exists, Azure will create a paid account even with `cosmos_enable_free_tier = true`.
- IoT Hub is set to SKU F1 (free). Stay under the ~8k messages/day limit or upgrade SKUs if you outgrow it.

## Edge devices (managed outside Terraform)
Device identities are operational objects; keep them out of Terraform state. Use the provided scripts after the IoT Hub exists:

- PowerShell (Windows): `./scripts/create-edge-devices.ps1 -HubName "<hub-name>" -DeviceListPath "devices.txt" [-PrintConnectionStrings] [-PruneNotInList]`
- Bash (Linux/macOS): `./scripts/create-edge-devices.sh -h <hub-name> -f devices.txt [--print-connection-strings] [--prune]`

Create a plain text list of device IDs (one per line, `#` for comments). The scripts will create/update Edge-enabled identities and optionally print connection strings.
Start from the example and edit locally: `cp devices.example.txt devices.txt` (device lists are gitignored by default).
Note: the square brackets in the examples mean the flags are optional—omit the brackets when running (e.g., `-PrintConnectionStrings -PruneNotInList`).
If the PowerShell script reports an azure-iot extension install error, run `az extension add --name azure-iot --yes --debug` manually, then retry.
The prune flags remove any device IDs in the hub that are not listed in your devices file—review the list before pruning.

## Files of interest
- `main.tf`, `modules/iot-hub/`: define the resource group and IoT Hub.
- `modules/cosmos/`: Cosmos DB account, SQL DB, and container.
- `environments/dev.tfvars.example`: template for project/environment/region settings.
- `environments/dev.tfvars`: your local copy of tfvars (kept out of git by default).
- `backend-dev.example.hcl`: template for remote state settings. Create your own `backend-*.hcl` locally and keep it out of git.
- `scripts/create-edge-devices.ps1`, `scripts/create-edge-devices.sh`: helper scripts to create Edge device identities via Azure CLI (outside Terraform).
