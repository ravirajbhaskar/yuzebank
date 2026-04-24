############################################
# Provider
############################################

variable "location" {
  description = "Default Azure region (used by identity_governance where needed)."
  type        = string
}

############################################
# GLOBAL CONFIGURATION
############################################
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

variable "common_tags" {
  description = "Common tags to apply to all resources."
  type        = map(string)
}

############################################
# MODULE ENABLE/DISABLE CONTROLS
############################################
variable "enable_network" {
  description = "Enable or disable the network module deployment. When false, module is skipped without destroying existing resources."
  type        = bool
  default     = true
}

variable "enable_compute" {
  description = "Enable or disable the compute module deployment. When false, module is skipped without destroying existing resources."
  type        = bool
  default     = true
}

variable "enable_identity_governance" {
  description = "Enable or disable the identity_governance module deployment. When false, module is skipped without destroying existing resources."
  type        = bool
  default     = true
}

variable "enable_database" {
  description = "Enable or disable the database module deployment. When false, module is skipped without destroying existing resources."
  type        = bool
  default     = true
}

variable "enable_monitoring" {
  description = "Enable or disable the monitoring module deployment. When false, module is skipped without destroying existing resources."
  type        = bool
  default     = true
}

############################################
# CLOUD SHELL CONFIGURATION
############################################
variable "cloudshell_tags" {
  description = "Tags to apply to all Cloud Shell resources."
  type        = map(string)
  default     = {}
}

variable "cloudshell_storage_quota" {
  description = "Quota for the Cloud Shell storage share (in GB)."
  type        = number
  default     = 10
}

variable "cloudshell_storage_sku" {
  description = "SKU for the Cloud Shell storage account."
  type        = string
  default     = "Standard"
}

variable "cloudshell_storage_replication_type" {
  description = "Replication type for the Cloud Shell storage account."
  type        = string
  default     = "LRS"
}

variable "cloudshell_relay_sku" {
  description = "SKU for the Azure Relay namespace."
  type        = string
  default     = "Standard"
}

variable "cloudshell_dns_ttl" {
  description = "TTL for the private DNS A record."
  type        = number
  default     = 600
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

# Cloud Shell Virtual Network Configuration
variable "vnet_address_space" {
  description = "Address space for the virtual network."
  type        = list(string)
}

variable "containers_subnet_prefix" {
  description = "Address prefix for Cloud Shell containers subnet."
  type        = list(string)
}

variable "relay_subnet_prefix" {
  description = "Address prefix for Azure Relay subnet."
  type        = list(string)
}

# Cloud Shell Dynamic Naming Variables
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

# Legacy Cloud Shell variables (backward compatibility)
variable "storage_account_prefix" {
  description = "LEGACY: Cloud Shell storage prefix"
  type        = string
}

variable "storage_share_prefix" {
  description = "LEGACY: Prefix for storage share name (not used - Cloud Shell storage created in Cloudshell.tf)"
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

variable "role_assignment_enabled" {
  description = "Whether to enable role assignments."
  type        = bool
}

variable "private_dns_zone_name" {
  description = "Name of private DNS zone for relay."
  type        = string
}

############################################
# NETWORK (VNets, Subnets, LB, Front Door)
############################################
variable "vnet_prefix" {
  description = "Prefix for virtual network names."
  type        = string
  default     = "vnet"
}

variable "subnet_prefix" {
  description = "Prefix for subnet names."
  type        = string
  default     = "snet"
}

variable "nsg_prefix" {
  description = "Prefix for Network Security Group names."
  type        = string
  default     = "nsg"
}

variable "network_resource_group_prefix" {
  description = "Prefix for network module resource groups."
  type        = string
  default     = "rg"
}

variable "nsg_rules" {
  description = "Configuration for NSG security rules."
  type = map(object({
    rules = list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string
    }))
  }))
  default = {}
}

variable "nsg_subnets" {
  description = "List of subnet names that need NSGs"
  type        = list(string)
  default     = []
}

