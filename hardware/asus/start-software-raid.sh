#!/usr/bin/env bash
set -euo pipefail

md_device_path="/dev/md0"

gpt_a_device="$(losetup --nooverlap --show --find /var/lib/libvirt/extra-images/efi1)"
gpt_b_device="$(losetup --nooverlap --show --find /var/lib/libvirt/extra-images/efi2)"
echo "gpt_a_device: ${gpt_a_device}"
echo "gpt_b_device: ${gpt_b_device}"
mdadm --build --verbose "${md_device_path}" --chunk=512 --level=linear --raid-devices=4 "${gpt_a_device}" /dev/disk/by-partuuid/d0edc5af-facf-4d99-9198-161b74ee0e8d /dev/disk/by-partuuid/5b2a92ae-705b-4575-9929-065abde484ef "${gpt_b_device}"
