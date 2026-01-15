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
