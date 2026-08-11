module "open-webui" {
  source             = "${local.lib_path}/terraform/service"
  name               = "open-webui"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  secrets = {
    "secret-key" = {
      key = var.open_webui_secret_key
    }
  }

  oidc = {
    redirect_uris = ["https://open-webui.${var.domain}/oauth/oidc/callback"]
    group_ids     = [vault_identity_group.this["open-webui"].id]
  }
}
