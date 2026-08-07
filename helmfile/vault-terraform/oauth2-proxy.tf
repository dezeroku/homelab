module "oauth2-proxy" {
  source             = "${local.lib_path}/terraform/service"
  name               = "oauth2-proxy"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  service_account_names = ["oauth2-proxy"]
  secrets_prefix        = "core/oauth2-proxy"

  oidc = {
    redirect_uris = ["https://sso.${var.domain}/oauth2/callback"]
    group_ids     = [vault_identity_group.this["users"].id]
  }

  secrets = {
    "cookie-secret" = {
      "cookie-secret" = var.oauth2_proxy_cookie_secret
    }
  }
}

moved {
  from = vault_identity_oidc_assignment.oauth2-proxy
  to   = module.oauth2-proxy.vault_identity_oidc_assignment.this[0]
}

moved {
  from = vault_identity_oidc_client.oauth2-proxy
  to   = module.oauth2-proxy.vault_identity_oidc_client.this[0]
}

moved {
  from = vault_kubernetes_auth_backend_role.oauth2-proxy
  to   = module.oauth2-proxy.vault_kubernetes_auth_backend_role.this[0]
}

moved {
  from = vault_policy.oauth2-proxy
  to   = module.oauth2-proxy.vault_policy.this[0]
}

moved {
  from = vault_generic_secret.oauth2-proxy-cookie-secret
  to   = module.oauth2-proxy.vault_generic_secret.this["cookie-secret"]
}
