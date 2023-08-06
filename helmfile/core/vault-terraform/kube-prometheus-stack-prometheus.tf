resource "vault_kubernetes_auth_backend_role" "kube-prometheus-stack-prometheus" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "kube-prometheus-stack-prometheus"
  bound_service_account_namespaces = ["kube-prometheus-stack"]
  token_ttl                        = 3600
  bound_service_account_names      = ["kube-prometheus-stack-prometheus"]
  token_policies                   = ["kube-prometheus-stack-prometheus"]
}

resource "vault_policy" "kube-prometheus-stack-prometheus" {
  name = "kube-prometheus-stack-prometheus"

  policy = <<EOT
path "kvv2/data/kube-prometheus-stack/prometheus-ingress-basic-auth" {
  capabilities = ["read"]
}
EOT
}

resource "vault_generic_secret" "kube-prometheus-stack-prometheus-ingress-basic-auth" {
  path = "kvv2/kube-prometheus-stack/prometheus-ingress-basic-auth"

  data_json = jsonencode(
    {
      # Field compatible with the ingress-nginx
      # Sadly vault secrets injector doesn't seem to support secrets templating yet
      "auth" : "${var.kube_prometheus_stack_prometheus_ingress_username}:${bcrypt(var.kube_prometheus_stack_prometheus_ingress_password)}",
      "username" : var.kube_prometheus_stack_prometheus_ingress_username,
      "password" : var.kube_prometheus_stack_prometheus_ingress_password
    }
  )
}
