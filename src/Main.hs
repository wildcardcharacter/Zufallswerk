import Control.Monad (filterM)
import qualified Data.ByteString as BS
import Data.Word
import System.Directory (doesFileExist)
import System.Exit
import System.IO
import System.Process
import Text.Read (readMaybe)

versionDatei :: FilePath
versionDatei = "VERSION"

ladeVersion :: IO String
ladeVersion = do
    inhalt <- readFile versionDatei
    return (head (lines inhalt))

klein, gross, zahlen, sonder :: String
klein  = ['a'..'z']
gross  = ['A'..'Z']
zahlen = ['0'..'9']
sonder = "!@#$%&*-_?"

appTitel :: String -> String
appTitel version = "Zufallswerk " ++ version

wortlistenPfade :: [FilePath]
wortlistenPfade =
    [ "assets/words/words_de.txt"
    , "/usr/share/zufallswerk/words/words_de.txt"
    ]

findeWortliste :: IO (Maybe FilePath)
findeWortliste = do
    vorhandene <- filterM doesFileExist wortlistenPfade
    return $
        case vorhandene of
            (pfad:_) -> Just pfad
            []       -> Nothing

data Generierungsmodus
    = PasswortModus
    | PassphraseModus
    deriving (Eq, Show)

splitPipe :: String -> [String]
splitPipe "" = []
splitPipe xs =
    let (a, rest) = break (== '|') xs
    in a : case rest of
        []     -> []
        (_:ys) -> splitPipe ys

baueZeichensatz :: String -> String -> String -> String -> String
baueZeichensatz k g z s =
    concat
        [ if k == "TRUE" then klein else ""
        , if g == "TRUE" then gross else ""
        , if z == "TRUE" then zahlen else ""
        , if s == "TRUE" then sonder else ""
        ]

byteZuZeichen :: String -> Word8 -> Char
byteZuZeichen zeichensatz b =
    zeichensatz !! (fromIntegral b `mod` length zeichensatz)

erzeugePasswort :: Int -> String -> IO String
erzeugePasswort laenge zeichensatz = do
    h <- openBinaryFile "/dev/urandom" ReadMode
    bytes <- BS.hGet h laenge
    hClose h
    return (map (byteZuZeichen zeichensatz) (BS.unpack bytes))

kopiereZwischenablage :: String -> IO ()
kopiereZwischenablage text = do
    (Just hin, _, _, _) <- createProcess
        (proc "xclip" ["-selection", "clipboard"])
            { std_in = CreatePipe }
    hPutStr hin text
    hClose hin

anzahlGruppen :: String -> Int
anzahlGruppen zeichensatz =
    length
        [ ()
        | gruppe <- [klein, gross, zahlen, sonder]
        , any (`elem` gruppe) zeichensatz
        ]

berechneEntropie :: Int -> Int -> Double
berechneEntropie laenge zeichensatzGroesse =
    fromIntegral laenge * logBase 2 (fromIntegral zeichensatzGroesse)

berechnePassphraseEntropie :: Int -> Int -> Double
berechnePassphraseEntropie anzahlWoerter wortlistenGroesse =
    fromIntegral anzahlWoerter * logBase 2 (fromIntegral wortlistenGroesse)

bewerteEntropie :: Double -> String
bewerteEntropie bits
    | bits < 40  = "Sehr schwach"
    | bits < 60  = "Schwach"
    | bits < 80  = "Mittel"
    | bits < 100 = "Stark"
    | otherwise = "Sehr stark"

fehler :: String -> IO ()
fehler text = do
    _ <- readProcessWithExitCode
        "yad"
        [ "--error"
        , "--title=Fehler"
        , "--text=" ++ text
        ]
        ""
    return ()

ladeWortliste :: FilePath -> IO [String]
ladeWortliste datei = do
    inhalt <- readFile datei
    return
        [ wort
        | zeile <- lines inhalt
        , let teile = words zeile
        , length teile >= 2
        , let wort = last teile
        ]

zufallsIndex :: Int -> IO Int
zufallsIndex maxWert = do
    if maxWert <= 0
    then error "Ungültige maximale Indexgröße."
    else do
        h <- openBinaryFile "/dev/urandom" ReadMode
        index <- leseIndex h
        hClose h
        return index

    where
        maxZufallswert = 65536 :: Int
        bereich = (maxZufallswert `div` maxWert) * maxWert

        leseIndex h = do
            bytes <- BS.hGet h 2

            if BS.length bytes /= 2
            then error "Konnte keine Zufallsdaten lesen."
            else do
                let high = fromIntegral (BS.index bytes 0) :: Int
                let low  = fromIntegral (BS.index bytes 1) :: Int
                let wert = high * 256 + low

                if wert < bereich
                then return (wert `mod` maxWert)
                else leseIndex h

