module "minio-k8s-backups" {
  source             = "../lib/terraform/service"
  name               = "minio-k8s-backups"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  secrets_prefix = "core/minio/k8s-backups"

  secrets = {
    "root-credentials" = {
      rootUser     = var.minio_k8s_backups_root_username
      rootPassword = var.minio_k8s_backups_root_password
    }
    "backuper-credentials" = {
      username = var.minio_k8s_backups_backuper_username
      password = var.minio_k8s_backups_backuper_password
    }
  }
}

moved {
  from = vault_kubernetes_auth_backend_role.minio_k8s_backups
  to   = module.minio-k8s-backups.vault_kubernetes_auth_backend_role.this[0]
}

moved {
  from = vault_policy.minio_k8s_backups
  to   = module.minio-k8s-backups.vault_policy.this[0]
}

moved {
  from = vault_generic_secret.minio-k8s-backups-root-credentials
  to   = module.minio-k8s-backups.vault_generic_secret.this["root-credentials"]
}

moved {
  from = vault_generic_secret.minio-k8s-backups-backuper-credentials
  to   = module.minio-k8s-backups.vault_generic_secret.this["backuper-credentials"]
}
