locals {
  base_dn = join(",", [for part in split(".", var.domain) : "dc=${part}"])

  # Shared minio bucket that services back themselves up to; handed to the
  # `service` module's backuper_credentials_path. The private repo has a bucket
  # of its own and passes its own path.
  backuper_credentials_path = "core/minio/k8s-backups/backuper-credentials"
}
