# Resource group for identity and governance
resource "azurerm_resource_group" "identity_rg" {
  name     = "${var.rg_prefix}-identity-${var.client_name}-${var.environment}-${var.location_code}"
  location = var.location
  tags     = var.common_tags
}

# Current client configuration
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  for_each = var.key_vaults

  name                = "${each.value.resource_prefix}-${var.client_name}-${var.environment}-${var.location_code}-${var.random_suffix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.identity_rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = var.sku_name

  purge_protection_enabled   = var.purge_protection_enabled
  rbac_authorization_enabled = var.create_kv_rbac_assignments # Enable RBAC only if assignments will be created

  # Network access configuration
  network_acls {
    default_action             = "Allow"         # Allow by default for Terraform operations; restrict later if needed
    bypass                     = "AzureServices" # Allow Azure services to access
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }

  # Use access policies when RBAC is disabled
  dynamic "access_policy" {
    for_each = var.create_kv_rbac_assignments ? [] : [1]
    content {
      tenant_id = data.azurerm_client_config.current.tenant_id
      object_id = var.kv_rbac_group_object_id

      key_permissions = var.key_permissions

      secret_permissions = var.secret_permissions

      certificate_permissions = var.certificate_permissions
    }
  }

  tags = merge(
    var.common_tags,
    {
      "access-policy-sync" = "2025-11-20"
    }
  )
}

# RBAC role assignments for Key Vault
resource "azurerm_role_assignment" "kv_secrets_user" {
  for_each             = var.create_kv_rbac_assignments ? var.key_vaults : {}
  scope                = azurerm_key_vault.kv[each.key].id
  role_definition_name = var.kv_secrets_user_role
  principal_id         = var.kv_rbac_group_object_id
}

resource "azurerm_role_assignment" "kv_admin" {
  for_each             = var.create_kv_rbac_assignments ? var.key_vaults : {}
  scope                = azurerm_key_vault.kv[each.key].id
  role_definition_name = var.kv_admin_role
  principal_id         = var.kv_rbac_group_object_id
}

resource "azurerm_role_assignment" "kv_cert_officer" {
  for_each             = var.create_kv_rbac_assignments ? var.key_vaults : {}
  scope                = azurerm_key_vault.kv[each.key].id
  role_definition_name = var.kv_cert_officer_role
  principal_id         = var.kv_rbac_group_object_id
}

# Key Vault access policy for App Gateway
resource "azurerm_key_vault_access_policy" "agw_cert_access" {
  for_each = var.key_vaults

  key_vault_id = azurerm_key_vault.kv[each.key].id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.managed_identities["agw"].principal_id

  certificate_permissions = [
    "Get",
    "List"
  ]

  secret_permissions = [
    "Get",
    "List"
  ]

  depends_on = [azurerm_user_assigned_identity.managed_identities]
}

# Key Vault access policy for current user (Terraform client and certificate operations)
resource "azurerm_key_vault_access_policy" "terraform_client" {
  for_each = var.key_vaults

  key_vault_id = azurerm_key_vault.kv[each.key].id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  certificate_permissions = [
    "Get",
    "List",
    "Create",
    "Delete",
    "Update",
    "Import",
    "Purge"
  ]

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Purge"
  ]

  key_permissions = [
    "Get",
    "List",
    "Create",
    "Delete",
    "Update"
  ]

  lifecycle {
    replace_triggered_by = [azurerm_key_vault.kv]
  }
}