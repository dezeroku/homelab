resource "vault_kubernetes_auth_backend_role" "homepage" {
  backend                          = var.vault_auth_backend_kubernetes_path
  role_name                        = "homepage"
  bound_service_account_namespaces = ["homepage"]
  token_ttl                        = 3600
  bound_service_account_names      = ["homepage"]
  token_policies                   = ["homepage"]
}

resource "vault_policy" "homepage" {
  name = "homepage"

  policy = <<EOT
path "kvv2/data/services/homepage/*" {
  capabilities = ["read"]
}
EOT
}

resource "vault_generic_secret" "homepage-jellyfin" {
  path = "kvv2/services/homepage/jellyfin"

  data_json = jsonencode(
    {
      "apikey" : var.homepage_jellyfin_apikey,
    }
  )
}
