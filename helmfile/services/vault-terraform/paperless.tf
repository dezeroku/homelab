resource "vault_kubernetes_auth_backend_role" "paperless" {
  backend                          = var.vault_auth_backend_kubernetes_path
  role_name                        = "paperless"
  bound_service_account_namespaces = ["paperless"]
  token_ttl                        = 3600
  bound_service_account_names      = ["paperless"]
  token_policies                   = ["paperless"]
}

resource "vault_policy" "paperless" {
  name = "paperless"

  policy = <<EOT
path "kvv2/data/services/paperless/secret-key" {
  capabilities = ["read"]
}
path "kvv2/data/services/paperless/admin" {
  capabilities = ["read"]
}
path "kvv2/data/services/paperless/redis" {
  capabilities = ["read"]
}
EOT
}

resource "vault_generic_secret" "paperless-secret-key" {
  path = "kvv2/services/paperless/secret-key"

  data_json = jsonencode(
    {
      "key" : var.paperless_secret_key,
    }
  )
}

resource "vault_generic_secret" "paperless-admin" {
  path = "kvv2/services/paperless/admin"

  data_json = jsonencode(
    {
      "username" : var.paperless_admin_username,
      "password" : var.paperless_admin_password,
      "email" : var.paperless_admin_email,
    }
  )
}

resource "vault_generic_secret" "paperless-redis" {
  path = "kvv2/services/paperless/redis"

  data_json = jsonencode(
    {
      "password" : var.paperless_redis_password,
    }
  )
}
