module "vm-logs" {
  source             = "${local.lib_path}/terraform/service"
  name               = "vm-logs"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  oidc = {
    redirect_uris = ["https://vm-logs.${var.domain}/oauth2/callback"]
    group_ids = [
      vault_identity_group.this["vm-logs"].id,
    ]
  }
}
