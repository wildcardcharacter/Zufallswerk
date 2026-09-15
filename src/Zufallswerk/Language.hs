module Zufallswerk.Language
    ( Sprache(..)
    , passphraseTitel
    , passphraseBeschreibung
    , passphraseModus
    , passphraseWoerter
    , passphraseZeichenbloecke
    , passphraseAnzahlWoerter
    , passphraseAnzahlBloecke
    , passphraseZeichenProBlock
    , passphraseTrennzeichen
    , passphraseGenerieren
    , passphraseSchliessen
    , passphraseWortlisteFehlt
    , passphraseWortlisteLeer
    , passphraseKopiert
    , passphraseEntropie
    , passphraseStaerke
    , staerkeText
    , passwortTitel
    , passwortBeschreibung
    , passwortLaenge
    , passwortZeichensatz
    , passwortKleinbuchstaben
    , passwortGrossbuchstaben
    , passwortZahlen
    , passwortSonderzeichen
    , passwortGenerieren
    , passwortSchliessen
    , passwortOptionFehlt
    , passwortOptionFehltStatus
    , passwortKopiert
    , passwortEntropie
    , passwortStaerke
    , mainTitel
    , mainUntertitel
    , mainFrage
    , mainBeschreibung
    , mainPasswort
    , mainPasswortBeschreibung
    , mainPassphrase
    , mainPassphraseBeschreibung
    , mainEinstellungen
    , mainUeber
    , mainBeenden
    , aboutTitel
    , aboutUntertitel
    , aboutEntropieTitel
    , aboutEntropieText
    , aboutCopyright
    , aboutWebsite
    , aboutGitHub
    , aboutSupport
    , aboutLicense
    , aboutOk
    , einstellungenTitel
    , einstellungenSprache
    , einstellungenDeutsch
    , einstellungenEnglish
    , einstellungenSchliessen
    ) where


data Sprache
    = Deutsch
    | English
    deriving (Eq, Show)

-- =========================================================
-- Passphrase
-- =========================================================

passphraseTitel :: Sprache -> String
passphraseTitel Deutsch = "💬  Passphrase generieren"
passphraseTitel English = "💬  Generate Passphrase"


passphraseBeschreibung :: Sprache -> String
passphraseBeschreibung Deutsch =
    "Erstelle eine sichere Passphrase."
passphraseBeschreibung English =
    "Create a secure passphrase."


passphraseModus :: Sprache -> String
passphraseModus Deutsch = "Passphrase-Modus"
passphraseModus English = "Passphrase Mode"


passphraseWoerter :: Sprache -> String
passphraseWoerter Deutsch = "Wörter"
passphraseWoerter English = "Words"


passphraseZeichenbloecke :: Sprache -> String
passphraseZeichenbloecke Deutsch = "Zufällige Zeichenblöcke"
passphraseZeichenbloecke English = "Random Character Blocks"


passphraseAnzahlWoerter :: Sprache -> String
passphraseAnzahlWoerter Deutsch = "Anzahl Wörter"
passphraseAnzahlWoerter English = "Number of Words"


passphraseAnzahlBloecke :: Sprache -> String
passphraseAnzahlBloecke Deutsch = "Anzahl Blöcke"
passphraseAnzahlBloecke English = "Number of Blocks"


passphraseZeichenProBlock :: Sprache -> String
passphraseZeichenProBlock Deutsch = "Zeichen pro Block"
passphraseZeichenProBlock English = "Characters per Block"


passphraseTrennzeichen :: Sprache -> String
passphraseTrennzeichen Deutsch = "Trennzeichen"
passphraseTrennzeichen English = "Separator"


passphraseGenerieren :: Sprache -> String
passphraseGenerieren Deutsch = "🔄 Passphrase generieren"
passphraseGenerieren English = "🔄 Generate Passphrase"


passphraseSchliessen :: Sprache -> String
passphraseSchliessen Deutsch = "Schließen"
passphraseSchliessen English = "Close"

passphraseWortlisteFehlt :: Sprache -> String
passphraseWortlisteFehlt Deutsch =
    "⚠️ Deutsche Wortliste wurde nicht gefunden."
passphraseWortlisteFehlt English =
    "⚠️ German word list was not found."


passphraseWortlisteLeer :: Sprache -> String
passphraseWortlisteLeer Deutsch =
    "⚠️ Die Wortliste ist leer."
