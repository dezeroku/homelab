# Home Server

This repository is a collection of tooling, docs and configuration that defines my small homelab
(the stable one, not a development machine).

# Hardware

It's currently an RPi 4B, 8GB of RAM, 4x1.5GHz CPU.
Because of that, probably some tooling will be chosen with ARM in mind, but it shouldn't matter too much.
Argon One (with M2 extension board) is chosen for a case + some cheap M.2 SATA SSD on top to increase speeds.

It's connected via Ethernet to a separate IoT subnetwork, as defined in [network_layout](repo).
This comes mostly from the `Homebridge` deployment, as it needs (or at least should need) to
be in the same network that the devices are.

# Initial steps

In other words, what needs to be done when you lay your hands on the machine.

1. Update the bootloader and make it boot from the USB first. `RPi Imager` > `Bootloader` > `USB Boot`
2. (optional) Flash the Raspberry Pi OS (64-bit) and make sure that it works fine
3. Pick your system. Pure Debian "Bookworm" was chosen for this exercise
4. Install it on the Pi and make sure that you can SSH into it

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

TBD

## Core cluster setup

A bunch of charts to be installed, that will cover:

1. certificates generation
2. incoming traffic redirection
3. storage

## End applications

1. Homebridge
2. Some kind of a monitoring stack to collect Homebridge sensors data to
