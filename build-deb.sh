#!/usr/bin/env bash
set -e

APP_NAME="zufallswerk"
VERSION="$(cat VERSION)"
ARCH="amd64"
DEB_NAME="${APP_NAME}_${VERSION}_${ARCH}.deb"

echo "==> Build-Ordner vorbereiten"
rm -rf build
mkdir -p build

echo "==> Haskell-Projekt mit Cabal bauen"
cabal build

echo "==> Kompiliertes Programm ermitteln"
BIN_PATH="$(cabal list-bin zufallswerk)"

echo "==> Binary:"
echo "    ${BIN_PATH}"

cp "$BIN_PATH" "build/${APP_NAME}"

echo "==> Debian-Paketstruktur vorbereiten"

rm -rf packaging

mkdir -p packaging/DEBIAN
mkdir -p packaging/usr/bin
mkdir -p packaging/usr/share/applications
mkdir -p packaging/usr/share/icons/hicolor/256x256/apps
mkdir -p packaging/usr/share/zufallswerk/words

echo "==> Dateien kopieren"

cp "build/${APP_NAME}" \
   "packaging/usr/bin/${APP_NAME}"

cp "assets/logo/zufallswerk-256.png" \
   "packaging/usr/share/icons/hicolor/256x256/apps/zufallswerk.png"

cp "assets/words/words_de.txt" \
   "packaging/usr/share/zufallswerk/words/words_de.txt"

cp "data/style.css" \
   "packaging/usr/share/zufallswerk/style.css"

echo "==> Desktop-Datei erstellen"

cat > packaging/usr/share/applications/zufallswerk.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Zufallswerk
GenericName=Password Generator
Comment=Secure password and passphrase generator
Exec=/usr/bin/zufallswerk
Icon=zufallswerk
Terminal=false
Categories=Utility;Security;
Keywords=password;passphrase;generator;security;haskell;
StartupNotify=true
EOF

echo "==> Debian control-Datei erstellen"

cat > packaging/DEBIAN/control <<EOF
Package: ${APP_NAME}
Version: ${VERSION}
Section: utils
Priority: optional
Architecture: ${ARCH}
Maintainer: Markus <wildcardcharacter@icloud.com>
Depends: libgtk-3-0t64
Homepage: https://wildcardcharacter.github.io
Description: Secure password and passphrase generator
 Zufallswerk is a secure password and passphrase generator
 written in Haskell.
 .
 It supports customizable passwords, word-based passphrases,
 random character blocks, entropy calculation and password
 strength indicators.
EOF

echo "==> Dateirechte setzen"

chmod 755 packaging/usr/bin/${APP_NAME}

chmod 644 \
    packaging/usr/share/applications/zufallswerk.desktop

chmod 644 \
    packaging/usr/share/zufallswerk/style.css

chmod 644 \
    packaging/usr/share/zufallswerk/words/words_de.txt

chmod 644 \
    packaging/usr/share/icons/hicolor/256x256/apps/zufallswerk.png

chmod 755 packaging/DEBIAN

chmod 644 packaging/DEBIAN/control

echo "==> Debian-Paket bauen"

rm -f "${DEB_NAME}"

dpkg-deb --root-owner-group \
    --build packaging \
    "${DEB_NAME}"

echo ""
echo "========================================"
echo " Paket erfolgreich erstellt"
echo "========================================"
echo ""
echo " ${DEB_NAME}"
echo ""