# Zufallswerk

Zufallswerk is a simple password generator written in Haskell for Linux.

## Features

* Secure random numbers generated from `/dev/urandom`
* Graphical user interface using YAD
* Custom password length
* Supports:

  * Lowercase letters
  * Uppercase letters
  * Numbers
  * Special characters

## Requirements

### Debian / Ubuntu

```bash
sudo apt install ghc yad
```

## Build

```bash
ghc Main.hs -O2 -o zufallswerk
```

## Run

```bash
./zufallswerk
```

## Planned Features

* Clipboard integration
* Password strength indicator
* Advanced character set options
* Custom application icon

## Author

GitHub: wildcardcharacter

## License

MIT License
