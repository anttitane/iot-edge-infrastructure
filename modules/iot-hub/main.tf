# Single IoT Hub instance for the given project/environment (F1 free tier)
resource "azurerm_iothub" "hub" {
  name                = "iothub-${var.project_name}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = "F1"
    capacity = 1
  }
}

resource "azurerm_iothub_endpoint_cosmosdb_account" "cosmos" {
  count = var.enable_cosmos_routing ? 1 : 0

  name                = var.cosmos_endpoint_name
  resource_group_name = var.resource_group_name
  iothub_id           = azurerm_iothub.hub.id
  container_name      = var.cosmos_sql_container_name
  database_name       = var.cosmos_sql_db_name
  endpoint_uri        = var.cosmos_account_endpoint
  authentication_type = "keyBased"
  primary_key         = var.cosmos_account_primary_key
  secondary_key       = var.cosmos_account_secondary_key
}

resource "azurerm_iothub_route" "cosmos" {
  count = var.enable_cosmos_routing ? 1 : 0

  name                = var.cosmos_route_name
  resource_group_name = var.resource_group_name
  iothub_name         = azurerm_iothub.hub.name
  source              = "DeviceMessages"
  condition           = var.cosmos_route_condition
  endpoint_names      = [var.cosmos_endpoint_name]
  enabled             = true

  depends_on = [azurerm_iothub_endpoint_cosmosdb_account.cosmos]
}
