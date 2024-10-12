resource "vault_kubernetes_auth_backend_role" "minio_k8s_backups" {
  backend                          = vault_auth_backend.kubernetes_homeserver.path
  role_name                        = "minio-k8s-backups"
  bound_service_account_namespaces = ["minio-k8s-backups"]
  token_ttl                        = 3600
  bound_service_account_names      = ["default"]
  token_policies                   = ["minio-k8s-backups"]
}

resource "vault_policy" "minio_k8s_backups" {
  name = "minio-k8s-backups"

  policy = <<EOT
path "kvv2/data/core/minio/k8s-backups/root-credentials" {
  capabilities = ["read"]
}
path "kvv2/data/core/minio/k8s-backups/backuper-credentials" {
  capabilities = ["read"]
}
EOT
}

resource "vault_generic_secret" "minio-k8s-backups-root-credentials" {
  path = "kvv2/core/minio/k8s-backups/root-credentials"

  data_json = jsonencode(
    {
      "rootUser" : var.minio_k8s_backups_root_username,
      "rootPassword" : var.minio_k8s_backups_root_password
    }
  )
}

resource "vault_generic_secret" "minio-k8s-backups-backuper-credentials" {
  path = "kvv2/core/minio/k8s-backups/backuper-credentials"

  data_json = jsonencode(
    {
      "username" : var.minio_k8s_backups_backuper_username,
      "password" : var.minio_k8s_backups_backuper_password
    }
  )
}
