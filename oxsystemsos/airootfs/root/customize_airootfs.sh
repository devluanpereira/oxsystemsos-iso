#!/bin/bash
set -e

useradd -m -s /bin/bash -G wheel ox || true
echo "ox:ox" | chpasswd

sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

systemctl enable dhcpcd.service || true
systemctl enable sshd.service || true

mkdir -p /etc/ssh/sshd_config.d
cat > /etc/ssh/sshd_config.d/oxsystemsos.conf <<'CONF'
PermitRootLogin no
PasswordAuthentication yes
CONF

# Keep distro identity consistent in tools that still read lsb/arch-release.
cat > /etc/lsb-release <<'EOF'
DISTRIB_ID="OXSystemsOS"
DISTRIB_RELEASE="2026.03"
DISTRIB_DESCRIPTION="OXSystemsOS Live • Infra / Rescue"
EOF
echo "OXSystemsOS" > /etc/arch-release

chmod 750 /root || true
