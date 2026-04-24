# ───────── Key Vault (root expects plural names) ─────────
# Plural list outputs to satisfy root references
output "key_vault_ids" {
  value = { for k, v in azurerm_key_vault.kv : k => v.id }
}

output "key_vault_names" {
  value       = { for k, v in azurerm_key_vault.kv : k => v.name }
  description = "Map of Key Vault names with dynamic random suffix"
}

output "key_vault_uris" {
  value = { for k, v in azurerm_key_vault.kv : k => v.vault_uri }
}

# For compatibility - return first key vault if exists
output "key_vault_id" {
  value = length(azurerm_key_vault.kv) > 0 ? values(azurerm_key_vault.kv)[0].id : ""
}

output "key_vault_name" {
  value       = length(azurerm_key_vault.kv) > 0 ? values(azurerm_key_vault.kv)[0].name : ""
  description = "Name of the first Key Vault (with random suffix)"
}

output "key_vault_uri" {
  value = length(azurerm_key_vault.kv) > 0 ? values(azurerm_key_vault.kv)[0].vault_uri : ""
}

# ───────── Service Bus ─────────
output "servicebus_namespace_ids" {
  value = { for k, v in azurerm_servicebus_namespace.sb_namespace : k => v.id }
}

output "servicebus_queue_ids" {
  value = { for k, v in azurerm_servicebus_queue.sb_queue : k => v.id }
}

# ───────── Managed Identities ─────────
output "managed_identity_ids" {
  value = { for k, v in azurerm_user_assigned_identity.managed_identities : k => v.id }
}

output "managed_identity_principal_ids" {
  value = { for k, v in azurerm_user_assigned_identity.managed_identities : k => v.principal_id }
}

output "managed_identity_client_ids" {
  value = { for k, v in azurerm_user_assigned_identity.managed_identities : k => v.client_id }
}

# ───────── Key Vault Access Policies ─────────
# Export AGW access policy ID to ensure it's created before AGW resource
output "agw_access_policy_ids" {
  value       = { for k, v in azurerm_key_vault_access_policy.agw_cert_access : k => v.id }
  description = "IDs of AGW Key Vault access policies to enforce dependency ordering"
}

# ───────── Key Vault Secrets ─────────

# NOTE: SQL admin password secret outputs were removed because this module does
# not declare `azurerm_key_vault_secret.sql_admin_password` by default. If you
# want these outputs, create the secret resource in this module or expose it
# from the caller and re-add the outputs.

# SSH public key provided via Azure DevOps variable group (not stored in Key Vault)

output "identity_rg_name" {
  value       = azurerm_resource_group.identity_rg.name
  description = "Name of the resource group created by identity_governance module for Key Vault and Service Bus"
}

# ───────── Application Resource Group ─────────
# App RG is now created in compute module - these outputs are deprecated
