# =============================================================================
# NO DATA SOURCES NEEDED
# Using module outputs directly for better reliability in same-run apply
# =============================================================================

# Random suffix for global uniqueness
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
  numeric = true
  lower   = true
}

locals {
  # Use randomly generated suffix for global uniqueness
  effective_random_suffix = random_string.suffix.result
}

# ─────────────────────────────────────────
# NETWORK (VNets, Subnets, Front Door, LB)
# ─────────────────────────────────────────
module "network" {
  count  = var.enable_network ? 1 : 0
  source = "./modules/network"

  # Centralized variables
  client_name   = var.client_name
  environment   = var.environment
  location_code = var.location_code
  location      = var.location
  common_tags   = var.common_tags
  rg_prefix     = var.rg_prefix

  # Network naming prefixes
  vnet_prefix                   = var.vnet_prefix
  subnet_prefix                 = var.subnet_prefix
  nsg_prefix                    = var.nsg_prefix
  network_resource_group_prefix = var.network_resource_group_prefix
  nsg_rules                     = var.nsg_rules
  nsg_subnets                   = var.nsg_subnets

  # Network configuration
  vnets                = var.vnets
  application_gateways = var.application_gateways
  # aks_dns_zone         = var.aks_dns_zone  # NOT REQUIRED - Commented out

  # Application Gateway naming variables
  public_ip_prefix       = var.public_ip_prefix
  agw_prefix             = var.agw_prefix
  agw_subnet_suffix      = var.agw_subnet_suffix
  ip_config_suffix       = var.ip_config_suffix
  frontend_port_suffix   = var.frontend_port_suffix
  public_frontend_suffix = var.public_frontend_suffix
  backend_pool_suffix    = var.backend_pool_suffix
  http_settings_suffix   = var.http_settings_suffix
  http_listener_suffix   = var.http_listener_suffix
  rule_suffix            = var.rule_suffix
  protocol_suffix        = var.protocol_suffix

  # VNet Peering configuration
  enable_cloudshell_peering = var.enable_cloudshell_peering

  # Key Vault configuration for dynamic certificate fetching
  key_vault_name           = try(module.identity_governance[0].key_vault_name, "")
  key_vault_resource_group = try(module.identity_governance[0].identity_rg_name, "")
  certificate_names        = var.certificate_names

  # AGW identity and access policy
  agw_managed_identity_id = var.enable_identity_governance ? try(module.identity_governance[0].managed_identity_ids["agw"], null) : null
  agw_access_policy_ids   = var.enable_identity_governance ? try(module.identity_governance[0].agw_access_policy_ids, {}) : {}
}


# ─────────────────────────────────────────
# COMPUTE / APP (AKS, ACR, Plans, WebApps, Funcs, NH)
# ─────────────────────────────────────────
# MUST BE CREATED FIRST: Creates app_rg used by identity_governance and database modules
module "compute" {
  count      = var.enable_compute ? 1 : 0
  source     = "./modules/compute"
  depends_on = [module.network]

  # Centralized variables
  client_name   = var.client_name
  environment   = var.environment
  location_code = var.location_code
  location      = var.location
  common_tags   = var.common_tags
  rg_prefix     = var.rg_prefix

  # Random suffix for globally unique names
  random_suffix = local.effective_random_suffix

  # Required variables
  resource_prefix = var.resource_prefix
  vnet_rg_name    = var.enable_network ? module.network[0].vnet_rg_name : ""
  netprofile_name = var.netprofile_name

  # Cloud Shell configuration
  cloudshell_tags                       = var.cloudshell_tags
  cloudshell_storage_quota              = var.cloudshell_storage_quota
  cloudshell_storage_sku                = var.cloudshell_storage_sku
  cloudshell_storage_replication_type   = var.cloudshell_storage_replication_type
  cloudshell_relay_sku                  = var.cloudshell_relay_sku
  cloudshell_dns_ttl                    = var.cloudshell_dns_ttl
  cloudshell_vnet_address_space         = var.cloudshell_vnet_address_space
  cloudshell_subnet_address_prefix      = var.cloudshell_subnet_address_prefix
  cloudshell_subnet_suffix              = var.cloudshell_subnet_suffix
  cloudshell_delegation_name            = var.cloudshell_delegation_name
  cloudshell_service_delegation_name    = var.cloudshell_service_delegation_name
  cloudshell_service_delegation_actions = var.cloudshell_service_delegation_actions
  cloudshell_service_endpoints          = var.cloudshell_service_endpoints
  cloudshell_vnet_suffix                = var.cloudshell_vnet_suffix
  main_vnet_id                          = var.enable_network ? module.network[0].vnet_ids["vnet-${var.client_name}-${var.environment}-${var.location_code}"] : ""

