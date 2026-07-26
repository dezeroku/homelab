terraform {
  required_version = "~> 1.0"
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.19.0"
    }
    lldap = {
      source  = "tasansga/lldap"
      version = "~> 0.4.1"
    }
  }
}
