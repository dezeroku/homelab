resource "vault_kubernetes_auth_backend_role" "longhorn" {
  backend                          = vault_auth_backend.kubernetes_homeserver.path
  role_name                        = "longhorn"
  bound_service_account_namespaces = ["longhorn"]
  token_ttl                        = 3600
  bound_service_account_names      = ["longhorn-service-account"]
  token_policies                   = ["longhorn"]
}

resource "vault_policy" "longhorn" {
  name = "longhorn"

  policy = <<EOT
path "kvv2/data/longhorn/minio-backup-credentials-s3" {
  capabilities = ["read"]
}
EOT
}

resource "vault_generic_secret" "longhorn-minio-backup-credentials-s3" {
  path = "kvv2/longhorn/minio-backup-credentials-s3"

  data_json = jsonencode(
    {
      "AWS_ACCESS_KEY_ID" : var.minio_longhorn_backup_username,
      "AWS_SECRET_ACCESS_KEY" : var.minio_longhorn_backup_password,
      "AWS_ENDPOINTS" : var.minio_longhorn_backup_endpoint
    }
  )
}
