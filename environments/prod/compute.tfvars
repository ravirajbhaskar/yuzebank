# =============================================================================
# COMPUTE RESOURCES - Production Environment
# =============================================================================

# --- Azure Kubernetes Service (AKS) ---
date_format      = "2006-01-02"
node_pool_prefix = "nodepool"

# SSH public key - Automatically generated and managed by CI/CD pipeline
# The pipeline:
#   1. Checks Key Vault for existing SSH keys (aks-ssh-private-key, aks-ssh-public-key)
#   2. If found: Retrieves and reuses existing key (NO regeneration)
#   3. If missing: Generates new 4096-bit RSA key pair and stores in Key Vault
#   4. Exports AKS_SSH_PUBLIC_KEY to pipeline variable for Terraform
# This ensures consistent SSH access across all pipeline runs without manual intervention.
# ⚠️  DO NOT hardcode SSH key here - it's passed via -var flag from pipeline

aks_clusters = {
  primary = {
    resource_prefix         = "aks"
    orchestrator_version    = "1.32.7"
    dns_zone_suffix         = "privatelink.centralindia.azmk8s.io"
    registration_enabled    = false
    sku_tier                = "Standard"
    node_pool_prefix        = "nodepool"
    node_count              = 3
    vm_size                 = "Standard_D4ds_v5"
    os_disk_size_gb         = 128
    node_pool_type          = "VirtualMachineScaleSets"
    kubernetes_version      = "1.32.7"
    max_pods                = 30
    enable_auto_scaling     = true
    min_count               = 2
    max_count               = 5
    identity_type           = "SystemAssigned"
    private_cluster_enabled = true
    admin_username          = "azureuser"
    network_plugin          = "azure"
    network_plugin_mode     = "overlay"
    load_balancer_sku       = "standard"
    network_policy          = "azure"
    outbound_type           = "loadBalancer"
    pod_cidr                = "10.244.0.0/16"
    service_cidr            = "10.1.0.0/16"
    dns_service_ip          = "10.1.0.10"
    date_tag_key            = "CreatedDate"
    created_by_tag_key      = "CreatedBy"
    created_by_value        = "Terraform-IaC"
  }
}

# --- Azure Container Registry (ACR) ---
acr_registries = {
  primary = {
    resource_prefix               = "acr"
    sku                           = "Standard"
    admin_enabled                 = true
    retention_days                = 30
    retention_enabled             = true
    georeplications               = []
    public_network_access_enabled = true
    zone_redundancy_enabled       = false
  }
}

# --- Azure Function Apps ---
# Workload type (notification) is tracked via tags, not in resource names
function_apps = {
  primary = {
    resource_prefix  = "funapp1"
    service_plan_key = "primary"
    site_config = {
      python_version = "3.12"
    }
    identity_type   = "UserAssigned"
    identity_prefix = "mi"
    tags            = { Workload = "notification" }
  }

  secondary = {
    resource_prefix  = "funapp2"
    service_plan_key = "primary"
    site_config = {
      python_version = "3.12"
    }
    identity_type   = "UserAssigned"
    identity_prefix = "mi"
    tags            = { Workload = "notification" }
  }

  tertiary = {
    resource_prefix  = "funapp3"
    service_plan_key = "primary"
    site_config = {
      python_version = "3.12"
    }
    identity_type   = "UserAssigned"
    identity_prefix = "mi"
    tags            = { Workload = "notification" }
  }
}

# --- Cloud Shell Infrastructure ---
# Cloud Shell Tags
cloudshell_tags = {}

# Cloud Shell VNet Configuration
cloudshell_vnet_address_space    = ["172.16.20.0/24"]
cloudshell_subnet_address_prefix = "172.16.20.0/25"
cloudshell_subnet_suffix         = "cloudshell"

# Cloud Shell Resource Settings
cloudshell_storage_quota            = 10
cloudshell_storage_sku              = "Standard"
cloudshell_storage_replication_type = "LRS"
cloudshell_relay_sku                = "Standard"
cloudshell_dns_ttl                  = 600

# Cloud Shell Delegation and Service Endpoints
cloudshell_delegation_name            = "cloudshell-delegation"
cloudshell_service_delegation_name    = "Microsoft.ContainerInstance/containerGroups"
cloudshell_service_delegation_actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
cloudshell_service_endpoints          = ["Microsoft.Storage"]
cloudshell_vnet_suffix                = "cloudshell"

# Cloud Shell Dynamic Naming Suffixes
container_subnet_suffix  = "containers"
relay_subnet_suffix      = "relay"
relay_namespace_prefix   = "relay"
private_endpoint_prefix  = "pe"
relay_endpoint_suffix    = "endpoint"
storage_endpoint_suffix  = "storage"
dns_link_suffix          = "link"
storage_account_prefix   = "st"
storage_share_prefix     = "share"
network_profile_prefix   = "netprofile"
network_interface_suffix = "nic"
ip_config_suffix         = "ipconfig"
delegation_suffix        = "delegation"
connection_suffix        = "connection"

# Cloud Shell Service Configuration
container_service_delegation_name  = "Microsoft.ContainerInstance/containerGroups"
container_subnet_service_endpoints = ["Microsoft.Storage"]
relay_subresource_names            = ["namespace"]
relay_is_manual_connection         = false
storage_default_action             = "Deny"
storage_suffix_length              = 6
storage_suffix_special             = false
storage_suffix_upper               = false
aci_service_principal_name         = "Azure Container Instance Service"
network_contributor_role_name      = "Network Contributor"
relay_contributor_role_name        = "Azure Relay Owner"
role_assignment_enabled            = false # Disabled due to insufficient permissions
private_dns_zone_name              = "privatelink.servicebus.windows.net"

# Cloud Shell VNet Subnet Configuration
vnet_address_space       = ["10.15.0.0/16"]
containers_subnet_prefix = ["10.15.99.0/24"]
relay_subnet_prefix      = ["10.15.99.0/24"]
