module "whisper" {
  source             = "${local.lib_path}/terraform/service"
  name               = "whisper"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  secrets = {
    hass = {
      token = var.whisper_hass_token
    }
  }
}
