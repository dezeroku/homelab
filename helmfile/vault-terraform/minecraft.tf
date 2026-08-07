module "minecraft" {
  source             = "${local.lib_path}/terraform/service"
  name               = "minecraft"
  kubernetes_backend = vault_auth_backend.kubernetes_homeserver.path

  secrets = {
    rcon = {
      password = var.minecraft_rcon_password
    }
  }
}

moved {
  from = vault_kubernetes_auth_backend_role.minecraft
  to   = module.minecraft.vault_kubernetes_auth_backend_role.this[0]
}

moved {
  from = vault_policy.minecraft
  to   = module.minecraft.vault_policy.this[0]
}

moved {
  from = vault_generic_secret.minecraft-rcon
  to   = module.minecraft.vault_generic_secret.this["rcon"]
}
