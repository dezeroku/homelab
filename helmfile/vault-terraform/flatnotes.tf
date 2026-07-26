module "flatnotes" {
  source             = "./service"
  name               = "flatnotes"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  oidc = {
    redirect_uris = ["https://flatnotes.${var.domain}/oauth2/callback"]
    group_ids     = [vault_identity_group.this["flatnotes"].id]
  }
}
