module "tgtg" {
  source             = "../lib/terraform/service"
  name               = "tgtg"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  service_account_names = ["default"]

  secrets = {
    username = {
      username = var.tgtg_username
    }
    ses = {
      access_key_id     = var.ses_access_key_id
      access_key_secret = var.ses_access_key_secret
      from              = var.tgtg_ses_from
      to                = var.tgtg_ses_to
    }
  }
}

moved {
  from = vault_kubernetes_auth_backend_role.tgtg
  to   = module.tgtg.vault_kubernetes_auth_backend_role.this[0]
}

moved {
  from = vault_policy.tgtg
  to   = module.tgtg.vault_policy.this[0]
}

moved {
  from = vault_generic_secret.tgtg-username
  to   = module.tgtg.vault_generic_secret.this["username"]
}

moved {
  from = vault_generic_secret.tgtg-ses
  to   = module.tgtg.vault_generic_secret.this["ses"]
}
