# Resource group for SQL Database
resource "azurerm_resource_group" "sql_rg" {
  name     = "${var.rg_prefix}-sql-${var.client_name}-${var.environment}-${var.location_code}"
  location = var.location
  tags     = var.common_tags
}

# Local values and SQL admin password
locals {
  app_rg_name       = var.resource_group_name
  sql_server_config = values(var.sql_databases)[0]
  sql_server_name   = "${local.sql_server_config.sql_server_prefix}-${var.client_name}-${var.environment}-${var.location_code}-${var.random_suffix}"
}

resource "random_password" "sql_admin_password" {
  length  = 16
  special = true
  upper   = true
  lower   = true
  numeric = true
  # Ensure password meets SQL Server complexity requirements
  min_upper   = 2
  min_lower   = 2
  min_numeric = 2
  min_special = 2
}

# Store SQL Server admin password in Key Vault
resource "azurerm_key_vault_secret" "sql_admin_password" {
  name         = "${local.sql_server_name}-admin-password"
  value        = random_password.sql_admin_password.result
  key_vault_id = var.key_vault_id

  tags = var.common_tags

  lifecycle {
    ignore_changes = [value]
  }
}

# Read the password back from Key Vault
data "azurerm_key_vault_secret" "sql_admin_password" {
  name         = azurerm_key_vault_secret.sql_admin_password.name
  key_vault_id = var.key_vault_id

  depends_on = [azurerm_key_vault_secret.sql_admin_password]
}

# Single SQL Server for all databases
resource "azurerm_mssql_server" "sql_server" {
  # Use the first database configuration for server settings
  name                          = local.sql_server_name
  resource_group_name           = azurerm_resource_group.sql_rg.name
  location                      = var.location
  version                       = local.sql_server_config.sql_server_version
  administrator_login           = local.sql_server_config.admin_username
  administrator_login_password  = data.azurerm_key_vault_secret.sql_admin_password.value
  minimum_tls_version           = local.sql_server_config.minimum_tls_version
  public_network_access_enabled = local.sql_server_config.public_network_access_enabled

  tags = var.common_tags

  depends_on = [data.azurerm_key_vault_secret.sql_admin_password]
}

# Multiple databases on the single SQL server
resource "azurerm_mssql_database" "sql_db" {
  for_each = var.sql_databases

  name                 = "${each.value.sql_database_prefix}-${var.client_name}-${var.environment}-${var.location_code}"
  server_id            = azurerm_mssql_server.sql_server.id
  sku_name             = each.value.sku_name
  max_size_gb          = each.value.max_size_gb
  zone_redundant       = each.value.zone_redundant
  storage_account_type = each.value.storage_account_type
  geo_backup_enabled   = each.value.geo_backup_enabled
  read_scale           = each.value.read_scale
  collation            = each.value.collation

  # Only set license_type for "application" database
  license_type = each.key == "application" ? each.value.license_type : null

  # Serverless-specific settings (only applied if serverless SKU is used)
  auto_pause_delay_in_minutes = each.value.auto_pause_delay_in_minutes
  min_capacity                = each.value.min_capacity

  # Long-term retention only for "application" database
  dynamic "long_term_retention_policy" {
    for_each = each.key == "application" ? [1] : []

    content {
      weekly_retention  = each.value.weekly_retention
      monthly_retention = each.value.monthly_retention
      yearly_retention  = each.value.yearly_retention
    }
  }

  tags = var.common_tags
}