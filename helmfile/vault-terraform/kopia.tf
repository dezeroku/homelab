module "kopia" {
  source             = "./service"
  name               = "kopia"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  secrets = {
    "users/control" = {
      username = var.kopia_control_user_username
      password = var.kopia_control_user_password
    }
    "users/server" = {
      username = var.kopia_server_user_username
      password = var.kopia_server_user_password
    }
    "users/target" = {
      mapping_raw = var.kopia_target_users
      # Concatenate entries from map to the correct format
      # TODO: this could be done on VSO level too, but should also be ok to keep this here
      mapping = join(" ", [for item in var.kopia_target_users : "${item.username}:${item.password}"])
    }
    "repository" = {
      password = var.kopia_repository_password
    }
    "pushover" = {
      app_token = var.kopia_pushover_app_token
      user_key  = var.kopia_pushover_user_key
    }
  }
}

moved {
  from = vault_kubernetes_auth_backend_role.kopia
  to   = module.kopia.vault_kubernetes_auth_backend_role.this[0]
}

moved {
  from = vault_policy.kopia
  to   = module.kopia.vault_policy.this[0]
}

moved {
  from = vault_generic_secret.kopia-control
  to   = module.kopia.vault_generic_secret.this["users/control"]
}

moved {
  from = vault_generic_secret.kopia-server
  to   = module.kopia.vault_generic_secret.this["users/server"]
}

moved {
  from = vault_generic_secret.kopia-target
  to   = module.kopia.vault_generic_secret.this["users/target"]
}

moved {
  from = vault_generic_secret.kopia-repository
  to   = module.kopia.vault_generic_secret.this["repository"]
}

moved {
  from = vault_generic_secret.kopia-pushover
  to   = module.kopia.vault_generic_secret.this["pushover"]
}
