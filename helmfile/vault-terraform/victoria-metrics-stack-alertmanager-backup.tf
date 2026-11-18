# victoria-metrics alertmanager on the backup cluster. Role only; policy/secrets live in the main file.
module "victoria-metrics-stack-alertmanager-backup" {
  source             = "${local.lib_path}/terraform/service"
  name               = "victoria-metrics-stack-alertmanager"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver_backup.path

  namespace             = "victoria-metrics-stack"
  service_account_names = ["vmalertmanager-vm-victoria-metrics-k8s-stack"]
  create_policy         = false
}
