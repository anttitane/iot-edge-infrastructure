variable "project_name" {
  type        = string
  description = "Project name used for resource naming"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, test, prod)"
}

variable "location" {
  type        = string
  description = "Azure region where resources are created"
  default     = "westeurope"
}

# Cosmos DB configuration (defaults target free tier)
variable "cosmos_account_name" {
  type        = string
  description = "Cosmos DB account name (must be globally unique)."
}

variable "cosmos_enable_free_tier" {
  type        = bool
  description = "Whether to enable the free tier for the Cosmos account (one free tier account per subscription)."
  default     = true
}

variable "cosmos_consistency_level" {
  type        = string
  description = "Consistency level for Cosmos DB account."
  default     = "Session"
}

variable "cosmos_sql_db_name" {
  type        = string
  description = "Cosmos SQL database name."
  default     = "IotDatabase"
}

variable "cosmos_sql_container_name" {
  type        = string
  description = "Cosmos SQL container name."
  default     = "TelemetryData"
}

variable "cosmos_partition_key_path" {
  type        = string
  description = "Partition key path for the Cosmos container."
  default     = "/NodeName"
}

variable "cosmos_container_throughput" {
  type        = number
  description = "Manual throughput (RU/s) for the Cosmos container."
  default     = 400
}

variable "cosmos_default_ttl_seconds" {
  type        = number
  description = "Default TTL in seconds for Cosmos documents (-1 disables TTL)."
  default     = -1
}

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

