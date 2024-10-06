resource "vault_kubernetes_auth_backend_role" "victoria-metrics-stack-alertmanager" {
  backend                          = vault_auth_backend.kubernetes_homeserver.path
  role_name                        = "victoria-metrics-stack-alertmanager"
  bound_service_account_namespaces = ["victoria-metrics-stack"]
  token_ttl                        = 3600
  bound_service_account_names      = ["vmalertmanager-vm-victoria-metrics-k8s-stack"]
  token_policies                   = ["victoria-metrics-stack-alertmanager"]
}

resource "vault_policy" "victoria-metrics-stack-alertmanager" {
  name = "victoria-metrics-stack-alertmanager"

  policy = <<EOT
path "kvv2/data/victoria-metrics-stack/alertmanager-pagerduty-token" {
  capabilities = ["read"]
}
path "kvv2/data/victoria-metrics-stack/alertmanager-deadmanssnitch-url" {
  capabilities = ["read"]
}
EOT
}

resource "vault_generic_secret" "victoria-metrics-stack-alertmanager-pagerduty-token" {
  path = "kvv2/victoria-metrics-stack/alertmanager-pagerduty-token"

  data_json = jsonencode(
    {
      "token" : var.victoria_metrics_alertmanager_pagerduty_token
    }
  )
}

resource "vault_generic_secret" "victoria-metrics-stack-alertmanager-deadmanssnitch-url" {
  path = "kvv2/victoria-metrics-stack/alertmanager-deadmanssnitch-url"

  data_json = jsonencode(
    {
      "url" : var.victoria_metrics_alertmanager_deadmanssnitch_url
    }
  )
}
