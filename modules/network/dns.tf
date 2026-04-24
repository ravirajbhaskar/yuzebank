# AKS private DNS zone (optional)
# resource "azurerm_dns_zone" "aks" {
#   name                = var.aks_dns_zone.name
#   resource_group_name = var.aks_dns_zone.resource_group_name
#   tags                = merge(var.common_tags, var.aks_dns_zone.tags)
# }

