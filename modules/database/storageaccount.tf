# Storage accounts
resource "azurerm_storage_account" "sa" {
  for_each = var.storage_accounts

  # Remove invalid characters and ensure lowercase
  name                = substr(lower(replace(replace("${each.value.resource_prefix}${var.client_name}${var.environment}${var.location_code}${each.key}${var.random_suffix}", "-", ""), "#", "")), each.value.substr_start, each.value.max_name_length)
  resource_group_name = local.app_rg_name # Reference the app resource group passed from compute module
  location            = var.location

  account_kind             = each.value.account_kind
  account_tier             = each.value.account_tier
  account_replication_type = each.value.account_replication_type
  access_tier              = each.value.access_tier

  min_tls_version                 = each.value.min_tls_version
  allow_nested_items_to_be_public = each.value.allow_nested_items_to_be_public
  https_traffic_only_enabled      = each.value.https_traffic_only_enabled
  public_network_access_enabled   = each.value.public_network_access_enabled
  is_hns_enabled                  = each.value.is_hns_enabled
  sftp_enabled                    = each.value.sftp_enabled

  tags = var.common_tags
}

resource "azurerm_storage_container" "sc" {
  for_each = var.storage_containers

  name                  = "${each.value.resource_prefix}-${var.client_name}-${var.environment}-${var.location_code}-${each.key}"
  storage_account_id    = azurerm_storage_account.sa[each.value.storage_account_key].id
  container_access_type = each.value.container_access_type
}