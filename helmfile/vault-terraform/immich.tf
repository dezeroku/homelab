module "immich" {
  source             = "${local.lib_path}/terraform/service"
  name               = "immich"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  backuper_credentials_path = local.backuper_credentials_path

  # immich does not read its own OIDC client from Vault, so no client read grant.
  grant_oidc_client_read = false

  oidc = {
    redirect_uris = [
      "app.immich:///oauth-callback",
      "https://immich.${var.domain}/auth/login",
      "https://immich.${var.domain}/user-settings",
    ]
    group_ids = [vault_identity_group.this["immich"].id]
  }
}

moved {
  from = vault_identity_oidc_assignment.immich
  to   = module.immich.vault_identity_oidc_assignment.this[0]
}

moved {
  from = vault_identity_oidc_client.immich
  to   = module.immich.vault_identity_oidc_client.this[0]
}

moved {
  from = vault_kubernetes_auth_backend_role.immich
  to   = module.immich.vault_kubernetes_auth_backend_role.this[0]
}

moved {
  from = vault_policy.immich
  to   = module.immich.vault_policy.this[0]
}
