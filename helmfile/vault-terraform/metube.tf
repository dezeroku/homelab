module "metube" {
  source             = "./service"
  name               = "metube"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  namespace = "media"

  oidc = {
    redirect_uris = ["https://metube.${var.domain}/oauth2/callback"]
    group_ids = [
      vault_identity_group.this["metube"].id,
    ]
  }
}
