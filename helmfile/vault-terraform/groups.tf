locals {
  # Vault identity groups. The value is the list of policies attached to the group;
  # almost all are membership-only, while "users" carries the oidc-auth policy.
  identity_groups = {
    "users"                     = ["oidc-auth"]
    "media-viewers"             = []
    "media-admins"              = []
    "download-viewers"          = []
    "download-admins"           = []
    "monitoring-viewers"        = []
    "monitoring-editors"        = []
    "monitoring-admins"         = []
    "netbootxyz-admins"         = []
    "storage-admins"            = []
    "cluster-admins"            = []
    "paperless"                 = []
    "immich"                    = []
    "filebrowser-drive-clients" = []
    "filebrowser-drive-admins"  = []
    "redbot-main-admins"        = []
    "redbot-premiers-admins"    = []
    "change-detection"          = []
    "metube"                    = []
    "actual-budget"             = []
    "jellyfin"                  = []
    "esphome"                   = []
  }
}

resource "vault_identity_group" "this" {
  for_each = local.identity_groups

  name                       = each.key
  type                       = "internal"
  policies                   = each.value
  external_member_entity_ids = true
}

resource "lldap_group" "this" {
  for_each = local.identity_groups

  display_name = each.key
}

moved {
  from = vault_identity_group.users
  to   = vault_identity_group.this["users"]
}

moved {
  from = vault_identity_group.media_viewers
  to   = vault_identity_group.this["media-viewers"]
}

moved {
  from = vault_identity_group.media_admins
  to   = vault_identity_group.this["media-admins"]
}

moved {
  from = vault_identity_group.download_viewers
  to   = vault_identity_group.this["download-viewers"]
}

moved {
  from = vault_identity_group.download_admins
  to   = vault_identity_group.this["download-admins"]
}

moved {
  from = vault_identity_group.monitoring_viewers
  to   = vault_identity_group.this["monitoring-viewers"]
}

moved {
  from = vault_identity_group.monitoring_editors
  to   = vault_identity_group.this["monitoring-editors"]
}

moved {
  from = vault_identity_group.monitoring_admins
  to   = vault_identity_group.this["monitoring-admins"]
}

moved {
  from = vault_identity_group.netbootxyz_admins
  to   = vault_identity_group.this["netbootxyz-admins"]
}

moved {
  from = vault_identity_group.storage_admins
  to   = vault_identity_group.this["storage-admins"]
}

moved {
  from = vault_identity_group.cluster_admins
  to   = vault_identity_group.this["cluster-admins"]
}

moved {
  from = vault_identity_group.paperless
  to   = vault_identity_group.this["paperless"]
}

moved {
  from = vault_identity_group.immich
  to   = vault_identity_group.this["immich"]
}

moved {
  from = vault_identity_group.filebrowser_drive_clients
  to   = vault_identity_group.this["filebrowser-drive-clients"]
}

moved {
  from = vault_identity_group.filebrowser_drive_admins
  to   = vault_identity_group.this["filebrowser-drive-admins"]
}

moved {
  from = vault_identity_group.redbot_main_admins
  to   = vault_identity_group.this["redbot-main-admins"]
}

moved {
  from = vault_identity_group.redbot_premiers_admins
  to   = vault_identity_group.this["redbot-premiers-admins"]
}

moved {
  from = vault_identity_group.change_detection
  to   = vault_identity_group.this["change-detection"]
}

moved {
  from = vault_identity_group.metube
  to   = vault_identity_group.this["metube"]
}
