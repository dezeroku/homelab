variable "name" {
  description = "Service name. Used for the k8s auth role, the policy, the OIDC client, and the default namespace / service account names."
  type        = string
}

variable "kubernetes_backend" {
  description = "Path of the vault_auth_backend (kubernetes type) this role binds to. Each call targets exactly one cluster; a service present on the backup cluster gets a separate <service>-backup.tf call. Ignored when create_k8s_role = false."
  type        = string
  default     = null
}

variable "create_k8s_role" {
  description = "Whether to create a kubernetes auth backend role for this service on var.kubernetes_backend."
  type        = bool
  default     = true
}

variable "create_policy" {
  description = "Whether to create the Vault policy. A backup-cluster (-backup.tf) call sets this false: it only registers a role against the policy the main file already creates."
  type        = bool
  default     = true
}

variable "namespace" {
  description = "Bound service account namespace. Defaults to var.name."
  type        = string
  default     = null
}

variable "service_account_names" {
  description = "Bound service account names. Defaults to [\"<name>-main\"]."
  type        = list(string)
  default     = null
}

variable "token_ttl" {
  description = "TTL for tokens issued to the k8s role."
  type        = number
  default     = 3600
}

variable "secrets" {
  description = <<-EOT
    Map of subpath => object. Each entry is stored (jsonencode'd) at kvv2/<secrets_prefix>/<subpath>
    and, unless derive_policy_from_secrets = false, granted read in the policy at
    kvv2/data/<secrets_prefix>/<subpath>. Values may have differing shapes, hence `any`.
  EOT
  type        = any
  default     = {}
}

variable "secrets_prefix" {
  description = "Path prefix (under the kvv2 mount) for this service's secrets. Defaults to services/<name>."
  type        = string
  default     = null
}

variable "derive_policy_from_secrets" {
  description = "Auto-grant read on each stored secret's kvv2/data path. Set false when you want a custom (e.g. wildcard) policy via extra_policy_read_paths."
  type        = bool
  default     = true
}

variable "include_backuper_credentials" {
  description = "Grant read on the shared minio k8s-backups backuper credentials."
  type        = bool
  default     = false
}

variable "extra_policy_read_paths" {
  description = "Additional Vault paths to grant read on, beyond those derived from secrets / oidc / backuper."
  type        = list(string)
  default     = []
}

variable "grant_oidc_client_read" {
  description = "When oidc is set, also grant read on identity/oidc/client/<client_name>. A few apps don't read their own client and set this false."
  type        = bool
  default     = true
}

variable "oidc" {
  description = "OIDC client config for this service. Leave null to skip creating an OIDC client."
  type = object({
    redirect_uris    = list(string)
    group_ids        = list(string)
    id_token_ttl     = optional(number, 2400)
    access_token_ttl = optional(number, 7200)
    client_name      = optional(string) # defaults to var.name
    assignment_name  = optional(string) # defaults to client_name
  })
  default = null
}
