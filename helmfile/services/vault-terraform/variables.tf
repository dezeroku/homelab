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
