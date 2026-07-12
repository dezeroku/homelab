module "victoria-metrics-stack-alertmanager" {
  source             = "./service"
  name               = "victoria-metrics-stack-alertmanager"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  namespace             = "victoria-metrics-stack"
  service_account_names = ["vmalertmanager-vm-victoria-metrics-k8s-stack"]
  secrets_prefix        = "victoria-metrics-stack"

  secrets = {
    "alertmanager-pagerduty-token" = {
      token = var.victoria_metrics_alertmanager_pagerduty_token
    }
    "alertmanager-pagerduty-token-backup" = {
      token = var.homeserver_backup_victoria_metrics_alertmanager_pagerduty_token
    }
    "alertmanager-deadmanssnitch-url" = {
      url = var.victoria_metrics_alertmanager_deadmanssnitch_url
    }
  }
}

moved {
  from = vault_kubernetes_auth_backend_role.victoria-metrics-stack-alertmanager
  to   = module.victoria-metrics-stack-alertmanager.vault_kubernetes_auth_backend_role.this[0]
}

moved {
  from = vault_policy.victoria-metrics-stack-alertmanager
  to   = module.victoria-metrics-stack-alertmanager.vault_policy.this[0]
}

moved {
  from = vault_generic_secret.victoria-metrics-stack-alertmanager-pagerduty-token
  to   = module.victoria-metrics-stack-alertmanager.vault_generic_secret.this["alertmanager-pagerduty-token"]
}

moved {
  from = vault_generic_secret.victoria-metrics-stack-alertmanager-pagerduty-token-backup
  to   = module.victoria-metrics-stack-alertmanager.vault_generic_secret.this["alertmanager-pagerduty-token-backup"]
}

moved {
  from = vault_generic_secret.victoria-metrics-stack-alertmanager-deadmanssnitch-url
  to   = module.victoria-metrics-stack-alertmanager.vault_generic_secret.this["alertmanager-deadmanssnitch-url"]
}
