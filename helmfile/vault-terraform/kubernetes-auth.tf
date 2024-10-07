resource "vault_auth_backend" "kubernetes_homeserver" {
  type = "kubernetes"
  path = "k8s/homeserver"
}

resource "vault_kubernetes_auth_backend_config" "kubernetes_homeserver" {
  backend         = vault_auth_backend.kubernetes_homeserver.path
  kubernetes_host = "https://kubernetes.default.svc.cluster.local:443"
}

resource "vault_auth_backend" "kubernetes_homeserver_backup" {
  type = "kubernetes"
  path = "k8s/homeserver-backup"
}

resource "vault_kubernetes_auth_backend_config" "kubernetes_homeserver_backup" {
  backend            = vault_auth_backend.kubernetes_homeserver_backup.path
  kubernetes_host    = var.backup_cluster_kubernetes_host
  kubernetes_ca_cert = var.backup_cluster_kubernetes_ca_cert
  token_reviewer_jwt = var.backup_cluster_token_reviewer_jwt
}
