module "piper" {
  source             = "${local.lib_path}/terraform/service"
  name               = "piper"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  oidc = {
    redirect_uris = ["https://piper.${var.domain}/oauth2/callback"]
    group_ids     = [vault_identity_group.this["piper"].id]
  }
}