# Dynamic naming prefixes for compute resources
variable "cloudshell_resource_group_prefix" {
  description = "Prefix for CloudShell resource group names."
  type        = string
  default     = "rg"
}

variable "node_pool_prefix" {
  description = "Prefix for AKS node pool names."
  type        = string
  default     = "akspool"
}

variable "vnets" {
  description = "List of VNets, each with its own subnets"
  type = list(object({
    address_space = list(string)
    subnets = list(object({
      subnet_name    = string
      address_prefix = string
      delegation = optional(object({
        name         = string
        service_name = string
        actions      = list(string)
      }))
    }))
  }))
}

variable "application_gateways" {
  description = "Map of Application Gateways with dynamic naming."
  type = map(object({
    resource_prefix = string
    subnet_id       = optional(string)

    # Public IP Configuration
    public_ip_allocation_method = string # "Static" or "Dynamic"
    public_ip_sku               = string # "Standard" or "Basic"

    sku = object({
      name     = string # e.g., "WAF_v2" or "Standard_v2"
      tier     = string
      capacity = number
    })

    # Autoscaling Configuration
    enable_autoscale       = optional(bool, false)
    autoscale_min_capacity = optional(number, 0)
    autoscale_max_capacity = optional(number, 10)

    # Basic Configuration (kept for backward compatibility)
    frontend_port         = optional(number)
    backend_port          = optional(number)
    request_timeout       = optional(number)
    private_ip_allocation = optional(string) # "Dynamic" or "Static"
    cookie_based_affinity = optional(string) # "Enabled" or "Disabled"
    protocol              = optional(string) # "Http" or "Https"
    rule_type             = optional(string) # "Basic" or "PathBasedRouting"
    priority              = optional(number) # Priority for request routing rule
    enable_http2          = bool

    # Frontend Ports Configuration
    frontend_ports = map(object({
      port = number
    }))

    # Backend Address Pools Configuration
    backend_address_pools = map(object({
      fqdns        = list(string)
      ip_addresses = list(string)
    }))

    # Backend HTTP Settings Configuration
    backend_http_settings = map(object({
      cookie_based_affinity               = string
      affinity_cookie_name                = optional(string)
      path                                = optional(string)
      port                                = number
      protocol                            = string
      request_timeout                     = number
      probe_name                          = optional(string)
      host_name                           = optional(string)
      pick_host_name_from_backend_address = optional(bool)
    }))

    # HTTP/HTTPS Listeners Configuration
    http_listeners = map(object({
      frontend_port_key    = string
      protocol             = string
      host_name            = optional(string)
      host_names           = optional(list(string))
      require_sni          = optional(bool)
      ssl_certificate_name = optional(string)
      firewall_policy_id   = optional(string)
    }))

    # Request Routing Rules Configuration
    request_routing_rules = map(object({
      rule_type                  = string
      priority                   = number
      http_listener_key          = string
      backend_address_pool_key   = optional(string)
      backend_http_settings_key  = optional(string)
      redirect_configuration_key = optional(string)
      url_path_map_key           = optional(string)
    }))

    # Health Probes Configuration
    probes = optional(map(object({
      protocol                                  = string
      path                                      = string
      interval                                  = number
      timeout                                   = number
      unhealthy_threshold                       = number
      pick_host_name_from_backend_http_settings = optional(bool)
      host                                      = optional(string)
      match = optional(object({
        status_code = list(string)
        body        = optional(string)
      }))
    })))

    # URL Path Maps Configuration for path-based routing
    url_path_maps = optional(map(object({
      default_backend_address_pool_key  = string
      default_backend_http_settings_key = string
      path_rules = map(object({
        paths                     = list(string)
        backend_address_pool_key  = string
        backend_http_settings_key = string
      }))
    })))

    # SSL Certificates Configuration
    ssl_certificates = optional(map(object({
      data                = optional(string)
      password            = optional(string)
      key_vault_secret_id = optional(string)
      # Alternative way to specify Key Vault certificate when a full
      # secret id is not supplied. The module will construct a secret id
      # URL from these values and reference the latest version.
      key_vault_name             = optional(string)
      key_vault_certificate_name = optional(string)
    })))

    # Redirect Configurations
    redirect_configurations = optional(map(object({
      redirect_type        = string
      target_listener_key  = optional(string)
      target_url           = optional(string)
      include_path         = optional(bool)
      include_query_string = optional(bool)
    })))

    # WAF Configuration
    waf_configuration = object({
      enabled          = bool
      firewall_mode    = string # "Detection" or "Prevention"
      rule_set_type    = string # "OWASP"
      rule_set_version = string # e.g., "3.2"
    })
  }))
  default = {}
}

