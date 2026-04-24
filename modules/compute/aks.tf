locals {
  today_date = formatdate(var.date_format, timestamp())
}

# Azure Kubernetes Service cluster
resource "azurerm_kubernetes_cluster" "aks" {
  for_each = var.aks_clusters

  name                      = "${each.value.resource_prefix}-${var.client_name}-${var.environment}-${var.location_code}"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.app_rg.name
  dns_prefix                = "${each.value.resource_prefix}-${var.client_name}"
  kubernetes_version        = each.value.kubernetes_version
  sku_tier                  = each.value.sku_tier
  oidc_issuer_enabled       = true
  workload_identity_enabled = true
  azure_active_directory_role_based_access_control {
    tenant_id              = "e47cda1d-4b77-426f-a278-1dfb585535c1"   # Azure AD Tenant ID
    admin_group_object_ids = ["e29b2e39-6f15-4917-ac82-5b458241facb"] # Azure AD Group Object ID for AKS Admins
    azure_rbac_enabled     = false
  }


  default_node_pool {
    name                 = "${var.node_pool_prefix}${var.environment}"
    vm_size              = each.value.vm_size
    os_disk_size_gb      = each.value.os_disk_size_gb
    type                 = each.value.node_pool_type
    orchestrator_version = each.value.orchestrator_version
    vnet_subnet_id       = each.value.aks_subnet_id
    max_pods             = each.value.max_pods

    # Autoscaling configuration
    auto_scaling_enabled = each.value.enable_auto_scaling
    min_count            = each.value.enable_auto_scaling ? each.value.min_count : null
    max_count            = each.value.enable_auto_scaling ? each.value.max_count : null
    node_count           = each.value.enable_auto_scaling ? null : each.value.node_count
  }

  identity {
    type = each.value.identity_type
  }

  private_cluster_enabled             = each.value.private_cluster_enabled
  private_dns_zone_id                 = each.value.private_cluster_enabled ? "System" : null
  private_cluster_public_fqdn_enabled = false

  # SSH access - only if SSH key is provided
  dynamic "linux_profile" {
    for_each = each.value.ssh_public_key != "" && each.value.ssh_public_key != null ? [1] : []
    content {
      admin_username = each.value.admin_username

      ssh_key {
        key_data = each.value.ssh_public_key
      }
    }
  }

  network_profile {
    network_plugin      = each.value.network_plugin
    network_plugin_mode = try(each.value.network_plugin_mode, null)
    load_balancer_sku   = each.value.load_balancer_sku
    network_policy      = each.value.network_policy
    outbound_type       = try(each.value.outbound_type, "loadBalancer")
    pod_cidr            = try(each.value.pod_cidr, null)
    service_cidr        = each.value.service_cidr
    dns_service_ip      = each.value.dns_service_ip
  }

  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      linux_profile,
      identity,
      kubelet_identity,
      default_node_pool,
    ]
  }

  tags = merge(var.common_tags, {
    "${each.value.date_tag_key}"       = local.today_date
    "${each.value.created_by_tag_key}" = each.value.created_by_value
  })
}

# User node pool for workloads
resource "azurerm_kubernetes_cluster_node_pool" "user_pool" {
  for_each = var.aks_clusters

  name                  = "yuzepool${var.environment}"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks[each.key].id
  vm_size               = each.value.vm_size
  vnet_subnet_id        = each.value.aks_subnet_id

  # Autoscaling configuration
  auto_scaling_enabled = true
  min_count            = each.value.min_count
  max_count            = each.value.max_count

  mode = "User"

  tags = merge(var.common_tags, {
    "${each.value.date_tag_key}"       = local.today_date
    "${each.value.created_by_tag_key}" = each.value.created_by_value
  })
}

# Grant AKS managed identity AcrPull role on ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  for_each = {
    for pair in flatten([
      for aks_key in keys(azurerm_kubernetes_cluster.aks) : [
        for acr_key in keys(azurerm_container_registry.acr) : {
          aks_key = aks_key
          acr_key = acr_key
        }
      ]
    ]) : "${pair.aks_key}-${pair.acr_key}" => pair
  }

  scope                = azurerm_container_registry.acr[each.value.acr_key].id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks[each.value.aks_key].kubelet_identity[0].object_id

  # Protective lifecycle: prevent accidental destroy of role assignments
  lifecycle {
    prevent_destroy = true
  }

  # Ensure we create role assignments after ACR and AKS exist
  depends_on = [
    azurerm_container_registry.acr,
    azurerm_kubernetes_cluster.aks,
  ]
}