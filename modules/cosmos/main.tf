# Cosmos DB account
resource "azurerm_cosmosdb_account" "cosmos_account" {
  name                = var.account_name
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  free_tier_enabled = var.enable_free_tier

  consistency_policy {
    consistency_level = var.consistency_level
  }

  geo_location {
    location          = var.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "iot_db" {
  name                = var.sql_db_name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmos_account.name
}

resource "azurerm_cosmosdb_sql_container" "telemetry_container" {
  name                = var.sql_container_name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmos_account.name
  database_name       = azurerm_cosmosdb_sql_database.iot_db.name

  partition_key_paths = [var.partition_key_path]
  default_ttl         = var.default_ttl_seconds
  throughput          = var.container_throughput
}
