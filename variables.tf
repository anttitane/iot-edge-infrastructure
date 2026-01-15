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

