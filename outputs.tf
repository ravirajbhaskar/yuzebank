############################################
# NETWORK
############################################
output "vnet_ids" {
  value = var.enable_network ? module.network[0].vnet_ids : {}
}

output "nsg_ids" {
  value       = var.enable_network ? module.network[0].nsg_ids : {}
  description = "The IDs of all Network Security Groups"
}

############################################
# IDENTITY & GOVERNANCE
############################################
output "key_vault_ids" {
  value = var.enable_identity_governance ? module.identity_governance[0].key_vault_ids : {}
}

output "key_vault_name" {
  description = "Primary Key Vault name for SSH key and certificate storage"
  value       = var.enable_identity_governance ? module.identity_governance[0].key_vault_name : ""
}

output "key_vault_uris" {
  value = var.enable_identity_governance ? module.identity_governance[0].key_vault_uris : {}
}

# SSH key provided via Azure DevOps variable group (not stored in Key Vault)

# Names and vault IDs only (no secret values)
# output "key_vault_seeded_secrets" {
#   value = module.identity_governance.key_vault_seeded_secrets
# }

# Removed the `managed_identity_ids` output as it is no longer valid.

# output "managed_identity_principal_ids" {
#   value = module.monitoring.managed_identity_principal_ids
# }

# output "log_analytics_workspace_ids" {
#   value = module.monitoring.log_analytics_workspace_ids
# }

# output "application_insights_ids" {
#   value = module.monitoring.application_insights_ids
# }

output "servicebus_namespace_ids" {
  value = var.enable_identity_governance ? module.identity_governance[0].servicebus_namespace_ids : {}
}

output "servicebus_queue_ids" {
  value = var.enable_identity_governance ? module.identity_governance[0].servicebus_queue_ids : {}
}

############################################
# DATA LAYER
############################################
output "storage_account_ids" {
  value = var.enable_database ? module.database[0].storage_account_ids : {}
}

output "storage_account_names" {
  value = var.enable_database ? module.database[0].storage_account_names : {}
}

output "storage_account_primary_access_keys" {
  value     = var.enable_database ? module.database[0].storage_account_primary_access_keys : {}
  sensitive = true
}

output "storage_container_names" {
  value = var.enable_database ? module.database[0].storage_container_names : {}
}

output "eventhub_namespace_ids" {
  value = var.enable_database ? module.database[0].eventhub_namespace_ids : {}
}

output "eventhub_ids" {
  value = var.enable_database ? module.database[0].eventhub_ids : {}
}


############################################
# COMPUTE / APP
############################################
output "aks_ids" {
  value = var.enable_compute ? module.compute[0].aks_ids : {}
}

output "function_app_ids" {
  value = var.enable_compute ? module.compute[0].function_app_ids : {}
}
