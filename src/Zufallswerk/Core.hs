module Zufallswerk.Core where

import qualified Data.ByteString as BS
import System.Directory (doesFileExist)
import Control.Monad (filterM)
import Data.Word
import System.IO

klein, gross, zahlen, sonder :: String
klein  = ['a'..'z']
gross  = ['A'..'Z']
zahlen = ['0'..'9']
sonder = "!@#$%&*-_?"

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

byteZuZeichen :: String -> Word8 -> Char
byteZuZeichen zeichensatz b =
    zeichensatz !! (fromIntegral b `mod` length zeichensatz)

erzeugePasswort :: Int -> String -> IO String
erzeugePasswort laenge zeichensatz = do
    h <- openBinaryFile "/dev/urandom" ReadMode
    bytes <- BS.hGet h laenge
    hClose h
    return (map (byteZuZeichen zeichensatz) (BS.unpack bytes))

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
