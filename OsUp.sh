#!/bin/bash

# 1. Pulizia totale
echo "--- 🧹 Pulizia in corso... ---"
sudo umount -l mnt_billy 2>/dev/null || true
sudo losetup -D

# 2. Creazione immagine
echo "--- 💾 Creazione immagine BillyOS.img ---"
dd if=/dev/zero of=BillyOS.img bs=1M count=100

# 3. Partizionamento (con SUDO e modalità SCRIPT)
echo "--- 🏗️ Partizionamento GPT ---"
sudo parted --script BillyOS.img mklabel gpt
sudo parted --script BillyOS.img mkpart primary fat32 1MiB 100%
sudo parted --script BillyOS.img set 1 esp on

# 4. Collegamento Loop Device
echo "--- 🔗 Collegamento Loop Device ---"
LOOP_DEV=$(sudo losetup -fP --show $(pwd)/BillyOS.img)
sleep 1 # Attesa vitale per far apparire /dev/loopXp1

# 5. Formattazione (Usiamo la partizione p1 creata da parted)
echo "--- ✨ Formattazione partizione... ---"
sudo mkfs.vfat -F 32 "${LOOP_DEV}p1"

# 6. Mount e Copia
mkdir -p mnt_billy
sudo mount "${LOOP_DEV}p1" mnt_billy

sudo mkdir -p mnt_billy/EFI/BOOT

sudo cp -v iso_prepare/billy-kernel.efi mnt_billy/EFI/BOOT/BOOTX64.EFI
sudo cp -v iso_prepare/init.cpio mnt_billy/
sudo cp -v iso_prepare/startup.nsh mnt_billy/

# 7. Sincronizzazione e smontaggio
echo "--- 🏁 Chiusura e salvataggio... ---"
sync
sleep 1
sudo umount mnt_billy
sudo losetup -d "$LOOP_DEV"

echo "✅ BillyOS.img è FINALMENTE pronto!"
