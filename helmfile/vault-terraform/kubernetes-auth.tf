resource "vault_auth_backend" "kubernetes_homeserver" {
  type = "kubernetes"
  path = "k8s/homeserver"
}

resource "vault_kubernetes_auth_backend_config" "kubernetes_homeserver" {
  backend         = vault_auth_backend.kubernetes_homeserver.path
  kubernetes_host = "https://kubernetes.default.svc.cluster.local:443"
}
