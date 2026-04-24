# Resource group for Application Gateway
resource "azurerm_resource_group" "agw_rg" {
  name     = "${var.rg_prefix}-agw-${var.client_name}-${var.environment}-${var.location_code}"
  location = var.location
  tags     = var.common_tags
}

# Key Vault access policy dependency
locals {
  _agw_access_policies = length(var.agw_access_policy_ids) > 0 ? values(var.agw_access_policy_ids) : []
}

# Fetch Key Vault for certificates
data "azurerm_key_vault" "certificate_vault" {
  count               = var.key_vault_name != "" ? 1 : 0
  name                = var.key_vault_name
  resource_group_name = var.key_vault_resource_group
}

# ==========================================
# Local: Determine which certificates to fetch
# ==========================================
# Only attempt to fetch certificates that:
# 1. Are marked as enabled in configuration
# 2. Key Vault is specified
# 3. Key Vault resource exists (has been created)
# Certificates will be fetched during apply after being uploaded to Key Vault
locals {
  certs_to_fetch = {
    for cert_key, cert_config in var.certificate_names : cert_key => cert_config
    if cert_config.enabled && var.key_vault_name != "" && try(data.azurerm_key_vault.certificate_vault[0].id, null) != null
  }
}

# Fetch certificate secret IDs from Key Vault
data "azurerm_key_vault_certificate" "app_gateway_certs" {
  for_each = local.certs_to_fetch

  name         = each.value.certificate_name
  key_vault_id = data.azurerm_key_vault.certificate_vault[0].id

  depends_on = [data.azurerm_key_vault.certificate_vault]
}

# Certificate IDs with fallback for missing certificates
locals {
  certificate_ids = {
    for cert_key, cert_config in var.certificate_names : cert_key => try(
      data.azurerm_key_vault_certificate.app_gateway_certs[cert_key].versionless_secret_id,
      ""
    )
  }
}
# Application Gateway certificate IDs with dummy fallbacks
locals {
  app_gateway_cert_ids = {
    for cert_key, cert_config in var.certificate_names : cert_key => (
      try(
        data.azurerm_key_vault_certificate.app_gateway_certs[cert_key].secret_id,
        # Fallback to dummy secret ID if certificate doesn't exist
        var.key_vault_name != "" ? "${data.azurerm_key_vault.certificate_vault[0].vault_uri}secrets/${cert_config.certificate_name}/00000000000000000000000000000000" : ""
      )
    ) if cert_config.enabled
  }
}

