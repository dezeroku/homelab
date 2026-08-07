module "homepage" {
  source             = "${local.lib_path}/terraform/service"
  name               = "homepage"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  # Policy is a wildcard over the whole homepage subtree rather than per-secret.
  derive_policy_from_secrets = false
  extra_policy_read_paths    = ["kvv2/data/services/homepage/*"]

  secrets = {
    jellyfin = {
      apikey = var.homepage_jellyfin_apikey
    }
  }
}

moved {
  from = vault_kubernetes_auth_backend_role.homepage
  to   = module.homepage.vault_kubernetes_auth_backend_role.this[0]
}

moved {
  from = vault_policy.homepage
  to   = module.homepage.vault_policy.this[0]
}

moved {
  from = vault_generic_secret.homepage-jellyfin
  to   = module.homepage.vault_generic_secret.this["jellyfin"]
}
