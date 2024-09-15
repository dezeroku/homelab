# Define userpass auth method and users
resource "vault_auth_backend" "userpass" {
  type = "userpass"

  # oidc-auth is defined in oidc.tf
  tune {
    default_lease_ttl  = "1h"
    max_lease_ttl      = "1h"
    listing_visibility = "unauth"
  }
}

module "user" {
  for_each = var.users

  source = "./user"

  userpass_accessor = vault_auth_backend.userpass.accessor
  username          = each.key
  user_password     = each.value.password
  metadata = {
    email = each.value.email
  }
  groups = each.value.groups

  groups_mapping = {
    users              = vault_identity_group.users.id
    media-viewers      = vault_identity_group.media_viewers.id
    media-admins       = vault_identity_group.media_admins.id
    download-viewers   = vault_identity_group.download_viewers.id
    download-admins    = vault_identity_group.download_admins.id
    monitoring-viewers = vault_identity_group.monitoring_viewers.id
    monitoring-admins  = vault_identity_group.monitoring_admins.id
    netbootxyz-admins  = vault_identity_group.netbootxyz_admins.id
    storage-admins     = vault_identity_group.storage_admins.id
    cluster-admins     = vault_identity_group.cluster_admins.id
  }
}