passphraseWortlisteLeer English =
    "⚠️ The word list is empty."


passphraseKopiert :: Sprache -> String
passphraseKopiert Deutsch =
    "✅ Passphrase wurde in die Zwischenablage kopiert."
passphraseKopiert English =
    "✅ Passphrase copied to clipboard."

passphraseEntropie :: Sprache -> String
passphraseEntropie Deutsch = "📊 Entropie"
passphraseEntropie English = "📊 Entropy"

passphraseStaerke :: Sprache -> String
passphraseStaerke Deutsch = "💪 Stärke"
passphraseStaerke English = "💪 Strength"

staerkeText :: Sprache -> String -> String
staerkeText Deutsch text = text
staerkeText English text =
    case text of
        "Sehr schwach" -> "Very weak"
        "Schwach"      -> "Weak"
        "Mittel"       -> "Medium"
        "Stark"        -> "Strong"
        "Sehr stark"   -> "Very strong"
        _              -> text

-- =========================================================
-- Passwort
-- =========================================================

passwortTitel :: Sprache -> String
passwortTitel Deutsch = "🔐  Passwort generieren"
passwortTitel English = "🔐  Generate Password"


passwortBeschreibung :: Sprache -> String
passwortBeschreibung Deutsch =
    "Erstelle ein sicheres Zufallspasswort."
passwortBeschreibung English =
    "Create a secure random password."


passwortLaenge :: Sprache -> String
passwortLaenge Deutsch = "Passwortlänge"
passwortLaenge English = "Password Length"


passwortZeichensatz :: Sprache -> String
passwortZeichensatz Deutsch = "Zeichensatz"
passwortZeichensatz English = "Character Set"


passwortKleinbuchstaben :: Sprache -> String
passwortKleinbuchstaben Deutsch = "Kleinbuchstaben (a-z)"
passwortKleinbuchstaben English = "Lowercase Letters (a-z)"


passwortGrossbuchstaben :: Sprache -> String
passwortGrossbuchstaben Deutsch = "Großbuchstaben (A-Z)"
passwortGrossbuchstaben English = "Uppercase Letters (A-Z)"


passwortZahlen :: Sprache -> String
passwortZahlen Deutsch = "Zahlen (0-9)"
passwortZahlen English = "Numbers (0-9)"


passwortSonderzeichen :: Sprache -> String
passwortSonderzeichen Deutsch =
    "Sonderzeichen (!@#$%&*-_?)"
passwortSonderzeichen English =
    "Special Characters (!@#$%&*-_?)"


passwortGenerieren :: Sprache -> String
passwortGenerieren Deutsch = "🔄 Passwort generieren"
passwortGenerieren English = "🔄 Generate Password"


passwortSchliessen :: Sprache -> String
passwortSchliessen Deutsch = "Schließen"
passwortSchliessen English = "Close"


passwortOptionFehlt :: Sprache -> String
passwortOptionFehlt Deutsch =
    "Bitte mindestens eine Option auswählen."
passwortOptionFehlt English =
    "Please select at least one option."


passwortOptionFehltStatus :: Sprache -> String
passwortOptionFehltStatus Deutsch =
    "⚠️ Bitte mindestens eine Option auswählen."
passwortOptionFehltStatus English =
    "⚠️ Please select at least one option."


passwortKopiert :: Sprache -> String
passwortKopiert Deutsch =
    "✅ Passwort wurde in die Zwischenablage kopiert."
passwortKopiert English =
    "✅ Password copied to clipboard."


passwortEntropie :: Sprache -> Double -> String
passwortEntropie Deutsch entropie =
    "📊 Entropie: " ++ show (round entropie :: Int) ++ " Bit"
passwortEntropie English entropie =
    "📊 Entropy: " ++ show (round entropie :: Int) ++ " bits"


passwortStaerke :: Sprache -> String -> String
passwortStaerke Deutsch staerke =
    "💪 Stärke: " ++ staerke
passwortStaerke English staerke =
    "💪 Strength: " ++ staerke

-- =========================================================
-- Main-Fenster
-- =========================================================

mainTitel :: Sprache -> String
mainTitel Deutsch = "Zufallswerk"
mainTitel English = "Zufallswerk"


mainUntertitel :: Sprache -> String
mainUntertitel Deutsch = "Sichere Passwörter & Passphrasen"
mainUntertitel English = "Secure Passwords & Passphrases"


