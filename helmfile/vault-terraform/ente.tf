module "ente" {
  source             = "../lib/terraform/service"
  name               = "ente"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  backuper_credentials_path = local.backuper_credentials_path

  secrets = {
    "jwt-secret" = {
      secret = var.ente_jwt_secret
    }
    key = {
      encryption = var.ente_key_encryption
      hash       = var.ente_key_hash
    }
  }
}

moved {
  from = vault_kubernetes_auth_backend_role.ente
  to   = module.ente.vault_kubernetes_auth_backend_role.this[0]
}

moved {
  from = vault_policy.ente
  to   = module.ente.vault_policy.this[0]
}

moved {
  from = vault_generic_secret.ente-jwt-secret
  to   = module.ente.vault_generic_secret.this["jwt-secret"]
}

moved {
  from = vault_generic_secret.ente-key
  to   = module.ente.vault_generic_secret.this["key"]
}
