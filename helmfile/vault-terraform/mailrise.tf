resource "vault_kubernetes_auth_backend_role" "mailrise" {
  backend                          = vault_auth_backend.kubernetes_homeserver.path
  role_name                        = "mailrise"
  bound_service_account_namespaces = ["mailrise"]
  token_ttl                        = 3600
  bound_service_account_names      = ["mailrise"]
  token_policies                   = ["mailrise"]
}

resource "vault_policy" "mailrise" {
  name = "mailrise"

  policy = <<EOT
path "kvv2/data/services/mailrise/pushover/general" {
  capabilities = ["read"]
}
EOT
}

resource "vault_generic_secret" "mailrise-pushover-general" {
  path = "kvv2/services/mailrise/pushover/general"

  data_json = jsonencode(
    {
      "user_key" : var.mailrise_pushover_general_user_key,
      "api_key" : var.mailrise_pushover_general_api_key
    }
  )
}
