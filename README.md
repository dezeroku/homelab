# Home Server

This repository is a collection of tooling, docs and configuration that defines my small homelab
(the stable one, not a development machine).

# Hardware

It's currently an RPi 4B, 8GB of RAM, 4x1.5GHz CPU.
Because of that, probably some tooling will be chosen with ARM in mind, but it shouldn't matter too much.
Argon One (with M2 extension board) is chosen for a case + some cheap M.2 SATA SSD on top to increase speeds.

It's connected via Ethernet to a separate IoT subnetwork, as defined in [network_layout](https://github.com/dezeroku/network_layout).
This comes mostly from the `Homebridge` deployment, as it needs (or at least should need) to
be in the same network that the devices are.

# Initial steps

In other words, what needs to be done when you lay your hands on the machine.

1. Update the bootloader and make it boot from the USB first. `RPi Imager` > `Bootloader` > `USB Boot`
2. (optional) Flash the Raspberry Pi OS (64-bit) and make sure that it works fine
3. (optional) Disconnect the fan cable from Argon One case. The case itself is good enough for cooling and the fan noise is annoying
4. Pure Debian "Bookworm" OS was chosen for this exercise.
   Install it on the Pi and make sure that you can SSH into it as `ansible_bootstrap` user and have root privileges.
   For Debian this can be done by setting up a non-root user and giving it e.g. sudo access

# Flashing Debian

To make the whole process a bit easier, a custom Debian image (that fulfills the requirements listed above)
can be built using the scripts in `image_build` directory.
It requires `vagrant` and `ssh` to be available on host

Running the `build.sh` script will create an image that:

1. is based on the newest `bookworm` release packages available to date
2. contains `ansible_bootstrap` user with passwordless sudo, which can be logged in via SSH using any of the keys that
   correspond to `ssh-add -L`
3. sets up the minimal hardening of ssh server (denies password authentication, denies root login, allows public key based auth)

The built image can be found in `image_build/output` directory.

If you were to use an official image you'll have to do the user and SSH setup manually.

In later steps, the Ansible deploy will make sure that SSH config is properly hardened and `ansible_bootstrap` user is removed.

When you have the image on hand you can flash it on the SSD using the tool of your choice, e.g. with `dd`

```
dd of=<path to your SSD> bs=64k oflag=dsync status=progress
```

or using a tool like `rufus` or `etcher`.

# Software

The end-goal here is to be able to run few relatively low-resource applications, such as
`Homebridge` or a file server.

There are many ways this could be done, just running container, using `docker-compose`, etc.

I've chosen to set-up a Kubernetes (k3s flavour) "cluster" of a single-node, as in my opinion
it greatly simplifies the setup once you get through the initial learning curve and additionally
gives you access to a lot of battle-tested tools and helpers, such as `cert-manager` or `ingress-nginx`.

This may seem like an overkill (and probably is), but let's remember, that Fortune favours the bold.

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
2. Get dependencies via `ansible-galaxy install -r requirements.yml`
3. Run the `ansible-playbook site.yml -i initial-inventory.yml --extra-vars user_password=<password you want to set>` command to provision the default `server` user.
   You can also use the `--extra-vars ssh_pub_key_file=<path_to_a_pub_key_file>` if the default of `~/.ssh/id_rsa.pub` doesn't suit you.

   (optional, but recommended) Make sure that you can log in as the user (ssh as user `server` to the server)
   This step won't be runnable later, as the underlying ansible_bootstrap user will be removed.
   You can modify `initial-inventory.yml` to use another user if needed in the future.

4. Run the `ansible-playbook site.yml -i inventory.yml --ask-become-pass --extra-vars cleanup_bootstrap_user=true --extra-vars k3s_tls_san=<domain of your choice>` and enter the password that you chose to provision the k3s cluster.
   You don't have to pass the `cleanup_bootstrap_user` param on subsequent calls
5. Obtain kubeconfig via `scp server@<homeserver_ip_dns>:/etc/rancher/k3s/k3s.yaml kubeconfig.yaml`.
   You'll have to modify the `127.0.0.1` so it points to your homeserver

Note: later on you can use the above command again, but this time also make it run system updates:

```
ansible-playbook site.yml -i inventory.yml --ask-become-pass --extra-vars k3s_tls_san=<domain of your choice> --extra-vars upgrade_packages=true
```

This will ensure that your setup didn't drift away and also reboot when required after applying the upgrades.

## Core cluster setup

TODO: nginx based basic auth for prometheus and alertmanager

This chapter assumes that the `kubeconfig.yaml` obtained in previous step is the one in use.
Prefix commands with `KUBECONFIG=<path_to_kubeconfig_yaml>` if needed.
It also requires the `helm` (with [diff-plugin](https://github.com/databus23/helm-diff)) and `helmfile` tools to be present.

A bunch of charts to be installed, that will cover:

1. cert-manager for certificates generation (Route53 DNS solver under the hood)
2. ingress-nginx for reverse proxying
3. kube-prometheus-stack for monitoring
4. VictoriaMetrics for push-model metrics collection (and possibly more in the future)
5. vault for secrets management. It's not really "properly" deployed but should be more than enough for the use-case, basically we just want a central storage for credentials

How to deploy:

1. Go to `helmfile/core/cert-manager-cluster-issuer/aws-cert-user/` and follow the README to obtain AWS access data that will be used later on for obtaining certificates
2. Copy the `helmfile/core/cert-manager-cluster-issuer/values.yaml` as `helmfile/core/values-cert-manager-cluster-issuer.yaml` and adjust accordingly to your needs
3. Go to `helmfile/core`
4. Run `DOMAIN=<your domain> helmfile sync` (it's fine to use `DOMAIN=<your domain> helmfile apply` on subsequent calls, but deploying prometheus requires CRDs, so `sync` is needed on the initial deploy)

While the steps above cover the deployment, there's some special treatment needed to initialize vault.
Please follow the [helmfile/core/vault-setup.md](helmfile/core/vault-setup.md).

## End applications

This sets up:

1. [Homebridge](https://github.com/homebridge/homebridge) for Homekit support for smart devices that aren't officially compatible
2. [Pacoloco](https://github.com/anatol/pacoloco) for caching the archlinux packages (I have few Arch hosts running on LAN)

How to deploy:

1. Go to `helmfile/services`
2. Run `DOMAIN=<your domain> helmfile sync` (it's fine to use `DOMAIN=<your domain> helmfile apply` on subsequent calls)
