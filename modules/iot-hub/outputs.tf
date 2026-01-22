output "hub_name" {
  value = azurerm_iothub.hub.name
}

output "hub_id" {
  value = azurerm_iothub.hub.id
}

output "event_hub_events_endpoint" {
  value = azurerm_iothub.hub.event_hub_events_endpoint
}

output "event_hub_events_path" {
  value = azurerm_iothub.hub.event_hub_events_path
}