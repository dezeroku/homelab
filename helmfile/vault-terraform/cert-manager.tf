resource "vault_kubernetes_auth_backend_role" "cert-manager-backup" {
  backend                          = vault_auth_backend.kubernetes_homeserver_backup.path
  role_name                        = "cert-manager"
  bound_service_account_namespaces = ["cert-manager"]
  token_ttl                        = 3600
  bound_service_account_names      = ["cert-manager"]
  token_policies                   = ["cert-manager"]
}

resource "vault_kubernetes_auth_backend_role" "cert-manager" {
  backend                          = vault_auth_backend.kubernetes_homeserver.path
  role_name                        = "cert-manager"
  bound_service_account_namespaces = ["cert-manager"]
  token_ttl                        = 3600
  bound_service_account_names      = ["cert-manager"]
  token_policies                   = ["cert-manager"]
}

resource "vault_policy" "cert-manager" {
  name = "cert-manager"

  policy = <<EOT
path "kvv2/data/cert-manager/letsencrypt-dns-prod-credentials-secret" {
  capabilities = ["read"]
}
EOT
}

resource "vault_generic_secret" "cert-manager-letsencrypt-dns-prod-credentials-secret" {
  path = "kvv2/cert-manager/letsencrypt-dns-prod-credentials-secret"

  data_json = jsonencode(
    {
      "AWS_ACCESS_KEY_ID" : var.cert_manager_aws_access_key_id,
      "AWS_SECRET_ACCESS_KEY" : var.cert_manager_aws_secret_access_key,
    }
  )
}
