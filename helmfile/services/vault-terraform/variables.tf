# This comes from the `core` deployment via terragrunt
variable "vault_auth_backend_kubernetes_path" {
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

variable "netbootxyz_ingress_username" {
  type = string
}

variable "netbootxyz_ingress_password" {
  type = string
}

variable "netbootxyz_ingress_password_bcrypt_hash" {
  type = string
}
