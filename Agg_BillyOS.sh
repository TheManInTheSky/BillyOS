#!/bin/bash

# --- CONFIGURAZIONE ---
PROJECT_DIR=$(pwd)
ROOTFS_DIR="$PROJECT_DIR/rootfs"
ISO_PREPARE="$PROJECT_DIR/iso_prepare"
KERNEL="$PROJECT_DIR/billy-kernel.efi"
IMG_NAME="BillyOS.img"
OVMF_PATH="/usr/share/edk2-ovmf/x64/OVMF.4m.fd" # Controlla questo percorso!

echo "=== 1. Pulizia Ambiente ==="
sudo umount "$PROJECT_DIR/mnt_billy" 2>/dev/null
sudo losetup -D
rm -f "$IMG_NAME" "$ISO_PREPARE/init.cpio"

echo "=== 2. Aggiornamento init.cpio (dal rootfs) ==="
cd "$ROOTFS_DIR"
# Trova tutti i file, usa il formato cpio e comprimi
find . | cpio -o -H newc | gzip > "$ISO_PREPARE/init.cpio"
cd "$PROJECT_DIR"

echo "=== 3. Preparazione iso_prepare ==="
# Assicuriamoci che il kernel sia aggiornato nella cartella di boot
cp "$KERNEL" "$ISO_PREPARE/billy-kernel.efi"
cp "$KERNEL" "$ISO_PREPARE/EFI/BOOT/BOOTX64.EFI"

echo "=== 4. Creazione Immagine Disco (.img) ==="
dd if=/dev/zero of="$IMG_NAME" bs=1M count=100 status=none
parted -s "$IMG_NAME" mktable gpt
parted -s "$IMG_NAME" mkpart primary fat32 1MiB 100%
parted -s "$IMG_NAME" set 1 esp on

# Usiamo mtools per copiare i file senza dover montare (più sicuro)
mformat -i "${IMG_NAME}@@1M" -F 32 ::
mcopy -i "${IMG_NAME}@@1M" -s "$ISO_PREPARE"/* ::

echo "=== 5. Test su QEMU ==="
read -p "Vuoi avviare QEMU per testare? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    qemu-system-x86_64 -m 512M \
        -drive if=pflash,format=raw,readonly=on,file="$OVMF_PATH" \
        -drive file="$IMG_NAME",format=raw \
        -net none
fi

echo "=== PROCESSO COMPLETATO ==="
