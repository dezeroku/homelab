dependency "core_vault" {
  config_path = "../../core/vault-terraform"
}

inputs = {
  vault_auth_backend_kubernetes_path = dependency.core_vault.outputs.vault_auth_backend_kubernetes_path
}
