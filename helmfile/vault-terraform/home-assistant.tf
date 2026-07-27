module "home-assistant" {
  source             = "../lib/terraform/service"
  name               = "home-assistant"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  secrets = {
    prometheus = {
      token = var.home_assistant_prometheus_token
    }
    mosquitto = {
      mqtt_username = "home-assistant"
      mqtt_password = var.mosquitto_users["home-assistant"].password
    }
  }
}

moved {
  from = vault_kubernetes_auth_backend_role.home-assistant
  to   = module.home-assistant.vault_kubernetes_auth_backend_role.this[0]
}

moved {
  from = vault_policy.home-assistant
  to   = module.home-assistant.vault_policy.this[0]
}

moved {
  from = vault_generic_secret.home-assistant-prometheus-token
  to   = module.home-assistant.vault_generic_secret.this["prometheus"]
}
