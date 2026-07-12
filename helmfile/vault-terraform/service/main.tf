locals {
  namespace             = coalesce(var.namespace, var.name)
  service_account_names = coalesce(var.service_account_names, ["${var.name}-main"])
  secrets_prefix        = coalesce(var.secrets_prefix, "services/${var.name}")

  oidc_client_name     = var.oidc == null ? null : coalesce(var.oidc.client_name, var.name)
  oidc_assignment_name = var.oidc == null ? null : coalesce(var.oidc.assignment_name, local.oidc_client_name)

  # Read paths derived from the secrets this service stores (note: policy reads use the kvv2 *data* path).
  secret_read_paths   = var.derive_policy_from_secrets ? [for subpath, _ in var.secrets : "kvv2/data/${local.secrets_prefix}/${subpath}"] : []
  oidc_read_paths     = (var.oidc == null || !var.grant_oidc_client_read) ? [] : ["identity/oidc/client/${local.oidc_client_name}"]
  backuper_read_paths = var.include_backuper_credentials ? ["kvv2/data/core/minio/k8s-backups/backuper-credentials"] : []

  policy_read_paths = toset(concat(
    local.secret_read_paths,
    local.oidc_read_paths,
    local.backuper_read_paths,
    var.extra_policy_read_paths,
  ))
}

resource "vault_kubernetes_auth_backend_role" "this" {
  count = var.create_k8s_role ? 1 : 0

  backend                          = var.kubernetes_backend
  role_name                        = var.name
  bound_service_account_namespaces = [local.namespace]
  token_ttl                        = var.token_ttl
  bound_service_account_names      = local.service_account_names
  token_policies                   = [var.name]
}

resource "vault_policy" "this" {
  count = var.create_policy ? 1 : 0

  name   = var.name
  policy = join("\n", [for p in local.policy_read_paths : "path \"${p}\" {\n  capabilities = [\"read\"]\n}\n"])
}

resource "vault_generic_secret" "this" {
  for_each = var.secrets

  path      = "kvv2/${local.secrets_prefix}/${each.key}"
  data_json = jsonencode(each.value)
}

resource "vault_identity_oidc_assignment" "this" {
  count = var.oidc == null ? 0 : 1

  name      = local.oidc_assignment_name
  group_ids = var.oidc.group_ids
}

resource "vault_identity_oidc_client" "this" {
  count = var.oidc == null ? 0 : 1

  name             = local.oidc_client_name
  redirect_uris    = var.oidc.redirect_uris
  assignments      = [vault_identity_oidc_assignment.this[0].name]
  id_token_ttl     = var.oidc.id_token_ttl
  access_token_ttl = var.oidc.access_token_ttl
}