# # Declare the missing input variable for identity_mapping
# variable "identity_mapping" {
#   description = "Mapping of function app names to managed identity IDs"
#   type        = map(string)
# }

############################################
# IDENTITY & GOVERNANCE (KV, UAMI, LAW, AppI, SB)
############################################
variable "key_vault_name" {
  description = "Name of the Key Vault to create (identity_governance module)."
  type        = string
  default     = ""
}

variable "kv_resource_group_name" {
  description = "Resource group name for the Key Vault (created/used by module)."
  type        = string
  default     = ""
}

variable "kv_rbac_group_object_id" {
  description = "Object ID of the principal/group to assign Key Vault RBAC roles."
  type        = string
}

variable "create_kv_rbac_assignments" {
  description = "Whether to create RBAC role assignments for Key Vault. Requires User Access Administrator or Owner role."
  type        = bool
  default     = true
}

variable "managed_identities" {
  description = "Map of user-assigned managed identities. Names are dynamically computed as mi-{resource_prefix}-{client_name}-{environment}-{location_code}. All created in identity resource group."
  type = map(object({
    resource_prefix = string
    tags            = optional(map(string), {})
  }))
}

variable "managed_identities_rg_name" {
  description = "Name of the resource group for managed identities."
  type        = string
  default     = ""
}

variable "log_analytics_workspaces" {
  description = "Map of Log Analytics workspaces (each with its own RG)."
  type = map(object({
    sku               = string
    retention_in_days = number
    tags              = map(string)
  }))
}

variable "application_insights" {
  description = "Map of Application Insights (each with its own RG)."
  type = map(object({
    application_type  = string
    retention_in_days = number
    workspace_id      = optional(string)
    tags              = map(string)
  }))
}

variable "servicebus_namespaces" {
  description = "Map of Service Bus namespaces."
  type = map(object({
    resource_prefix = string
    sku             = string
    capacity        = number
  }))
  default = {}
}

variable "servicebus_queues" {
  description = "Map of Service Bus queues; each references a namespace by key."
  type = map(object({
    name                  = string
    namespace_key         = string
    max_size_in_megabytes = number
  }))
  default = {}
}

variable "service_bus" {
  description = "Service Bus configuration object."
  type = object({
    resource_prefix = string
    sku             = string
    additional_tags = optional(map(string), {})
  })
  default = {
    resource_prefix = "sbus"
    sku             = "Standard"
    additional_tags = {}
  }
}

# Key Vault Additional Configuration
variable "purge_protection_enabled" {
  description = "Enable purge protection for Key Vault."
  type        = bool
  default     = true
}

variable "key_permissions" {
  description = "List of key permissions for Key Vault access policy."
  type        = list(string)
  default     = ["Get", "List", "Create", "Delete", "Update", "Recover", "Backup", "Restore"]
}

variable "secret_permissions" {
  description = "List of secret permissions for Key Vault access policy."
  type        = list(string)
  default     = ["Get", "List", "Set", "Delete", "Recover", "Backup", "Restore"]
}

variable "certificate_permissions" {
  description = "List of certificate permissions for Key Vault access policy."
  type        = list(string)
  default     = ["Get", "List", "Create", "Delete", "Update", "Import", "Recover", "Backup", "Restore"]
}

