# Changelog

All notable changes to **Zufallswerk** are documented in this file.

---

## [2.0.0] — 2026-08-24

### 🚀 Major Rework

Zufallswerk 2.0 introduces a completely reworked GTK-based graphical interface,
a cleaner internal project structure and expanded password and passphrase
generation capabilities.

### ✨ Added

- 🖥️ New native GTK-based graphical user interface
- 🔐 Separate password generation window
- 🎲 Separate passphrase generation window
- 🎛️ Configurable character sets for password generation
- 📏 Password length selection from **4–256 characters**
- 📋 Automatic clipboard copying of generated passwords and passphrases
- 🧩 Random character-block passphrase generation
- 📚 Bundled German word list with **7,776 words**
- 🔢 Configurable word count from **2–36 words**
- 🧩 Configurable character-block generation:
  - **2–12 blocks**
  - **2–12 characters per block**
  - Custom separator
  - Letters and numbers
- 📊 Entropy calculation for passwords and passphrases
- 💪 Password and passphrase strength classification
- 🌍 German and English interface
- 💾 Persistent language settings
- 🌙 GTK theme support for dark and light desktop environments
- ℹ️ Native GTK About dialog
- 🌐 Website, GitHub and support links
- 🖼️ Application icon integration
- 📦 Debian package generation
- 🔢 Central version management through the `VERSION` file
- 🔍 Automatic resource discovery for development and installed systems
- 💾 Project backup script

### 🛡️ Security

- Password and character-block generation use the Linux system random
  source `/dev/urandom`
- Random character selection uses rejection sampling to avoid modulo bias
- Passwords and passphrases are generated locally
- No online service is required for generation
- The German word-based passphrase mode uses the bundled **7,776-word**
  dictionary

### 🖥️ GUI

- Reworked main application window
- Separate password and passphrase generation workflows
- Dedicated settings dialog
- Live German/English interface switching
- Improved result display
- Entropy and strength information shown with generated results
- Native About dialog with version and project information
- GTK stylesheet support
- Improved handling of long generated passwords

### 📦 Packaging

- Added Debian package generation through `build-deb.sh`
- Application installed to `/usr/bin/zufallswerk`
- GTK stylesheet installed to `/usr/share/zufallswerk/style.css`
- German word list installed to `/usr/share/zufallswerk/words/words_de.txt`
- Application icon installed to the standard hicolor icon directory
- Added `.desktop` launcher
- Added Debian package metadata and runtime dependency
- Debian package successfully built and tested on **Debian 13 (Trixie)**

### 🧹 Improvements

- Centralized application version handling
- Improved German word-list handling
- Improved random number generation
- Improved error handling for missing or empty word lists
- Cleaner source structure
- Separated application logic into dedicated Haskell modules
- Updated project documentation
- Updated screenshots

---

## [0.3.0] — 2026-08-18

### 🚀 Major Rework

Version 0.3.0 is a major overhaul of Zufallswerk, introducing a cleaner
application structure, improved generation features and a more polished
Linux desktop experience.

### ✨ Added

- 🔐 Configurable password generation with selectable character sets:
  - Lowercase letters
  - Uppercase letters
  - Numbers
  - Special characters
- 📏 Password lengths from **1 to 256 characters**
- 🇩🇪 German passphrase generation
- 📚 Bundled German word list with **7,776 words**
- 🔢 Configurable number of words for passphrases
- 📊 Entropy calculation for passwords and passphrases
- 💪 Password and passphrase strength classification
- 📋 Automatic clipboard integration using `xclip`
- ℹ️ New About dialog
- 🌐 Website, GitHub and development support links
- 🖼️ Application icon integration
- 📦 Debian package support
- 🔢 Central version management through the `VERSION` file
- 🔍 Automatic word-list discovery for development and installed systems

### 🛡️ Security

- Password generation uses the Linux system random source `/dev/urandom`
- Passwords and passphrases are generated locally
- No online service is required for generation

### 🖥️ GUI

- Reworked YAD-based graphical interface
- Separate password and passphrase generation workflows
- Improved navigation with Generate, Back, Continue and Exit actions
- Improved result dialogs
- Entropy and strength information shown with generated results
- Improved About dialog layout and positioning

### 📦 Packaging

- Added Debian package generation through `build-deb.sh`
- Application installed to `/usr/bin/zufallswerk`
- German word list installed to `/usr/share/zufallswerk/words/words_de.txt`
- Application icon installed to the standard hicolor icon directory
- Added `.desktop` launcher
- Added Debian package metadata and dependencies

### 🧹 Improvements

- Centralized application version handling
- Improved German word-list handling
- Improved error handling for missing or empty word lists
- Cleaner source structure
- Updated project documentation
- Added modern screenshots
- Updated README with installation, project and Haskell information

---

## [0.2.0]

### Added

- Initial graphical password generator functionality
- Password generation using `/dev/urandom`
- Basic YAD interface
- Clipboard support
- Password strength information
- Initial Debian/Linux support

---

## [0.1.0]

### 🎉 Initial Release

- First development version of Zufallswerk
- Basic password generation
- Initial Haskell implementation
- Linux-focused application workflow

---

## Versioning

The current application version is maintained centrally in:

```text
VERSION
```

This version is used by the application and can also be used by the Debian
packaging process.

---

<div align="center">

**Zufallswerk · Haskell · Linux · Open Source**

</div>
