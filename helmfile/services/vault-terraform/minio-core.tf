resource "vault_kubernetes_auth_backend_role" "minio" {
  backend                          = var.vault_auth_backend_kubernetes_path
  role_name                        = "minio"
  bound_service_account_namespaces = ["minio-core"]
  token_ttl                        = 3600
  bound_service_account_names      = ["default"]
  token_policies                   = ["minio"]
}

resource "vault_policy" "minio" {
  name = "minio"

  policy = <<EOT
path "kvv2/data/services/minio/core/root-credentials" {
  capabilities = ["read"]
}
path "kvv2/data/services/minio/core/dezeroku-credentials" {
  capabilities = ["read"]
}
EOT
}

resource "vault_generic_secret" "minio-root-credentials" {
  path = "kvv2/services/minio/core/root-credentials"

  data_json = jsonencode(
    {
      "rootUser" : var.minio_root_username,
      "rootPassword" : var.minio_root_password
    }
  )
}

resource "vault_generic_secret" "minio-dezeroku-credentials" {
  path = "kvv2/services/minio/core/dezeroku-credentials"

  data_json = jsonencode(
    {
      "username" : var.minio_dezeroku_username,
      "password" : var.minio_dezeroku_password
    }
  )
}
