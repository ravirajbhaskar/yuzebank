# =============================================================================
# GLOBAL CONFIGURATION - Production Environment
# =============================================================================

# Azure subscription and location details
location = "Central India"
# subscription_id and tenant_id are automatically provided by the Azure Pipeline
# from the Yuze_28-Jul variable group via ARM_SUBSCRIPTION_ID and ARM_TENANT_ID

# Dynamic naming convention components
# All resources follow: {prefix}-{resource_type}-{client_name}-{environment}-{location_code}
client_name   = "yuze"
environment   = "prod"
location_code = "cin"

# Random suffix for globally unique resource names (storage accounts, etc.)
# This is dynamically passed from the pipeline using the first 8 chars of tenant_id

# Resource group prefix for all resource groups
rg_prefix = "rg"

# Resource group names - Dynamically computed in modules as:
# {rg_prefix}-{module_name}-{client_name}-{environment}-{location_code}
# Examples: rg-storage-yuze-prod-cin, rg-sql-yuze-prod-cin, rg-eventhub-yuze-prod-cin, rg-monitor-yuze-prod-cin

# Common tags applied to all resources
common_tags = {
  Environment = "prod"
  CreatedBy   = "Terraform"
  Project     = "YuzeIndia"
}

# Additional tags configuration
tags = {}

# =============================================================================
# MODULE ENABLE/DISABLE CONTROLS
# =============================================================================
# Control which modules to deploy (true = deploy, false = skip without destroying)
enable_network             = true
enable_compute             = true
enable_identity_governance = true
enable_database            = true
enable_monitoring          = true

# =============================================================================
# SHARED NAMING PREFIXES
# =============================================================================
# Note: resource_prefix removed - use client_name variable instead
# Note: netprofile_name removed - computed dynamically as "netprofile-{client_name}-{environment}-{location_code}"
