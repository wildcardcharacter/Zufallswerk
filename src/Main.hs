import qualified Data.ByteString as BS
import Data.Word
import System.Exit
import System.IO
import System.Process
import Text.Read (readMaybe)

version :: String
version = "0.2.0"

klein, gross, zahlen, sonder :: String
klein  = ['a'..'z']
gross  = ['A'..'Z']
zahlen = ['0'..'9']
sonder = "!@#$%&*-_?"

appTitel :: String
appTitel = "Zufallswerk " ++ version

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
kopiereZwischenablage passwort = do
    (Just hin, _, _, _) <- createProcess
        (proc "xclip" ["-selection", "clipboard"])
            { std_in = CreatePipe }
    hPutStr hin passwort
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

bewerteEntropie :: Double -> String
bewerteEntropie bits
    | bits < 40  = "Sehr schwach"
    | bits < 60  = "Schwach"
    | bits < 80  = "Mittel"
    | bits < 100 = "Stark"
    | otherwise  = "Sehr stark"

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

zeigeErgebnis :: String -> String -> Double -> IO Bool
zeigeErgebnis passwort staerke entropie = do
    (code, _, _) <- readProcessWithExitCode
        "yad"
        [ "--info"
        , "--no-markup"
        , "--title=" ++ appTitel
        , "--width=520"
        , "--text=Passwort erzeugt und in die Zwischenablage kopiert:\n\n"
            ++ passwort
            ++ "\n\nPasswortstärke: "
            ++ staerke
            ++ "\nEntropie: "
            ++ show (round entropie)
            ++ " Bit"
        , "--button=Weiteres Passwort:0"
        , "--button=Beenden:1"
        ]
        ""

    case code of
        ExitSuccess   -> return True
        ExitFailure _ -> return False

zeigeUeberDialog :: IO ()
zeigeUeberDialog = do
    _ <- readProcessWithExitCode
        "yad"
        [ "--info"
        , "--no-markup"
        , "--title=Über " ++ appTitel
        , "--width=500"
        , "--text=Zufallswerk " ++ version
            ++ "\n\nSecure Password Generator"
            ++ "\n\nWritten in Haskell"
            ++ "\n\nWas bedeutet Entropie?"
            ++ "\n\nDie Entropie beschreibt die Anzahl möglicher"
            ++ "\nKombinationen eines Passworts. Je höher der"
            ++ "\nWert, desto größer der theoretische Suchraum."
            ++ "\n\nBeispiele:"
            ++ "\n80 Bit  → 2^80 Kombinationen"
            ++ "\n128 Bit → 2^128 Kombinationen"
            ++ "\n\n© 2026 Markus"
            ++ "\nhttps://wildcardcharacter.github.io"
            ++ "\n\nMIT License"
        , "--button=OK:0"
        ]
        ""
    return ()

zeigeHauptfenster :: IO (Maybe (Int, String))
zeigeHauptfenster = do
    (code, eingabe, _) <- readProcessWithExitCode
        "yad"
        [ "--form"
        , "--title=" ++ appTitel
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
        , "--button=Über:2"
        , "--button=Beenden:1"
        ]
        ""

    case code of
        ExitFailure 2 -> do
            zeigeUeberDialog
            zeigeHauptfenster

        ExitFailure _ ->
            return Nothing

        ExitSuccess -> do
            let werte = splitPipe eingabe

            case werte of
                (laengeText:k:g:z:s:_) ->
                    case readMaybe laengeText :: Maybe Int of
                        Nothing -> do
                            fehler "Keine gültige Zahl."
                            return (Just (0, ""))

                        Just laenge ->
                            if laenge < 1 || laenge > 256
                            then do
                                fehler "Bitte Länge zwischen 1 und 256 wählen."
                                return (Just (0, ""))
                            else do
                                let zeichensatz = baueZeichensatz k g z s

                                if null zeichensatz
                                then do
                                    fehler "Bitte mindestens einen Zeichensatz auswählen."
                                    return (Just (0, ""))
                                else
                                    return (Just (laenge, zeichensatz))

                _ -> do
                    fehler "Unerwartete Eingabe."
                    return (Just (0, ""))

programmSchleife :: IO ()
programmSchleife = do
    auswahl <- zeigeHauptfenster

    case auswahl of
        Nothing ->
            return ()

        Just (0, _) ->
            programmSchleife

        Just (laenge, zeichensatz) -> do
            passwort <- erzeugePasswort laenge zeichensatz
            kopiereZwischenablage passwort

            let entropie = berechneEntropie laenge (length zeichensatz)
            let staerke  = bewerteEntropie entropie

            weiter <- zeigeErgebnis passwort staerke entropie

            if weiter
            then programmSchleife
            else return ()

main :: IO ()
main = programmSchleife