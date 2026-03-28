#!/bin/bash
mkdir -p mnt_usb
sudo mount /dev/sdb1 mnt_usb

# Crea la struttura che ha fatto funzionare il boot prima
sudo mkdir -p mnt_usb/EFI/BOOT
sudo cp -v iso_prepare/billy-kernel.efi mnt_usb/EFI/BOOT/BOOTX64.EFI

# Copia i file che QEMU ha appena confermato essere 0.3
sudo cp -v iso_prepare/init.cpio mnt_usb/
sudo cp -v iso_prepare/startup.nsh m_usb/ 2>/dev/null || true

sync
sudo umount mnt_usb
