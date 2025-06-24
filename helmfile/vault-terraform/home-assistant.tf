resource "vault_kubernetes_auth_backend_role" "home-assistant" {
  backend                          = vault_auth_backend.kubernetes_homeserver.path
  role_name                        = "home-assistant"
  bound_service_account_namespaces = ["home-assistant"]
  token_ttl                        = 3600
  bound_service_account_names      = ["home-assistant-main"]
  token_policies                   = ["home-assistant"]
}

resource "vault_policy" "home-assistant" {
  name = "home-assistant"

  policy = <<EOT
path "kvv2/data/services/home-assistant/prometheus" {
  capabilities = ["read"]
}
EOT
}

resource "vault_generic_secret" "home-assistant-prometheus-token" {
  path = "kvv2/services/home-assistant/prometheus"

  data_json = jsonencode(
    {
      "token" : var.home_assistant_prometheus_token
    }
  )
}
