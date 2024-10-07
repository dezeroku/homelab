resource "vault_kubernetes_auth_backend_role" "minio_longhorn" {
  backend                          = vault_auth_backend.kubernetes_homeserver_backup.path
  role_name                        = "minio-longhorn"
  bound_service_account_namespaces = ["minio-longhorn"]
  token_ttl                        = 3600
  bound_service_account_names      = ["default"]
  token_policies                   = ["minio-longhorn"]
}

resource "vault_policy" "minio_longhorn" {
  name = "minio-longhorn"

  policy = <<EOT
path "kvv2/data/services/minio/longhorn/root-credentials" {
  capabilities = ["read"]
}
path "kvv2/data/services/minio/longhorn/longhorn-credentials" {
  capabilities = ["read"]
}
EOT
}

resource "vault_generic_secret" "minio-longhorn-root-credentials" {
  path = "kvv2/services/minio/longhorn/root-credentials"

  data_json = jsonencode(
    {
      "rootUser" : var.minio_longhorn_root_username,
      "rootPassword" : var.minio_longhorn_root_password
    }
  )
}

resource "vault_generic_secret" "minio-longhorn-longhorn-credentials" {
  path = "kvv2/services/minio/longhorn/longhorn-credentials"

  data_json = jsonencode(
    {
      "username" : var.minio_longhorn_longhorn_username,
      "password" : var.minio_longhorn_longhorn_password
    }
  )
}
