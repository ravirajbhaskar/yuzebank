# Service plan for Function Apps
resource "azurerm_service_plan" "app_plan" {
  for_each = toset(["primary"]) # Create a primary service plan

  name                = "asp-${var.client_name}-${var.environment}-${var.location_code}"
  location            = var.location
  resource_group_name = azurerm_resource_group.app_rg.name
  os_type             = "Linux"
  sku_name            = "P1v3" # Premium v3 plan
  tags                = var.common_tags
}
