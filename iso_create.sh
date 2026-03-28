#!/bin/bash

# 1. Pulizia profonda: eliminiamo le schifezze
echo "Cleaning up iso_prepare..."
rm -f ~/BillyOS/iso_prepare/efiboot.img
rm -f ~/BillyOS/iso_prepare/NvVars
rm -f ~/BillyOS/iso_prepare/startup.nsh
# Se vuoi essere estremo, cancella tutto tranne il kernel, il cpio e i file di limine
# find ~/BillyOS/iso_prepare/ -type f ! -name 'billy-kernel.efi' ! -name 'init.cpio' ! -name 'limine*' -delete

# 2. Ricostruisci la ISO con i parametri corretti per Limine
echo "Building BillyOS.iso..."
xorriso -as mkisofs -R -J -b limine-bios-cd.bin \
        -no-emul-boot -boot-load-size 4 -boot-info-table \
        --efi-boot limine-uefi-cd.bin \
        -efi-boot-part --efi-boot-image --protective-msdos-label \
        ~/BillyOS/iso_prepare -o ~/BillyOS/BillyOS.iso

echo "Done! Ready for QEMU."
