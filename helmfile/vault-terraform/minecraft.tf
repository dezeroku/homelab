resource "vault_kubernetes_auth_backend_role" "minecraft" {
  backend                          = vault_auth_backend.kubernetes_homeserver.path
  role_name                        = "minecraft"
  bound_service_account_namespaces = ["minecraft"]
  token_ttl                        = 3600
  bound_service_account_names      = ["minecraft"]
  token_policies                   = ["minecraft"]
}

resource "vault_policy" "minecraft" {
  name = "minecraft"

  policy = <<EOT
path "kvv2/data/services/minecraft/rcon" {
  capabilities = ["read"]
}
EOT
}

resource "vault_generic_secret" "minecraft-rcon" {
  path = "kvv2/services/minecraft/rcon"

  data_json = jsonencode(
    {
      "password" : var.minecraft_rcon_password,
    }
  )
}
