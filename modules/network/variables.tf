variable "location" {
  description = "Azure region where the resource group will be created"
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

# Common tags for all resources
variable "common_tags" {
  description = "Common tags to apply to all resources."
  type        = map(string)
}

# Resource group prefix for network module
variable "network_resource_group_prefix" {
  description = "Prefix for network module resource groups."
  type        = string
  default     = "rg"
}

# Network resource prefixes
variable "vnet_prefix" {
  description = "Prefix for virtual network names."
  type        = string
  default     = "vnet"
}

variable "subnet_prefix" {
  description = "Prefix for subnet names."
  type        = string
  default     = "subnet"
}

variable "nsg_prefix" {
  description = "Prefix for Network Security Group names."
  type        = string
  default     = "nsg"
}

# NSG Rules Configuration
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

# Resource group names
variable "aks_dns_zone" {
  description = "DNS zone for AKS cluster (optional - not required)."
  type = object({
    name                = string
    resource_group_name = string
    tags                = optional(map(string), {})
  })
  default = null
}

############################################
# LOAD BALANCER
############################################
############################################
# VNET + SUBNETS
############################################
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

############################################
# APPLICATION GATEWAY
############################################
variable "application_gateways" {
  description = "Map of Application Gateways with dynamic naming."
  type = map(object({
    resource_prefix = string
    # resource_group_name, subnet_id, and user_assigned_identity_id are computed dynamically
    # No need to specify them in tfvars - they're computed from module outputs
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
      # Allow providing Key Vault by name + certificate name as an alternative
      # to supplying a full secret id. When both are provided the module
      # constructs the secret id URL to reference the latest version.
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

variable "ip_config_suffix" {
  description = "Suffix for IP configuration names."
  type        = string
  default     = "ipcfg"
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

# VNet Peering variables
variable "enable_cloudshell_peering" {
  description = "Enable VNet peering between main VNet and CloudShell VNet"
  type        = bool
  default     = false
}

# Key Vault variables for certificate fetching
variable "key_vault_name" {
  description = "Name of the Key Vault containing SSL certificates"
  type        = string
}

variable "key_vault_resource_group" {
  description = "Resource group name where Key Vault is located"
  type        = string
}

variable "certificate_names" {
  description = "Map of certificate names to fetch from Key Vault for Application Gateway"
  type = map(object({
    certificate_name = string
    enabled          = bool
  }))
  default = {}
}

variable "agw_managed_identity_id" {
  description = "Managed Identity ID for Application Gateway to access Key Vault (dynamically passed from identity_governance module)"
  type        = string
  default     = null
}

variable "agw_access_policy_ids" {
  description = "Map of AGW Key Vault access policy IDs to enforce dependency ordering (from identity_governance module)"
  type        = map(string)
  default     = {}
}

