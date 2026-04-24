# Random suffix for function app uniqueness
resource "random_string" "func_suffix" {
  for_each = var.function_apps
  length   = 6
  special  = false
  upper    = false
}

# Azure Function Apps
resource "azurerm_linux_function_app" "functions" {
  for_each            = var.function_apps
  name                = "${each.value.resource_prefix}-${var.client_name}-${var.environment}-${var.location_code}-${random_string.func_suffix[each.key].result}"
  location            = var.location
  resource_group_name = azurerm_resource_group.app_rg.name

  service_plan_id            = azurerm_service_plan.app_plan[each.value.service_plan_key].id
  storage_account_name       = var.shared_storage_account_name
  storage_account_access_key = var.shared_storage_account_key

  site_config {
    application_stack {
      python_version = each.value.site_config.python_version
    }
  }

  identity {
    type         = each.value.identity_type
    identity_ids = [var.managed_identity_ids["${each.key}"]]
  }

  tags = each.value.tags
}
