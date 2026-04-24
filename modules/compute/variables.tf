variable "tags" {
  description = "A map of tags to apply to all resources."
  type        = map(string)
  default     = {}
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
  description = "Prefix for all resource groups."
  type        = string
  default     = "rg"
}

variable "cloudshell_tags" {
  description = "Tags to apply to all Cloud Shell resources."
  type        = map(string)
}

variable "cloudshell_storage_quota" {
  description = "Quota for the Cloud Shell storage share (in GB)."
  type        = number
}

variable "cloudshell_storage_sku" {
  description = "SKU for the Cloud Shell storage account."
  type        = string
}

variable "cloudshell_storage_replication_type" {
  description = "Replication type for the Cloud Shell storage account."
  type        = string
}

variable "cloudshell_relay_sku" {
  description = "SKU for the Azure Relay namespace."
  type        = string
}

variable "cloudshell_dns_ttl" {
  description = "TTL for the private DNS A record."
  type        = number
}

variable "cloudshell_vnet_address_space" {
  description = "Address space for the CloudShell VNet."
  type        = list(string)
}

variable "cloudshell_subnet_address_prefix" {
  description = "Address prefix for the CloudShell subnet."
  type        = string
}

variable "cloudshell_subnet_suffix" {
  description = "Suffix for CloudShell subnet name."
  type        = string
}

variable "resource_prefix" {
  description = "Resource prefix for naming convention."
  type        = string
}

variable "vnet_rg_name" {
  description = "Name of the resource group for virtual network."
  type        = string
}

variable "netprofile_name" {
  description = "Name for the network profile."
  type        = string
  default     = "cloudshell-netprofile"
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources."
  type        = map(string)
}

# SSH public key is provided via Azure DevOps variable group
variable "aks_ssh_public_key" {
  description = "SSH public key for AKS nodes, provided from Azure DevOps library variable"
  type        = string
  sensitive   = true
}

variable "vnet_name" {
  description = "Name of the virtual network."
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the virtual network."
  type        = list(string)
}

variable "containers_subnet_name" {
  description = "Subnet name for Cloud Shell containers."
  type        = string
}

variable "containers_subnet_prefix" {
  description = "Address prefix for Cloud Shell containers subnet."
  type        = list(string)
}

variable "relay_subnet_name" {
  description = "Subnet name for Azure Relay."
  type        = string
}

variable "relay_subnet_prefix" {
  description = "Address prefix for Azure Relay subnet."
  type        = list(string)
}

variable "relay_namespace_name" {
  description = "Name for Azure Relay namespace."
  type        = string
}

# Legacy variables - not used (Cloud Shell storage created directly in Cloudshell.tf)
variable "storage_account_name" {
  description = "LEGACY: Not used - Cloud Shell storage account name is generated in Cloudshell.tf"
  type        = string
  default     = ""
}

variable "storage_share_name" {
  description = "LEGACY: Not used - Cloud Shell storage share name is generated in Cloudshell.tf"
  type        = string
  default     = ""
}

variable "private_dns_zone_name" {
  description = "Name for the private DNS zone."
  type        = string
}

variable "role_assignment_enabled" {
  description = "Enable role assignments for ACI service principal."
  type        = bool
}

# Resource group prefix for compute module
variable "compute_resource_group_prefix" {
  description = "Prefix for compute module resource groups."
  type        = string
  default     = "rg"
}

# Container Registries (ACR)
variable "acr_registries" {
  description = "Map of Azure Container Registries to create."
  type = map(object({
    resource_prefix               = string
    sku                           = string
    admin_enabled                 = bool
    retention_days                = number
    retention_enabled             = bool
    georeplications               = list(string)
    public_network_access_enabled = bool
    zone_redundancy_enabled       = bool
  }))
}

# AKS clusters (one RG per cluster)
variable "aks_clusters" {
  description = "Map of AKS clusters to create."
  type = map(object({
    resource_prefix      = string
    client_name          = string
    environment          = string
    location_code        = string
    dns_zone_suffix      = string
    registration_enabled = bool
    sku_tier             = string
    node_pool_prefix     = string
    # node_pool_name removed - now dynamically generated using node_pool_prefix
    node_count              = number
    vm_size                 = string
    os_disk_size_gb         = number
    node_pool_type          = string
    kubernetes_version      = string
    orchestrator_version    = string
    aks_subnet_id           = string
    aks_vnet_id             = string
    max_pods                = number
    identity_type           = string
    private_cluster_enabled = bool
    admin_username          = string
    ssh_public_key          = string
    network_plugin          = string
    network_plugin_mode     = string
    load_balancer_sku       = string
    network_policy          = string
    outbound_type           = string
    pod_cidr                = string
    service_cidr            = string
    dns_service_ip          = string
    # Autoscaling configuration
    enable_auto_scaling = bool
    min_count           = number
    max_count           = number
    tags                = map(string)
    date_tag_key        = string
    created_by_tag_key  = string
    created_by_value    = string
  }))
}

variable "date_format" {
  description = "Date format for timestamp formatting."
  type        = string
}