# Create public IP for Application Gateway
resource "azurerm_public_ip" "agw_pip" {
  for_each = var.application_gateways

  name                = "${var.public_ip_prefix}-${var.agw_prefix}-${var.client_name}-${var.environment}-${var.location_code}-${each.key}"
  location            = var.location
  resource_group_name = azurerm_resource_group.agw_rg.name
  allocation_method   = each.value.public_ip_allocation_method
  sku                 = each.value.public_ip_sku
  tags                = var.common_tags
  # Do not treat tag-only changes as meaningful for lifecycle; ignore tag diffs so
  # small/benign tag updates don't trigger unnecessary resource updates.
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_application_gateway" "this" {
  for_each = var.application_gateways

  name                = "${each.value.resource_prefix}-${var.client_name}-${var.environment}-${var.location_code}"
  location            = var.location
  resource_group_name = azurerm_resource_group.agw_rg.name
  # Ensure Key Vault access policy is created before AGW tries to access the secret
  depends_on = [azurerm_subnet.subnet]

  sku {
    name     = each.value.sku.name # e.g., "WAF_v2" or "Standard_v2"
    tier     = each.value.sku.tier
    capacity = each.value.enable_autoscale != true ? each.value.sku.capacity : null
  }

  # Autoscale Configuration (optional)
  dynamic "autoscale_configuration" {
    for_each = each.value.enable_autoscale == true ? [1] : []
    content {
      min_capacity = each.value.autoscale_min_capacity
      max_capacity = each.value.autoscale_max_capacity
    }
  }

  # Managed Identity for Key Vault access (optional)
  # Included only when a managed identity ID is provided from identity_governance module
  dynamic "identity" {
    for_each = var.agw_managed_identity_id == null ? [] : [var.agw_managed_identity_id]
    content {
      type         = "UserAssigned"
      identity_ids = [identity.value]
    }
  }

  gateway_ip_configuration {
    name      = "${var.agw_prefix}-${var.client_name}-${var.environment}-${var.location_code}-${each.key}-${var.ip_config_suffix}"
    subnet_id = azurerm_subnet.subnet["${var.vnet_prefix}-${var.client_name}-${var.environment}-${var.location_code}-${var.subnet_prefix}-${var.agw_subnet_suffix}-${var.client_name}-${var.environment}-${var.location_code}"].id
  }

  # Dynamic Frontend Ports
  dynamic "frontend_port" {
    for_each = each.value.frontend_ports
    content {
      name = "${var.agw_prefix}-${var.client_name}-${var.environment}-${var.location_code}-${each.key}-port-${frontend_port.key}"
      port = frontend_port.value.port
    }
  }

  frontend_ip_configuration {
    name                 = "${var.agw_prefix}-${var.client_name}-${var.environment}-${var.location_code}-${each.key}-${var.public_frontend_suffix}"
    public_ip_address_id = azurerm_public_ip.agw_pip[each.key].id
  }

  # Dynamic Backend Address Pools
  dynamic "backend_address_pool" {
    for_each = each.value.backend_address_pools
    content {
      name         = "${var.agw_prefix}-${var.client_name}-${var.environment}-${var.location_code}-${each.key}-pool-${backend_address_pool.key}"
      fqdns        = backend_address_pool.value.fqdns
      ip_addresses = backend_address_pool.value.ip_addresses
    }
  }

  # Dynamic Backend HTTP Settings
  dynamic "backend_http_settings" {
    for_each = each.value.backend_http_settings
    content {
      name                  = "${var.agw_prefix}-${var.client_name}-${var.environment}-${var.location_code}-${each.key}-httpsettings-${backend_http_settings.key}"
      cookie_based_affinity = backend_http_settings.value.cookie_based_affinity
      #affinity_cookie_name                = backend_http_settings.value.affinity_cookie_name
      #path                                = backend_http_settings.value.path
      port                                = backend_http_settings.value.port
      protocol                            = backend_http_settings.value.protocol
      request_timeout                     = backend_http_settings.value.request_timeout
      probe_name                          = backend_http_settings.value.probe_name != null ? "${var.agw_prefix}-${var.client_name}-${var.environment}-${var.location_code}-${each.key}-${backend_http_settings.value.probe_name}" : null
      host_name                           = backend_http_settings.value.host_name
      pick_host_name_from_backend_address = backend_http_settings.value.pick_host_name_from_backend_address
    }
  }

  # Dynamic HTTP/HTTPS Listeners
  dynamic "http_listener" {
    for_each = each.value.http_listeners
    content {
      name                           = "${var.agw_prefix}-${var.client_name}-${var.environment}-${var.location_code}-${each.key}-${http_listener.key}"
      frontend_ip_configuration_name = "${var.agw_prefix}-${var.client_name}-${var.environment}-${var.location_code}-${each.key}-${var.public_frontend_suffix}"
      frontend_port_name             = "${var.agw_prefix}-${var.client_name}-${var.environment}-${var.location_code}-${each.key}-port-${http_listener.value.frontend_port_key}"
      protocol                       = http_listener.value.protocol
      host_name                      = http_listener.value.host_name
      #host_names                     = http_listener.value.host_names
      require_sni          = http_listener.value.require_sni
      ssl_certificate_name = http_listener.value.ssl_certificate_name != null ? "${var.agw_prefix}-${var.client_name}-${var.environment}-${var.location_code}-${each.key}-${http_listener.value.ssl_certificate_name}" : null
      firewall_policy_id   = http_listener.value.firewall_policy_id
    }
  }

  # Dynamic Request Routing Rules
  dynamic "request_routing_rule" {
    for_each = each.value.request_routing_rules
    content {
      name                        = "${var.agw_prefix}-${var.client_name}-${var.environment}-${var.location_code}-${each.key}-${request_routing_rule.key}"
      rule_type                   = request_routing_rule.value.rule_type
      priority                    = request_routing_rule.value.priority
      http_listener_name          = "${var.agw_prefix}-${var.client_name}-${var.environment}-${var.location_code}-${each.key}-${request_routing_rule.value.http_listener_key}"
      backend_address_pool_name   = request_routing_rule.value.backend_address_pool_key != null ? "${var.agw_prefix}-${var.client_name}-${var.environment}-${var.location_code}-${each.key}-pool-${request_routing_rule.value.backend_address_pool_key}" : null
      backend_http_settings_name  = request_routing_rule.value.backend_http_settings_key != null ? "${var.agw_prefix}-${var.client_name}-${var.environment}-${var.location_code}-${each.key}-httpsettings-${request_routing_rule.value.backend_http_settings_key}" : null
      redirect_configuration_name = request_routing_rule.value.redirect_configuration_key != null ? "${var.agw_prefix}-${var.client_name}-${var.environment}-${var.location_code}-${each.key}-redirect-${request_routing_rule.value.redirect_configuration_key}" : null
      url_path_map_name           = request_routing_rule.value.url_path_map_key != null ? "${var.agw_prefix}-${var.client_name}-${var.environment}-${var.location_code}-${each.key}-pathmap-${request_routing_rule.value.url_path_map_key}" : null
    }
  }

  # Dynamic Health Probes
  dynamic "probe" {
    for_each = each.value.probes != null ? each.value.probes : {}
    content {
      name                                      = "${var.agw_prefix}-${var.client_name}-${var.environment}-${var.location_code}-${each.key}-${probe.key}"
      protocol                                  = probe.value.protocol
      path                                      = probe.value.path
      interval                                  = probe.value.interval
      timeout                                   = probe.value.timeout
      unhealthy_threshold                       = probe.value.unhealthy_threshold
      pick_host_name_from_backend_http_settings = probe.value.pick_host_name_from_backend_http_settings
      host                                      = probe.value.host

      dynamic "match" {
        for_each = probe.value.match != null ? [probe.value.match] : []
        content {
          status_code = match.value.status_code
          #body        = match.value.body
        }
      }
    }
  }

  # Dynamic URL Path Maps for path-based routing
  dynamic "url_path_map" {
    for_each = each.value.url_path_maps != null ? each.value.url_path_maps : {}
    content {
      name                               = "${var.agw_prefix}-${var.client_name}-${var.environment}-${var.location_code}-${each.key}-pathmap-${url_path_map.key}"
      default_backend_address_pool_name  = "${var.agw_prefix}-${var.client_name}-${var.environment}-${var.location_code}-${each.key}-pool-${url_path_map.value.default_backend_address_pool_key}"
      default_backend_http_settings_name = "${var.agw_prefix}-${var.client_name}-${var.environment}-${var.location_code}-${each.key}-httpsettings-${url_path_map.value.default_backend_http_settings_key}"

      dynamic "path_rule" {
        for_each = url_path_map.value.path_rules
        content {
          name                       = "${var.agw_prefix}-${var.client_name}-${var.environment}-${var.location_code}-${each.key}-pathrule-${path_rule.key}"
          paths                      = path_rule.value.paths
          backend_address_pool_name  = "${var.agw_prefix}-${var.client_name}-${var.environment}-${var.location_code}-${each.key}-pool-${path_rule.value.backend_address_pool_key}"
          backend_http_settings_name = "${var.agw_prefix}-${var.client_name}-${var.environment}-${var.location_code}-${each.key}-httpsettings-${path_rule.value.backend_http_settings_key}"
        }
      }
    }
  }

  # Dynamic SSL Certificates
  dynamic "ssl_certificate" {
    for_each = each.value.ssl_certificates != null ? each.value.ssl_certificates : {}
    content {
      # Certificate name for AppGW internal reference
      name = "${var.agw_prefix}-${var.client_name}-${var.environment}-${var.location_code}-${each.key}-${ssl_certificate.key}"

      # Use dynamically fetched certificate secret ID from Key Vault
      # Falls back to dummy ID if certificate doesn't exist (e.g., during destroy)
      key_vault_secret_id = try(
        local.app_gateway_cert_ids[ssl_certificate.key],
        ssl_certificate.value.key_vault_secret_id # Fallback to hardcoded value if exists
      )

      # These are only used if providing certificate inline (not recommended for production)
      data     = ssl_certificate.value.data
      password = ssl_certificate.value.password
    }
  }

  # Dynamic Redirect Configurations
  dynamic "redirect_configuration" {
    for_each = each.value.redirect_configurations != null ? each.value.redirect_configurations : {}
    content {
      name                 = "${var.agw_prefix}-${var.client_name}-${var.environment}-${var.location_code}-${each.key}-redirect-${redirect_configuration.key}"
      redirect_type        = redirect_configuration.value.redirect_type
      target_listener_name = redirect_configuration.value.target_listener_key != null ? "${var.agw_prefix}-${var.client_name}-${var.environment}-${var.location_code}-${each.key}-${redirect_configuration.value.target_listener_key}" : null
      target_url           = redirect_configuration.value.target_url
      include_path         = redirect_configuration.value.include_path
      include_query_string = redirect_configuration.value.include_query_string
    }
  }

  waf_configuration {
    enabled          = each.value.waf_configuration.enabled
    firewall_mode    = each.value.waf_configuration.firewall_mode
    rule_set_type    = each.value.waf_configuration.rule_set_type
    rule_set_version = each.value.waf_configuration.rule_set_version
  }

  enable_http2 = each.value.enable_http2

  tags = var.common_tags

  # Ignore tag-only changes to avoid unnecessary updates when tags are modified
  # outside of Terraform or for minor metadata tweaks.
  lifecycle {
    ignore_changes = [tags]
  }
}