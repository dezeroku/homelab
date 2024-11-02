resource "vault_identity_oidc_assignment" "ryot" {
  name      = "ryot"
  group_ids = [vault_identity_group.users.id]
}

resource "vault_identity_oidc_client" "ryot" {
  name = "ryot"
  redirect_uris = [
    "https://ryot.${var.domain}/api/auth",
  ]
  assignments      = [vault_identity_oidc_assignment.ryot.name]
  id_token_ttl     = 2400
  access_token_ttl = 7200
}

resource "vault_kubernetes_auth_backend_role" "ryot" {
  backend                          = vault_auth_backend.kubernetes_homeserver.path
  role_name                        = "ryot"
  bound_service_account_namespaces = ["ryot"]
  token_ttl                        = 3600
  bound_service_account_names      = ["ryot"]
  token_policies                   = ["ryot"]
}

resource "vault_policy" "ryot" {
  name = "ryot"

  policy = <<EOT
path "identity/oidc/client/ryot" {
  capabilities = ["read"]
}
path "kvv2/data/core/minio/k8s-backups/backuper-credentials" {
  capabilities = ["read"]
}
EOT
}
