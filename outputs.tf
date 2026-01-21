output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "iot_hub_name" {
  value = module.iot_hub.hub_name
}

output "cosmos_account_name" {
  value = module.cosmos.account_name
}

output "cosmos_account_endpoint" {
  value = module.cosmos.account_endpoint
}

output "cosmos_sql_db_name" {
  value = module.cosmos.sql_db_name
}

output "cosmos_sql_container_name" {
  value = module.cosmos.sql_container_name
}

