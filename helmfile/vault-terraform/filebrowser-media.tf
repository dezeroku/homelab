module "filebrowser-media" {
  source             = "./service"
  name               = "filebrowser-media"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  namespace = "media"

  oidc = {
    redirect_uris = ["https://filebrowser.media.${var.domain}/api/auth/oidc/callback"]
    group_ids = [
      vault_identity_group.this["filebrowser-media"].id,
    ]
  }
}
