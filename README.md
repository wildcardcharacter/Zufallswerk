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

**Language:** English · [Deutsch](README.de.md)

<p align="center">
  <img src="https://img.shields.io/badge/version-2.1.0-2ea44f?style=for-the-badge">
  <img src="https://img.shields.io/badge/platform-Linux-333333?style=for-the-badge&logo=linux">
  <img src="https://img.shields.io/badge/Debian-13-A81D33?style=for-the-badge&logo=debian">
  <img src="https://img.shields.io/badge/Haskell-5e5086?style=for-the-badge&logo=haskell">
  <img src="https://img.shields.io/badge/GTK-3-4A86CF?style=for-the-badge&logo=gtk">
  <img src="https://img.shields.io/badge/license-MIT-green?style=for-the-badge">
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

#### 🌍 Word-based passphrases

Choose between two bundled Diceware-style word lists, each containing
**7,776 words**: German or the English EFF Large Wordlist. The selected list
is remembered for the next launch.

Example:

```text
pracht-crashtest-anziehen-entgangen
```

The number of words can be configured from **2–36**.

The separator can also be customized.

The English list is provided by the [Electronic Frontier Foundation](https://www.eff.org/dice)
and is distributed under [CC BY 3.0 US](https://creativecommons.org/licenses/by/3.0/us/).
Attribution and source details are included in the Debian package.

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

Entropy is a theoretical estimate. Password calculations assume uniform,
independent choices from the selected character set; word passphrases sample
from the list with replacement. It does not assess user behavior or constitute
an independent security audit.

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
Clipboard errors are shown in the window. Clipboard integration uses `wl-copy` on Wayland and `xclip` on
X11; the matching `wl-clipboard` or `xclip` package is required.

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
  <img src="assets/screenshots/password.png"
       width="700"
       alt="Zufallswerk password generator">
</p>

### Word-based Passphrases

<p align="center">
  <img src="assets/screenshots/passphrase.png"
       width="600"
       alt="Zufallswerk passphrase generator">
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
- `wl-clipboard` on Wayland or `xclip` on X11 for clipboard integration

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

This creates a package for the current system architecture, for example:

```text
zufallswerk_2.1.0_amd64.deb
```

Install the package with:

```bash
sudo apt install ./zufallswerk_2.1.0_amd64.deb
```

The package includes the application, desktop entry, icon, GTK stylesheet and
both word lists: `words_de.txt` and the English EFF list `words_en_eff.txt`.
They are installed under `/usr/share/zufallswerk/words/`. The EFF list's
license and attribution are included in the package documentation. Push a
version tag such as `v2.1.0` to build a Debian package and create or update a
GitHub Release automatically.

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
│   │   ├── about.png
│   │   ├── main-window.png
│   │   ├── passphrase.png
│   │   └── password.png
│   └── words/
│       ├── words_de.txt
│       └── words_en_eff.txt
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
├── .github/workflows/
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

**Zufallswerk 2.1.0** is the current version.

The 2.1 release includes:

- 🖥️ Modern GTK interface
- 🔐 Password generation
- 🎲 Word-based passphrases
- 🧩 Random character-block passphrases
- 📊 Entropy calculation
- 💪 Strength classification
- 📋 Clipboard integration
- 🌍 German / English interface
- 💾 Persistent language settings
- 💾 Remembered password length and passphrase mode
- 🇩🇪 German and English word lists
- 🖥️ Wayland and X11 clipboard support
- 🌙 GTK theme support
- ℹ️ Native About dialog
- ⚙️ Settings
- 📦 Debian package

The Debian package is built for the current system architecture. GitHub
Actions creates or updates a release when a matching `v2.1.0` tag is pushed.

---

## 🤝 Contributing

Suggestions, bug reports and improvements are welcome.

If you find a problem or have an idea for improving Zufallswerk, feel
free to open an issue or submit a pull request.

GitHub Actions builds the application and runs core tests for pushes and pull
requests. Run both locally with `cabal build all` and `cabal test all`.

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
