module "mailrise" {
  source             = "${local.lib_path}/terraform/service"
  name               = "mailrise"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  secrets = {
    "pushover/dezeroku/general" = {
      user_key = var.mailrise_pushover_dezeroku_general_user_key
      api_key  = var.mailrise_pushover_dezeroku_general_api_key
    }
    "pushover/dezeroku/mailrise" = {
      user_key = var.mailrise_pushover_dezeroku_mailrise_user_key
      api_key  = var.mailrise_pushover_dezeroku_mailrise_api_key
    }
    "ses" = {
      access_key_id     = var.ses_access_key_id
      access_key_secret = var.ses_access_key_secret
    }
  }
}

moved {
  from = vault_kubernetes_auth_backend_role.mailrise
  to   = module.mailrise.vault_kubernetes_auth_backend_role.this[0]
}

moved {
  from = vault_policy.mailrise
  to   = module.mailrise.vault_policy.this[0]
}

moved {
  from = vault_generic_secret.mailrise-pushover-dezeroku-general
  to   = module.mailrise.vault_generic_secret.this["pushover/dezeroku/general"]
}

moved {
  from = vault_generic_secret.mailrise-pushover-dezeroku-mailrise
  to   = module.mailrise.vault_generic_secret.this["pushover/dezeroku/mailrise"]
}

moved {
  from = vault_generic_secret.mailrise-ses
  to   = module.mailrise.vault_generic_secret.this["ses"]
}
