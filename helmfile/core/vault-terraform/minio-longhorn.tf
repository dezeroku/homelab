resource "vault_kubernetes_auth_backend_role" "minio_longhorn" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "minio-longhorn"
  bound_service_account_namespaces = ["longhorn"]
  token_ttl                        = 3600
  bound_service_account_names      = ["default"]
  token_policies                   = ["minio-longhorn"]
}

resource "vault_policy" "minio_longhorn" {
  name = "minio-longhorn"

  policy = <<EOT
path "kvv2/data/core/minio/longhorn/root-credentials" {
  capabilities = ["read"]
}
path "kvv2/data/core/minio/longhorn/longhorn-credentials" {
  capabilities = ["read"]
}
EOT
}

resource "vault_generic_secret" "minio-longhorn-root-credentials" {
  path = "kvv2/core/minio/longhorn/root-credentials"

  data_json = jsonencode(
    {
      # TODO: do this properly when https://github.com/hashicorp/vault-secrets-operator/issues/135 is done
      "config.env" : "export MINIO_ROOT_USER=${var.minio_longhorn_root_username}\nexport MINIO_ROOT_PASSWORD=${var.minio_longhorn_root_password}",
      "rootUser" : var.minio_longhorn_root_username,
      "rootPassword" : var.minio_longhorn_root_password
    }
  )
}

resource "vault_generic_secret" "minio-longhorn-longhorn-credentials" {
  path = "kvv2/core/minio/longhorn/longhorn-credentials"

  data_json = jsonencode(
    {
      # TODO: do this properly when https://github.com/hashicorp/vault-secrets-operator/issues/135 is done
      "CONSOLE_ACCESS_KEY" : var.minio_longhorn_longhorn_username,
      "CONSOLE_SECRET_KEY" : var.minio_longhorn_longhorn_password,
      "username" : var.minio_longhorn_longhorn_username,
      "password" : var.minio_longhorn_longhorn_password
    }
  )
}
