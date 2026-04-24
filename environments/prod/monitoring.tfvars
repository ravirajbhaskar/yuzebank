# =============================================================================
# MONITORING & OBSERVABILITY - Production Environment
# =============================================================================
# NOTE: Names and resource groups are computed dynamically in the monitoring module
# using standard naming conventions: {prefix}-{client_name}-{environment}-{location_code}

# --- Application Insights ---
application_insights = {
  primary = {
    # Name will be: appi-yuze-prod-cin (computed dynamically)
    # Resource group: rg-monitor-yuze-prod-cin (computed dynamically)
    application_type  = "web"
    workspace_id      = null # Will be linked to Log Analytics workspace dynamically
    retention_in_days = 90
    tags              = {}
  }
}

# --- Log Analytics ---
log_analytics_workspaces = {
  primary = {
    # Name will be: log-yuze-prod-cin (computed dynamically)
    # Resource group: rg-monitor-yuze-prod-cin (computed dynamically)
    sku               = "PerGB2018"
    retention_in_days = 30
    tags              = {}
  }
}

# --- Notification Hub ---
notification_hub_namespaces = {
  primary = {
    # Name will be: ntfns-yuze-prod-cin (computed dynamically)
    # Resource group: rg-monitor-yuze-prod-cin (computed dynamically)
    sku_name       = "Free"
    namespace_type = "NotificationHub"
    tags           = {}
  }
}

notification_hubs = {
  mobile = {
    # Name will be: ntfh-mobile-yuze-prod-cin (computed dynamically)
    # Resource group: rg-monitor-yuze-prod-cin (computed dynamically)
    namespace_key = "primary"
    tags          = {}
  }
}
