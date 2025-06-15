resource "vault_identity_group" "users" {
  name                       = "users"
  type                       = "internal"
  policies                   = ["oidc-auth"]
  external_member_entity_ids = true
}

resource "vault_identity_group" "media_viewers" {
  name                       = "media-viewers"
  type                       = "internal"
  policies                   = []
  external_member_entity_ids = true
}

resource "vault_identity_group" "media_admins" {
  name                       = "media-admins"
  type                       = "internal"
  policies                   = []
  external_member_entity_ids = true
}

resource "vault_identity_group" "download_viewers" {
  name                       = "download-viewers"
  type                       = "internal"
  policies                   = []
  external_member_entity_ids = true
}

resource "vault_identity_group" "download_admins" {
  name                       = "download-admins"
  type                       = "internal"
  policies                   = []
  external_member_entity_ids = true
}

resource "vault_identity_group" "monitoring_viewers" {
  name                       = "monitoring-viewers"
  type                       = "internal"
  policies                   = []
  external_member_entity_ids = true
}

resource "vault_identity_group" "monitoring_editors" {
  name                       = "monitoring-editors"
  type                       = "internal"
  policies                   = []
  external_member_entity_ids = true
}

resource "vault_identity_group" "monitoring_admins" {
  name                       = "monitoring-admins"
  type                       = "internal"
  policies                   = []
  external_member_entity_ids = true
}

resource "vault_identity_group" "netbootxyz_admins" {
  name                       = "netbootxyz-admins"
  type                       = "internal"
  policies                   = []
  external_member_entity_ids = true
}

resource "vault_identity_group" "storage_admins" {
  name                       = "storage-admins"
  type                       = "internal"
  policies                   = []
  external_member_entity_ids = true
}

resource "vault_identity_group" "cluster_admins" {
  name                       = "cluster-admins"
  type                       = "internal"
  policies                   = []
  external_member_entity_ids = true
}

resource "vault_identity_group" "paperless" {
  name                       = "paperless"
  type                       = "internal"
  policies                   = []
  external_member_entity_ids = true
}

resource "vault_identity_group" "immich" {
  name                       = "immich"
  type                       = "internal"
  policies                   = []
  external_member_entity_ids = true
}

resource "vault_identity_group" "filebrowser_drive_clients" {
  name                       = "filebrowser-drive-clients"
  type                       = "internal"
  policies                   = []
  external_member_entity_ids = true
}

resource "vault_identity_group" "filebrowser_drive_admins" {
  name                       = "filebrowser-drive-admins"
  type                       = "internal"
  policies                   = []
  external_member_entity_ids = true
}
