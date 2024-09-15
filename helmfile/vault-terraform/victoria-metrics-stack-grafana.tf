resource "vault_identity_oidc_assignment" "grafana" {
  name = "grafana"
  group_ids = [
    vault_identity_group.monitoring_admins.id,
    vault_identity_group.monitoring_editors.id,
    vault_identity_group.monitoring_viewers.id,
  ]
}

resource "vault_identity_oidc_client" "grafana" {
  name = "grafana"
  redirect_uris = [
    "https://grafana.${var.domain}/login/generic_oauth"
  ]
  assignments      = [vault_identity_oidc_assignment.grafana.name]
  id_token_ttl     = 2400
  access_token_ttl = 7200
}

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
path "identity/oidc/client/grafana" {
  capabilities = ["read"]
}
EOT
}