# Function Apps (one RG per app; references a plan by key)
variable "function_apps" {
  description = "Map of Linux Function Apps. Storage account details are now provided via shared storage from database module."
  type = map(object({
    resource_prefix  = string
    service_plan_key = string
    # storage_account_name and storage_account_access_key removed - using shared storage
    site_config = object({
      python_version = string
    })
    identity_type   = string
    identity_prefix = string
    tags            = map(string)
  }))
  default = {}
}

# Managed Identity IDs passed from identity_governance module
variable "managed_identity_ids" {
  description = "Map of managed identity IDs from identity_governance module"
  type        = map(string)
  default     = {}
}

# Shared Storage Account for Function Apps (from database module)
variable "shared_storage_account_name" {
  description = "Name of the shared storage account for all Function Apps"
  type        = string
}

variable "shared_storage_account_key" {
  description = "Primary access key of the shared storage account for all Function Apps"
  type        = string
  sensitive   = true
}



# variable "managed_identity_ids" {
#   description = "Map of managed identity resource IDs to use for UserAssigned identities."
#   type        = map(string)
# }

variable "managed_identities" {
  description = "Map of managed identities. Names are dynamically computed as mi-{resource_prefix}-{client_name}-{environment}-{location_code}. All created in identity resource group."
  type = map(object({
    resource_prefix = string
    tags            = optional(map(string), {})
  }))
}

# Cloudshell dynamic variables
variable "subnet_prefix" {
  description = "Prefix for subnet names."
  type        = string
}

variable "container_subnet_suffix" {
  description = "Suffix for container subnet name."
  type        = string
}

variable "relay_subnet_suffix" {
  description = "Suffix for relay subnet name."
  type        = string
}

variable "relay_namespace_prefix" {
  description = "Prefix for relay namespace name."
  type        = string
}

variable "private_endpoint_prefix" {
  description = "Prefix for private endpoint name."
  type        = string
}

variable "relay_endpoint_suffix" {
  description = "Suffix for relay endpoint name."
  type        = string
}

variable "storage_endpoint_suffix" {
  description = "Suffix for storage endpoint name."
  type        = string
}

variable "dns_link_suffix" {
  description = "Suffix for DNS link name."
  type        = string
}

variable "storage_account_prefix" {
  description = "Prefix for storage account name."
  type        = string
}

variable "storage_share_prefix" {
  description = "Prefix for storage share name."
  type        = string
}

variable "network_profile_prefix" {
  description = "Prefix for network profile name."
  type        = string
}

variable "network_interface_suffix" {
  description = "Suffix for network interface name."
  type        = string
}

variable "ip_config_suffix" {
  description = "Suffix for IP configuration name."
  type        = string
}

variable "delegation_suffix" {
  description = "Suffix for delegation name."
  type        = string
}

variable "connection_suffix" {
  description = "Suffix for connection name."
  type        = string
}

variable "container_service_delegation_name" {
  description = "Service delegation name for container subnet."
  type        = string
}

variable "container_subnet_service_endpoints" {
  description = "Service endpoints for container subnet."
  type        = list(string)
}

variable "relay_subresource_names" {
  description = "Subresource names for relay private endpoint."
  type        = list(string)
}

variable "relay_is_manual_connection" {
  description = "Whether relay private endpoint connection is manual."
  type        = bool
}

variable "storage_default_action" {
  description = "Default action for storage account network rules."
  type        = string
}

variable "storage_suffix_length" {
  description = "Length of storage account suffix."
  type        = number
}

variable "storage_suffix_special" {
  description = "Include special characters in storage suffix."
  type        = bool
}

variable "storage_suffix_upper" {
  description = "Include uppercase letters in storage suffix."
  type        = bool
}

variable "network_contributor_role_name" {
  description = "Name of network contributor role."
  type        = string
}

variable "relay_contributor_role_name" {
  description = "Name of relay contributor role."
  type        = string
}

# Network resource naming variables
variable "vnet_prefix" {
  description = "Prefix for virtual network names."
  type        = string
}

variable "network_resource_group_prefix" {
  description = "Prefix for network module resource groups."
  type        = string
}

variable "corevm_subnet_suffix" {
  description = "Suffix for CoreVM subnet names."
  type        = string
  default     = "corevm"
}

# AKS node pool naming variable
variable "node_pool_prefix" {
  description = "Prefix for AKS node pool names."
  type        = string
  default     = "akspool"
}

# CloudShell delegation and service endpoint variables
variable "cloudshell_delegation_name" {
  description = "Name for CloudShell subnet delegation."
  type        = string
}

variable "cloudshell_service_delegation_name" {
  description = "Service delegation name for CloudShell subnet."
  type        = string
}

variable "cloudshell_service_delegation_actions" {
  description = "Actions for CloudShell service delegation."
  type        = list(string)
}

variable "cloudshell_service_endpoints" {
  description = "Service endpoints for CloudShell subnet."
  type        = list(string)
}

variable "cloudshell_vnet_suffix" {
  description = "Suffix for CloudShell VNet name."
  type        = string
}

variable "main_vnet_id" {
  description = "The resource ID of the main VNet to peer with CloudShell VNet."
  type        = string
}

variable "aci_service_principal_name" {
  description = "The name of the service principal for Azure Container Instance."
  type        = string
  default     = "Azure Container Instance Service"
}
