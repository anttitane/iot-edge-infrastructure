# Single IoT Hub instance for the given project/environment (F1 free tier)
resource "azurerm_iothub" "hub" {
  name                = "iothub-${var.project_name}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location

  # Keep partitions stable; IoT Hub free (F1) defaults to 4, but your existing hub has 2.
  event_hub_partition_count = 2

  sku {
    name     = "F1"
    capacity = 1
  }

  fallback_route {
    enabled        = true
    source         = "DeviceMessages"
    endpoint_names = ["events"]
  }
}