# Everything a second Vault state - the private repo's - needs in order to hang
# its own services off the identity defined here. Consumed by its terragrunt.hcl,
# which declares this directory as a `dependency`.

output "vault_auth_backend_kubernetes_homeserver_path" {
  value = vault_auth_backend.kubernetes_homeserver.path
}

output "identity_group_ids" {
  description = "Vault identity groups declared in groups.tf, by name. Feed into a service module's oidc.group_ids."
  value       = { for name, group in vault_identity_group.this : name => group.id }
}

output "user_entity_ids" {
  description = <<-EOT
    Vault identity entities of the users declared here, by username. A dependent state adds them
    to its own groups with vault_identity_group_member_entity_ids (exclusive = false, exactly as
    the user module does), without needing the userpass mount or the passwords.
  EOT
  value       = { for username, user in module.user : username => user.entity_id }
}
