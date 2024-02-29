resource "vault_kubernetes_auth_backend_role" "victoria-metrics-stack-grafana" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "victoria-metrics-stack-grafana"
  bound_service_account_namespaces = ["victoria-metrics-stack"]
  token_ttl                        = 3600
  bound_service_account_names      = ["vm-grafana"]
  token_policies                   = ["victoria-metrics-stack-grafana"]
}

resource "vault_policy" "victoria-metrics-stack-grafana" {
  name = "victoria-metrics-stack-grafana"

  policy = <<EOT
path "kvv2/data/victoria-metrics-stack/grafana-admin-credentials" {
  capabilities = ["read"]
}
EOT
}

resource "vault_generic_secret" "victoria-metrics-stack-grafana-admin-credentials" {
  path = "kvv2/victoria-metrics-stack/grafana-admin-credentials"

  data_json = jsonencode(
    {
      "admin-username" : var.victoria_metrics_grafana_admin_username,
      "admin-password" : var.victoria_metrics_grafana_admin_password,
    }
  )
}
