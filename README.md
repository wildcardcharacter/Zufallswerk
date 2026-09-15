<p align="center">
  <img src="assets/logo/zufallswerk-256.png" width="160" alt="Zufallswerk Logo">
</p>

<h1 align="center">🔐 Zufallswerk</h1>

<p align="center">
  <strong>A modern password & passphrase generator for Linux</strong>
</p>

<p align="center">
  <strong>Secure · Lightweight · Open Source · Haskell · GTK</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/version-2.0.0-2ea44f?style=for-the-badge">
  <img src="https://img.shields.io/badge/platform-Linux-333333?style=for-the-badge&logo=linux">
  <img src="https://img.shields.io/badge/Debian-13-A81D33?style=for-the-badge&logo=debian">
  <img src="https://img.shields.io/badge/Haskell-5e5086?style=for-the-badge&logo=haskell">
  <img src="https://img.shields.io/badge/GTK-3-4A86CF?style=for-the-badge&logo=gtk">
  <img src="https://img.shields.io/badge/license-MIT-green?style=for-the-badge">
</p>

<p align="center">
  <a href="#features">Features</a> ·
  <a href="#screenshots">Screenshots</a> ·
  <a href="#requirements">Requirements</a> ·
  <a href="#building-from-source">Build</a> ·
  <a href="#debian-package">Debian Package</a> ·
  <a href="#security">Security</a>
</p>

---

## ✨ About

**Zufallswerk** is a lightweight password and passphrase generator for
Linux, written in **Haskell** with a native **GTK-based graphical
interface**.

The goal is simple:

> **Generate secure passwords and memorable passphrases without
> unnecessary complexity.**

Zufallswerk runs locally on the Linux desktop and does not require an
online service to generate passwords or passphrases.

---

## 🚀 Features

### 🔐 Password Generator

Create random passwords with a configurable length of **4–256
characters**.

Choose the character sets to use:

- Lowercase letters (`a-z`)
- Uppercase letters (`A-Z`)
- Numbers (`0-9`)
- Special characters

Generated passwords are automatically copied to the clipboard.

---

### 🎲 Passphrase Generator

Zufallswerk provides two different passphrase methods.

#### 🇩🇪 Word-based passphrases

Generate passphrases from a bundled German word list containing
**7,776 words**.

Example:

```text
pracht-crashtest-anziehen-entgangen
```

The number of words can be configured from **2–36**.

The separator can also be customized.

#### 🧩 Random character blocks

Generate passphrases from random alphanumeric character blocks.

Example:

```text
Ct4v-s2pG-wUvP
```

Available settings:

- **2–12 blocks**
- **2–12 characters per block**
- Custom separator
- `a-z`, `A-Z` and `0-9`

This mode does not require the word list.

---

### 📊 Entropy & Strength

Zufallswerk calculates the theoretical entropy of generated passwords
and passphrases.

The result is accompanied by a simple strength classification:

```text
Very weak
Weak
Medium
Strong
Very strong
```

For example:

```text
📊 Entropy: 1580 Bit
💪 Strength: Very strong
```

---

### 🌍 German & English UI

The interface supports:

- 🇩🇪 German
- 🇬🇧 English

The language can be changed directly in **Settings** and is stored for
future launches.

The selected language is applied to the main window, generators,
dialogs, status messages, entropy labels and strength classifications.

---

### 🌙 Dark Mode

The interface follows the GTK desktop theme, allowing Zufallswerk to
integrate naturally with dark and light Linux desktop environments.

---

### 📋 Clipboard Integration

Generated passwords and passphrases are automatically copied to the
clipboard so they can be used immediately.

---

### ⚙️ Settings

The application includes a simple settings dialog for changing the
interface language.

The selected language is stored in the user's configuration directory
and restored on the next launch.

---

### ℹ️ Native About Dialog

The application includes a dedicated About dialog with:

- Version information
- Entropy explanation
- Project links
- License information

---

## 🖼️ Screenshots

### Main Window

<p align="center">
  <img src="assets/screenshots/main-window.png"
       width="700"
       alt="Zufallswerk main window">
</p>

### Password Generator

<p align="center">
  <img src="assets/screenshots/password-weak.png"
       width="600"
       alt="Zufallswerk password generator with weak password">
</p>

<p align="center">
  <img src="assets/screenshots/password-medium.png"
       width="600"
       alt="Zufallswerk password generator with medium password">
</p>

<p align="center">
  <img src="assets/screenshots/password-strong.png"
       width="700"
       alt="Zufallswerk password generator with strong password">
</p>

### Word-based Passphrases

<p align="center">
  <img src="assets/screenshots/passphrase-weak.png"
       width="600"
       alt="Zufallswerk weak word-based passphrase">
</p>

<p align="center">
  <img src="assets/screenshots/passphrase-medium.png"
       width="600"
       alt="Zufallswerk medium word-based passphrase">
</p>

<p align="center">
  <img src="assets/screenshots/passphrase-strong.png"
       width="600"
       alt="Zufallswerk strong word-based passphrase">
