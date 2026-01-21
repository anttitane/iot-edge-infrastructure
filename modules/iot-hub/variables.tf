terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "project_name"        { type = string }
variable "environment"         { type = string }

# Cosmos DB configuration
variable "enable_cosmos_routing" {
  type        = bool
  description = "Whether to create an IoT Hub endpoint and route to Cosmos DB."
  default     = true
}

variable "cosmos_endpoint_name" {
  type        = string
  description = "IoT Hub endpoint name targeting Cosmos DB."
  default     = "CosmosEndpoint"
}

variable "cosmos_route_name" {
  type        = string
  description = "IoT Hub route name for Cosmos DB."
  default     = "RouteToCosmos"
}

variable "cosmos_route_condition" {
  type        = string
  description = "Condition for routing to Cosmos DB (expression over message body/headers)."
  default     = "true"
}

variable "cosmos_sql_db_name" {
  type        = string
  description = "Cosmos SQL database name used by the IoT Hub endpoint."
}

variable "cosmos_sql_container_name" {
  type        = string
  description = "Cosmos SQL container name used by the IoT Hub endpoint."
}

variable "cosmos_account_endpoint" {
  type        = string
  description = "Cosmos DB account endpoint URI."
}

variable "cosmos_account_primary_key" {
  type        = string
  description = "Cosmos DB account primary key (used by IoT Hub endpoint)."
  sensitive   = true
}

variable "cosmos_account_secondary_key" {
  type        = string
  description = "Cosmos DB account secondary key (used by IoT Hub endpoint)."
  sensitive   = true
}