variable "kv_secrets_user_role" {
  description = "Role definition name for Key Vault Secrets User."
  type        = string
  default     = "Key Vault Secrets User"
}

variable "kv_admin_role" {
  description = "Role definition name for Key Vault Administrator."
  type        = string
  default     = "Key Vault Administrator"
}

variable "kv_cert_officer_role" {
  description = "Role definition name for Key Vault Certificates Officer."
  type        = string
  default     = "Key Vault Certificates Officer"
}

variable "tags" {
  description = "Common tags to apply (optional)."
  type        = map(string)
  default     = {}
}

variable "eventhub_rg_name" {
  description = "Name of the resource group for Event Hub."
  type        = string
  default     = ""
}

############################################
# DATA LAYER (SQL MI, Storage, Event Hub, Redis)
############################################

variable "storage_rg_name" {
  description = "Name of the resource group for storage accounts."
  type        = string
  default     = ""
}

variable "sql_rg_name" {
  description = "Name of the resource group for SQL databases."
  type        = string
  default     = ""
}

variable "storage_accounts" {
  description = "Map of Storage Accounts."
  type = map(object({
    resource_prefix                 = string
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
    public_network_access_enabled   = optional(bool, true)
    is_hns_enabled                  = optional(bool, false)
    sftp_enabled                    = optional(bool, false)
  }))
  default = {}
}

variable "storage_containers" {
  description = "Map of Storage Containers by storage_account_key."
  type = map(object({
    resource_prefix       = string
    storage_account_key   = string
    container_access_type = string
  }))
  default = {}
}

variable "eventhub_namespaces" {
  description = "Map of Event Hub namespaces."
  type = map(object({
    resource_prefix = string
    sku             = string
    capacity        = number
  }))
  default = {}
}

variable "eventhubs" {
  description = "Map of Event Hubs; each references a namespace by key."
  type = map(object({
    resource_prefix   = string
    namespace_key     = string
    partition_count   = number
    message_retention = number
  }))
  default = {}
}

############################################
# COMPUTE / APP (AKS, ACR, Plans, WebApps, Funcs, APIM, NH)
############################################

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

# AKS Clusters
variable "aks_clusters" {
  description = "Map of AKS clusters to create. aks_subnet_id, aks_vnet_id, and ssh_public_key are set dynamically in main.tf."
  type = map(object({
    resource_prefix      = string
    dns_zone_suffix      = string
    registration_enabled = bool
    sku_tier             = optional(string, "Free") # Free or Standard (Paid)
    node_pool_prefix     = string
    node_count           = number
    # node_pool_name removed - now dynamically generated using node_pool_prefix
    vm_size                 = string
    os_disk_size_gb         = number
    node_pool_type          = string
    kubernetes_version      = string
    orchestrator_version    = string
    aks_subnet_id           = optional(string, "") # Set dynamically in main.tf from network module
    aks_vnet_id             = optional(string, "") # Set dynamically in main.tf from network module
    max_pods                = number
    identity_type           = string
    private_cluster_enabled = bool
    admin_username          = string
    ssh_public_key          = optional(string, "") # Set dynamically in main.tf from Azure DevOps variable
    network_plugin          = string
    network_plugin_mode     = optional(string, null)
    load_balancer_sku       = string
    network_policy          = string
    outbound_type           = optional(string, "loadBalancer")
    pod_cidr                = optional(string, null)
    service_cidr            = string
    dns_service_ip          = string
    # Autoscaling configuration
    enable_auto_scaling = bool
    min_count           = number
    max_count           = number
    date_tag_key        = string
    created_by_tag_key  = string
    created_by_value    = string
  }))
}

# SSH public key for AKS nodes from local keys directory
variable "aks_ssh_public_key" {
  description = "SSH public key for AKS nodes, read from keys/aks_yuze_prod.pub file"
  type        = string
  sensitive   = true
  default     = ""
}