erzeugePassphrase :: Int -> [String] -> String -> IO String
erzeugePassphrase anzahlWoerter wortliste trennzeichen = do
    woerter <- mapM
        (\_ -> do
            index <- zufallsIndex (length wortliste)
            return (wortliste !! index)
        )
        [1 .. anzahlWoerter]

    return (verbindeMit trennzeichen woerter)

verbindeMit :: String -> [String] -> String
verbindeMit _ [] = ""
verbindeMit trennzeichen (x:xs) =
    x ++ concatMap (trennzeichen ++) xs

zeigeErgebnis :: String -> String -> Double -> String -> String -> IO Bool
zeigeErgebnis text staerke entropie typ version = do
    (code, _, _) <- readProcessWithExitCode
        "yad"
        [ "--info"
        , "--no-markup"
        , "--title=" ++ appTitel version
        , "--width=520"
        , "--text=" ++ typ
            ++ " erzeugt und in die Zwischenablage kopiert:\n\n"
            ++ text
            ++ "\n\nStärke: "
            ++ staerke
            ++ "\nEntropie: "
            ++ show (round entropie)
            ++ " Bit"
        , "--button=Weiter:0"
        , "--button=Beenden:1"
        ]
        ""

    case code of
        ExitSuccess   -> return True
        ExitFailure _ -> return False

zeigeUeberDialog :: String -> IO ()
zeigeUeberDialog version = do
    _ <- readProcessWithExitCode
        "yad"
        [ "--info"
        , "--title=Über " ++ appTitel version
        , "--width=520"
        , "--center"
        , "--text=Zufallswerk " ++ version
            ++ "\nSecure Password Generator · Written in Haskell"
            ++ "\n\nWas bedeutet Entropie?"
            ++ "\nDie Entropie beschreibt den theoretischen Suchraum."
            ++ "\nJe höher der Wert, desto mehr Kombinationen sind möglich."
            ++ "\n\n80 Bit → 2^80   |   128 Bit → 2^128   |   1580 Bit → 2^1580"
            ++ "\n\n© 2026 Markus"
            ++ "\n<a href=\"https://wildcardcharacter.github.io\">🌐 Website</a>   <a href=\"https://github.com/wildcardcharacter/Zufallswerk\">💻 GitHub</a>"
            ++ "\n<a href=\"https://buymeacoffee.com/wildcardcharacter\">☕ Support development</a>"
            ++ "\n\nMIT License"
        , "--button=OK:0"
        ]
        ""
    return ()

zeigeModuswahl :: String -> IO (Maybe Generierungsmodus)
zeigeModuswahl version = do
    (code, eingabe, _) <- readProcessWithExitCode
        "yad"
        [ "--form"
        , "--title=" ++ appTitel version
        , "--width=420"
        , "--text=Was möchtest du erzeugen?"
        , "--field=Generierungsart:CB"
        , "Passwort!Passphrase (Deutsch)"
        , "--button=Weiter:0"
        , "--button=Über:2"
        , "--button=Beenden:1"
        ]
        ""

    case code of
        ExitFailure 2 -> do
            zeigeUeberDialog version
            zeigeModuswahl version

        ExitFailure _ ->
            return Nothing

        ExitSuccess ->
            case splitPipe eingabe of
                (modus:_) ->
                    if modus == "Passphrase (Deutsch)"
                    then return (Just PassphraseModus)
                    else return (Just PasswortModus)

                _ ->
                    return Nothing

