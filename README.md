# Zufallswerk

Zufallswerk is a simple and secure password generator written in Haskell for Linux.

## Features

* Secure random numbers generated from `/dev/urandom`
* Graphical user interface using YAD
* Custom password length
* Automatic clipboard support via `xclip`
* Generate multiple passwords without restarting the application
* Supports:

  * Lowercase letters
  * Uppercase letters
  * Numbers
  * Special characters

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

* Character set selection
* Password strength indicator
* Application icon
* Desktop launcher
* Debian package (.deb)

## Author

Markus

Website:

https://wildcardcharacter.github.io

Support development:

https://buymeacoffee.com/wildcardcharacter

## License

MIT License
