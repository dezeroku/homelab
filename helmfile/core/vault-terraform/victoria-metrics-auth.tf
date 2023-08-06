resource "vault_kubernetes_auth_backend_role" "victoria-metrics-auth" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "victoria-metrics-auth"
  bound_service_account_namespaces = ["victoriametrics"]
  token_ttl                        = 3600
  bound_service_account_names      = ["victoriametrics-auth-victoria-metrics-auth"]
  token_policies                   = ["victoria-metrics-auth"]
}

resource "vault_policy" "victoria-metrics-auth" {
  name = "victoria-metrics-auth"

  policy = <<EOT
path "kvv2/data/victoria-metrics/auth-config" {
  capabilities = ["read"]
}
EOT
}

resource "vault_generic_secret" "victoria-metrics-auth-config" {
  path = "kvv2/victoria-metrics/auth-config"

  data_json = jsonencode(
    {
      "homekit_token" = "homekit",
      "test_username" = "test",
      "test_password" = "test"
    }
  )
}
