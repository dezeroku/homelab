resource "vault_kubernetes_auth_backend_role" "redbot-main" {
  backend                          = vault_auth_backend.kubernetes_homeserver.path
  role_name                        = "redbot-main"
  bound_service_account_namespaces = ["redbot-main"]
  token_ttl                        = 3600
  bound_service_account_names      = ["redbot-main"]
  token_policies                   = ["redbot-main"]
}

resource "vault_policy" "redbot-main" {
  name = "redbot-main"

  policy = <<EOT
path "kvv2/data/services/redbot/main/secrets" {
  capabilities = ["read"]
}
EOT
}

resource "vault_generic_secret" "redbot-main-secrets" {
  path = "kvv2/services/redbot/main/secrets"

  data_json = jsonencode(
    {
      "token" : var.redbot_main_token
    }
  )
}
