variable "location" {
  description = "Azure region used where needed (e.g., for KV child resources)."
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

variable "rg_prefix" {
  description = "Resource group prefix for naming convention."
  type        = string
  default     = "rg"
}

# Common tags for all resources
variable "common_tags" {
  description = "Common tags to apply to all resources."
  type        = map(string)
}

variable "managed_identities" {
  description = "Map of user-assigned managed identities. Names are dynamically computed as mi-{resource_prefix}-{client_name}-{environment}-{location_code}"
  type = map(object({
    resource_prefix = string
    tags            = optional(map(string), {})
  }))
}

variable "vnet_rg_name" {
  description = "Name of the resource group for the virtual network."
  type        = string
}

variable "sku_name" {
  description = "SKU name for Key Vault."
  type        = string
}

variable "purge_protection_enabled" {
  description = "Enable purge protection for Key Vault."
  type        = bool
}

variable "kv_rbac_group_object_id" {
  description = "Object ID of principal/group to assign RBAC on Key Vault."
  type        = string
}

variable "create_kv_rbac_assignments" {
  description = "Whether to create RBAC role assignments for Key Vault. Requires User Access Administrator or Owner role."
  type        = bool
}

# Key Vault permissions
variable "key_permissions" {
  description = "List of key permissions for Key Vault access policy."
  type        = list(string)
}

variable "secret_permissions" {
  description = "List of secret permissions for Key Vault access policy."
  type        = list(string)
}

variable "certificate_permissions" {
  description = "List of certificate permissions for Key Vault access policy."
  type        = list(string)
}

# RBAC role names
variable "kv_secrets_user_role" {
  description = "Role definition name for Key Vault Secrets User."
  type        = string
}

variable "kv_admin_role" {
  description = "Role definition name for Key Vault Administrator."
  type        = string
}

variable "kv_cert_officer_role" {
  description = "Role definition name for Key Vault Certificates Officer."
  type        = string
}

# Service Bus (namespaces in own RGs; queues reference namespace by key)
variable "eventhub_rg_name" {
  description = "Name of the resource group for Event Hub."
  type        = string
}

variable "servicebus_namespaces" {
  description = "Map of Service Bus namespaces."
  type = map(object({
    resource_prefix = string
    sku             = string
    capacity        = number
    tags            = optional(map(string), {})
  }))
}

variable "servicebus_queues" {
  description = "Map of Service Bus queues; references a namespace by key."
  type = map(object({
    namespace_key         = string
    max_size_in_megabytes = number
  }))
  default = {}
}

# (Optional) common tags if you reference var.tags in module code; default avoids prompts.
variable "tags" {
  description = "Common tags to apply (optional)."
  type        = map(string)
}

variable "key_vaults" {
  description = "Key vault configuration"
  type        = any
}


# SSH public key is provided via Azure DevOps variable group (not stored in Key Vault)
