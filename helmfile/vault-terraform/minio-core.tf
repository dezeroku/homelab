module "minio-core" {
  source             = "./service"
  name               = "minio"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  namespace             = "minio-core"
  service_account_names = ["default"]
  secrets_prefix        = "services/minio/core"

  secrets = {
    "root-credentials" = {
      rootUser     = var.minio_root_username
      rootPassword = var.minio_root_password
    }
    "dezeroku-credentials" = {
      username = var.minio_dezeroku_username
      password = var.minio_dezeroku_password
    }
  }
}

moved {
  from = vault_kubernetes_auth_backend_role.minio
  to   = module.minio-core.vault_kubernetes_auth_backend_role.this[0]
}

moved {
  from = vault_policy.minio
  to   = module.minio-core.vault_policy.this[0]
}

moved {
  from = vault_generic_secret.minio-root-credentials
  to   = module.minio-core.vault_generic_secret.this["root-credentials"]
}

moved {
  from = vault_generic_secret.minio-dezeroku-credentials
  to   = module.minio-core.vault_generic_secret.this["dezeroku-credentials"]
}
