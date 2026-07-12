module "redbot-main" {
  source             = "./service"
  name               = "redbot-main"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  service_account_names = ["redbot-main"]
  secrets_prefix        = "services/redbot/main"

  secrets = {
    secrets = {
      token = var.redbot_main_token
    }
  }
}

moved {
  from = vault_kubernetes_auth_backend_role.redbot-main
  to   = module.redbot-main.vault_kubernetes_auth_backend_role.this[0]
}

moved {
  from = vault_policy.redbot-main
  to   = module.redbot-main.vault_policy.this[0]
}

moved {
  from = vault_generic_secret.redbot-main-secrets
  to   = module.redbot-main.vault_generic_secret.this["secrets"]
}
