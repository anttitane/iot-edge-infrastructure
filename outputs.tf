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

output "iot_hub_function_connection_string" {
  value     = format("Endpoint=%s;SharedAccessKeyName=%s;SharedAccessKey=%s;EntityPath=%s",
    module.iot_hub.event_hub_events_endpoint,
    azurerm_iothub_shared_access_policy.function_listener.name,
    azurerm_iothub_shared_access_policy.function_listener.primary_key,
    module.iot_hub.event_hub_events_path
  )
  sensitive = true
}

output "cosmos_primary_sql_connection_string" {
  value     = module.cosmos.primary_sql_connection_string
  sensitive = true
}

output "function_storage_connection_string" {
  value     = azurerm_storage_account.func_storage.primary_connection_string
  sensitive = true
}

