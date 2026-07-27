module "minio-private" {
  source             = "../lib/terraform/service"
  name               = "minio-private"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  service_account_names = ["default"]
  secrets_prefix        = "services/minio/private"

  secrets = {
    "root-credentials" = {
      rootUser     = var.minio_private_root_username
      rootPassword = var.minio_private_root_password
    }
    "dezeroku-credentials" = {
      username = var.minio_private_dezeroku_username
      password = var.minio_private_dezeroku_password
    }
  }
}

moved {
  from = vault_kubernetes_auth_backend_role.minio_private
  to   = module.minio-private.vault_kubernetes_auth_backend_role.this[0]
}

moved {
  from = vault_policy.minio_private
  to   = module.minio-private.vault_policy.this[0]
}

moved {
  from = vault_generic_secret.minio-private-root-credentials
  to   = module.minio-private.vault_generic_secret.this["root-credentials"]
}

moved {
  from = vault_generic_secret.minio-private-dezeroku-credentials
  to   = module.minio-private.vault_generic_secret.this["dezeroku-credentials"]
}
