output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "iot_hub_name" {
  value = module.iot_hub.hub_name
}

