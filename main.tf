# 1. Create a resource group for all project components
resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location
}

# 2. Invoke the Cosmos DB and IoT Hub module
module "cosmos" {
  source                = "./modules/cosmos"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  account_name          = var.cosmos_account_name
  enable_free_tier      = var.cosmos_enable_free_tier
  consistency_level     = var.cosmos_consistency_level
  sql_db_name           = var.cosmos_sql_db_name
  sql_container_name    = var.cosmos_sql_container_name
  partition_key_path    = var.cosmos_partition_key_path
  container_throughput  = var.cosmos_container_throughput
  default_ttl_seconds   = var.cosmos_default_ttl_seconds
}

module "iot_hub" {
  source              = "./modules/iot-hub"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  project_name        = var.project_name
  environment         = var.environment
  enable_cosmos_routing          = var.enable_cosmos_routing
  cosmos_endpoint_name           = var.cosmos_endpoint_name
  cosmos_route_name              = var.cosmos_route_name
  cosmos_route_condition         = var.cosmos_route_condition
  cosmos_sql_db_name             = module.cosmos.sql_db_name
  cosmos_sql_container_name      = module.cosmos.sql_container_name
  cosmos_account_endpoint        = module.cosmos.account_endpoint
  cosmos_account_primary_key     = module.cosmos.primary_key
  cosmos_account_secondary_key   = module.cosmos.secondary_key
}