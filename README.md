# Home Server

This repository is a collection of tooling, docs and configuration that defines my homelab and specific purpose nodes.
Currently this boils down to:

- `homeserver` cluster, serving general-purpose applications
- `homeserver-backup` cluster, keeping backups from the above
- `printserver`, which enables wireless access to a USB-only printer

# Overview

![Overview](docs/diagrams/created/overview.png?raw=true "Overview")

Key takeaways:

- `ingress-nginx` on entry, with `cert-manager` + `Let's Encrypt` (DNS based challenges in Route53) backed
  SSL, `oauth2-proxy` for non-OIDC-native services
- `vault` for centralized identity and secrets management
- `longhorn` used for storage with daily backups of "important" volumes in a separate cluster

# Networking

Clusters live in a separate `cluster` VLAN defined in a [network_layout repository](https://github.com/dezeroku/network_layout/blob/master/build/config/mainrouter/template-variables.yaml).
Mentioned repo also defines the VPN setup and IPs assignment.

All traffic to `*.<DOMAIN>` and `*.backup.<DOMAIN>` is redirected to specific cluster LBs on a router/VPN level.

# Hardware

## homeserver

Three Dell Optiplex nodes, totaling 18 cores, 192G of RAM and 6T of storage (1x2T NVMe on each node).

Nodes mounted in a 10″ rack using the [3d printed frames](https://dimitrije.website/posts/2024-01-02-homelab-hardware.html)
with minor modifications (TODO: upstream model changes).

## homeserver backup

Three RPis 4B, totaling 12 cores, 24G of RAM and 3T of storage (1x1T M.2 SATA attached over USB on each node).

Pis are mounted in a 10″ rack using the [3d printed frames](https://www.thingiverse.com/thing:4078710).
Power is provided via official PoE+ hats.

## printserver

RPi Zero 2 W, with OTG splitter for a USB-A type port.

# Bootstrapping

## Initial steps

In other words, what needs to be done when you lay your hands on a new machine.
As a rule of thumb this only has to be done once.

### RPi nodes

1. Update the bootloader and make it boot from the USB first. `RPi Imager` > `Bootloader` > `USB Boot`
2. Flash the official Raspberry Pi OS (64-bit) image and make sure that it works fine. You can use this step to run `raspi-config` and set WLAN country

### Dell Optiplex

1. Run extended diagnostic suite
2. Update BIOS
3. Run extended diagnostic suite again

## Installing OS

We want to use a bootstrap image that is ready to be provisioned with `ansible` without requiring any user interaction first.
To achieve it, we need to:

1. create bootstrap user `ansible_bootstrap` with passwordless `sudo` privileges
2. provide public SSH key to be added to `authorized_keys`
3. setup minimal required SSH hardening (deny password authentication, deny root login, only allow public key based logins)

Scripts are provided to prepare such image

### Building OS image

Currently `Raspbian` is used for RPi nodes (because of the OOTB support for PoE+ hat fans), while Dell nodes use `Debian`.

Take a look at corresponding `build_` scripts in `image_build` directory for more details.
Few useful variables:

1. `HOST_SSH_PUB_KEYS_FILE` points to a pubkey that should be added to `authorized_keys` on the target
2. `LUKS_PASSWORD` (`build_debian` specific) if provided, will be used for full disk encryption.
   Defaults to obtaining the password from password manager

Required packages on host for the build to succeed:

- `vagrant` (builds are performed in VMs for better interoperability)
- `ssh`

Built images can be found in `image_build/output` directory.

<!---
#The `build.sh` script optionally takes a number as a parameter (defaults to `4`), below redacted excerpt from the build repo describes its meaning:
#
- Model `1` should be used for the Raspberry Pi 0, 0w and 1, models A and B
- Model `2` for the Raspberry Pi 2 models A and B
- Model `3` for all models of the Raspberry Pi 3
- Model `4` for all models of the Raspberry Pi 4.
You can also optionally pass the `WIFI_SETUP`, `WIFI_SSID` and `WIFI_PASSWORD` environment variables if you want to perform a WiFi based setup.
TODO: restore this section after script supports them again
-->

If you were to use an official image you would have to perform the user, SSH and (optionally) LUKS setup manually.

In later steps Ansible will make sure that SSH config is properly hardened and `ansible_bootstrap` user is removed.

### Creating boot media

#### RPi

When you have the image on hand you can flash it to the drive using the tool of your choice, e.g. with `dd`

```
# dd if=<path to the image> of=<path to your SSD> bs=64k oflag=dsync status=progress
```

or using a tool like `rufus` or `etcher`.

#### Dell

Create a bootable USB drive or upload the file to a TFTP server to perform netboot.
Afterwards, install the system as usual.
Beware, you have to use the _Install_ (not graphical) option for the preseed file to be taken into account.

The preseed file responsible for the initial setup is burned into the image itself.

## Ansible

This part is responsible for most of the software provisioning.

The idea is to ensure that core blocks are in place, for example:

1. users
2. firewall
3. access restriction, e.g. via SSH
4. required dependencies
5. container runtime

This step also removes the `ansible_bootstrap` user and initializes Kubernetes clusters.

To provision the nodes:

1. Enter the `ansible` directory
2. Set up the workspace with `poetry install`
3. Get dependencies via `poetry run ansible-galaxy install -r requirements.yml`
4. Run the `poetry run ansible-playbook site.yml`

Take a look at `inventory.yml` and `site.yml` for supported options.
Most notably passwords that will be set for the newly created users are obtained from the password manager by default.

## Core cluster setup (homeserver/homeserver_backup)

At the very beginning obtain kubeconfig via `scp server@<node>:/etc/rancher/k3s/k3s.yaml kubeconfig.yaml`.
You will have to modify the `server` field in the kubeconfig so it points to a remote node and not `127.0.0.1` (which is the default).

It's assumed that `homeserver` and `homeserver_backup` have corresponding contexts created under
the names `homeserver` and `homeserver-backup` respectively

Required tools:

- `kubectl`
- `helm`
- `helmfile`
- `terragrunt`
- `terraform`

Few important charts that will be deployed in this step:

1. `cert-manager` for certificates generation (Route53 DNS solver under the hood)
2. `ingress-nginx` for reverse proxying
3. `victoria-metrics-k8s-stack` for monitoring, configured with PagerDuty and Dead Man's Snitch
4. `vault` for secrets and identity management
5. `oauth2-proxy` for OIDC support for applications that do not support it natively
6. `longhorn` for distributed storage

### Cluster deployment

All the cluster related configuration is stored under `helmfile` directory.
Different directories are to be used depending on the cluster.
Below instructions define how to perform a full (from scratch) deployment

#### homeserver

1. cd to `helmfile/core`
2. run `DOMAIN=<your domain> helmfile sync`
3. cd to `helmfile/vault-terraform`
4. run `terragrunt apply`
5. cd to `helmfile/services`
6. run `DOMAIN=<your domain> helmfile sync`

While the steps above cover the deployment, there's some special treatment needed to initialize vault from scratch.
Please follow the [helmfile/vault-terraform/vault-setup.md](helmfile/vault-terraform/vault-setup.md).
Make sure that you have provided the required values for `helmfile/vault-terraform/terraform.tfvars`.

#### homeserver_backup

This cluster largely depends on the `homeserver` setup, e.g. for auth.
Make sure that the above cluster is deployed and ready first

1. cd to `helmfile/backup`
2. run `DOMAIN=<your domain> helmfile sync`

## Notes

### printserver

Currently the ansible playbook takes care of:

1. setting up the CUPS server
2. installing (properiatary) drivers for HP LaserJet Pro P1102 printer

It requires the printer to be connected to the device when the playbook is being applied.
