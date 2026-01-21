output "account_name" {
  value = azurerm_cosmosdb_account.cosmos_account.name
}

output "account_endpoint" {
  value = azurerm_cosmosdb_account.cosmos_account.endpoint
}

output "primary_sql_connection_string" {
  value     = azurerm_cosmosdb_account.cosmos_account.primary_sql_connection_string
  sensitive = true
}

output "primary_key" {
  value     = azurerm_cosmosdb_account.cosmos_account.primary_key
  sensitive = true
}

output "secondary_key" {
  value     = azurerm_cosmosdb_account.cosmos_account.secondary_key
  sensitive = true
}

output "sql_db_name" {
  value = azurerm_cosmosdb_sql_database.iot_db.name
}

output "sql_container_name" {
  value = azurerm_cosmosdb_sql_container.telemetry_container.name
}
