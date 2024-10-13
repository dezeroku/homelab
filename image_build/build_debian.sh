#!/usr/bin/env bash
set -euo pipefail

# TODO: dockerize it
# Required packages (on Arch):
# * syslinux
# * cdrtools

pubkey_file="/home/dezeroku/.ssh/id_smartcard_dezeroku.pub"
pubkey="$(cat "$pubkey_file")"

# Get password from password manager
luks_password="$(rbw get homeserver_luks)"

debian_version=12.7.0
debian_arch=amd64
# This is a directory suffix in the unpacked ISO, depends on the architecture
debian_arch_dir=amd
debian_iso="debian-${debian_version}-${debian_arch}-netinst.iso"

[ ! -f "${debian_iso}" ] && wget "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/${debian_iso}" -O "${debian_iso}"
[ ! -f "debian_netinst_sha256sums" ] && wget https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/SHA256SUMS -O debian_netinst_sha256sums
sha256sum --check debian_netinst_sha256sums --ignore-missing


staging_dir="$(mktemp -d)"
bsdtar -C "$staging_dir/" -xf "$debian_iso"
cp preseed.cfg "$staging_dir"
pushd "$staging_dir"
sed -i "s#PUB_KEY_SED_ME#$pubkey#" preseed.cfg
sed -i "s#LUKS_PASSWORD_SED_ME#$luks_password#" preseed.cfg
cat preseed.cfg

chmod +w -R "install.$debian_arch_dir/"
gunzip "install.$debian_arch_dir/initrd.gz"
echo preseed.cfg | cpio -H newc -o -A -F "install.$debian_arch_dir/initrd"
rm preseed.cfg
gzip "install.$debian_arch_dir/initrd"
chmod -w -R "install.$debian_arch_dir/"

chmod +w md5sum.txt
find . -follow -type f ! -name md5sum.txt -print0 || true | xargs -0 md5sum > md5sum.txt
chmod -w md5sum.txt
popd

#/usr/lib/syslinux/bios/isohdpfx.bin
mkdir -p output

xorriso -as mkisofs -o "output/preseed-${debian_iso}" \
        -isohybrid-mbr /usr/lib/syslinux/bios/isohdpfx.bin \
        -c isolinux/boot.cat -b isolinux/isolinux.bin -no-emul-boot \
        -boot-load-size 4 -boot-info-table "$staging_dir"
