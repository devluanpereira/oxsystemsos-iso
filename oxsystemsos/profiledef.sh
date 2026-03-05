#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="oxsystemsos"
iso_label="OXSYSTEMS_202603"
iso_publisher="OXSystemsOS"
iso_application="OXSystemsOS Live • Infra / Rescue"
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)"
install_dir="ox"
buildmodes=('iso')
bootmodes=('bios.syslinux'
           'uefi.grub')
pacman_conf="pacman.conf"
airootfs_image_type="erofs"
airootfs_image_tool_options=('-zlzma,109' -E 'ztailpacking')
bootstrap_tarball_compression=(xz -9e)
file_permissions=(
  ["/etc/shadow"]="0:0:400"
)
