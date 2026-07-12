# victoria-metrics grafana role on the backup cluster.
# Kept hand-written alongside victoria-metrics-stack-grafana.tf (two OIDC clients don't fit the ./service module).
resource "vault_kubernetes_auth_backend_role" "victoria-metrics-stack-grafana_backup" {
  backend                          = vault_auth_backend.kubernetes_homeserver_backup.path
  role_name                        = "victoria-metrics-stack-grafana"
  bound_service_account_namespaces = ["victoria-metrics-stack"]
  token_ttl                        = 3600
  bound_service_account_names      = ["vm-grafana"]
  token_policies                   = ["victoria-metrics-stack-grafana"]
}
