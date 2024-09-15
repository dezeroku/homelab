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

variable "minio_root_username" {
  type = string
}

variable "minio_root_password" {
  type = string
}

variable "minio_dezeroku_username" {
  type = string
}

variable "minio_dezeroku_password" {
  type = string
}

variable "minio_private_root_username" {
  type = string
}

variable "minio_private_root_password" {
  type = string
}

variable "minio_private_dezeroku_username" {
  type = string
}

variable "minio_private_dezeroku_password" {
  type = string
}

variable "tgtg_username" {
  type = string
}

variable "tgtg_ses_from" {
  type = string
}

variable "tgtg_ses_to" {
  type = string
}

variable "ses_access_key_id" {
  type = string
}

variable "ses_access_key_secret" {
  type = string
}

variable "home_assistant_prometheus_token" {
  type = string
}

variable "invidious_hmac_key" {
  type = string
}

#variable "redbot_owner" {
#  type = string
#}

variable "redbot_token" {
  type = string
}

variable "homepage_jellyfin_apikey" {
  # TODO: this value is currently generated by hand via Jellyfin UI
  # Automate the process
  type = string
}

variable "paperless_secret_key" {
  type = string
}

variable "paperless_admin_username" {
  type = string
}

variable "paperless_admin_password" {
  type = string
}

variable "paperless_admin_email" {
  type = string
}

variable "paperless_redis_password" {
  type = string
}

variable "ses_smtp_username" {
  type = string
}

variable "ses_smtp_password" {
  type = string
}

variable "ses_smtp_host" {
  type = string
}
