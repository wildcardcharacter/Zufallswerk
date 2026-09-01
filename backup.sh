#!/bin/bash

PROJEKT="Zufallswerk"
QUELLE="$(pwd)"
BACKUP_DIR="$HOME/Backups/Zufallswerk"

mkdir -p "$BACKUP_DIR"

DATUM=$(date +"%Y-%m-%d_%H-%M-%S")
ARCHIV="$BACKUP_DIR/${PROJEKT}_${DATUM}.tar.gz"

tar \
    --exclude=".git" \
    --exclude="dist-newstyle" \
    --exclude="build" \
    --exclude="*.o" \
    --exclude="*.hi" \
    -czf "$ARCHIV" \
    -C "$(dirname "$QUELLE")" \
    "$PROJEKT"

if [ $? -eq 0 ]; then
    echo "✅ Backup erfolgreich erstellt:"
    echo "$ARCHIV"
else
    echo "❌ Backup fehlgeschlagen."
    exit 1
fi
