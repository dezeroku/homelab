resource "vault_kubernetes_auth_backend_role" "ente" {
  backend                          = vault_auth_backend.kubernetes_homeserver.path
  role_name                        = "ente"
  bound_service_account_namespaces = ["ente"]
  token_ttl                        = 3600
  bound_service_account_names      = ["ente-main"]
  token_policies                   = ["ente"]
}

resource "vault_policy" "ente" {
  name = "ente"

  policy = <<EOT
path "kvv2/data/core/minio/k8s-backups/backuper-credentials" {
  capabilities = ["read"]
}
path "kvv2/data/services/ente/jwt-secret" {
  capabilities = ["read"]
}
path "kvv2/data/services/ente/key" {
  capabilities = ["read"]
}
EOT
}

resource "vault_generic_secret" "ente-jwt-secret" {
  path = "kvv2/services/ente/jwt-secret"

  data_json = jsonencode(
    {
      "secret" : var.ente_jwt_secret,
    }
  )
}

resource "vault_generic_secret" "ente-key" {
  path = "kvv2/services/ente/key"

  data_json = jsonencode(
    {
      "encryption" : var.ente_key_encryption,
      "hash" : var.ente_key_hash,
    }
  )
}
