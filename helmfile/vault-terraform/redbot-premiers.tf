resource "vault_kubernetes_auth_backend_role" "redbot-premiers" {
  backend                          = vault_auth_backend.kubernetes_homeserver.path
  role_name                        = "redbot-premiers"
  bound_service_account_namespaces = ["redbot-premiers"]
  token_ttl                        = 3600
  bound_service_account_names      = ["redbot-premiers-main"]
  token_policies                   = ["redbot-premiers"]
}

resource "vault_policy" "redbot-premiers" {
  name = "redbot-premiers"

  policy = <<EOT
path "kvv2/data/services/redbot/premiers/secrets" {
  capabilities = ["read"]
}
EOT
}

resource "vault_generic_secret" "redbot-premiers-secrets" {
  path = "kvv2/services/redbot/premiers/secrets"

  data_json = jsonencode(
    {
      "token" : var.redbot_premiers_token
    }
  )
}
