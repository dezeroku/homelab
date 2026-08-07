module "filebrowser-media-readonly" {
  source             = "${local.lib_path}/terraform/service"
  name               = "filebrowser-media-readonly"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  namespace = "media"

  oidc = {
    redirect_uris = ["https://filebrowser-readonly.media.${var.domain}/api/auth/oidc/callback"]
    group_ids = [
      vault_identity_group.this["filebrowser-media-readonly"].id,
    ]
  }
}
