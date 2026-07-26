module "change-detection" {
  source             = "./service"
  name               = "change-detection"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  oidc = {
    redirect_uris = ["https://change-detection.${var.domain}/oauth2/callback"]
    group_ids     = [vault_identity_group.this["change-detection"].id]
  }
}