zeigePasswortFenster :: String -> IO (Maybe (Int, String))
zeigePasswortFenster version = do
    (code, eingabe, _) <- readProcessWithExitCode
        "yad"
        [ "--form"
        , "--title=" ++ appTitel version ++ " – Passwort"
        , "--width=420"
        , "--field=Passwortlänge"
        , "20"
        , "--field=Kleinbuchstaben:CHK"
        , "TRUE"
        , "--field=Großbuchstaben:CHK"
        , "TRUE"
        , "--field=Zahlen:CHK"
        , "TRUE"
        , "--field=Sonderzeichen:CHK"
        , "TRUE"
        , "--button=Generieren:0"
        , "--button=Zurück:2"
        , "--button=Beenden:1"
        ]
        ""

    case code of
        ExitFailure 2 ->
            return Nothing

        ExitFailure _ ->
            return Nothing

        ExitSuccess ->
            case splitPipe eingabe of
                (laengeText:k:g:z:s:_) ->
                    case readMaybe laengeText :: Maybe Int of
                        Nothing -> do
                            fehler "Keine gültige Zahl."
                            zeigePasswortFenster version

                        Just laenge ->
                            if laenge < 1 || laenge > 256
                            then do
                                fehler "Bitte Länge zwischen 1 und 256 wählen."
                                zeigePasswortFenster version
                            else do
                                let zeichensatz = baueZeichensatz k g z s

                                if null zeichensatz
                                then do
                                    fehler "Bitte mindestens einen Zeichensatz auswählen."
                                    zeigePasswortFenster version
                                else
                                    return (Just (laenge, zeichensatz))

                _ -> do
                    fehler "Unerwartete Eingabe."
                    zeigePasswortFenster version

zeigePassphraseFenster :: String -> IO (Maybe Int)
zeigePassphraseFenster version = do
    (code, eingabe, _) <- readProcessWithExitCode
        "yad"
        [ "--form"
        , "--title=" ++ appTitel version ++ " – Passphrase"
        , "--width=420"
        , "--text=Deutsche Passphrase aus 7.776 Wörtern"
        , "--field=Anzahl Wörter"
        , "6"
        , "--button=Generieren:0"
        , "--button=Zurück:2"
        , "--button=Beenden:1"
        ]
        ""

    case code of
        ExitFailure 2 ->
            return Nothing

        ExitFailure _ ->
            return Nothing

        ExitSuccess ->
            case splitPipe eingabe of
                (worterText:_) ->
                    case readMaybe worterText :: Maybe Int of
                        Nothing -> do
                            fehler "Keine gültige Wortanzahl."
                            zeigePassphraseFenster version

                        Just anzahlWoerter ->
                            if anzahlWoerter < 3 || anzahlWoerter > 36
                            then do
                                fehler "Bitte zwischen 3 und 36 Wörter wählen."
                                zeigePassphraseFenster version
                            else
                                return (Just anzahlWoerter)

                _ -> do
                    fehler "Keine gültige Wortanzahl."
                    zeigePassphraseFenster version

programmSchleife :: String -> [String] -> IO ()
programmSchleife version wortliste = do
    modus <- zeigeModuswahl version

    case modus of
        Nothing ->
            return ()

        Just PasswortModus -> do
            auswahl <- zeigePasswortFenster version

            case auswahl of
                Nothing ->
                    programmSchleife version wortliste

                Just (laenge, zeichensatz) -> do
                    passwort <- erzeugePasswort laenge zeichensatz
                    kopiereZwischenablage passwort

                    let entropie =
                            berechneEntropie
                                laenge
                                (length zeichensatz)

                    let staerke =
                            bewerteEntropie entropie

                    weiter <-
                        zeigeErgebnis
                            passwort
                            staerke
                            entropie
                            "Passwort"
                            version

                    if weiter
                    then programmSchleife version wortliste
                    else return ()

        Just PassphraseModus -> do
            auswahl <- zeigePassphraseFenster version

            case auswahl of
                Nothing ->
                    programmSchleife version wortliste

                Just anzahlWoerter -> do
                    passphrase <-
                        erzeugePassphrase
                            anzahlWoerter
                            wortliste
                            "-"

                    kopiereZwischenablage passphrase

                    let entropie =
                            berechnePassphraseEntropie
                                anzahlWoerter
                                (length wortliste)

                    let staerke =
                            bewerteEntropie entropie

                    weiter <-
                        zeigeErgebnis
                            passphrase
                            staerke
                            entropie
                            "Passphrase"
                            version

                    if weiter
                    then programmSchleife version wortliste
                    else return ()

main :: IO ()
main = do
    version <- ladeVersion
    pfad <- findeWortliste

    case pfad of
        Nothing -> do
            fehler
                "Die deutsche Wortliste konnte nicht geladen werden.\n\n\
                \Erwartet:\n\
                \assets/words/words_de.txt"
            return ()

        Just wortlistenPfad -> do
            wortliste <- ladeWortliste wortlistenPfad

            if null wortliste
            then do
                fehler
                    "Die deutsche Wortliste ist leer oder konnte nicht gelesen werden."
                return ()
            else
                programmSchleife  version wortliste