resource "vault_identity_oidc_assignment" "filebrowser_drive" {
  name = "filebrowser_drive"
  group_ids = [
    vault_identity_group.filebrowser_drive_clients.id,
    vault_identity_group.filebrowser_drive_admins.id,
  ]
}

resource "vault_identity_oidc_client" "filebrowser_drive" {
  name = "filebrowser-drive"
  redirect_uris = [
    "https://filebrowser-drive.${var.domain}/api/auth/oidc/callback"
  ]
  assignments      = [vault_identity_oidc_assignment.filebrowser_drive.name]
  id_token_ttl     = 2400
  access_token_ttl = 7200
}

resource "vault_kubernetes_auth_backend_role" "filebrowser_drive" {
  backend                          = vault_auth_backend.kubernetes_homeserver.path
  role_name                        = "filebrowser-drive"
  bound_service_account_namespaces = ["filebrowser-drive"]
  token_ttl                        = 3600
  bound_service_account_names      = ["filebrowser-drive"]
  token_policies                   = ["filebrowser-drive"]
}

resource "vault_policy" "filebrowser_drive" {
  name = "filebrowser-drive"

  policy = <<EOT
path "identity/oidc/client/filebrowser-drive" {
  capabilities = ["read"]
}
EOT
}
