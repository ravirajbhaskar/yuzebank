# =============================================================================
# IDENTITY & SECURITY - Production Environment
# =============================================================================

# --- Managed Identities ---
# Names are dynamically computed as: mi-{resource_prefix}-{client_name}-{environment}-{location_code}
# Resource groups are determined by resource type (identity resources go to identity RG)
managed_identities = {
  agw = {
    resource_prefix = "agw"
    tags            = {}
  }

  func1 = {
    resource_prefix = "func1"
    tags            = {}
  }

  func2 = {
    resource_prefix = "func2"
    tags            = {}
  }

  func3 = {
    resource_prefix = "func3"
    tags            = {}
  }

  keycloak = {
    resource_prefix = "kc"
    tags            = {}
  }
}

# --- Key Vault ---
key_vaults = {
  primary = {
    resource_prefix = "kv"
  }
}

# Key Vault Configuration
sku_name                   = "standard"
purge_protection_enabled   = false
create_kv_rbac_assignments = false
kv_rbac_group_object_id    = "e29b2e39-6f15-4917-ac82-5b458241facb"

# Key Vault Permissions
key_permissions = [
  "Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore"
]

secret_permissions = [
  "Get", "List", "Set", "Delete", "Recover", "Backup", "Restore"
]

certificate_permissions = [
  "Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore",
  "ManageContacts", "ManageIssuers", "GetIssuers", "ListIssuers", "SetIssuers", "DeleteIssuers"
]

# Key Vault RBAC Roles
kv_secrets_user_role = "Key Vault Secrets User"
kv_admin_role        = "Key Vault Administrator"
kv_cert_officer_role = "Key Vault Certificates Officer"

# --- Service Bus ---
servicebus_namespaces = {
  primary = {
    resource_prefix = "sbns"
    sku             = "Standard"
    capacity        = 0
  }
}

# Service Bus Queues (if any - add here)
servicebus_queues = {}

service_bus = {
  resource_prefix = "sbus-notification"
  sku             = "Standard"
  additional_tags = {}
}
