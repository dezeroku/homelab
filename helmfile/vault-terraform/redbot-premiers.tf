module "redbot-premiers" {
  source             = "./service"
  name               = "redbot-premiers"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  service_account_names = ["redbot-premiers-main"]
  secrets_prefix        = "services/redbot/premiers"

  secrets = {
    secrets = {
      token = var.redbot_premiers_token
    }
  }
}

moved {
  from = vault_kubernetes_auth_backend_role.redbot-premiers
  to   = module.redbot-premiers.vault_kubernetes_auth_backend_role.this[0]
}

moved {
  from = vault_policy.redbot-premiers
  to   = module.redbot-premiers.vault_policy.this[0]
}

moved {
  from = vault_generic_secret.redbot-premiers-secrets
  to   = module.redbot-premiers.vault_generic_secret.this["secrets"]
}
