//packer {
//  required_plugins {
//    builder-arm = {
//      version = "=v1.0.9"
//      source  = "github.com/mkaczanowski/packer-builder-arm"
//    }
//  }
//}

variable "hostname" {
  type    = string
  default = "homeserver"
}

variable "bootstrap_username" {
  type    = string
  default = "ansible_bootstrap"
}

variable "host_ssh_pub_keys_file" {
  type = string
  #default = "~/.ssh/id_smartcard_dezeroku.pub"
  # Small WA for sudo runs
  default = "/home/dezeroku/.ssh/id_smartcard_dezeroku.pub"
}

variable "arch" {
  type    = string
  default = "arm64"
}

local "host_ssh_pub_keys" {
  expression = file(var.host_ssh_pub_keys_file)
}

source "arm" "rpios" {
  file_urls             = ["https://downloads.raspberrypi.com/raspios_lite_arm64/images/raspios_lite_arm64-2023-12-11/2023-12-11-raspios-bookworm-${var.arch}-lite.img.xz"]
  file_checksum_url     = "https://downloads.raspberrypi.com/raspios_lite_arm64/images/raspios_lite_arm64-2023-12-11/2023-12-11-raspios-bookworm-${var.arch}-lite.img.xz.sha256"
  file_checksum_type    = "sha256"
  file_target_extension = "xz"
  file_unarchive_cmd    = ["xz", "--decompress", "$ARCHIVE_PATH"]
  image_build_method    = "reuse"
  image_path            = "rpios.img"
  image_size            = "3.5G"
  image_type            = "dos"
  image_partitions {
    name         = "boot"
    type         = "c"
    start_sector = "2048"
    filesystem   = "fat"
    size         = "256M"
    mountpoint   = "/boot/firmware"
  }
  image_partitions {
    name         = "root"
    type         = "83"
    start_sector = "526336"
    filesystem   = "ext4"
    size         = "3.0G"
    mountpoint   = "/"
  }
  image_chroot_env             = ["PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin"]
  qemu_binary_source_path      = "/usr/bin/qemu-aarch64-static"
  qemu_binary_destination_path = "/usr/bin/qemu-aarch64-static"
}

build {
  sources = ["source.arm.rpios"]

  provisioner "shell" {
    inline = [
      # Get rid of the default user
      "userdel -r -f pi",

      "echo ${var.hostname} > /etc/hostname",

      "adduser --disabled-password --gecos \"\" ${var.bootstrap_username}",
      "echo \"${var.bootstrap_username} ALL=(ALL) NOPASSWD:ALL\" > /etc/sudoers.d/01-${var.bootstrap_username}",
      "mkdir /home/${var.bootstrap_username}/.ssh",
      "echo \"${local.host_ssh_pub_keys}\" > /home/${var.bootstrap_username}/.ssh/authorized_keys",
      "chown ${var.bootstrap_username}:${var.bootstrap_username} /home/${var.bootstrap_username}/.ssh",
      "chown ${var.bootstrap_username}:${var.bootstrap_username} /home/${var.bootstrap_username}/.ssh/authorized_keys",
      "chmod 0700 /home/${var.bootstrap_username}",
      "chmod 0600 /home/${var.bootstrap_username}/.ssh/authorized_keys",

      "echo \"PermitRootLogin no\nPubkeyAuthentication yes\nPasswordAuthentication no\nAuthenticationMethods publickey\" > /etc/ssh/sshd_config.d/01-basic-sshd-hardening.conf",

      "sudo systemctl enable ssh",
    ]
  }
}
