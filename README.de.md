# Zufallswerk

**Zufallswerk** ist ein lokaler Passwort- und Passphrasen-Generator für Linux.
Die Anwendung nutzt Haskell und GTK 3. [English documentation](README.md).

## Funktionen

- Passwörter mit 4 bis 256 Zeichen und wählbaren Zeichengruppen
- Wortpassphrasen mit 2 bis 36 Wörtern
- Deutsche oder englische Wortliste mit jeweils 7.776 Wörtern; die Auswahl bleibt gespeichert
- Zufällige Zeichenblöcke mit einstellbarer Anzahl und Länge
- Automatisches Kopieren in die Zwischenablage
- Deutsche und englische Oberfläche; Spracheinstellung bleibt erhalten
- Theoretische Entropieanzeige und Stärke-Klassifizierung

Die Entropie ist ein theoretischer Schätzwert. Bei Passwörtern wird eine
gleichverteilte, unabhängige Auswahl aus dem gewählten Zeichensatz angenommen.
Bei Wortpassphrasen wird mit Zurücklegen aus der Wortliste gezogen. Der Wert
bewertet weder Nutzergewohnheiten noch Implementierungsfehler und ersetzt
keine unabhängige Sicherheitsprüfung.

Die englische Liste stammt von der [Electronic Frontier Foundation](https://www.eff.org/dice)
und steht unter [CC BY 3.0 US](https://creativecommons.org/licenses/by/3.0/us/).
Beide Wortlisten sind im Debian-Paket enthalten: `words_de.txt` und die
englische EFF-Liste `words_en_eff.txt`. Installiert werden sie unter
`/usr/share/zufallswerk/words/`. Lizenz und Namensnennung der EFF-Liste liegen
ebenfalls der Paketdokumentation bei.

## Installation und Start

Das Debian-Paket wird im Projektordner mit `./build-deb.sh` erstellt und kann
anschließend mit `sudo apt install ./zufallswerk_2.1.0_amd64.deb` installiert
werden. Die Paketabhängigkeiten umfassen GTK 3 sowie `wl-clipboard` oder
`xclip` für die Zwischenablage. Unter Wayland wird `wl-copy`, unter X11
`xclip` verwendet.

Ein Versions-Tag wie `v2.1.0` baut automatisch ein Debian-Paket und erstellt
oder aktualisiert den passenden GitHub-Release.

Aus dem Quellcode bauen und starten:

```sh
cabal build
cabal run
```

Voraussetzungen sind Linux, GHC 9.6.x, Cabal und GTK-3-Entwicklungsdateien.
Entwickelt und getestet wird auf Debian 13 (Trixie).

## Tests und Mitarbeit

```sh
cabal test all
```

GitHub Actions baut das Projekt und führt die Core-Tests bei Pushes und Pull
Requests aus. Fehlerberichte und Verbesserungsvorschläge sind willkommen.

## Sicherheit

Zufallsdaten werden lokal aus `/dev/urandom` gelesen; Passwörter werden nicht
an einen Online-Dienst gesendet. Das Projekt wurde nicht unabhängig
sicherheitsüberprüft. Für Hochsicherheits- oder regulierte Umgebungen sollte
geeignet geprüfte Software verwendet werden.

Lizenz: MIT. Quellcode und Projektinformationen: [GitHub](https://github.com/wildcardcharacter/Zufallswerk).
