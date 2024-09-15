resource "vault_kubernetes_auth_backend_role" "minio_private" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "minio-private"
  bound_service_account_namespaces = ["minio-private"]
  token_ttl                        = 3600
  bound_service_account_names      = ["default"]
  token_policies                   = ["minio-private"]
}

resource "vault_policy" "minio_private" {
  name = "minio-private"

  policy = <<EOT
path "kvv2/data/services/minio/private/root-credentials" {
  capabilities = ["read"]
}
path "kvv2/data/services/minio/private/dezeroku-credentials" {
  capabilities = ["read"]
}
EOT
}

resource "vault_generic_secret" "minio-private-root-credentials" {
  path = "kvv2/services/minio/private/root-credentials"

  data_json = jsonencode(
    {
      "rootUser" : var.minio_private_root_username,
      "rootPassword" : var.minio_private_root_password
    }
  )
}

resource "vault_generic_secret" "minio-private-dezeroku-credentials" {
  path = "kvv2/services/minio/private/dezeroku-credentials"

  data_json = jsonencode(
    {
      "username" : var.minio_private_dezeroku_username,
      "password" : var.minio_private_dezeroku_password
    }
  )
}
