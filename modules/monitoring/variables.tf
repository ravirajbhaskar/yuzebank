variable "location" {
  description = "The Azure region to deploy resources into."
  type        = string
}

# Centralized naming variables
variable "client_name" {
  description = "Client name for naming convention."
  type        = string
}

variable "environment" {
  description = "Environment name for naming convention."
  type        = string
}

variable "location_code" {
  description = "Location code for naming convention."
  type        = string
}

variable "rg_prefix" {
  description = "Prefix for all resource groups."
  type        = string
  default     = "rg"
}

variable "monitor_rg_name" {
  description = "Name of the resource group for monitoring resources."
  type        = string
}

# Common tags for all resources
variable "common_tags" {
  description = "Common tags to apply to all resources."
  type        = map(string)
}

# Notification Hub Namespaces
variable "notification_hub_namespaces" {
  description = "Map of Notification Hub Namespaces. Names computed dynamically as: ntfns-{key}-{client_name}-{environment}-{location_code}"
  type = map(object({
    sku_name       = string
    namespace_type = string
    tags           = optional(map(string), {})
  }))
}

# Notification Hubs (references a namespace by key)
variable "notification_hubs" {
  description = "Map of Notification Hubs. Names computed dynamically as: ntfh-{key}-{client_name}-{environment}-{location_code}. namespace_key must match a key in var.notification_hub_namespaces."
  type = map(object({
    namespace_key = string
    tags          = optional(map(string), {})
  }))
}

# Application Insights
variable "application_insights" {
  description = "Map of Application Insights instances. Names computed dynamically as: appi-{key}-{client_name}-{environment}-{location_code}"
  type = map(object({
    application_type  = string
    retention_in_days = number
    workspace_id      = optional(string)
    tags              = optional(map(string), {})
  }))
}

# Log Analytics workspaces
variable "log_analytics_workspaces" {
  description = "Map of Log Analytics workspaces. Names computed dynamically as: log-{key}-{client_name}-{environment}-{location_code}"
  type = map(object({
    sku               = string
    retention_in_days = number
    tags              = optional(map(string), {})
  }))
}
