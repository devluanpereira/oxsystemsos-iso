#!/bin/bash
set -e

useradd -m -s /bin/bash -G wheel ox || true
echo "ox:ox" | chpasswd

sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

systemctl enable dhcpcd.service || true
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

# If Calamares is installed, pin it to OX branding and local config.
if [[ -f /usr/share/calamares/settings.conf ]]; then
  install -Dm644 /usr/share/calamares/settings.conf /etc/calamares/settings.conf
  sed -i 's/^branding:.*/branding: oxsystemsos/' /etc/calamares/settings.conf || true
  sed -i 's/^prompt-install:.*/prompt-install: true/' /etc/calamares/settings.conf || true
fi

# Apply system-wide GNOME defaults (wallpaper, favorites, etc.).
dconf update || true

# Keep distro identity consistent in tools that still read lsb/arch-release.
cat > /etc/lsb-release <<'EOF'
DISTRIB_ID="OXSystemsOS"
DISTRIB_RELEASE="2026.03"
DISTRIB_DESCRIPTION="OXSystemsOS Live • Infra / Rescue"
EOF
echo "OXSystemsOS" > /etc/arch-release

chmod 750 /root || true
