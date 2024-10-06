resource "vault_kubernetes_auth_backend_role" "invidious" {
  backend                          = vault_auth_backend.kubernetes_homeserver.path
  role_name                        = "invidious"
  bound_service_account_namespaces = ["invidious"]
  token_ttl                        = 3600
  bound_service_account_names      = ["invidious"]
  token_policies                   = ["invidious"]
}

resource "vault_policy" "invidious" {
  name = "invidious"

  policy = <<EOT
path "kvv2/data/services/invidious/hmac" {
  capabilities = ["read"]
}
EOT
}

resource "vault_generic_secret" "invidious-hmac" {
  path = "kvv2/services/invidious/hmac"

  data_json = jsonencode(
    {
      "key" : var.invidious_hmac_key,
    }
  )
}
