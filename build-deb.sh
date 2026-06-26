#!/usr/bin/env bash
set -e

APP_NAME="zufallswerk"
VERSION="0.1"
ARCH="amd64"
DEB_NAME="${APP_NAME}_${VERSION}_${ARCH}.deb"

echo "==> Build-Ordner vorbereiten"
rm -rf build
mkdir -p build

echo "==> Haskell kompilieren"
ghc \
  -outputdir build \
  src/Main.hs \
  -O2 \
  -o build/${APP_NAME}

echo "==> Paketstruktur vorbereiten"
rm -rf packaging
mkdir -p packaging/DEBIAN
mkdir -p packaging/usr/bin
mkdir -p packaging/usr/share/applications
mkdir -p packaging/usr/share/icons/hicolor/256x256/apps

echo "==> Dateien kopieren"
cp build/${APP_NAME} packaging/usr/bin/
cp assets/zufallswerk.png packaging/usr/share/icons/hicolor/256x256/apps/

cat > packaging/usr/share/applications/zufallswerk.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Zufallswerk
GenericName=Password Generator
Comment=Secure password generator written in Haskell
Exec=/usr/bin/zufallswerk
Icon=zufallswerk
Terminal=false
Categories=Utility;System;
Keywords=password;generator;security;haskell;
StartupNotify=true
EOF

cat > packaging/DEBIAN/control <<EOF
Package: zufallswerk
Version: ${VERSION}
Section: utils
Priority: optional
Architecture: ${ARCH}
Maintainer: Markus <wildcardcharacter@icloud.com>
Depends: yad, xclip
Homepage: https://wildcardcharacter.github.io
Description: Secure password generator written in Haskell
 Zufallswerk generates secure passwords using /dev/urandom.
 It includes a graphical YAD interface, clipboard support,
 password strength indicator and configurable character sets.
EOF

echo "==> Rechte setzen"
chmod 755 packaging/DEBIAN
chmod 644 packaging/DEBIAN/control
chmod 755 packaging/usr/bin/${APP_NAME}

echo "==> Debian-Paket bauen"
dpkg-deb --root-owner-group --build packaging "${DEB_NAME}"

echo ""
echo "Fertig: ${DEB_NAME}"
