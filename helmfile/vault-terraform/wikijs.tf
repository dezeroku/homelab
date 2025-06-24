resource "vault_identity_oidc_assignment" "wikijs" {
  name      = "wikijs"
  group_ids = [vault_identity_group.users.id]
}

resource "vault_identity_oidc_client" "wikijs" {
  name = "wikijs"
  redirect_uris = [
    "https://wikijs.${var.domain}/login/${var.wikijs_oidc_auth_id}/callback"
  ]
  assignments      = [vault_identity_oidc_assignment.wikijs.name]
  id_token_ttl     = 2400
  access_token_ttl = 7200
}

resource "vault_kubernetes_auth_backend_role" "wikijs" {
  backend                          = vault_auth_backend.kubernetes_homeserver.path
  role_name                        = "wikijs"
  bound_service_account_namespaces = ["wikijs"]
  token_ttl                        = 3600
  bound_service_account_names      = ["wikijs-main"]
  token_policies                   = ["wikijs"]
}

resource "vault_policy" "wikijs" {
  name = "wikijs"

  policy = <<EOT
path "identity/oidc/client/wikijs" {
  capabilities = ["read"]
}
path "kvv2/data/core/minio/k8s-backups/backuper-credentials" {
  capabilities = ["read"]
}
EOT
}
