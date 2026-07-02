resource "vault_kubernetes_auth_backend_role" "esphome" {
  backend                          = vault_auth_backend.kubernetes_homeserver.path
  role_name                        = "esphome"
  bound_service_account_namespaces = ["esphome"]
  token_ttl                        = 3600
  bound_service_account_names      = ["esphome-main"]
  token_policies                   = ["esphome"]
}

resource "vault_policy" "esphome" {
  name = "esphome"

  policy = <<EOT
path "kvv2/data/services/esphome/secrets" {
  capabilities = ["read"]
}
EOT
}

resource "vault_generic_secret" "esphome-secrets" {
  path = "kvv2/services/esphome/secrets"

  data_json = jsonencode(
    {
      "iot_wifi_ssid" : var.iot_wifi_ssid,
      "iot_wifi_password" : var.iot_wifi_password,
      "mqtt_username" : var.mosquitto_username,
      "mqtt_password" : var.mosquitto_password,
      "esphome_ota_password" : var.esphome_ota_password,
    }
  )
}
