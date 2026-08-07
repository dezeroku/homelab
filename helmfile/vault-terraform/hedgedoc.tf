module "hedgedoc" {
  source             = "${local.lib_path}/terraform/service"
  name               = "hedgedoc"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  backuper_credentials_path = local.backuper_credentials_path

  oidc = {
    redirect_uris = ["https://hedgedoc.${var.domain}/auth/oauth2/callback"]
    group_ids     = [vault_identity_group.this["users"].id]
  }
}

moved {
  from = vault_identity_oidc_assignment.hedgedoc
  to   = module.hedgedoc.vault_identity_oidc_assignment.this[0]
}

moved {
  from = vault_identity_oidc_client.hedgedoc
  to   = module.hedgedoc.vault_identity_oidc_client.this[0]
}

moved {
  from = vault_kubernetes_auth_backend_role.hedgedoc
  to   = module.hedgedoc.vault_kubernetes_auth_backend_role.this[0]
}

moved {
  from = vault_policy.hedgedoc
  to   = module.hedgedoc.vault_policy.this[0]
}
