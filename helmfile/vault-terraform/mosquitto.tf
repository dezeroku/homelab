resource "vault_kubernetes_auth_backend_role" "mosquitto" {
  backend                          = vault_auth_backend.kubernetes_homeserver.path
  role_name                        = "mosquitto"
  bound_service_account_namespaces = ["mosquitto"]
  token_ttl                        = 3600
  bound_service_account_names      = ["mosquitto-main"]
  token_policies                   = ["mosquitto"]
}

resource "vault_policy" "mosquitto" {
  name = "mosquitto"

  policy = <<EOT
path "kvv2/data/services/mosquitto/credentials" {
  capabilities = ["read"]
}
EOT
}

resource "vault_generic_secret" "mosquitto-credentials" {
  path = "kvv2/services/mosquitto/credentials"

  data_json = jsonencode(
    {
      "username" : var.mosquitto_username,
      "password" : var.mosquitto_password,
      "passwordfile" : var.mosquitto_passwordfile,
    }
  )
}
