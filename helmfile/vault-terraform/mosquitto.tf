module "mosquitto" {
  source             = "./service"
  name               = "mosquitto"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  secrets = {
    credentials = {
      username     = var.mosquitto_username
      password     = var.mosquitto_password
      passwordfile = var.mosquitto_passwordfile
    }
  }
}

moved {
  from = vault_kubernetes_auth_backend_role.mosquitto
  to   = module.mosquitto.vault_kubernetes_auth_backend_role.this[0]
}

moved {
  from = vault_policy.mosquitto
  to   = module.mosquitto.vault_policy.this[0]
}

moved {
  from = vault_generic_secret.mosquitto-credentials
  to   = module.mosquitto.vault_generic_secret.this["credentials"]
}
