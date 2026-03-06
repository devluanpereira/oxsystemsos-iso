#!/bin/bash
set -e

useradd -m -s /bin/bash -G wheel ox || true
echo "ox:ox" | chpasswd

sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

systemctl disable dhcpcd.service || true
systemctl enable NetworkManager.service || true
systemctl enable sshd.service || true
systemctl enable gdm.service || true
systemctl set-default graphical.target || true

mkdir -p /etc/ssh/sshd_config.d
cat > /etc/ssh/sshd_config.d/oxsystemsos.conf <<'CONF'
PermitRootLogin no
PasswordAuthentication yes
CONF

mkdir -p /etc/gdm
cat > /etc/gdm/custom.conf <<'CONF'
[daemon]
AutomaticLoginEnable=True
AutomaticLogin=ox
CONF

install -d -m 0755 /etc/sudoers.d
cat > /etc/sudoers.d/90-ox-live-installer <<'CONF'
ox ALL=(ALL) NOPASSWD: /usr/bin/archinstall
ox ALL=(ALL) NOPASSWD: /usr/bin/calamares
CONF
chmod 0440 /etc/sudoers.d/90-ox-live-installer

# Apply system-wide GNOME defaults (wallpaper, favorites, etc.).
dconf update || true

# Keep distro identity consistent in tools that still read lsb/arch-release.
cat > /etc/lsb-release <<'EOF'
DISTRIB_ID="OXSystemsOS"
DISTRIB_RELEASE="2026.03"
DISTRIB_DESCRIPTION="OXSystemsOS Live • Infra / Rescue"
EOF
echo "OXSystemsOS" > /etc/arch-release

# Initialize pacman keyring in the live rootfs so signed repos work out of box.
install -d -m 0700 /etc/pacman.d/gnupg
if [[ ! -s /etc/pacman.d/gnupg/pubring.gpg && ! -s /etc/pacman.d/gnupg/pubring.kbx ]]; then
  pacman-key --init || true
fi
pacman-key --populate archlinux || true

# Promote OX repo signature policy after keyring population succeeds.
if pacman-key --populate oxsystemsos >/dev/null 2>&1; then
  sed -i '/^\[oxsystemsos\]/,/^$/{s/^SigLevel.*/SigLevel = Required DatabaseRequired/}' /etc/pacman.conf
else
  # Fallback to Never to avoid locking users out of pacman if key import fails.
  sed -i '/^\[oxsystemsos\]/,/^$/{s/^SigLevel.*/SigLevel = Never/}' /etc/pacman.conf
fi

chmod 750 /root || true
