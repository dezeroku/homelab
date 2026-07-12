module "longhorn" {
  source             = "./service"
  name               = "longhorn"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  service_account_names = ["longhorn-service-account"]
  secrets_prefix        = "longhorn"

  secrets = {
    "minio-backup-credentials-s3" = {
      AWS_ACCESS_KEY_ID     = var.minio_longhorn_longhorn_username
      AWS_SECRET_ACCESS_KEY = var.minio_longhorn_longhorn_password
      AWS_ENDPOINTS         = var.minio_longhorn_endpoint
    }
  }
}

moved {
  from = vault_kubernetes_auth_backend_role.longhorn
  to   = module.longhorn.vault_kubernetes_auth_backend_role.this[0]
}

moved {
  from = vault_policy.longhorn
  to   = module.longhorn.vault_policy.this[0]
}

moved {
  from = vault_generic_secret.longhorn-minio-backup-credentials-s3
  to   = module.longhorn.vault_generic_secret.this["minio-backup-credentials-s3"]
}
