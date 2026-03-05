#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo "Uso: $0 <caminho-da-iso> <disco-usb>"
  echo "Exemplo: sudo $0 ./out-iso/oxsystemsos-2026.03.05-x86_64.iso /dev/sdb"
  exit 1
fi

iso_path="$1"
usb_disk="$2"

if [[ ! -f "${iso_path}" ]]; then
  echo "ISO nao encontrada: ${iso_path}"
  exit 1
fi

if [[ ! -b "${usb_disk}" ]]; then
  echo "Dispositivo invalido: ${usb_disk}"
  exit 1
fi

if [[ "${EUID}" -ne 0 ]]; then
  echo "Execute como root: sudo $0 ${iso_path} ${usb_disk}"
  exit 1
fi

if ! lsblk -dn -o TYPE "${usb_disk}" | grep -qx "disk"; then
  echo "O alvo precisa ser um disco inteiro (ex.: /dev/sdb), nao particao."
  exit 1
fi

echo "ISO: ${iso_path}"
echo "Destino: ${usb_disk}"
lsblk -o NAME,SIZE,TYPE,MODEL "${usb_disk}"
echo
read -r -p "ATENCAO: todos os dados em ${usb_disk} serao apagados. Continuar? [YES]: " confirm
if [[ "${confirm}" != "YES" ]]; then
  echo "Cancelado."
  exit 0
fi

for p in $(lsblk -ln -o NAME "${usb_disk}" | tail -n +2); do
  umount "/dev/${p}" 2>/dev/null || true
done

echo "Gravando imagem..."
dd if="${iso_path}" of="${usb_disk}" bs=4M status=progress conv=fsync oflag=direct
sync

echo "Concluido. Pendrive bootavel criado em ${usb_disk}."
