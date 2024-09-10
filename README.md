# Home Server

This repository is a collection of tooling, docs and configuration that defines my small homelab
(the stable one, not a development machine).
It currently spans three nodes to get some HA and distributed storage.

DNS setup (pointing `homeserver` to all the IPs and `homeserver-{one,two...}/printserver` to the specific machine is out of the scope of this repo).
It is defined in [network_layout](https://github.com/dezeroku/network_layout) repository.

# Hardware

I currently use RPis 4B, 8GB of RAM, 4x1.5GHz CPU.
Because of that, probably some tooling will be chosen with ARM in mind, but it shouldn't matter too much.
RPis are mounted in rack using the [3d printed frames](https://www.thingiverse.com/thing:4078710),
M.2 SSD to USB adapters are used for storage.
Power is provided via official PoE+ hats.

It's connected via Ethernet to a separate IoT subnetwork, as defined in [network_layout](https://github.com/dezeroku/network_layout).
This comes mostly from the `home-assistant` deployment, as I didn't have time to spend resolving mDNS connectivity between networks yet.

# Initial steps

In other words, what needs to be done when you lay your hands on the machine.

1. Update the bootloader and make it boot from the USB first. `RPi Imager` > `Bootloader` > `USB Boot`
2. (optional) Flash the Raspberry Pi OS (64-bit) and make sure that it works fine. You can use this step to run `raspi-config` and set WLAN country
3. Pure Debian "Bookworm" OS was chosen for this exercise.
   Install it on the Pi and make sure that you can SSH into it as `ansible_bootstrap` user and have root privileges.
   For Debian this can be done by setting up a non-root user and giving it e.g. sudo access

# Flashing Debian

To make the whole process a bit easier, a custom Debian/Raspbian image (that fulfills the requirements listed above)
can be built using the scripts in `image_build` directory.
It requires `vagrant` and `ssh` to be available on the build host

Running the `build_raspbian.sh/build_debian.sh` script will create an image that:

1. is based on the newest `bookworm` release packages available to date
2. contains `ansible_bootstrap` user with passwordless sudo, which can be logged in via SSH using any of the keys defined in file under `HOST_SSH_PUB_KEYS_FILE` variable
3. sets up the minimal hardening of ssh server (denies password authentication, denies root login, allows public key based auth)

The built image can be found in `image_build/output` directory.

The `build.sh` script optionally takes a number as a parameter (defaults to `4`), below redacted excerpt from the build repo describes its meaning:

- Model `1` should be used for the Raspberry Pi 0, 0w and 1, models A and B
- Model `2` for the Raspberry Pi 2 models A and B
- Model `3` for all models of the Raspberry Pi 3
- Model `4` for all models of the Raspberry Pi 4.

You can also optionally pass the `WIFI_SETUP`, `WIFI_SSID` and `WIFI_PASSWORD` environment variables if you want to perform a WiFi based setup.

If you were to use an official image you'll have to do the user and SSH setup manually.

In later steps, the Ansible will make sure that SSH config is properly hardened and `ansible_bootstrap` user is removed.

When you have the image on hand you can flash it on the SSD using the tool of your choice, e.g. with `dd`

```
# dd if=<path to the image> of=<path to your SSD> bs=64k oflag=dsync status=progress
```

or using a tool like `rufus` or `etcher`.

In case of "normal" machines a preseed file is burned into the image and is responsible for the initial setup.
Beware, you have to use the _Install_ (not graphical) option for the preseed file to be taken into account.

# Software

The end-goal here is to be able to run few relatively low-resource applications, such as
`Home Assistant` or a file server.

There are many ways this could be done, just running container, using `docker-compose`, etc.

I've chosen to set-up a Kubernetes (k3s flavour) cluster, as in my opinion
it greatly simplifies the setup once you get through the initial learning curve and additionally
gives you access to a lot of battle-tested tools and helpers, such as `cert-manager` or `ingress-nginx`.
Lastly, it has some HA properties and allows for distributed storage.

This may seem like an overkill (and in fact is), but why not do it.

## Initial provisioning

There are few "layers" of automation that are going to be used to minimise the effort needed to set this up from scratch.

Starting with `Ansible` the idea is to ensure that core blocks such as:

1. users
2. firewall
3. access restriction, e.g. via SSH
4. required dependencies installed
5. container runtime setup

are properly configured and versioned.

What you need to do (this step assumes that your homeserver is available as `homeserver.lan`. Modify the inventories if it's not true):

1. Enter the `ansible` directory
2. Set up the workspace with `poetry install`
3. Get dependencies via `poetry run ansible-galaxy install -r requirements.yml`
4. Run the `poetry run ansible-playbook site.yml -l k8s_nodes`
   You can also use the `--extra-vars ssh_pub_key_file=<path_to_a_pub_key_file>` and `--extra-vars user_password=<password you want to set>` if the default values don't suit you.
   This will also remove the `ansible_bootstrap` user by default.
   The user_password is obtained from Bitwarden by default

5. Obtain kubeconfig via `scp server@homeserver-one:/etc/rancher/k3s/k3s.yaml kubeconfig.yaml`.
   You'll have to modify the `127.0.0.1` so it points to your homeserver

Note: later on you can use the above command again, but this time also make it run system updates:

```
poetry run ansible-playbook site.yml -l k8s_nodes --extra-vars upgrade_packages=true
```

This will ensure that your setup didn't drift away and also reboot when required after applying the upgrades.

## Core cluster setup

This chapter assumes that the `kubeconfig.yaml` obtained in previous step is the one in use.
Prefix commands with `KUBECONFIG=<path_to_kubeconfig_yaml>` if needed.
It also requires the `helm` (with [diff-plugin](https://github.com/databus23/helm-diff)) and `helmfile` tools to be present.

A bunch of charts to be installed, that will cover:

1. cert-manager for certificates generation (Route53 DNS solver under the hood)
2. ingress-nginx for reverse proxying
3. kube-prometheus-stack for monitoring, configured with PagerDuty and Dead Man's Snitch
4. vault for secrets management. It's not really "properly" deployed but should be more than enough for the use-case, basically we just want a central storage for credentials
5. longhorn for distributed storage

How to deploy:

1. Go to `helmfile/core/charts/cert-manager-cluster-issuer/aws-cert-user/` and follow the README to obtain AWS access data that will be used later on for obtaining certificates
2. Copy the `helmfile/core/charts/cert-manager-cluster-issuer/values.yaml` as `helmfile/core/values/cert-manager-cluster-issuer.yaml` and adjust accordingly to your needs
3. Go to `helmfile/core`
4. Run `DOMAIN=<your domain> helmfile sync` (it's fine to use `DOMAIN=<your domain> helmfile apply` on subsequent calls, but deploying prometheus requires CRDs, so `sync` is needed on the initial deploy)

While the steps above cover the deployment, there's some special treatment needed to initialize vault.
Please follow the [helmfile/core/vault-setup.md](helmfile/core/vault-setup.md).
Make sure that you have entered the required values for both `helmfile/core/vault-terraform/terraform.tfvars` and `helmfile/services/vault-terraform/terraform.tfvars`.

## End applications

This sets up:

1. [Home Assistant](https://github.com/home-assistant) for managing smart devices
2. [Pacoloco](https://github.com/anatol/pacoloco) for caching the archlinux packages (I have few Arch hosts running on LAN)
3. `minio` for object storage

How to deploy:

1. Go to `helmfile/services`
2. Run `DOMAIN=<your domain> helmfile sync` (it's fine to use `DOMAIN=<your domain> helmfile apply` on subsequent calls)

## Tips

### Printserver

This repository allows you to set up a Raspberry Pi as a CUPS printserver.
For this to happen, you've got to follow the instructions from "Initial Steps" and "Flashing Debian" chapters, following it up
with applying ansible playbook `printserver.yml`:

1. Enter the `ansible` directory
2. Set up the workspace with `poetry install`
3. Get dependencies via `poetry run ansible-galaxy install -r requirements.yml`
4. Run the `poetry run ansible-playbook site.yml -l printserver`
   You can also use the `--extra-vars ssh_pub_key_file=<path_to_a_pub_key_file>` and `--extra-vars user_password=<password you want to set>` if the default values don't suit you.
   This will also remove the `ansible_bootstrap` user by default.
   The user_password is obtained from Bitwarden by default

Note: later on you can use the above command again, but this time also make it run system updates:

```
poetry run ansible-playbook site.yml -l printserver -extra-vars upgrade_packages=true
```

This will ensure that your setup didn't drift away and also reboot when required after applying the upgrades.

Currently the ansible playbook takes care of:

1. setting up the CUPS server
2. installing (properiatary) drivers for HP LaserJet Pro P1102 printer

It requires the printer to be connected to the device when the playbook is being applied.

### PRs for helmfile

[Renovate Bot](https://github.com/renovatebot/github-action) is set up to run daily in the repo.
It's meant to notify about new charts releases (and general dependencies).
The workflow for these changes should be roughly:

1. Checkout the PR locally (it's recommended to read the Release Notes first)
2. Run `DOMAIN=<domain of your choice> helmfile deps` in the appropriate directory (depending on the change)
3. Run `DOMAIN=<domain of your choice> helmfile diff` and make sure that the changes look good
4. Run `DOMAIN=<domain of your choice> helmfile apply`
5. Amend the changed `helmfile.lock` if needed and merge to master
6. Push to upstream
