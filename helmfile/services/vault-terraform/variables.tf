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
