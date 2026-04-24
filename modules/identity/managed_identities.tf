# Create user-assigned managed identities (in identity resource group)
resource "azurerm_user_assigned_identity" "managed_identities" {
  for_each = var.managed_identities

  # Dynamically compute the name: mi-{resource_prefix}-{client_name}-{environment}-{location_code}
  name                = "mi-${each.value.resource_prefix}-${var.client_name}-${var.environment}-${var.location_code}"
  location            = var.location
  resource_group_name = azurerm_resource_group.identity_rg.name # ✅ Use identity RG reference

  tags = each.value.tags
}
