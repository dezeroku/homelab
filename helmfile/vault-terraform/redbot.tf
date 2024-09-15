resource "vault_kubernetes_auth_backend_role" "redbot" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "redbot"
  bound_service_account_namespaces = ["redbot"]
  token_ttl                        = 3600
  bound_service_account_names      = ["redbot"]
  token_policies                   = ["redbot"]
}

resource "vault_policy" "redbot" {
  name = "redbot"

  policy = <<EOT
path "kvv2/data/services/redbot/secrets" {
  capabilities = ["read"]
}
EOT
}

resource "vault_generic_secret" "redbot-secrets" {
  path = "kvv2/services/redbot/secrets"

  data_json = jsonencode(
    {
      "token" : var.redbot_token
    }
  )
}
