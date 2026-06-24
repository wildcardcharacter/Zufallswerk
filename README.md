<p align="center">
  <img src="zufallswerk.png" width="150">
</p>

<h1 align="center">Zufallswerk</h1>

<p align="center">
  A simple and secure password generator written in written in Haskell for Linux.
</p>

It uses `/dev/urandom` as a source of randomness and provides a lightweight graphical user interface based on YAD.

## Features

* Secure random password generation using `/dev/urandom` (CSPRNG)
* Lightweight graphical user interface powered by YAD
* Custom password length
* Automatic clipboard integration via `xclip`
* Generate multiple passwords without restarting the application
* Configurable character sets:

  * Lowercase letters
  * Uppercase letters
  * Numbers
  * Special characters
* Password strength indicator
* Input validation and error handling
* Prevents generation of passwords with an empty character set
* XFCE application menu integration

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

## Roadmap

* Custom application icon
* Debian package (.deb)
* Additional customization options

## Author

Markus

Website:
https://wildcardcharacter.github.io

Support development:
https://buymeacoffee.com/wildcardcharacter

## License

MIT License
