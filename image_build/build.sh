#!/usr/bin/env bash
set -euo pipefail

# TODO: migrate the RPI_VERSION login and WIFI patch
HOST_SSH_PUB_KEYS_FILE="${HOST_SSH_PUB_KEYS_FILE:-$HOME/.ssh/id_smartcard_dezeroku.pub}"

# Set up the build environment
vagrant up

# Set up communication with guest
ssh_config="$(mktemp)"
vagrant ssh-config > "${ssh_config}"

# Copy packer file
scp -F "${ssh_config}" "packer-rpios.pkr.hcl" default:/home/vagrant/packer-rpios.pkr.hcl

# Copy ssh pubkeys file
scp -F "${ssh_config}" "${HOST_SSH_PUB_KEYS_FILE}" default:/home/vagrant/ssh-keys.pub


# Perform the build
vagrant ssh -c "\
set -euo pipefail
#docker run --rm --privileged -v /home/vagrant/ssh-keys.pub:/root/.ssh/id_smartcard_dezeroku.pub -v /dev:/dev -v /home/vagrant:/build mkaczanowski/packer-builder-arm:1.0.9 build packer-rpios.pkr.hcl
# Use the /home/dezeroku WA
docker run --rm --privileged -v /home/vagrant/ssh-keys.pub:/home/dezeroku/.ssh/id_smartcard_dezeroku.pub -v /dev:/dev -v /home/vagrant:/build mkaczanowski/packer-builder-arm:1.0.9 build packer-rpios.pkr.hcl
    "

# Download the built image
mkdir -p output
scp -F "${ssh_config}" "default:/home/vagrant/rpios.img" ./output

#ALLOWED_RPI_VERSIONS=("1" "2" "3" "4")
#RPI_VERSION="4"
#
#if [ -n "${1:-}" ]; then
#    echo "Provided RPI_VERSION=$1"
#    if [[ " ${ALLOWED_RPI_VERSIONS[*]} " = *"$1"* ]]; then
#        RPI_VERSION="$1"
#    else
#        echo "Provided RPI_VERSION is not present in the allow-list"
#        exit 1
#    fi
#fi
#
#if [ "${WIFI_SETUP:-}" == "true" ]; then
#    echo "WIFI_SETUP=true"
#    if [ -z "${WIFI_SSID:-}" ]; then
#        echo "Missing WIFI_SSID env variable"
#        exit 1
#    fi
#
#    if [ -z "${WIFI_PASSWORD:-}" ]; then
#        echo "Missing WIFI_PASSWORD env variable"
#        exit 1
#    fi
#fi
#
#RUNDIR="$(readlink -f "$(dirname "$0")")"
#
#pushd "${RUNDIR}"
#
## Pass this through a magic sed to replace newlines with literal '\n' so it works in yaml context
##HOST_SSH_PUB_KEYS="$(ssh-add -L | sed ':a;N;$!ba;s/\n/\\\\n /g')"
#HOST_SSH_PUB_KEYS_FILE="${HOST_SSH_PUB_KEYS_FILE:-$HOME/.ssh/id_smartcard_dezeroku.pub}"
#HOST_SSH_PUB_KEYS="$(cat "${HOST_SSH_PUB_KEYS_FILE}")"
#export HOST_SSH_PUB_KEYS
#
## Maybe let's keep the default here in case we want to provision multiple devices with minimal effort?
#HOST_NAME="homeserver"
#export HOST_NAME
#
## Set up the build environment
#vagrant up
#
## Set up communication with guest
#ssh_config="$(mktemp)"
#vagrant ssh-config > "${ssh_config}"
#
#
## MAIN PATCH
#RASPI_MASTER_PATCH="$(mktemp)"
## We don't want the variables to expand, just envsubst to only substitute this single one
## shellcheck disable=SC2016
#envsubst '$HOST_SSH_PUB_KEYS $HOST_NAME' < patches/0001-misc-prepare-for-the-ansible_bootstrap.patch  > "${RASPI_MASTER_PATCH}"
#
## Copy patch file
#scp -F "${ssh_config}" "${RASPI_MASTER_PATCH}" default:/home/vagrant/0001-misc-prepare-for-the-ansible_bootstrap.patch
#
## WIFI PATCH
#if [ "${WIFI_SETUP:-}" == "true" ]; then
#    RASPI_WIFI_PATCH="$(mktemp)"
#
#    # We don't want the variables to expand, just envsubst to only substitute the ones we need
#    # shellcheck disable=SC2016
#    envsubst '$WIFI_SSID $WIFI_PASSWORD' < patches/0002-misc-add-support-for-bootstrapping-WiFi.patch > "${RASPI_WIFI_PATCH}"
#
#    scp -F "${ssh_config}" "${RASPI_WIFI_PATCH}" default:/home/vagrant/0002-misc-add-support-for-bootstrapping-WiFi.patch
#fi
#
## Perform the build
#vagrant ssh -c "\
#    set -euo pipefail
#    cd /home/vagrant
#    # Copy repo
#    if [ ! -d 'image-specs' ]; then
#        git clone https://salsa.debian.org/raspi-team/image-specs.git -b master
#    else
#        echo 'image-specs already cloned, using it'
#    fi
#
#    pushd image-specs
#
#    # Make git not complain when applying mail patches
#    git config --global user.email 'image_builder@example.com'
#    git config --global user.name 'image_builder'
#
#    # Checkout correct rev
#    # Hardcoded rev from Jan 1 2024
#    git checkout ff7fdbf07c727ba1d2277dc7f274bd234f2e2bfa
#
#    git am < ~/0001-misc-prepare-for-the-ansible_bootstrap.patch
#
#    if [ '${WIFI_SETUP:-}' == 'true' ]; then
#        git am < ~/0002-misc-add-support-for-bootstrapping-WiFi.patch
#    fi
#
#    sudo make raspi_${RPI_VERSION}_bookworm.img &&\
#    sha256sum raspi_${RPI_VERSION}_bookworm.img > raspi_${RPI_VERSION}_bookworm.img.sha256\
#    "
#
## Download the built images
#GUEST_BUILD_DIR="/home/vagrant/image-specs"
#
#mkdir -p output
#scp -F "${ssh_config}" "default:${GUEST_BUILD_DIR}/raspi_${RPI_VERSION}_bookworm.yaml" ./output
#scp -F "${ssh_config}" "default:${GUEST_BUILD_DIR}/raspi_${RPI_VERSION}_bookworm.img" ./output
#scp -F "${ssh_config}" "default:${GUEST_BUILD_DIR}/raspi_${RPI_VERSION}_bookworm.img.sha256" ./output
#
## Check the image just in case
#pushd output
#sha256sum -c "raspi_${RPI_VERSION}_bookworm.img.sha256"
#popd
#
## Clean up
#echo "Cleaning up, approve destroying the VM if you're done with building images"
#vagrant destroy
