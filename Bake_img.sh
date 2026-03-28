#!/bin/bash
IMG_NAME="BillyOS.img"
ISO_PREPARE="iso_prepare"

# Aggiungi questo per fermare lo script se c'è un errore
set -e 

echo "=== Creazione Immagine Disco ($IMG_NAME) ==="
# Cancella se esiste già per evitare conflitti
rm -f "$IMG_NAME"

# Crea il file da 100MB
dd if=/dev/zero of="$IMG_NAME" bs=1M count=100

# Partizionamento
sudo parted -s "$IMG_NAME" mktable gpt
sudo parted -s "$IMG_NAME" mkpart primary fat32 2048s 100%
sudo parted -s "$IMG_NAME" set 1 esp on

# Loop device
LOOP_DEV=$(sudo losetup -Pf --show "$IMG_NAME")
# Attendi un secondo che il kernel veda la partizione
sleep 1

# Formattazione (usa la partizione p1 del loop trovato)
sudo mkfs.vfat -F 32 "${LOOP_DEV}p1"

# Montaggio e copia
sudo mount "${LOOP_DEV}p1" mnt_billy
sudo cp -rv "$ISO_PREPARE"/* mnt_billy/

# Chiusura
sync
sudo umount mnt_billy
sudo losetup -d "$LOOP_DEV"
echo "--- Immagine creata con successo! ---"
