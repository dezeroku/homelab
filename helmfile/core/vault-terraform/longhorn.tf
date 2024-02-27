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
path "kvv2/data/longhorn/longhorn-credentials-s3" {
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

resource "vault_generic_secret" "longhorn-credentials-s3" {
  # TODO: this is basically the same secret as in minio-longhorn, but with different formatting
  # do this properly when https://github.com/hashicorp/vault-secrets-operator/issues/135 is done
  path = "kvv2/longhorn/longhorn-credentials-s3"

  data_json = jsonencode(
    {
      "AWS_ACCESS_KEY_ID" : var.minio_longhorn_longhorn_username,
      "AWS_SECRET_ACCESS_KEY" : var.minio_longhorn_longhorn_password,
      "AWS_ENDPOINTS" : var.minio_longhorn_endpoint
    }
  )
}
