locals {
  # Vault identity groups. The value is the list of policies attached to the group;
  # almost all are membership-only, while "users" carries the oidc-auth policy.
  identity_groups = {
    "users"                      = ["oidc-auth"]
    "media-viewers"              = []
    "media-admins"               = []
    "download-viewers"           = []
    "download-admins"            = []
    "netbootxyz-admins"          = []
    "storage-admins"             = []
    "cluster-admins"             = []
    "paperless"                  = []
    "immich"                     = []
    "filebrowser-drive-clients"  = []
    "filebrowser-drive-admins"   = []
    "redbot-admins"              = []
    "redbot-main"                = []
    "redbot-premiers"            = []
    "change-detection"           = []
    "actual-budget"              = []
    "jellyfin"                   = []
    "esphome"                    = []
    "flatnotes"                  = []
    "filebrowser-media"          = []
    "filebrowser-media-readonly" = []
    "metube"                     = []
    "navidrome"                  = []
    "silverbullet"               = []
    "mealie"                     = []
    "mealie-admin"               = []
    "piper"                      = []
    "open-webui"                 = []
    "open-webui-admin"           = []
    "homebox"                    = []
    "outline"                    = []
    "shelly-manager"             = []
    "longhorn"                   = []
    "bambuddy"                   = []
    "trek"                       = []
    "trek-admin"                 = []
    "vm"                         = []
    "vm-grafana"                 = []
    "vm-logs"                    = []
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
