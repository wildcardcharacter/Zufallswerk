# Zufallswerk

Zufallswerk is a simple and secure password generator written in Haskell for Linux.

It uses `/dev/urandom` as a source of randomness and provides a lightweight graphical user interface based on YAD.

## Features

* Secure random password generation using `/dev/urandom`
* Graphical user interface with YAD
* Custom password length
* Automatic clipboard integration via `xclip`
* Generate multiple passwords without restarting the application
* Select which character sets to use:

  * Lowercase letters
  * Uppercase letters
  * Numbers
  * Special characters
* Validation to ensure at least one character set is selected

## Requirements

### Debian / Ubuntu

```bash
sudo apt install ghc yad xclip
```

## Build

```bash
ghc Main.hs -O2 -o zufallswerk
```

## Run

```bash
./zufallswerk
```

## Screenshots

Coming soon.

## Roadmap

* Password strength indicator
* Custom application icon
* XFCE desktop launcher
* Debian package (.deb)
* Additional customization options

## Author

GitHub: wildcardcharacter

## License

MIT License
