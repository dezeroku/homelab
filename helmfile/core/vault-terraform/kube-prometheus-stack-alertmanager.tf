resource "vault_kubernetes_auth_backend_role" "kube-prometheus-stack-alertmanager" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "kube-prometheus-stack-alertmanager"
  bound_service_account_namespaces = ["kube-prometheus-stack"]
  token_ttl                        = 3600
  bound_service_account_names      = ["kube-prometheus-stack-alertmanager"]
  token_policies                   = ["kube-prometheus-stack-alertmanager"]
}

resource "vault_policy" "kube-prometheus-stack-alertmanager" {
  name = "kube-prometheus-stack-alertmanager"

  policy = <<EOT
path "kvv2/data/kube-prometheus-stack/alertmanager-ingress-basic-auth" {
  capabilities = ["read"]
}
path "kvv2/data/kube-prometheus-stack/alertmanager-pagerduty-token" {
  capabilities = ["read"]
}
path "kvv2/data/kube-prometheus-stack/alertmanager-deadmanssnitch-url" {
  capabilities = ["read"]
}
EOT
}

resource "vault_generic_secret" "kube-prometheus-stack-alertmanager-pagerduty-token" {
  path = "kvv2/kube-prometheus-stack/alertmanager-pagerduty-token"

  data_json = jsonencode(
    {
      "token" : var.kube_prometheus_stack_alertmanager_pagerduty_token
    }
  )
}

resource "vault_generic_secret" "kube-prometheus-stack-alertmanager-deadmanssnitch-url" {
  path = "kvv2/kube-prometheus-stack/alertmanager-deadmanssnitch-url"

  data_json = jsonencode(
    {
      "url" : var.kube_prometheus_stack_alertmanager_deadmanssnitch_url
    }
  )
}

resource "vault_generic_secret" "kube-prometheus-stack-alertmanager-ingress-basic-auth" {
  path = "kvv2/kube-prometheus-stack/alertmanager-ingress-basic-auth"

  data_json = jsonencode(
    {
      # Field compatible with the ingress-nginx
      # Sadly vault secrets injector doesn't seem to support secrets templating yet
      # This is undeterministic with resources, let's force the user to pass the bcrypted entry
      #"auth" : "${var.kube_prometheus_stack_alertmanager_ingress_username}:${bcrypt(var.kube_prometheus_stack_alertmanager_ingress_password)}",
      "auth" : "${var.kube_prometheus_stack_alertmanager_ingress_username}:${var.kube_prometheus_stack_alertmanager_ingress_password_bcrypt_hash}",
      "username" : var.kube_prometheus_stack_alertmanager_ingress_username,
      "password" : var.kube_prometheus_stack_alertmanager_ingress_password
    }
  )
}