  # Cloud Shell dynamic naming variables
  subnet_prefix                      = var.subnet_prefix
  container_subnet_suffix            = var.container_subnet_suffix
  relay_subnet_suffix                = var.relay_subnet_suffix
  relay_namespace_prefix             = var.relay_namespace_prefix
  private_endpoint_prefix            = var.private_endpoint_prefix
  relay_endpoint_suffix              = var.relay_endpoint_suffix
  storage_endpoint_suffix            = var.storage_endpoint_suffix
  dns_link_suffix                    = var.dns_link_suffix
  storage_account_prefix             = var.storage_account_prefix
  storage_share_prefix               = var.storage_share_prefix
  network_profile_prefix             = var.network_profile_prefix
  network_interface_suffix           = var.network_interface_suffix
  ip_config_suffix                   = var.ip_config_suffix
  delegation_suffix                  = var.delegation_suffix
  connection_suffix                  = var.connection_suffix
  container_service_delegation_name  = var.container_service_delegation_name
  container_subnet_service_endpoints = var.container_subnet_service_endpoints
  relay_subresource_names            = var.relay_subresource_names
  relay_is_manual_connection         = var.relay_is_manual_connection
  storage_default_action             = var.storage_default_action
  storage_suffix_length              = var.storage_suffix_length
  storage_suffix_special             = var.storage_suffix_special
  storage_suffix_upper               = var.storage_suffix_upper
  network_contributor_role_name      = var.network_contributor_role_name
  relay_contributor_role_name        = var.relay_contributor_role_name
  role_assignment_enabled            = var.role_assignment_enabled
  private_dns_zone_name              = var.private_dns_zone_name

  # Network resource naming variables
  vnet_prefix                   = var.vnet_prefix
  network_resource_group_prefix = var.network_resource_group_prefix
  # Compute naming prefixes
  node_pool_prefix = var.node_pool_prefix

  # Virtual network configuration
  vnet_name                = "${var.vnet_prefix}-${var.client_name}-${var.environment}-${var.location_code}"
  vnet_address_space       = var.vnet_address_space
  containers_subnet_name   = "${var.subnet_prefix}-containers-${var.client_name}-${var.environment}-${var.location_code}"
  containers_subnet_prefix = var.containers_subnet_prefix
  relay_subnet_name        = "${var.subnet_prefix}-relay-${var.client_name}-${var.environment}-${var.location_code}"
  relay_subnet_prefix      = var.relay_subnet_prefix
  relay_namespace_name     = "${var.relay_namespace_prefix}-${var.client_name}-${var.environment}-${var.location_code}"

  # Compute resources - Function Apps will be created without managed identities initially
  function_apps = var.function_apps

  # Managed Identity IDs - will be empty on first run, populated on subsequent runs
  managed_identity_ids = var.enable_identity_governance ? try(module.identity_governance[0].managed_identity_ids, {}) : {}

  # Shared Storage Account from Database Module for Function Apps
  shared_storage_account_name = var.enable_database ? module.database[0].storage_account_names["primary"] : ""
  shared_storage_account_key  = var.enable_database ? module.database[0].storage_account_primary_access_keys["primary"] : ""

  # AKS and ACR with dynamic subnet references from network module outputs
  aks_clusters = var.enable_network ? {
    for k, v in var.aks_clusters : k => merge(v, {
      aks_subnet_id  = module.network[0].subnet_ids["${var.vnet_prefix}-${var.client_name}-${var.environment}-${var.location_code}-${var.subnet_prefix}-aks-${var.client_name}-${var.environment}-${var.location_code}"]
      aks_vnet_id    = module.network[0].vnet_ids["${var.vnet_prefix}-${var.client_name}-${var.environment}-${var.location_code}"]
      client_name    = var.client_name
      environment    = var.environment
      location_code  = var.location_code
      ssh_public_key = var.aks_ssh_public_key
      tags           = var.common_tags
    })
  } : {}
  acr_registries     = var.acr_registries
  date_format        = var.date_format
  managed_identities = var.managed_identities

