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
}

resource "azurerm_iothub_shared_access_policy" "function_listener" {
  name                = "func-listen"
  resource_group_name = azurerm_resource_group.rg.name
  iothub_name         = module.iot_hub.hub_name

  registry_read    = false
  registry_write   = false
  service_connect  = true
  device_connect   = false
}

resource "azurerm_storage_account" "func_storage" {
  name                     = var.function_storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_nested_items_to_be_public = false
}

resource "azurerm_storage_container" "func_package" {
  name                  = "function-code"
  storage_account_id    = azurerm_storage_account.func_storage.id
  container_access_type = "private"
}

resource "azurerm_service_plan" "func_plan" {
  name                = var.function_plan_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "FC1"

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_function_app_flex_consumption" "func" {
  name                = var.function_app_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.func_plan.id

  storage_container_type      = "blobContainer"
  storage_container_endpoint  = "${azurerm_storage_account.func_storage.primary_blob_endpoint}${azurerm_storage_container.func_package.name}"
  storage_authentication_type = "StorageAccountConnectionString"
  storage_access_key          = azurerm_storage_account.func_storage.primary_access_key

  runtime_name    = "dotnet-isolated"
  runtime_version = "10.0"

  site_config {}

  app_settings = {
    IoTHubConnectionString   = format("Endpoint=%s;SharedAccessKeyName=%s;SharedAccessKey=%s;EntityPath=%s",
      module.iot_hub.event_hub_events_endpoint,
      azurerm_iothub_shared_access_policy.function_listener.name,
      azurerm_iothub_shared_access_policy.function_listener.primary_key,
      module.iot_hub.event_hub_events_path
    )
    CosmosDBConnectionString = module.cosmos.primary_sql_connection_string
    FUNCTIONS_EXTENSION_VERSION = "~4"
  }
}