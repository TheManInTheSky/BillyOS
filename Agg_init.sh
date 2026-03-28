#!/bin/bash
echo "--- 📦 TEST DI RIGENERAZIONE INIT ---"
# 1. Elimina il vecchio cpio (se non lo elimini, non sapremo mai se il nuovo è stato creato)
rm -f iso_prepare/init.cpio

# 2. Entra in rootfs e crea il pacchetto
# Usiamo 'find . | cpio' ma con il percorso completo
(cd rootfs && find . -print0 | cpio --null -ov -H newc | gzip -9 > ../iso_prepare/init.cpio)

# 3. VERIFICA REALE
if [ -f "iso_prepare/init.cpio" ]; then
    echo "✅ NUOVO init.cpio creato con successo!"
    echo "Contenuto test del nuovo init:"
    zcat iso_prepare/init.cpio | cpio -i --to-stdout ./init | grep "Versione"
else
    echo "❌ ERRORE: Il file init.cpio NON è stato generato. Controlla i permessi di rootfs."
    exit 1
fi
