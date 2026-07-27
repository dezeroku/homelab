module "ryot" {
  source             = "../lib/terraform/service"
  name               = "ryot"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  backuper_credentials_path = local.backuper_credentials_path

  oidc = {
    redirect_uris = ["https://ryot.${var.domain}/api/auth"]
    group_ids     = [vault_identity_group.this["users"].id]
  }

  secrets = {
    admin = {
      token = var.ryot_admin_token
    }
  }
}

moved {
  from = vault_identity_oidc_assignment.ryot
  to   = module.ryot.vault_identity_oidc_assignment.this[0]
}

moved {
  from = vault_identity_oidc_client.ryot
  to   = module.ryot.vault_identity_oidc_client.this[0]
}

moved {
  from = vault_kubernetes_auth_backend_role.ryot
  to   = module.ryot.vault_kubernetes_auth_backend_role.this[0]
}

moved {
  from = vault_policy.ryot
  to   = module.ryot.vault_policy.this[0]
}

moved {
  from = vault_generic_secret.ryot-admin
  to   = module.ryot.vault_generic_secret.this["admin"]
}
