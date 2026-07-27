module "cert-manager" {
  source             = "../lib/terraform/service"
  name               = "cert-manager"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  service_account_names = ["cert-manager"]
  secrets_prefix        = "cert-manager"

  secrets = {
    "letsencrypt-dns-prod-credentials-secret" = {
      AWS_ACCESS_KEY_ID     = var.cert_manager_aws_access_key_id
      AWS_SECRET_ACCESS_KEY = var.cert_manager_aws_secret_access_key
    }
  }
}

moved {
  from = vault_kubernetes_auth_backend_role.cert-manager
  to   = module.cert-manager.vault_kubernetes_auth_backend_role.this[0]
}

moved {
  from = vault_policy.cert-manager
  to   = module.cert-manager.vault_policy.this[0]
}

moved {
  from = vault_generic_secret.cert-manager-letsencrypt-dns-prod-credentials-secret
  to   = module.cert-manager.vault_generic_secret.this["letsencrypt-dns-prod-credentials-secret"]
}
