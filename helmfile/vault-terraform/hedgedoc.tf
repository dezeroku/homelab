resource "vault_identity_oidc_assignment" "hedgedoc" {
  name      = "hedgedoc"
  group_ids = [vault_identity_group.users.id]
}

resource "vault_identity_oidc_client" "hedgedoc" {
  name = "hedgedoc"
  redirect_uris = [
    "https://hedgedoc.${var.domain}/auth/oauth2/callback",
  ]
  assignments      = [vault_identity_oidc_assignment.hedgedoc.name]
  id_token_ttl     = 2400
  access_token_ttl = 7200
}

resource "vault_kubernetes_auth_backend_role" "hedgedoc" {
  backend                          = vault_auth_backend.kubernetes_homeserver.path
  role_name                        = "hedgedoc"
  bound_service_account_namespaces = ["hedgedoc"]
  token_ttl                        = 3600
  bound_service_account_names      = ["hedgedoc-main"]
  token_policies                   = ["hedgedoc"]
}

resource "vault_policy" "hedgedoc" {
  name = "hedgedoc"

  policy = <<EOT
path "identity/oidc/client/hedgedoc" {
  capabilities = ["read"]
}
path "kvv2/data/core/minio/k8s-backups/backuper-credentials" {
  capabilities = ["read"]
}
EOT
}
