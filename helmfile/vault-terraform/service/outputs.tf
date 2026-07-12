output "oidc_client_id" {
  description = "client_id of the OIDC client, or null when oidc was not configured. Feed this into the provider's allowed_client_ids."
  value       = var.oidc == null ? null : vault_identity_oidc_client.this[0].client_id
}

output "policy_name" {
  description = "Name of the created Vault policy, or null when create_policy = false."
  value       = var.create_policy ? vault_policy.this[0].name : null
}
