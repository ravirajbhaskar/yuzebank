# Event Hubs
output "eventhub_namespace_ids" {
  value = { for k, v in azurerm_eventhub_namespace.ehns : k => v.id }
}
output "eventhub_ids" {
  value = { for k, v in azurerm_eventhub.eh : k => v.id }
}
output "eventhub_rg_name" {
  value = azurerm_resource_group.eventhub_rg.name
}
# Storage
output "storage_account_ids" {
  value = { for k, v in azurerm_storage_account.sa : k => v.id }
}
output "storage_account_names" {
  value = { for k, v in azurerm_storage_account.sa : k => v.name }
}
output "storage_account_primary_access_keys" {
  value     = { for k, v in azurerm_storage_account.sa : k => v.primary_access_key }
  sensitive = true
}
output "storage_container_names" {
  value = { for k, v in azurerm_storage_container.sc : k => v.name }
}
output "storage_rg_name" {
  value = local.app_rg_name
}

# Redis Cache
output "redis_cache_ids" {
  value = { for k, v in azurerm_redis_cache.redis : k => v.id }
}
output "redis_cache_hostnames" {
  value = { for k, v in azurerm_redis_cache.redis : k => v.hostname }
}
output "redis_cache_primary_access_keys" {
  value     = { for k, v in azurerm_redis_cache.redis : k => v.primary_access_key }
  sensitive = true
}
output "redis_rg_names" {
  value = local.app_rg_name
}

# SQL Database - Single server outputs
output "sql_server_ids" {
  value = azurerm_mssql_server.sql_server.id
}

output "sql_server_names" {
  value = azurerm_mssql_server.sql_server.name
}

output "sql_server_fqdns" {
  value = azurerm_mssql_server.sql_server.fully_qualified_domain_name
}

output "sql_database_ids" {
  value = { for k, v in azurerm_mssql_database.sql_db : k => v.id }
}

output "sql_database_names" {
  value = { for k, v in azurerm_mssql_database.sql_db : k => v.name }
}

output "sql_rg_names" {
  value = azurerm_resource_group.sql_rg.name
}

# SQL Admin Password Secret
output "sql_admin_password_secret_name" {
  description = "The name of the Key Vault secret containing the SQL admin password"
  value       = azurerm_key_vault_secret.sql_admin_password.name
}

output "sql_admin_password_secret_id" {
  description = "The ID of the Key Vault secret containing the SQL admin password"
  value       = azurerm_key_vault_secret.sql_admin_password.id
}