resource "vault_identity_oidc_assignment" "immich" {
  name = "immich"
  group_ids = [
    vault_identity_group.immich.id,
  ]
}

resource "vault_identity_oidc_client" "immich" {
  name = "immich"
  redirect_uris = [
    "app.immich:///oauth-callback",
    "https://immich.${var.domain}/auth/login",
    "https://immich.${var.domain}/user-settings"
  ]
  assignments      = [vault_identity_oidc_assignment.immich.name]
  id_token_ttl     = 2400
  access_token_ttl = 7200
}

resource "vault_kubernetes_auth_backend_role" "immich" {
  backend                          = vault_auth_backend.kubernetes_homeserver.path
  role_name                        = "immich"
  bound_service_account_namespaces = ["immich"]
  token_ttl                        = 3600
  bound_service_account_names      = ["immich"]
  token_policies                   = ["immich"]
}

resource "vault_policy" "immich" {
  name = "immich"

  policy = <<EOT
path "kvv2/data/core/minio/k8s-backups/backuper-credentials" {
  capabilities = ["read"]
}
EOT
}
