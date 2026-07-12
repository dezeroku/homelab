module "invidious" {
  source             = "./service"
  name               = "invidious"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  include_backuper_credentials = true

  secrets = {
    hmac = {
      key = var.invidious_hmac_key
    }
    "companion-hmac" = {
      key = var.invidious_companion_hmac_key
    }
  }
}

moved {
  from = vault_kubernetes_auth_backend_role.invidious
  to   = module.invidious.vault_kubernetes_auth_backend_role.this[0]
}

moved {
  from = vault_policy.invidious
  to   = module.invidious.vault_policy.this[0]
}

moved {
  from = vault_generic_secret.invidious-hmac
  to   = module.invidious.vault_generic_secret.this["hmac"]
}

moved {
  from = vault_generic_secret.invidious-companion-hmac
  to   = module.invidious.vault_generic_secret.this["companion-hmac"]
}
