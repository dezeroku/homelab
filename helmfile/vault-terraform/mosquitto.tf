module "mosquitto" {
  source             = "./service"
  name               = "mosquitto"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  secrets = {
    # The broker reads only `passwordfile` (all users' hashes). The per-user
    # plaintext fields are stored alongside purely so the synced k8s secret
    # documents which username maps to which password.
    credentials = merge(
      {
        passwordfile = join("\n", [for u in var.mosquitto_users : u.passwordfile_line])
      },
      { for name, u in var.mosquitto_users : "${name}_username" => name },
      { for name, u in var.mosquitto_users : "${name}_password" => u.password },
    )
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
