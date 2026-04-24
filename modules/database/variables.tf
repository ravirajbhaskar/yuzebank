variable "location" {
  description = "Azure region for all resources."
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

variable "random_suffix" {
  description = "Random suffix for globally unique resource names (6 characters)."
  type        = string
}


variable "resource_group_name" {
  description = "The name of the app resource group (passed from compute module)."
  type        = string
}

variable "rg_prefix" {
  description = "Prefix for all resource groups."
  type        = string
  default     = "rg"
}

# Common tags for all resources
variable "common_tags" {
  description = "Common tags to apply to all resources."
  type        = map(string)
}

# Resource group prefix for database module
variable "database_resource_group_prefix" {
  description = "Prefix for database module resource groups."
  type        = string
  default     = "rg"
}

variable "storage_rg_name" {
  description = "Name of the resource group for storage accounts."
  type        = string
}

variable "sql_rg_name" {
  description = "Name of the resource group for SQL resources."
  type        = string
}

variable "eventhub_rg_name" {
  description = "Name of the resource group for Event Hub resources."
  type        = string
}

# Event Hub Namespaces
variable "eventhub_namespaces" {
  description = "Map of Event Hub Namespaces."
  type = map(object({
    resource_prefix = string # e.g., "evhns"
    sku             = string
    capacity        = number
  }))
}

# Event Hubs (inside namespaces; reference by key)
variable "eventhubs" {
  description = "Map of Event Hubs to create under the given namespace_key."
  type = map(object({
    resource_prefix   = string # e.g., "evh"
    namespace_key     = string # key in var.eventhub_namespaces
    partition_count   = number
    message_retention = number
  }))
}

# Storage Accounts
variable "storage_accounts" {
  description = "Map of Storage Accounts."
  type = map(object({
    resource_prefix                 = string # e.g., "st"
    replace_character               = string
    substr_start                    = number
    max_name_length                 = number
    account_kind                    = string
    account_tier                    = string
    account_replication_type        = string
    access_tier                     = string
    min_tls_version                 = string
    allow_nested_items_to_be_public = bool
    https_traffic_only_enabled      = bool
    public_network_access_enabled   = bool
    is_hns_enabled                  = bool
    sftp_enabled                    = bool
  }))
}

# Storage Containers (inside an account; reference by key)
variable "storage_containers" {
  description = "Map of Storage Containers by storage_account_key."
  type = map(object({
    resource_prefix       = string # e.g., "sc"
    storage_account_key   = string # key in var.storage_accounts
    container_access_type = string # private | blob | container
  }))
}

# Redis Caches
variable "redis_caches" {
  description = "Map of Redis Cache instances."
  type = map(object({
    resource_prefix = string
    capacity        = number
    family          = string
    sku_name        = string
  }))
  default = {}
}

# SQL Databases
variable "sql_databases" {
  description = "Map of SQL Database configurations."
  type = map(object({
    # Resource naming prefixes
    resource_group_prefix             = optional(string, "rg")
    sql_server_prefix                 = optional(string, "sqls")
    sql_database_prefix               = optional(string, "sqldb")
    private_endpoint_prefix           = optional(string, "pe")
    private_service_connection_prefix = optional(string, "psc")

    # Resource group name computed dynamically as: {resource_group_prefix}-sql-{client_name}-{environment}-{location_code}
    sql_subnet_id = optional(string) # Will be provided dynamically

    # SQL Server configuration
    sql_server_version            = string # e.g., "12.0"
    admin_username                = string
    minimum_tls_version           = string # e.g., "1.2"
    public_network_access_enabled = bool

    # SQL Database configuration
    sku_name                   = string # e.g., "GP_Gen5_2" (provisioned) or "GP_S_Gen5_2" (serverless)
    max_size_gb                = number
    license_type               = string # e.g., "LicenseIncluded"
    zone_redundant             = bool
    storage_account_type       = string # e.g., "LRS"
    geo_backup_enabled         = bool
    reserved_capacity_in_years = number
    read_scale                 = bool
    collation                  = string # e.g., "SQL_Latin1_General_CP1_CI_AS"

    # Serverless-specific configuration (only for serverless SKUs)
    auto_pause_delay_in_minutes = optional(number) # e.g., 60, -1 to disable auto-pause
    min_capacity                = optional(number) # e.g., 0.5 vCores (minimum)
    max_capacity                = optional(number) # e.g., 2.0 vCores (maximum)

    # Long term retention policy
    weekly_retention  = string # e.g., "P0W"
    monthly_retention = string # e.g., "P0M"
    yearly_retention  = string # e.g., "P0Y"
  }))
  default = {}
}

# Private Endpoint Configuration for SQL
variable "sql_private_endpoint_config" {
  description = "Configuration for SQL Server private endpoints."
  type = object({
    subresource_names    = list(string) # e.g., ["sqlServer"]
    is_manual_connection = bool         # e.g., false
  })
  default = {
    subresource_names    = ["sqlServer"]
    is_manual_connection = false
  }
}

# Key Vault ID for storing SQL admin password
variable "key_vault_id" {
  description = "The ID of the Key Vault where SQL admin password will be stored."
  type        = string
}
