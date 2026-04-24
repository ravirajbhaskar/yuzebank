# Redis caches
resource "azurerm_redis_cache" "redis" {
  for_each = var.redis_caches

  name                = "${each.value.resource_prefix}-${var.client_name}-${var.environment}-${var.location_code}-${var.random_suffix}"
  location            = var.location
  resource_group_name = local.app_rg_name
  capacity            = each.value.capacity
  family              = each.value.family
  sku_name            = each.value.sku_name

  tags = var.common_tags
}