</p>

### Random Character Blocks

Zufallswerk also provides a character-block mode for generating random
alphanumeric passphrases.

<p align="center">
  <img src="assets/screenshots/sketchpads-weak.png"
       width="600"
       alt="Zufallswerk random character blocks with weak strength">
</p>

<p align="center">
  <img src="assets/screenshots/sketchpads-medium.png"
       width="600"
       alt="Zufallswerk random character blocks with medium strength">
</p>

<p align="center">
  <img src="assets/screenshots/sketchpads-strong.png"
       width="600"
       alt="Zufallswerk random character blocks with strong strength">
</p>

### Settings

<p align="center">
  <img src="assets/screenshots/Settings.png"
       width="500"
       alt="Zufallswerk settings">
</p>

### About

<p align="center">
  <img src="assets/screenshots/about.png"
       width="600"
       alt="About Zufallswerk">
</p>

---

## 🛡️ Security

Zufallswerk obtains random data from the Linux system random source:

```text
/dev/urandom
```

Password and random character-block generation are performed locally on
the user's machine.

No generated password or passphrase is sent to an online service.

### Important

Zufallswerk is an open-source personal project and has **not undergone
an independent security audit**.

For highly sensitive, regulated or high-assurance environments, use
software that has undergone an appropriate security review.

---

## 🧰 Requirements

For building Zufallswerk from source, you need:

- Linux
- GHC 9.6.x
- Cabal
- GTK development libraries

The project is developed and tested on **Debian 13 (Trixie)**.

---

## 🔨 Building from Source

Clone the repository:

```bash
git clone https://github.com/wildcardcharacter/Zufallswerk.git
cd Zufallswerk
```

Build with Cabal:

```bash
cabal build
```

Run the application:

```bash
cabal run
```

---

## 📦 Debian Package

A Debian package can be built directly from the project:

```bash
./build-deb.sh
```

This creates:

```text
zufallswerk_2.0.0_amd64.deb
```

Install the package with:

```bash
sudo apt install ./zufallswerk_2.0.0_amd64.deb
```

The package includes the application, desktop entry, icon,
GTK stylesheet and German word list.

The Debian package has been successfully built, installed and tested
on **Debian 13 (Trixie)**.

---

## 📁 Project Structure

```text
Zufallswerk/
├── app/
│   └── Main.hs
├── assets/
│   ├── logo/
│   │   └── zufallswerk-256.png
│   ├── screenshots/
│   └── words/
│       └── words_de.txt
├── data/
│   └── style.css
├── packaging/
│   └── DEBIAN/
├── src/
│   └── Zufallswerk/
│       ├── Core.hs
│       ├── Language.hs
│       ├── Passphrase.hs
│       ├── Password.hs
│       └── Settings.hs
├── backup.sh
├── build-deb.sh
├── CHANGELOG.md
├── LICENSE
├── README.md
├── VERSION
├── .gitignore
└── zufallswerk.cabal
```

---

## 🟣 Why Haskell?

Zufallswerk is a practical exploration of **Haskell for Linux desktop
software**.

Haskell is used for:

- Strong static typing
- Functional programming
- Clear separation of application logic
- Password and passphrase generation
- Entropy calculations
- Language handling
- GTK application control

The project is split into small modules so that the individual
responsibilities remain easy to understand.

---

## 🧩 Technology

| Component | Technology |
|-----------|------------|
| Language | Haskell |
| Compiler | GHC 9.6.x |
| Build system | Cabal |
| GUI | GTK 3 |
| Platform | Linux |
| Tested on | Debian 13 (Trixie) |
| Random source | `/dev/urandom` |
| License | MIT |

---

## 📌 Development Status

**Zufallswerk 2.0.0** is the current major version.

The 2.0 release includes:

- 🖥️ Modern GTK interface
- 🔐 Password generation
- 🎲 Word-based passphrases
- 🧩 Random character-block passphrases
- 📊 Entropy calculation
- 💪 Strength classification
- 📋 Clipboard integration
- 🌍 German / English interface
- 💾 Persistent language settings
- 🌙 GTK theme support
- ℹ️ Native About dialog
- ⚙️ Settings
- 📦 Debian package

The 2.0.0 release has been built, installed and tested on
**Debian 13 (Trixie)**.

---

## 🤝 Contributing

Suggestions, bug reports and improvements are welcome.

If you find a problem or have an idea for improving Zufallswerk, feel
free to open an issue or submit a pull request.

---

## 📄 License

Zufallswerk is released under the **MIT License**.

See [`LICENSE`](LICENSE) for the complete license text.

---

## 🔗 Links

- 🌐 **Website:** https://wildcardcharacter.github.io
- 💻 **GitHub:** https://github.com/wildcardcharacter/Zufallswerk
- ☕ **Support:** https://buymeacoffee.com/wildcardcharacter

---

<p align="center">

### 🔐 Zufallswerk

**Secure passwords. Memorable passphrases. No unnecessary complexity.**

Made with ❤️ and Haskell on Linux 🐧

© 2026 Markus

</p>
