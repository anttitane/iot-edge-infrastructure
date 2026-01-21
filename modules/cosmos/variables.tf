terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "account_name" {
  type        = string
  description = "Cosmos DB account name (must be globally unique)."
}

variable "enable_free_tier" {
  type        = bool
  description = "Enable free tier (only one per subscription)."
  default     = true
}

variable "consistency_level" {
  type        = string
  description = "Consistency level for Cosmos DB account."
  default     = "Session"
}

variable "sql_db_name" {
  type        = string
  description = "Cosmos SQL database name."
  default     = "IotDatabase"
}

variable "sql_container_name" {
  type        = string
  description = "Cosmos SQL container name."
  default     = "TelemetryData"
}

variable "partition_key_path" {
  type        = string
  description = "Partition key path for the Cosmos container."
  default     = "/NodeName"
}

variable "container_throughput" {
  type        = number
  description = "Manual throughput (RU/s) for the Cosmos container."
  default     = 400

  validation {
    condition     = var.container_throughput > 0 && var.container_throughput <= 1000
    error_message = "container_throughput must be between 1 and 1000 RU/s to stay within the free-tier allowance."
  }
}

variable "default_ttl_seconds" {
  type        = number
  description = "Default TTL in seconds for documents (-1 disables TTL)."
  default     = -1
}
