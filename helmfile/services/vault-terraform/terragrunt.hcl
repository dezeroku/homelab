dependency "core_vault" {
  config_path = "../../core/vault-terraform"
}

dependency "ses_user" {
  config_path = "../../core/aws-ses-user"
}

inputs = {
  vault_auth_backend_kubernetes_path = dependency.core_vault.outputs.vault_auth_backend_kubernetes_path
  ses_access_key_id                  = dependency.ses_user.outputs.access_key_id
  ses_access_key_secret              = dependency.ses_user.outputs.access_key_secret
}
