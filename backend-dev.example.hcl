# Example backend configuration for a dev environment.
# Copy to backend-dev.hcl (or similar) and fill in your own state store details.
resource_group_name  = "<tfstate-resource-group>"
storage_account_name = "<tfstate-storage-account>"
container_name       = "<tfstate-container>"
key                  = "dev.terraform.tfstate"
