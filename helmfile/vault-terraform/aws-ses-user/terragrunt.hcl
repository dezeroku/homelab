# Terragrunt runs terraform from a copy of this directory under
# .terragrunt-cache, and re-copies terraform.tfstate into it on every run. With
# the implicit local backend (a relative "terraform.tfstate") the state written
# by an apply stays in the cache and is clobbered by the next run's copy, so the
# state has to be pinned to an absolute path in this directory instead.
remote_state {
  backend = "local"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    path = "${get_terragrunt_dir()}/terraform.tfstate"
  }
}
