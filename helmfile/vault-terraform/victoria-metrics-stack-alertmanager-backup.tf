# victoria-metrics alertmanager on the backup cluster. Role only; policy/secrets live in the main file.
module "victoria-metrics-stack-alertmanager-backup" {
  source             = "./service"
  name               = "victoria-metrics-stack-alertmanager"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver_backup.path

  namespace             = "victoria-metrics-stack"
  service_account_names = ["vmalertmanager-vm-victoria-metrics-k8s-stack"]
  create_policy         = false
}

moved {
  from = vault_kubernetes_auth_backend_role.victoria-metrics-stack-alertmanager_backup
  to   = module.victoria-metrics-stack-alertmanager-backup.vault_kubernetes_auth_backend_role.this[0]
}
