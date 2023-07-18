#!/usr/bin/env bash
set -euo pipefail

RUNDIR="$(readlink -f "$(dirname "$0")")"

pushd "${RUNDIR}"

# Pass this through a magic sed to replace newlines with literal '\n' so it works in yaml context
HOST_SSH_PUB_KEYS="$(ssh-add -L | sed ':a;N;$!ba;s/\n/\\\\n /g')"
export HOST_SSH_PUB_KEYS

# Maybe let's keep the default here in case we want to provision multiple devices with minimal effort?
HOST_NAME="homeserver"
export HOST_NAME

# Prepare patch file
RASPI_MASTER_PATCH="$(mktemp)"
# We don't want the variables to expand, just envsubst to only substitute this single one
# shellcheck disable=SC2016
envsubst '$HOST_SSH_PUB_KEYS $HOST_NAME' < raspi_master.patch > "${RASPI_MASTER_PATCH}"

# Set up the build environment
vagrant up

# Set up communication with guest
ssh_config="$(mktemp)"
vagrant ssh-config > "${ssh_config}"

# Copy patch file
scp -F "${ssh_config}" "${RASPI_MASTER_PATCH}" default:/home/vagrant/raspi_master.patch

# Perform the build
vagrant ssh -c "\
    set -euo pipefail
    cd /home/vagrant
    # Copy repo
    if [ ! -d 'image-specs' ]; then
        git clone https://salsa.debian.org/raspi-team/image-specs.git -b master
    else
        echo 'image-specs already cloned, using it'
    fi

    pushd image-specs

    # Checkout correct rev
    # Hardcoded rev from June 13 2023
    git checkout 20b903c771ca258e092df3767967b1ea225e3901

    cp ~/raspi_master.patch .
    # A dummy trick to allow multiple builds in the same dir
    git apply raspi_master.patch || (echo 'WA for patch' && git checkout raspi_master.yaml && git apply raspi_master.patch)

    sudo make raspi_4_bookworm.img &&\
    sha256sum raspi_4_bookworm.img > raspi_4_bookworm.img.sha256\
    "

# Download the built images
GUEST_BUILD_DIR="/home/vagrant/image-specs"

mkdir -p output
scp -F "${ssh_config}" "default:${GUEST_BUILD_DIR}/raspi_4_bookworm.yaml" ./output
scp -F "${ssh_config}" "default:${GUEST_BUILD_DIR}/raspi_4_bookworm.img" ./output
scp -F "${ssh_config}" "default:${GUEST_BUILD_DIR}/raspi_4_bookworm.img.sha256" ./output

# Check the image just in case
pushd output
sha256sum -c raspi_4_bookworm.img.sha256
popd

# Clean up
echo "Cleaning up, approve destroying the VM if you're done with building images"
vagrant destroy
