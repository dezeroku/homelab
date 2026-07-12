# cert-manager on the backup cluster. Role only; the policy/secret live in cert-manager.tf.
module "cert-manager-backup" {
  source             = "./service"
  name               = "cert-manager"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver_backup.path

  service_account_names = ["cert-manager"]
  create_policy         = false
}

moved {
  from = vault_kubernetes_auth_backend_role.cert-manager-backup
  to   = module.cert-manager-backup.vault_kubernetes_auth_backend_role.this[0]
}
