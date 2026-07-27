module "redbot-premiers" {
  source             = "./service"
  name               = "redbot-premiers"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  secrets_prefix = "services/redbot/redbot-premiers"

  secrets = {
    secrets = {
      token = var.redbot_premiers_token
    }
  }

  oidc = {
    redirect_uris = [
      "https://redbot-premiers-filebrowser.${var.domain}/api/auth/oidc/callback",
      "https://redbot-premiers-metube.${var.domain}/oauth2/callback"
    ]
    group_ids = [
      vault_identity_group.this["redbot-premiers"].id,
    ]
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