  # SSH public key from Azure DevOps library variable
  aks_ssh_public_key = var.aks_ssh_public_key

  # Azure Container Instance service principal name
  aci_service_principal_name = var.aci_service_principal_name
}


# ─────────────────────────────────────────
# IDENTITY & GOVERNANCE (KV, UAMI, LAW, AppI, SB)
# ─────────────────────────────────────────
module "identity_governance" {
  count  = var.enable_identity_governance ? 1 : 0
  source = "./modules/identity"
  # Centralized variables
  client_name   = var.client_name
  environment   = var.environment
  location_code = var.location_code
  location      = var.location
  common_tags   = var.common_tags
  rg_prefix     = var.rg_prefix

  # Random suffix for globally unique names
  random_suffix = local.effective_random_suffix

  # Key Vault + RBAC + seed secrets
  key_vaults                 = var.key_vaults
  kv_rbac_group_object_id    = var.kv_rbac_group_object_id
  create_kv_rbac_assignments = var.create_kv_rbac_assignments
  sku_name                   = var.sku_name
  purge_protection_enabled   = var.purge_protection_enabled
  key_permissions            = var.key_permissions
  secret_permissions         = var.secret_permissions
  certificate_permissions    = var.certificate_permissions
  kv_secrets_user_role       = var.kv_secrets_user_role
  kv_admin_role              = var.kv_admin_role
  kv_cert_officer_role       = var.kv_cert_officer_role
  tags                       = var.tags
  eventhub_rg_name           = var.eventhub_rg_name

  managed_identities    = var.managed_identities
  servicebus_namespaces = var.servicebus_namespaces
  servicebus_queues     = var.servicebus_queues
  vnet_rg_name          = var.enable_network ? module.network[0].vnet_rg_name : ""
}



# ─────────────────────────────────────────
# DATA LAYER (SQL MI, Storage, Event Hub, Redis)
# ─────────────────────────────────────────
module "database" {
  count  = var.enable_database ? 1 : 0
  source = "./modules/database"

  # KV access policies must exist first
  depends_on = [module.identity_governance]

  # Centralized variables
  client_name         = var.client_name
  environment         = var.environment
  location_code       = var.location_code
  resource_group_name = var.enable_compute ? module.compute[0].app_rg_name : ""
  location            = var.location
  common_tags         = var.common_tags
  rg_prefix           = var.rg_prefix

  # Random suffix for globally unique names
  random_suffix = local.effective_random_suffix

  # Resource group names
  storage_rg_name  = var.storage_rg_name
  sql_rg_name      = var.sql_rg_name
  eventhub_rg_name = var.eventhub_rg_name

  # Key Vault ID for storing SQL admin password
  key_vault_id = var.enable_identity_governance ? module.identity_governance[0].key_vault_ids["primary"] : ""

  # Database configuration
  storage_accounts    = var.storage_accounts
  storage_containers  = var.storage_containers
  eventhub_namespaces = var.eventhub_namespaces
  eventhubs           = var.eventhubs
  redis_caches        = var.redis_caches

  # SQL databases with dynamic subnet reference from network module outputs
  sql_databases = var.enable_network ? {
    for k, v in var.sql_databases : k => merge(v, {
      sql_subnet_id = module.network[0].subnet_ids["${var.vnet_prefix}-${var.client_name}-${var.environment}-${var.location_code}-${var.subnet_prefix}-sql-${var.client_name}-${var.environment}-${var.location_code}"]
    })
  } : {}
}


# ─────────────────────────────────────────
# MONITORING & OBSERVABILITY
# ─────────────────────────────────────────
module "monitoring" {
  count  = var.enable_monitoring ? 1 : 0
  source = "./modules/monitoring"

  # Centralized variables
  client_name     = var.client_name
  environment     = var.environment
  location_code   = var.location_code
  location        = var.location
  common_tags     = var.common_tags
  monitor_rg_name = var.monitor_rg_name
  rg_prefix       = var.rg_prefix

  # Monitoring configuration
  notification_hub_namespaces = var.notification_hub_namespaces
  notification_hubs           = var.notification_hubs
  log_analytics_workspaces    = var.log_analytics_workspaces
  application_insights        = var.application_insights
}

