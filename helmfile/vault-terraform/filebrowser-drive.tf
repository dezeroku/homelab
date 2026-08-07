module "filebrowser-drive" {
  source             = "${local.lib_path}/terraform/service"
  name               = "filebrowser-drive"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  oidc = {
    redirect_uris = ["https://drive.${var.domain}/api/auth/oidc/callback"]
    group_ids = [
      vault_identity_group.this["filebrowser-drive-clients"].id,
      vault_identity_group.this["filebrowser-drive-admins"].id,
    ]
    # The assignment was originally created with an underscore; keep it to avoid a replace.
    assignment_name = "filebrowser_drive"
  }
}

moved {
  from = vault_identity_oidc_assignment.filebrowser_drive
  to   = module.filebrowser-drive.vault_identity_oidc_assignment.this[0]
}

moved {
  from = vault_identity_oidc_client.filebrowser_drive
  to   = module.filebrowser-drive.vault_identity_oidc_client.this[0]
}

moved {
  from = vault_kubernetes_auth_backend_role.filebrowser_drive
  to   = module.filebrowser-drive.vault_kubernetes_auth_backend_role.this[0]
}

moved {
  from = vault_policy.filebrowser_drive
  to   = module.filebrowser-drive.vault_policy.this[0]
}
