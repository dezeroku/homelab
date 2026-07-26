module "navidrome" {
  source             = "./service"
  name               = "navidrome"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  namespace             = "media"
  service_account_names = ["navidrome"]

  oidc = {
    redirect_uris = ["https://navidrome-metube.home.dezeroku.com/oauth2/callback"]
    group_ids = [
      vault_identity_group.this["navidrome"].id,
    ]
  }
}
