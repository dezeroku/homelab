module "wikijs" {
  source             = "${local.lib_path}/terraform/service"
  name               = "wikijs"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  backuper_credentials_path = local.backuper_credentials_path

  oidc = {
    redirect_uris = ["https://wikijs.${var.domain}/login/${var.wikijs_oidc_auth_id}/callback"]
    group_ids     = [vault_identity_group.this["users"].id]
  }
}

moved {
  from = vault_identity_oidc_assignment.wikijs
  to   = module.wikijs.vault_identity_oidc_assignment.this[0]
}

moved {
  from = vault_identity_oidc_client.wikijs
  to   = module.wikijs.vault_identity_oidc_client.this[0]
}

moved {
  from = vault_kubernetes_auth_backend_role.wikijs
  to   = module.wikijs.vault_kubernetes_auth_backend_role.this[0]
}

moved {
  from = vault_policy.wikijs
  to   = module.wikijs.vault_policy.this[0]
}