mainFrage :: Sprache -> String
mainFrage Deutsch = "Was möchtest du erzeugen?"
mainFrage English = "What would you like to generate?"


mainBeschreibung :: Sprache -> String
mainBeschreibung Deutsch = "Wähle eine sichere Generierungsart."
mainBeschreibung English = "Choose a secure generation method."


mainPasswort :: Sprache -> String
mainPasswort Deutsch = "Passwort"
mainPasswort English = "Password"


mainPasswortBeschreibung :: Sprache -> String
mainPasswortBeschreibung Deutsch =
    "Sicheres Zufallspasswort erzeugen"
mainPasswortBeschreibung English =
    "Generate a secure random password"


mainPassphrase :: Sprache -> String
mainPassphrase Deutsch = "Passphrase"
mainPassphrase English = "Passphrase"


mainPassphraseBeschreibung :: Sprache -> String
mainPassphraseBeschreibung Deutsch =
    "Sichere Passphrase erzeugen"
mainPassphraseBeschreibung English =
    "Generate a secure passphrase"


mainEinstellungen :: Sprache -> String
mainEinstellungen Deutsch = "⚙ Einstellungen"
mainEinstellungen English = "⚙ Settings"


mainUeber :: Sprache -> String
mainUeber Deutsch = "ℹ Über Zufallswerk"
mainUeber English = "ℹ About Zufallswerk"


mainBeenden :: Sprache -> String
mainBeenden Deutsch = "⏻ Beenden"
mainBeenden English = "⏻ Exit"

-- =========================================================
-- About
-- =========================================================

aboutTitel :: Sprache -> String
aboutTitel Deutsch = "Über Zufallswerk"
aboutTitel English = "About Zufallswerk"

aboutUntertitel :: Sprache -> String
aboutUntertitel Deutsch = "Secure Password Generator · Written in Haskell"
aboutUntertitel English = "Secure Password Generator · Written in Haskell"

aboutEntropieTitel :: Sprache -> String
aboutEntropieTitel Deutsch = "Was bedeutet Entropie?"
aboutEntropieTitel English = "What is entropy?"

aboutEntropieText :: Sprache -> String
aboutEntropieText Deutsch =
    "Die Entropie beschreibt den theoretischen Suchraum.\n\n\
    \Je höher der Wert, desto mehr Kombinationen sind möglich.\n\n\
    \Eine hohe Entropie bedeutet, dass ein Passwort schwerer durch Ausprobieren zu erraten ist."

aboutEntropieText English =
    "Entropy describes the theoretical search space.\n\n\
    \The higher the value, the more possible combinations there are.\n\n\
    \Higher entropy means that a password is harder to guess by trying possible combinations."

aboutCopyright :: Sprache -> String
aboutCopyright Deutsch = "© 2026 Markus"
aboutCopyright English = "© 2026 Markus"

aboutWebsite :: Sprache -> String
aboutWebsite Deutsch = "🌐 Website"
aboutWebsite English = "🌐 Website"

aboutGitHub :: Sprache -> String
aboutGitHub Deutsch = "💻 GitHub"
aboutGitHub English = "💻 GitHub"

aboutSupport :: Sprache -> String
aboutSupport Deutsch = "☕ Support"
aboutSupport English = "☕ Support"

aboutLicense :: Sprache -> String
aboutLicense Deutsch = "MIT License"
aboutLicense English = "MIT License"

aboutOk :: Sprache -> String
aboutOk Deutsch = "OK"
aboutOk English = "OK"

-- =========================================================
-- Einstellungen
-- =========================================================

einstellungenTitel :: Sprache -> String
einstellungenTitel Deutsch = "⚙ Einstellungen"
einstellungenTitel English = "⚙ Settings"


einstellungenSprache :: Sprache -> String
einstellungenSprache Deutsch = "Sprache"
einstellungenSprache English = "Language"


einstellungenDeutsch :: Sprache -> String
einstellungenDeutsch Deutsch = "Deutsch"
einstellungenDeutsch English = "German"


einstellungenEnglish :: Sprache -> String
einstellungenEnglish Deutsch = "English"
einstellungenEnglish English = "English"


einstellungenSchliessen :: Sprache -> String
einstellungenSchliessen Deutsch = "Schließen"
einstellungenSchliessen English = "Close"