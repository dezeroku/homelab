resource "vault_identity_oidc_assignment" "oauth2-proxy" {
  name      = "oauth2-proxy"
  group_ids = [vault_identity_group.users.id]
}

resource "vault_identity_oidc_client" "oauth2-proxy" {
  name = "oauth2-proxy"
  redirect_uris = [
    "https://sso.${var.domain}/oauth2/callback",
  ]
  assignments      = [vault_identity_oidc_assignment.oauth2-proxy.name]
  id_token_ttl     = 2400
  access_token_ttl = 7200
}

resource "vault_kubernetes_auth_backend_role" "oauth2-proxy" {
  backend                          = vault_auth_backend.kubernetes_homeserver.path
  role_name                        = "oauth2-proxy"
  bound_service_account_namespaces = ["oauth2-proxy"]
  token_ttl                        = 3600
  bound_service_account_names      = ["oauth2-proxy"]
  token_policies                   = ["oauth2-proxy"]
}

resource "vault_policy" "oauth2-proxy" {
  name = "oauth2-proxy"

  policy = <<EOT
path "identity/oidc/client/oauth2-proxy" {
  capabilities = ["read"]
}
path "kvv2/data/core/oauth2-proxy/cookie-secret" {
  capabilities = ["read"]
}
EOT
}

resource "vault_generic_secret" "oauth2-proxy-cookie-secret" {
  path = "kvv2/core/oauth2-proxy/cookie-secret"

  data_json = jsonencode(
    {
      "cookie-secret" : var.oauth2_proxy_cookie_secret
    }
  )
}
