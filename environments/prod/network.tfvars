# =============================================================================
# NETWORK CONFIGURATION - Production Environment
# =============================================================================

# --- Network Naming Prefixes ---
vnet_prefix   = "vnet"
subnet_prefix = "snet"
nsg_prefix    = "nsg"

# Application Gateway naming variables
public_ip_prefix       = "pip"
agw_prefix             = "agw"
agw_subnet_suffix      = "agw"
ip_config_suffix       = "ipconfig"
frontend_port_suffix   = "feport"
public_frontend_suffix = "fefe"
backend_pool_suffix    = "bepool"
http_settings_suffix   = "htst"
http_listener_suffix   = "httplstn"
rule_suffix            = "rule"
protocol_suffix        = "proto"

# VNet Peering configuration
enable_cloudshell_peering = true

# --- Network Security Groups (NSG) ---
# Subnets that require NSGs
nsg_subnets = ["aks", "func", "sql"]

# NSG security rules per subnet
nsg_rules = {
  # AKS subnet security rules
  aks = {
    rules = [
      {
        name                       = "AllowHTTP"
        priority                   = 1000
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      {
        name                       = "AllowHTTPS"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      {
        name                       = "AllowKubernetesAPI"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "6443"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "*"
      }
    ]
  }

  # Function App subnet security rules
  func = {
    rules = [
      {
        name                       = "AllowHTTP"
        priority                   = 1000
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      {
        name                       = "AllowHTTPS"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    ]
  }

  # SQL subnet security rules
  sql = {
    rules = [
      {
        name                       = "AllowSQLServer"
        priority                   = 1000
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "1433"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "*"
      },
      {
        name                       = "DenyAllInbound"
        priority                   = 4096
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    ]
  }
}

# --- Virtual Networks and Subnets ---
# Main VNet for application workloads
vnets = [
  {
    address_space = ["10.15.0.0/16"]
    subnets = [
      {
        subnet_name    = "aks"
        address_prefix = "10.15.1.0/24"
        delegation     = null
      },
      {
        subnet_name    = "func"
        address_prefix = "10.15.5.0/24"
        delegation = {
          name         = "function-delegation"
          service_name = "Microsoft.Web/serverFarms"
          actions      = ["Microsoft.Network/virtualNetworks/subnets/action"]
        }
      },
      {
        subnet_name    = "agw"
        address_prefix = "10.15.10.0/24"
        delegation     = null
      },
      {
        subnet_name    = "sql"
        address_prefix = "10.15.20.0/24"
        delegation     = null
      },
      {
        subnet_name    = "corevm"
        address_prefix = "10.15.90.0/24"
        delegation     = null
      }
    ]
  }
]

# --- Application Gateway ---
# NOTE: subnet_id and user_assigned_identity_id are computed dynamically in appgateway.tf
# using data sources and local references. No need to specify them here.
application_gateways = {
  primary = {
    resource_prefix = "agw"

    # Public IP Configuration
    public_ip_allocation_method = "Static"
    public_ip_sku               = "Standard"

    # SKU Configuration (capacity removed for autoscaling support)
    sku = {
      name     = "WAF_v2"
      tier     = "WAF_v2"
      capacity = 0 # Set to 0 when using autoscaling
    }

    # Autoscaling Configuration
    enable_autoscale       = true
    autoscale_min_capacity = 0
    autoscale_max_capacity = 10

    # Listener and Backend Configuration
    frontend_ports = [
      {
        name = "port_80"
        port = 80
      },
      {
        name = "port_443"
        port = 443
      }
    ]
    request_timeout = 20
    # ===================================
    # FRONTEND IP CONFIGURATIONS
    # ===================================
    # Note: public_ip_address_id is dynamically set in appgateway.tf module
    # using: azurerm_public_ip.agw_pip[each.key].id
    # DO NOT hardcode resource IDs here - they will be computed automatically

    frontend_ip_configurations = [
      {
        name                          = null # Dynamically set by module using naming convention - DO NOT hardcode
        public_ip_address_id          = null # Dynamically set by module - DO NOT hardcode
        private_ip_address            = null
        private_ip_address_allocation = null
      }
    ]
    # Advanced Settings
    private_ip_allocation = "Dynamic"
    cookie_based_affinity = "Disabled"
    protocol              = "Http"
    rule_type             = "Basic"
    priority              = 100
    enable_http2          = true

    # Web Application Firewall (WAF)
    waf_configuration = {
      enabled          = true
      firewall_mode    = "Prevention"
      rule_set_type    = "OWASP"
      rule_set_version = "3.2"
    }

    # Frontend Ports
    frontend_ports = {
      http = {
        port = 80
      }
      https = {
        port = 443
      }
    }

    # Backend Pools - Using AKS Internal IPs
    backend_address_pools = {
      admin = {
        fqdns        = []
        ip_addresses = ["10.15.1.12"]
      }
      customer = {
        fqdns        = []
        ip_addresses = ["10.15.1.14"]
      }
      cards = {
        fqdns        = []
        ip_addresses = ["10.15.1.13"]
      }
      invoice = {
        fqdns        = []
        ip_addresses = ["10.15.1.15"]
      }
      master = {
        fqdns        = []
        ip_addresses = ["10.15.1.16"]
      }
      notify = {
        fqdns        = []
        ip_addresses = ["10.15.1.10"]
      }
      pdf = {
        fqdns        = []
        ip_addresses = ["10.15.1.9"]
      }
      operator = {
        fqdns        = []
        ip_addresses = ["10.15.1.11"]
      }
      keycloak = {
        fqdns        = []
        ip_addresses = ["10.15.7.4"]
      }
    }

    # Backend HTTP Settings
    backend_http_settings = {
      admin = {
        cookie_based_affinity               = "Disabled"
        port                                = 80
        protocol                            = "Http"
        request_timeout                     = 60
        probe_name                          = "admin"
        pick_host_name_from_backend_address = false
      }
      customer = {
        cookie_based_affinity               = "Disabled"
        port                                = 80
        protocol                            = "Http"
        request_timeout                     = 60
        probe_name                          = "customer"
        pick_host_name_from_backend_address = false
      }
      cards = {
        cookie_based_affinity               = "Disabled"
        port                                = 80
        protocol                            = "Http"
        request_timeout                     = 60
        probe_name                          = "cards"
        pick_host_name_from_backend_address = false
      }
      invoice = {
        cookie_based_affinity               = "Disabled"
        port                                = 80
        protocol                            = "Http"
        request_timeout                     = 60
        probe_name                          = "invoice"
        pick_host_name_from_backend_address = false
      }
      master = {
        cookie_based_affinity               = "Disabled"
        port                                = 80
        protocol                            = "Http"
        request_timeout                     = 60
        probe_name                          = "master"
        pick_host_name_from_backend_address = false
      }
      notify = {
        cookie_based_affinity               = "Disabled"
        port                                = 80
        protocol                            = "Http"
        request_timeout                     = 60
        probe_name                          = "notify"
        pick_host_name_from_backend_address = false
      }
      pdf = {
        cookie_based_affinity               = "Disabled"
        port                                = 80
        protocol                            = "Http"
        request_timeout                     = 60
        probe_name                          = "pdf"
        pick_host_name_from_backend_address = false
      }
      operator = {
        cookie_based_affinity               = "Disabled"
        port                                = 80
        protocol                            = "Http"
        request_timeout                     = 60
        probe_name                          = "operator"
        pick_host_name_from_backend_address = false
      }
      keycloak = {
        cookie_based_affinity               = "Disabled"
        port                                = 443
        protocol                            = "Https"
        request_timeout                     = 60
        probe_name                          = null
        host_name                           = "key-cloak.yuze.co.in"
        pick_host_name_from_backend_address = false
      }
    }

    # Health Probes
    probes = {
      admin = {
        protocol                                  = "Http"
        path                                      = "/health"
        interval                                  = 30
        timeout                                   = 30
        unhealthy_threshold                       = 3
        pick_host_name_from_backend_http_settings = false
        host                                      = "yuze-banking-api-admin.yuze.co.in"
        match                                     = null
      }
      customer = {
        protocol                                  = "Http"
        path                                      = "/health"
        interval                                  = 30
        timeout                                   = 30
        unhealthy_threshold                       = 3
        pick_host_name_from_backend_http_settings = false
        host                                      = "yuze-banking-api-customer.yuze.co.in"
        match                                     = null
      }
      cards = {
        protocol                                  = "Http"
        path                                      = "/health"
        interval                                  = 30
        timeout                                   = 30
        unhealthy_threshold                       = 3
        pick_host_name_from_backend_http_settings = false
        host                                      = "yuze-banking-api-card.yuze.co.in"
        match                                     = null
      }
      invoice = {
        protocol                                  = "Http"
        path                                      = "/health"
        interval                                  = 30
        timeout                                   = 30
        unhealthy_threshold                       = 3
        pick_host_name_from_backend_http_settings = false
        host                                      = "yuze-banking-api-invoice.yuze.co.in"
        match                                     = null
      }
      master = {
        protocol                                  = "Http"
        path                                      = "/health"
        interval                                  = 30
        timeout                                   = 30
        unhealthy_threshold                       = 3
        pick_host_name_from_backend_http_settings = false
        host                                      = "yuze-banking-api-master.yuze.co.in"
        match                                     = null
      }
      notify = {
        protocol                                  = "Http"
        path                                      = "/health"
        interval                                  = 30
        timeout                                   = 30
        unhealthy_threshold                       = 3
        pick_host_name_from_backend_http_settings = false
        host                                      = "yuze-banking-api-notification-stage.yuze.co.in"
        match                                     = null
      }
      pdf = {
        protocol                                  = "Http"
        path                                      = "/health"
        interval                                  = 30
        timeout                                   = 30
        unhealthy_threshold                       = 3
        pick_host_name_from_backend_http_settings = false
        host                                      = "yuze-banking-api-pdfgenerator.yuze.co.in"
        match                                     = null
      }
      operator = {
        protocol                                  = "Http"
        path                                      = "/"
        interval                                  = 30
        timeout                                   = 30
        unhealthy_threshold                       = 3
        pick_host_name_from_backend_http_settings = false
        host                                      = "operator.yuze.co.in"
        match                                     = null
      }
    }

    # HTTP/HTTPS Listeners
    http_listeners = {
      admin-http = {
        protocol             = "Http"
        frontend_port_key    = "http"
        host_name            = "yuze-banking-api-admin.yuze.co.in"
        require_sni          = false
        ssl_certificate_name = null
        firewall_policy_id   = null
      }
      admin-https = {
        protocol             = "Https"
        frontend_port_key    = "https"
        host_name            = "yuze-banking-api-admin.yuze.co.in"
        require_sni          = true
        ssl_certificate_name = "yuzebank-cert"
        firewall_policy_id   = null
      }
      customer-http = {
        protocol             = "Http"
        frontend_port_key    = "http"
        host_name            = "yuze-banking-api-customer.yuze.co.in"
        require_sni          = false
        ssl_certificate_name = null
        firewall_policy_id   = null
      }
      customer-https = {
        protocol             = "Https"
        frontend_port_key    = "https"
        host_name            = "yuze-banking-api-customer.yuze.co.in"
        require_sni          = true
        ssl_certificate_name = "yuzebank-cert"
        firewall_policy_id   = null
      }
      cards-http = {
        protocol             = "Http"
        frontend_port_key    = "http"
        host_name            = "yuze-banking-api-cards.yuze.co.in"
        require_sni          = false
        ssl_certificate_name = null
        firewall_policy_id   = null
      }
      cards-https = {
        protocol             = "Https"
        frontend_port_key    = "https"
        host_name            = "yuze-banking-api-cards.yuze.co.in"
        require_sni          = true
        ssl_certificate_name = "yuzebank-cert"
        firewall_policy_id   = null
      }
      invoice-http = {
        protocol             = "Http"
        frontend_port_key    = "http"
        host_name            = "yuze-banking-api-invoice.yuze.co.in"
        require_sni          = false
        ssl_certificate_name = null
        firewall_policy_id   = null
      }
      invoice-https = {
        protocol             = "Https"
        frontend_port_key    = "https"
        host_name            = "yuze-banking-api-invoice.yuze.co.in"
        require_sni          = true
        ssl_certificate_name = "yuzebank-cert"
        firewall_policy_id   = null
      }
      master-http = {
        protocol             = "Http"
        frontend_port_key    = "http"
        host_name            = "yuze-banking-api-master.yuze.co.in"
        require_sni          = false
        ssl_certificate_name = null
        firewall_policy_id   = null
      }
      master-https = {
        protocol             = "Https"
        frontend_port_key    = "https"
        host_name            = "yuze-banking-api-master.yuze.co.in"
        require_sni          = true
        ssl_certificate_name = "yuzebank-cert"
        firewall_policy_id   = null
      }
      notify-http = {
        protocol             = "Http"
        frontend_port_key    = "http"
        host_name            = "yuze-banking-api-notification.yuze.co.in"
        require_sni          = false
        ssl_certificate_name = null
        firewall_policy_id   = null
      }
      notify-https = {
        protocol             = "Https"
        frontend_port_key    = "https"
        host_name            = "yuze-banking-api-notification.yuze.co.in"
        require_sni          = true
        ssl_certificate_name = "yuzebank-cert"
        firewall_policy_id   = null
      }
      pdf-http = {
        protocol             = "Http"
        frontend_port_key    = "http"
        host_name            = "yuze-banking-api-pdfgenerator.yuze.co.in"
        require_sni          = false
        ssl_certificate_name = null
        firewall_policy_id   = null
      }
      pdf-https = {
        protocol             = "Https"
        frontend_port_key    = "https"
        host_name            = "yuze-banking-api-pdfgenerator.yuze.co.in"
        require_sni          = true
        ssl_certificate_name = "yuzebank-cert"
        firewall_policy_id   = null
      }
      operator-http = {
        protocol             = "Http"
        frontend_port_key    = "http"
        host_name            = "operator.yuze.co.in"
        require_sni          = false
        ssl_certificate_name = null
        firewall_policy_id   = null
      }
      operator-https = {
        protocol             = "Https"
        frontend_port_key    = "https"
        host_name            = "operator.yuze.co.in"
        require_sni          = true
        ssl_certificate_name = "yuzebank-cert"
        firewall_policy_id   = null
      }
      keycloak-http = {
        protocol             = "Http"
        frontend_port_key    = "http"
        host_name            = "keycloak.yuze.co.in"
        require_sni          = false
        ssl_certificate_name = null
        firewall_policy_id   = null
      }
      keycloak-https = {
        protocol             = "Https"
        frontend_port_key    = "https"
        host_name            = "keycloak.yuze.co.in"
        require_sni          = true
        ssl_certificate_name = "yuzebank-cert"
        firewall_policy_id   = null
      }
    }

    # Routing Rules
    request_routing_rules = {
      admin-https = {
        rule_type                 = "Basic"
        priority                  = 100
        http_listener_key         = "admin-https"
        backend_address_pool_key  = "admin"
        backend_http_settings_key = "admin"
      }
      admin-http = {
        rule_type                  = "Basic"
        priority                   = 110
        http_listener_key          = "admin-http"
        backend_address_pool_key   = null
        backend_http_settings_key  = null
        redirect_configuration_key = "admin-http-to-https"
      }
      customer-http = {
        rule_type                  = "Basic"
        priority                   = 120
        http_listener_key          = "customer-http"
        backend_address_pool_key   = null
        backend_http_settings_key  = null
        redirect_configuration_key = "customer-http-to-https"
      }
      customer-https = {
        rule_type                 = "Basic"
        priority                  = 130
        http_listener_key         = "customer-https"
        backend_address_pool_key  = "customer"
        backend_http_settings_key = "customer"
      }
      cards-https = {
        rule_type                 = "Basic"
        priority                  = 140
        http_listener_key         = "cards-https"
        backend_address_pool_key  = "cards"
        backend_http_settings_key = "cards"
      }
      cards-http = {
        rule_type                  = "Basic"
        priority                   = 150
        http_listener_key          = "cards-http"
        backend_address_pool_key   = null
        backend_http_settings_key  = null
        redirect_configuration_key = "cards-http-to-https"
      }
      invoice-https = {
        rule_type                 = "Basic"
        priority                  = 160
        http_listener_key         = "invoice-https"
        backend_address_pool_key  = "invoice"
        backend_http_settings_key = "invoice"
      }
      invoice-http = {
        rule_type                  = "Basic"
        priority                   = 170
        http_listener_key          = "invoice-http"
        backend_address_pool_key   = null
        backend_http_settings_key  = null
        redirect_configuration_key = "invoice-http-to-https"
      }
      master-https = {
        rule_type                 = "Basic"
        priority                  = 180
        http_listener_key         = "master-https"
        backend_address_pool_key  = "master"
        backend_http_settings_key = "master"
      }
      master-http = {
        rule_type                  = "Basic"
        priority                   = 190
        http_listener_key          = "master-http"
        backend_address_pool_key   = null
        backend_http_settings_key  = null
        redirect_configuration_key = "master-http-to-https"
      }
      notify-https = {
        rule_type                 = "Basic"
        priority                  = 200
        http_listener_key         = "notify-https"
        backend_address_pool_key  = "notify"
        backend_http_settings_key = "notify"
      }
      notify-http = {
        rule_type                  = "Basic"
        priority                   = 210
        http_listener_key          = "notify-http"
        backend_address_pool_key   = null
        backend_http_settings_key  = null
        redirect_configuration_key = "notify-http-to-https"
      }
      pdf-http = {
        rule_type                  = "Basic"
        priority                   = 220
        http_listener_key          = "pdf-http"
        backend_address_pool_key   = null
        backend_http_settings_key  = null
        redirect_configuration_key = "pdf-http-to-https"
      }
      pdf-https = {
        rule_type                 = "Basic"
        priority                  = 230
        http_listener_key         = "pdf-https"
        backend_address_pool_key  = "pdf"
        backend_http_settings_key = "pdf"
      }
      operator-http = {
        rule_type                  = "Basic"
        priority                   = 240
        http_listener_key          = "operator-http"
        backend_address_pool_key   = null
        backend_http_settings_key  = null
        redirect_configuration_key = "operator-http-to-https"
      }
      operator-https = {
        rule_type                 = "Basic"
        priority                  = 250
        http_listener_key         = "operator-https"
        backend_address_pool_key  = "operator"
        backend_http_settings_key = "operator"
      }
      keycloak-https = {
        rule_type                 = "Basic"
        priority                  = 260
        http_listener_key         = "keycloak-https"
        backend_address_pool_key  = "keycloak"
        backend_http_settings_key = "keycloak"
      }
      keycloak-http = {
        rule_type                  = "Basic"
        priority                   = 270
        http_listener_key          = "keycloak-http"
        backend_address_pool_key   = null
        backend_http_settings_key  = null
        redirect_configuration_key = "keycloak-http-to-https"
      }
    }

    # Redirect Configurations
    redirect_configurations = {
      admin-http-to-https = {
        redirect_type        = "Permanent"
        target_listener_key  = "admin-https"
        target_url           = null
        include_path         = true
        include_query_string = true
      }
      customer-http-to-https = {
        redirect_type        = "Permanent"
        target_listener_key  = "customer-https"
        target_url           = null
        include_path         = true
        include_query_string = true
      }
      cards-http-to-https = {
        redirect_type        = "Permanent"
        target_listener_key  = "cards-https"
        target_url           = null
        include_path         = true
        include_query_string = true
      }
      invoice-http-to-https = {
        redirect_type        = "Permanent"
        target_listener_key  = "invoice-https"
        target_url           = null
        include_path         = true
        include_query_string = true
      }
      master-http-to-https = {
        redirect_type        = "Permanent"
        target_listener_key  = "master-https"
        target_url           = null
        include_path         = true
        include_query_string = true
      }
      notify-http-to-https = {
        redirect_type        = "Permanent"
        target_listener_key  = "notify-https"
        target_url           = null
        include_path         = true
        include_query_string = true
      }
      pdf-http-to-https = {
        redirect_type        = "Permanent"
        target_listener_key  = "pdf-https"
        target_url           = null
        include_path         = true
        include_query_string = true
      }
      operator-http-to-https = {
        redirect_type        = "Permanent"
        target_listener_key  = "operator-https"
        target_url           = null
        include_path         = true
        include_query_string = true
      }
      keycloak-http-to-https = {
        redirect_type        = "Permanent"
        target_listener_key  = "keycloak-https"
        target_url           = null
        include_path         = true
        include_query_string = true
      }
    }

    # SSL Certificates
    ssl_certificates = {
      yuzebank-cert = {
        data                = null
        password            = null
        key_vault_secret_id = null # Will be fetched dynamically from Key Vault via data block
      }
    }
  }
}

# ═════════════════════════════════════════════════════════════════════════════
# KEY VAULT CONFIGURATION FOR DYNAMIC CERTIFICATE FETCHING
# ═════════════════════════════════════════════════════════════════════════════
# NOTE: key_vault_name and key_vault_resource_group are automatically fetched
# from the identity_governance module (see main.tf).
# You only need to specify which certificates to fetch from Key Vault.
# ═════════════════════════════════════════════════════════════════════════════

# Certificate names to fetch from Key Vault
certificate_names = {
  yuzebank-cert = {
    certificate_name = "star-yuze-co-in-fullchain-25-28" # Name of certificate in Key Vault
    enabled          = false # Disabled until certificate is uploaded to Key Vault
  }
}
