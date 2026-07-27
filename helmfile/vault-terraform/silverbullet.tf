module "silverbullet" {
  source             = "../lib/terraform/service"
  name               = "silverbullet"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  oidc = {
    redirect_uris = ["https://silverbullet.${var.domain}/oauth2/callback"]
    group_ids     = [vault_identity_group.this["silverbullet"].id]
  }
}
