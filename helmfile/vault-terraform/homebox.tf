module "homebox" {
  source             = "${local.lib_path}/terraform/service"
  name               = "homebox"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  backuper_credentials_path = local.backuper_credentials_path

  oidc = {
    redirect_uris = ["https://homebox.${var.domain}/api/v1/users/login/oidc/callback"]
    group_ids     = [vault_identity_group.this["homebox"].id]
  }

  secrets = {
    api-key = {
      pepper = random_password.homebox_api_key_pepper.result
    }
  }
}

resource "random_password" "homebox_api_key_pepper" {
  length = 32
}
