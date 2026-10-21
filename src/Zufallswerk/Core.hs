module Zufallswerk.Core where

import qualified Data.ByteString as BS
import System.Directory (doesFileExist)
import Control.Monad (filterM)
import System.IO
import Control.Exception (bracket)

klein, gross, zahlen, sonder :: String
klein  = ['a'..'z']
gross  = ['A'..'Z']
zahlen = ['0'..'9']
sonder = "!@#$%&*-_?"

buchstabenUndZahlen :: String
buchstabenUndZahlen = klein ++ gross ++ zahlen


wortlistenPfade :: String -> [FilePath]
wortlistenPfade sprache =
    [ "assets/words/" ++ dateiname
    , "/usr/share/zufallswerk/words/" ++ dateiname
    ]
  where
    dateiname = case sprache of
        "en" -> "words_en_eff.txt"
        _ -> "words_de.txt"


findeWortliste :: String -> IO (Maybe FilePath)
findeWortliste sprache = do
    vorhandene <- filterM doesFileExist (wortlistenPfade sprache)
    return $
        case vorhandene of
            (pfad:_) -> Just pfad
            []       -> Nothing


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


baueZeichensatz :: String -> String -> String -> String -> String
baueZeichensatz k g z s =
    concat
        [ if k == "TRUE" then klein else ""
        , if g == "TRUE" then gross else ""
        , if z == "TRUE" then zahlen else ""
        , if s == "TRUE" then sonder else ""
        ]


erzeugePasswort :: Int -> String -> IO String
erzeugePasswort laenge zeichensatz = do
    if null zeichensatz
    then ioError (userError "Zeichensatz darf nicht leer sein.")
    else do
        bracket (openBinaryFile "/dev/urandom" ReadMode) hClose $ \h ->
            mapM (const (zufallsZeichen h)) [1 .. laenge]
    where
        maxWert = length zeichensatz

        zufallsZeichen h = do
            index <- zufallsIndexMitHandle h maxWert
            return (zeichensatz !! index)


zufallsIndexMitHandle :: Handle -> Int -> IO Int
zufallsIndexMitHandle h maxWert = do
    if maxWert <= 0
    then ioError (userError "Ungültige maximale Indexgröße.")
    else do
        let maxZufallswert = 256 :: Int
            bereich = (maxZufallswert `div` maxWert) * maxWert

        leseIndex bereich
  where
    leseIndex bereich = do
        byte <- BS.hGet h 1

        if BS.length byte /= 1
        then ioError (userError "Konnte keine Zufallsdaten lesen.")
        else do
            let wert = fromIntegral (BS.head byte) :: Int

            if wert < bereich
            then return (wert `mod` maxWert)
            else leseIndex bereich

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
    | otherwise  = "Sehr stark"

zufallsIndex :: Int -> IO Int
zufallsIndex maxWert = do
    if maxWert <= 0
    then ioError (userError "Ungültige maximale Indexgröße.")
    else do
        bracket (openBinaryFile "/dev/urandom" ReadMode) hClose $ \h ->
            zufallsIndexMitHandle16 h maxWert

zufallsIndexMitHandle16 :: Handle -> Int -> IO Int
zufallsIndexMitHandle16 h maxWert = do
    leseIndex
  where
    maxZufallswert = 65536 :: Int
    bereich = (maxZufallswert `div` maxWert) * maxWert

    leseIndex = do
        bytes <- BS.hGet h 2

        if BS.length bytes /= 2
        then ioError (userError "Konnte keine Zufallsdaten lesen.")
        else do
            let high = fromIntegral (BS.index bytes 0) :: Int
                low  = fromIntegral (BS.index bytes 1) :: Int
                wert = high * 256 + low

            if wert < bereich
            then return (wert `mod` maxWert)
            else leseIndex


erzeugePassphrase :: Int -> [String] -> String -> IO String
erzeugePassphrase anzahlWoerter wortliste trennzeichen = do
    woerter <- mapM
        (\_ -> do
            index <- zufallsIndex (length wortliste)
            return (wortliste !! index)
        )
        [1 .. anzahlWoerter]

    return (verbindeMit trennzeichen woerter)


zufallsZeichenBlock :: Int -> String -> IO String
zufallsZeichenBlock laenge zeichensatz = do
    mapM
        (\_ -> do
            index <- zufallsIndex (length zeichensatz)
            return (zeichensatz !! index)
        )
        [1 .. laenge]


erzeugeZeichenblockPassphrase :: Int -> Int -> String -> String -> IO String
erzeugeZeichenblockPassphrase anzahlBloecke blockLaenge zeichensatz trennzeichen = do
    bloecke <- mapM
        (\_ -> zufallsZeichenBlock blockLaenge zeichensatz)
        [1 .. anzahlBloecke]

    return (verbindeMit trennzeichen bloecke)


verbindeMit :: String -> [String] -> String
verbindeMit _ [] = ""
verbindeMit trennzeichen (x:xs) =
    x ++ concatMap (trennzeichen ++) xs
