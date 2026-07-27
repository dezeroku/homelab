# Backup-cluster service: MinIO instance on the backup cluster that receives Longhorn backups.
module "minio-longhorn" {
  source             = "../lib/terraform/service"
  name               = "minio-longhorn"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver_backup.path

  service_account_names = ["default"]
  secrets_prefix        = "services/minio/longhorn"

  secrets = {
    "root-credentials" = {
      rootUser     = var.minio_longhorn_root_username
      rootPassword = var.minio_longhorn_root_password
    }
    "longhorn-credentials" = {
      username = var.minio_longhorn_longhorn_username
      password = var.minio_longhorn_longhorn_password
    }
  }
}

moved {
  from = vault_kubernetes_auth_backend_role.minio_longhorn
  to   = module.minio-longhorn.vault_kubernetes_auth_backend_role.this[0]
}

moved {
  from = vault_policy.minio_longhorn
  to   = module.minio-longhorn.vault_policy.this[0]
}

moved {
  from = vault_generic_secret.minio-longhorn-root-credentials
  to   = module.minio-longhorn.vault_generic_secret.this["root-credentials"]
}

moved {
  from = vault_generic_secret.minio-longhorn-longhorn-credentials
  to   = module.minio-longhorn.vault_generic_secret.this["longhorn-credentials"]
}
