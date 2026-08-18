# Changelog

All notable changes to **Zufallswerk** are documented in this file.

---

## [0.3.0] — 2026-08-18

### 🚀 Major Rework

Version 0.3.0 is a major overhaul of Zufallswerk, introducing a cleaner application structure, improved generation features and a more polished Linux desktop experience.

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

This version is used by the application and can also be used by the Debian packaging process.

---

<div align="center">

**Zufallswerk · Haskell · Linux · Open Source**

</div>
