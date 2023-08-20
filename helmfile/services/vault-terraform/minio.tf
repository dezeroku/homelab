resource "vault_kubernetes_auth_backend_role" "minio" {
  backend                          = var.vault_auth_backend_kubernetes_path
  role_name                        = "minio"
  bound_service_account_namespaces = ["minio"]
  token_ttl                        = 3600
  bound_service_account_names      = ["minio-sa"]
  token_policies                   = ["minio"]
}

resource "vault_policy" "minio" {
  name = "minio"

  policy = <<EOT
path "kvv2/data/services/minio/root-credentials" {
  capabilities = ["read"]
}
EOT
}

resource "vault_generic_secret" "minio-root-credentials" {
  path = "kvv2/services/minio/root-credentials"

  data_json = jsonencode(
    {
      "rootUser" : var.minio_root_username,
      "rootPassword" : var.minio_root_password
    }
  )
}
