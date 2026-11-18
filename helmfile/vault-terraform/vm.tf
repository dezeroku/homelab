module "vm" {
  source             = "${local.lib_path}/terraform/service"
  name               = "vm"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  secrets = {
    "alertmanager-pagerduty-token" = {
      token = var.victoria_metrics_alertmanager_pagerduty_token
    }
    # "alertmanager-pagerduty-token-backup" = {
    #   token = var.homeserver_backup_victoria_metrics_alertmanager_pagerduty_token
    # }
    "alertmanager-deadmanssnitch-url" = {
      url = var.victoria_metrics_alertmanager_deadmanssnitch_url
    }
  }

  oidc = {
    redirect_uris = [
      "https://alertmanager.${var.domain}/oauth2/callback",
      "https://prometheus.${var.domain}/oauth2/callback",
      "https://vmagent.${var.domain}/oauth2/callback",
    ]
    group_ids = [vault_identity_group.this["vm"].id]
  }
}

module "vm-grafana" {
  # Separate client for grafana, to allow users to access just the charts
  source             = "${local.lib_path}/terraform/service"
  name               = "vm-grafana"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  namespace = "vm"

  oidc = {
    redirect_uris = [
      "https://grafana.${var.domain}/login/generic_oauth",
    ]
    group_ids = [vault_identity_group.this["vm-grafana"].id]
  }
}
