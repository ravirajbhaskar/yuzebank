# =============================================================================
# DATABASE RESOURCES - Production Environment
# =============================================================================

# --- Storage Accounts ---
storage_accounts = {
  primary = {
    resource_prefix   = "st"
    replace_character = "-"
    substr_start      = 0
    max_name_length   = 24

    # Configuration
    account_kind                    = "StorageV2"
    account_tier                    = "Standard"
    account_replication_type        = "LRS"
    access_tier                     = "Hot"
    min_tls_version                 = "TLS1_2"
    allow_nested_items_to_be_public = false
    https_traffic_only_enabled      = true
    public_network_access_enabled   = true
    is_hns_enabled                  = false
    sftp_enabled                    = false
  }

  funcapps = {
    resource_prefix   = "funapp"
    replace_character = "-"
    substr_start      = 0
    max_name_length   = 24

    # Configuration for Function Apps storage
    account_kind                    = "StorageV2"
    account_tier                    = "Standard"
    account_replication_type        = "LRS"
    access_tier                     = "Hot"
    min_tls_version                 = "TLS1_2"
    allow_nested_items_to_be_public = false
    https_traffic_only_enabled      = true
    public_network_access_enabled   = true
    is_hns_enabled                  = false
    sftp_enabled                    = false
  }
}

# --- Storage Containers ---
storage_containers = {
  documents = {
    resource_prefix       = "stc-docs"
    storage_account_key   = "primary"
    container_access_type = "private"
  }

  images = {
    resource_prefix       = "stc-images"
    storage_account_key   = "primary"
    container_access_type = "private"
  }

  backups = {
    resource_prefix       = "stc-backups"
    storage_account_key   = "primary"
    container_access_type = "private"
  }
}

# --- Event Hub ---
eventhub_namespaces = {
  primary = {
    resource_prefix = "ehns"
    sku             = "Standard"
    capacity        = 1
  }
}

eventhubs = {
  events = {
    resource_prefix   = "eh-events"
    namespace_key     = "primary"
    partition_count   = 4
    message_retention = 7
  }

  telemetry = {
    resource_prefix   = "eh-telemetry"
    namespace_key     = "primary"
    partition_count   = 2
    message_retention = 3
  }
}

# --- Redis Cache ---
redis_caches = {
  primary = {
    resource_prefix = "redis-cache"
    capacity        = 1
    family          = "C"
    sku_name        = "Standard"
    tags            = {}
  }
}

# --- SQL Databases ---
sql_databases = {
  # Application Database
  application = {
    # Naming Prefixes
    resource_group_prefix             = "rg"
    sql_server_prefix                 = "sqls"
    sql_database_prefix               = "app-sql"
    private_endpoint_prefix           = "pep"
    private_service_connection_prefix = "psc"

    # Resource group name computed dynamically as: {resource_group_prefix}-sql-{client_name}-{environment}-{location_code}

    # SQL Server Configuration
    sql_server_version            = "12.0"
    admin_username                = "sqladmin"
    minimum_tls_version           = "1.2"
    public_network_access_enabled = false

    # Database Configuration
    sku_name                   = "GP_Gen5_2"
    max_size_gb                = 250
    license_type               = "LicenseIncluded"
    zone_redundant             = false
    storage_account_type       = "Local"
    geo_backup_enabled         = true
    reserved_capacity_in_years = 1
    read_scale                 = false
    collation                  = "SQL_Latin1_General_CP1_CI_AS"

    # Long Term Retention
    weekly_retention  = "P1W"
    monthly_retention = "P1M"
    yearly_retention  = "P1Y"
  }

  # Keycloak Database
  keycloak = {
    # Naming Prefixes
    resource_group_prefix             = "rg"
    sql_server_prefix                 = "sqls"
    sql_database_prefix               = "kc-sql"
    private_endpoint_prefix           = "pep"
    private_service_connection_prefix = "psc"

    # Resource group name computed dynamically as: {resource_group_prefix}-sql-{client_name}-{environment}-{location_code}

    # SQL Server Configuration
    sql_server_version            = "12.0"
    admin_username                = "sqladmin"
    minimum_tls_version           = "1.2"
    public_network_access_enabled = false

    # Database Configuration - SERVERLESS
    sku_name                   = "GP_S_Gen5_1" # Serverless SKU - 1 vCore (Standard-series Gen5)
    max_size_gb                = 100           # Smaller for Keycloak
    license_type               = "LicenseIncluded"
    zone_redundant             = false   # Serverless doesn't support zone redundancy
    storage_account_type       = "Local" # Use Local for serverless
    geo_backup_enabled         = true
    reserved_capacity_in_years = 1
    read_scale                 = false
    collation                  = "SQL_Latin1_General_CP1_CI_AS"

    # Serverless-specific settings
    auto_pause_delay_in_minutes = 60  # Auto-pause after 60 minutes of inactivity
    min_capacity                = 0.5 # Minimum 0.5 vCores
    max_capacity                = 1.0 # Maximum 1 vCore (billed vCore)

    # Long Term Retention
    weekly_retention  = "P1W"
    monthly_retention = "P1M"
    yearly_retention  = "P1Y"
  }
}