variable "date_format" {
  description = "Date format for timestamp formatting."
  type        = string
}

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

variable "api_management" {
  description = "Map of API Management instances (each with its own RG)."
  type = map(object({
    name                = string
    resource_group_name = string
    publisher_name      = string
    publisher_email     = string
    sku_name            = string
    tags                = map(string)
  }))
  default = {}
}

variable "notification_hub_namespaces" {
  description = "Map of Notification Hub Namespaces (each with its own RG)."
  type = map(object({
    sku_name       = string
    namespace_type = string
    tags           = map(string)
  }))
}

variable "notification_hubs" {
  description = "Map of Notification Hubs; references a namespace by key."
  type = map(object({
    namespace_key = string
    tags          = map(string)
  }))
}

variable "notification_rg_name" {
  description = "Name of the resource group for notifications."
  type        = string
  default     = ""
}

variable "monitor_rg_name" {
  description = "Name of the resource group for monitoring resources."
  type        = string
  default     = ""
}

variable "key_vaults" {
  description = "Configuration for Azure Key Vaults"
  type        = any
}

# Missing variables referenced in main.tf
variable "sku_name" {
  description = "SKU name for Key Vault"
  type        = string
  default     = "standard"
}

variable "redis_caches" {
  description = "Configuration for Redis caches"
  type        = any
  default     = {}
}

variable "sql_databases" {
  description = "Configuration for SQL databases"
  type        = any
  default     = {}
}

variable "resource_prefix" {
  description = "Resource prefix for naming convention."
  type        = string
  default     = ""
}

variable "netprofile_name" {
  description = "Name for the network profile."
  type        = string
  default     = "cloudshell-netprofile"
}

# Application Gateway naming variables
variable "public_ip_prefix" {
  description = "Prefix for public IP names."
  type        = string
  default     = "pip"
}

variable "agw_prefix" {
  description = "Prefix for Application Gateway resource names."
  type        = string
  default     = "appgw"
}

variable "agw_subnet_suffix" {
  description = "Suffix for Application Gateway subnet names."
  type        = string
  default     = "agw"
}

variable "frontend_port_suffix" {
  description = "Suffix for frontend port names."
  type        = string
  default     = "frontend-port"
}

variable "public_frontend_suffix" {
  description = "Suffix for public frontend configuration names."
  type        = string
  default     = "public-frontend"
}

variable "backend_pool_suffix" {
  description = "Suffix for backend pool names."
  type        = string
  default     = "backend-pool"
}

variable "http_settings_suffix" {
  description = "Suffix for HTTP settings names."
  type        = string
  default     = "http-settings"
}

variable "http_listener_suffix" {
  description = "Suffix for HTTP listener names."
  type        = string
  default     = "http-listener"
}

variable "rule_suffix" {
  description = "Suffix for routing rule names."
  type        = string
  default     = "rule"
}

variable "protocol_suffix" {
  description = "Suffix for protocol in rule names."
  type        = string
  default     = "http"
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

# VNet Peering variables
variable "enable_cloudshell_peering" {
  description = "Enable VNet peering between main VNet and CloudShell VNet."
  type        = bool
  default     = true
}

# Key Vault variables for certificate fetching
# NOTE: These are fallback values. In production, values are automatically 
# fetched from identity_governance module output (see main.tf).
# DUPLICATE REMOVED: key_vault_name already defined at line 519

variable "key_vault_resource_group" {
  description = "Resource group name where Key Vault is located (fallback - fetched from identity_governance module if enabled)"
  type        = string
  default     = ""
}

variable "certificate_names" {
  description = "Map of certificate names to fetch from Key Vault for Application Gateway"
  type = map(object({
    certificate_name = string
    enabled          = bool
  }))
  default = {}
}

variable "aci_service_principal_name" {
  description = "The name of the service principal for Azure Container Instance"
  type        = string
  default     = "Azure Container Instance Service"
}