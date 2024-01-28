resource "vault_kubernetes_auth_backend_role" "netbootxyz" {
  backend                          = var.vault_auth_backend_kubernetes_path
  role_name                        = "netbootxyz"
  bound_service_account_namespaces = ["netbootxyz"]
  token_ttl                        = 3600
  bound_service_account_names      = ["netbootxyz"]
  token_policies                   = ["netbootxyz"]
}

resource "vault_policy" "netbootxyz" {
  name = "netbootxyz"

  policy = <<EOT
path "kvv2/data/netbootxyz/ingress-basic-auth" {
  capabilities = ["read"]
}
EOT
}

resource "vault_generic_secret" "netbootxyz-ingress-basic-auth" {
  path = "kvv2/netbootxyz/ingress-basic-auth"

  data_json = jsonencode(
    {
      # Field compatible with the ingress-nginx
      # Sadly vault secrets injector doesn't seem to support secrets templating yet
      "auth" : "${var.netbootxyz_ingress_username}:${var.netbootxyz_ingress_password_bcrypt_hash}",
      "username" : var.netbootxyz_ingress_username,
      "password" : var.netbootxyz_ingress_password
    }
  )
}
