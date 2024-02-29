resource "vault_kubernetes_auth_backend_role" "victoria-metrics-stack-prometheus" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "victoria-metrics-stack-prometheus"
  bound_service_account_namespaces = ["victoria-metrics-stack"]
  token_ttl                        = 3600
  bound_service_account_names      = ["vmsingle-vm-victoria-metrics-k8s-stack"]
  token_policies                   = ["victoria-metrics-stack-prometheus"]
}

resource "vault_policy" "victoria-metrics-stack-prometheus" {
  name = "victoria-metrics-stack-prometheus"

  policy = <<EOT
path "kvv2/data/victoria-metrics-stack/prometheus-ingress-basic-auth" {
  capabilities = ["read"]
}
EOT
}

resource "vault_generic_secret" "victoria-metrics-stack-prometheus-ingress-basic-auth" {
  path = "kvv2/victoria-metrics-stack/prometheus-ingress-basic-auth"

  data_json = jsonencode(
    {
      # Field compatible with the ingress-nginx
      # Sadly vault secrets injector doesn't seem to support secrets templating yet
      # This is undeterministic with resources, let's force the user to pass the bcrypted entry
      #"auth" : "${var.victoria_metrics_prometheus_ingress_username}:${bcrypt(var.victoria_metrics_prometheus_ingress_password)}",
      "auth" : "${var.victoria_metrics_prometheus_ingress_username}:${var.victoria_metrics_prometheus_ingress_password_bcrypt_hash}",
      "username" : var.victoria_metrics_prometheus_ingress_username,
      "password" : var.victoria_metrics_prometheus_ingress_password
    }
  )
}
