resource "vault_kubernetes_auth_backend_role" "longhorn" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "longhorn"
  bound_service_account_namespaces = ["longhorn"]
  token_ttl                        = 3600
  bound_service_account_names      = ["longhorn-service-account"]
  token_policies                   = ["longhorn"]
}

resource "vault_policy" "longhorn" {
  name = "longhorn"

  policy = <<EOT
path "kvv2/data/longhorn/ingress-basic-auth" {
  capabilities = ["read"]
}
EOT
}

resource "vault_generic_secret" "longhorn-ingress-basic-auth" {
  path = "kvv2/longhorn/ingress-basic-auth"

  data_json = jsonencode(
    {
      # Field compatible with the ingress-nginx
      # Sadly vault secrets injector doesn't seem to support secrets templating yet
      # This is undeterministic with resources, let's force the user to pass the bcrypted entry
      "auth" : "${var.longhorn_ingress_username}:${var.longhorn_ingress_password_bcrypt_hash}",
      "username" : var.longhorn_ingress_username,
      "password" : var.longhorn_ingress_password
    }
  )
}
