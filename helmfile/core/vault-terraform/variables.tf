variable "victoria_metrics_grafana_admin_username" {
  type = string
}

variable "victoria_metrics_grafana_admin_password" {
  type = string
}

variable "victoria_metrics_prometheus_ingress_username" {
  type = string
}

variable "victoria_metrics_prometheus_ingress_password" {
  type = string
}

variable "victoria_metrics_prometheus_ingress_password_bcrypt_hash" {
  type = string
}

variable "victoria_metrics_alertmanager_ingress_username" {
  type = string
}

variable "victoria_metrics_alertmanager_ingress_password" {
  type = string
}

variable "victoria_metrics_alertmanager_ingress_password_bcrypt_hash" {
  type = string
}

variable "victoria_metrics_alertmanager_pagerduty_token" {
  type = string
}

variable "victoria_metrics_alertmanager_deadmanssnitch_url" {
  type = string
}

variable "minio_longhorn_backup_username" {
  type = string
}

variable "minio_longhorn_backup_password" {
  type = string
}

variable "minio_longhorn_backup_endpoint" {
  type    = string
  default = "minio.longhorn.svc.cluster.local:443"
}

variable "users" {
  type = map(object({
    email    = string
    password = string
    groups   = list(string)
  }))
}

variable "domain" {
  type = string
}

variable "oauth2_proxy_cookie_secret" {
  type = string
}

variable "cert_manager_aws_access_key_id" {
  type = string
}

variable "cert_manager_aws_secret_access_key" {
  type = string
}

variable "argocd_credentials_homelab_private_key" {
  type = string
}
