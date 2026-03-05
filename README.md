# OXSystemsOS ISO

Repositório oficial do profile ArchISO da **OXSystemsOS**.

## Estrutura

- `oxsystemsos/`: profile usado pelo `mkarchiso`
- `.github/workflows/build-iso.yml`: workflow para buildar ISO no GitHub Actions

## Build local (Podman)

```bash
sudo podman run --rm -it --privileged -v "$PWD:/work" -w /work archlinux:latest bash
```

Dentro do container:

```bash
pacman-key --init
pacman-key --populate archlinux
pacman -Sy --noconfirm archlinux-keyring
pacman -Syu --noconfirm --disable-download-timeout
pacman -S --noconfirm archiso grub dosfstools mtools efibootmgr
rm -rf /work/out-work
rm -f /work/out-iso/*.iso
mkarchiso -m iso -v -w /work/out-work -o /work/out-iso /work/oxsystemsos
```

## Teste rápido (QEMU + SSH)

```bash
qemu-system-x86_64 -m 2048 -enable-kvm \
  -cdrom ~/ox-systemsos/archiso/out-iso/oxsystemsos-*.iso \
  -nic user,model=virtio-net-pci,hostfwd=tcp::2222-:22
```

```bash
ssh -p 2222 ox@127.0.0.1
# senha: ox
```

## Live GNOME (OXSystemsOS)

- Login automático no usuário `ox`
- `Install OXSystemsOS` no menu de aplicativos
- Calamares (instalador gráfico) iniciado no login da sessão live
- Fallback para wizard `archinstall` se `calamares` não estiver disponível
- Navegador incluído: `firefox`

## Gravar pendrive bootável

```bash
sudo ./scripts/make-boot-usb.sh ./out-iso/oxsystemsos-*.iso /dev/sdX
```

Troque `/dev/sdX` pelo disco USB correto (ex.: `/dev/sdb`).
