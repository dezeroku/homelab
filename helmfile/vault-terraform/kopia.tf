resource "vault_kubernetes_auth_backend_role" "kopia" {
  backend                          = vault_auth_backend.kubernetes_homeserver.path
  role_name                        = "kopia"
  bound_service_account_namespaces = ["kopia"]
  token_ttl                        = 3600
  bound_service_account_names      = ["kopia"]
  token_policies                   = ["kopia"]
}

resource "vault_policy" "kopia" {
  name = "kopia"

  policy = <<EOT
path "kvv2/data/services/kopia/users/control" {
  capabilities = ["read"]
}
path "kvv2/data/services/kopia/users/server" {
  capabilities = ["read"]
}
path "kvv2/data/services/kopia/users/target" {
  capabilities = ["read"]
}
path "kvv2/data/services/kopia/repository" {
  capabilities = ["read"]
}
EOT
}

resource "vault_generic_secret" "kopia-control" {
  path = "kvv2/services/kopia/users/control"

  data_json = jsonencode(
    {
      "username" : var.kopia_control_user_username,
      "password" : var.kopia_control_user_password,
    }
  )
}

resource "vault_generic_secret" "kopia-server" {
  path = "kvv2/services/kopia/users/server"

  data_json = jsonencode(
    {
      "username" : var.kopia_server_user_username,
      "password" : var.kopia_server_user_password,
    }
  )
}

resource "vault_generic_secret" "kopia-target" {
  path = "kvv2/services/kopia/users/target"

  data_json = jsonencode(
    {
      "mapping_raw" : var.kopia_target_users,
      # Concatenate entries from map to the correct format
      # TODO: this could be done on VSO level too, but should also be ok to keep this here
      "mapping" : join(" ", [for item in var.kopia_target_users : "${item.username}:${item.password}"])
    }
  )
}

resource "vault_generic_secret" "kopia-repository" {
  path = "kvv2/services/kopia/repository"

  data_json = jsonencode(
    {
      "password" : var.kopia_repository_password
    }
  )
}
