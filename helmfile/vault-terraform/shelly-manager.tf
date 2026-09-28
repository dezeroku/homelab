module "shelly-manager" {
  source             = "${local.lib_path}/terraform/service"
  name               = "shelly-manager"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  secrets = {
    secret-key = {
      value = random_bytes.shelly_manager_secret_key.base64
    }
    auth-token = {
      value = var.shelly_manager_auth_token
    }
  }

  oidc = {
    redirect_uris = ["https://shelly-manager.${var.domain}/oauth2/callback"]
    group_ids     = [vault_identity_group.this["shelly-manager"].id]
  }
}

resource "random_bytes" "shelly_manager_secret_key" {
  length = 32
}
