resource "vault_kubernetes_auth_backend_role" "kube-prometheus-stack-grafana" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "kube-prometheus-stack-grafana"
  bound_service_account_namespaces = ["kube-prometheus-stack"]
  token_ttl                        = 3600
  bound_service_account_names      = ["kube-prometheus-stack-grafana"]
  token_policies                   = ["kube-prometheus-stack-grafana"]
}

resource "vault_policy" "kube-prometheus-stack-grafana" {
  name = "kube-prometheus-stack-grafana"

  policy = <<EOT
path "kvv2/data/kube-prometheus-stack/grafana-admin-credentials" {
  capabilities = ["read"]
}
EOT
}

resource "vault_generic_secret" "kube-prometheus-stack-grafana-admin-credentials" {
  path = "kvv2/kube-prometheus-stack/grafana-admin-credentials"

  data_json = jsonencode(
    {
      "admin-username" : var.kube_prometheus_stack_grafana_admin_username,
      "admin-password" : var.kube_prometheus_stack_grafana_admin_password,
    }
  )
}
