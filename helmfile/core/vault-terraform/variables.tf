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

variable "longhorn_ingress_username" {
  type = string
}

variable "longhorn_ingress_password" {
  type = string
}

variable "longhorn_ingress_password_bcrypt_hash" {
  type = string
}

variable "minio_longhorn_root_username" {
  type = string
}

variable "minio_longhorn_root_password" {
  type = string
}

variable "minio_longhorn_longhorn_username" {
  type = string
}

variable "minio_longhorn_longhorn_password" {
  type = string
}

variable "minio_longhorn_endpoint" {
  type    = string
  default = "minio.longhorn.svc.cluster.local:443"
}
