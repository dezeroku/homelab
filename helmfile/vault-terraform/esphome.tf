module "esphome" {
  source             = "${local.lib_path}/terraform/service"
  name               = "esphome"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  secrets = {
    secrets = {
      iot_wifi_ssid        = var.iot_wifi_ssid
      iot_wifi_password    = var.iot_wifi_password
      mqtt_username        = "esphome"
      mqtt_password        = var.mosquitto_users["esphome"].password
      esphome_ota_password = var.esphome_ota_password
      esphome_api_password = var.esphome_api_password
    }
  }

  oidc = {
    redirect_uris = ["https://esphome.${var.domain}/oauth2/callback"]
    group_ids     = [vault_identity_group.this["esphome"].id]
  }
}

moved {
  from = vault_kubernetes_auth_backend_role.esphome
  to   = module.esphome.vault_kubernetes_auth_backend_role.this[0]
}

moved {
  from = vault_policy.esphome
  to   = module.esphome.vault_policy.this[0]
}

moved {
  from = vault_generic_secret.esphome-secrets
  to   = module.esphome.vault_generic_secret.this["secrets"]
}
