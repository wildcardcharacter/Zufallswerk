# Zufallswerk

<p align="center">
  <img src="assets/logo/zufallswerk-256.png" width="140" alt="Zufallswerk Logo">
</p>

<p align="center">
**A simple and secure password generator for Linux written in Haskell.**
</p>

<p align="center">
![Version](https://img.shields.io/badge/version-0.2.0--dev-blue)
![Platform](https://img.shields.io/badge/platform-Linux-orange)
![Debian](https://img.shields.io/badge/Debian-13-A81D33?logo=debian)
![Language](https://img.shields.io/badge/language-Haskell-5D4F85?logo=haskell)
![License](https://img.shields.io/badge/license-MIT-green)
![Status](https://img.shields.io/badge/status-Development-yellow)
</p>

<p align="center">
Secure • Lightweight • Open Source • Debian • XFCE
</p>

---

## Features

* Secure random password generation using `/dev/urandom`
* Lightweight graphical user interface powered by **YAD**
* Configurable password length
* Selectable character sets
* Automatic clipboard integration via **xclip**
* Password strength indicator
* About dialog
* XFCE application menu integration
* Debian package builder (`build-deb.sh`)
* Open Source (MIT License)

---

## Language

> **Current Status**
>
> The graphical user interface is currently available **only in German**.
>
> 🇬🇧 English language support is planned for a future release.

---

## Screenshots

### Main Window

<p align="center">
  <img src="assets/screenshots/main-window.png" width="520" alt="Main Window">
</p>

### Password Strength

<p align="center">
  <img src="assets/screenshots/password-strong.png" width="520" alt="Strong Password">
</p>

<p align="center">
  <img src="assets/screenshots/password-medium.png" width="520" alt="Medium Password">
</p>

<p align="center">
  <img src="assets/screenshots/password-weak.png" width="520" alt="Weak Password">
</p>

### About

<p align="center">
  <img src="assets/screenshots/about.png" width="420" alt="About Dialog">
</p>

---

## Project Structure

```text
Zufallswerk/
├── src/
│   └── Main.hs
├── assets/
│   ├── logo/
│   └── screenshots/
├── build/
├── packaging/
├── README.md
├── CHANGELOG.md
├── LICENSE
├── .gitignore
└── build-deb.sh
```

---

## Requirements

### Debian / Ubuntu

```bash
sudo apt install ghc yad xclip
```

---

## Build

```bash
./build-deb.sh
```

---

## Run

```bash
./build/zufallswerk
```

---

## Debian Package

```bash
./build-deb.sh
sudo dpkg -i zufallswerk_0.1.0_amd64.deb
```

After installation, **Zufallswerk** is available from the XFCE application menu.

---

## Roadmap

* SVG application icon
* Password entropy (bits)
* Save user preferences
* English user interface
* Additional password options
* Improved About dialog
* Automatic GitHub Releases

---

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

---

## Author

**Markus Reichelt**

🌐 Website

https://wildcardcharacter.github.io

☕ Support development

https://buymeacoffee.com/wildcardcharacter

---

## License

This project is licensed under the **MIT License**.

See the [LICENSE](LICENSE) file for details.
