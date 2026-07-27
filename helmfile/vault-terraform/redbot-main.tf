module "redbot-main" {
  source             = "../lib/terraform/service"
  name               = "redbot-main"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  secrets_prefix = "services/redbot/redbot-main"

  secrets = {
    secrets = {
      token = var.redbot_main_token
    }
  }

  oidc = {
    redirect_uris = [
      "https://redbot-main-filebrowser.${var.domain}/api/auth/oidc/callback",
      "https://redbot-main-metube.${var.domain}/oauth2/callback"
    ]
    group_ids = [
      vault_identity_group.this["redbot-main"].id,
    ]
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
