{-# LANGUAGE OverloadedLabels #-}
{-# LANGUAGE OverloadedStrings #-}

module Zufallswerk.Password
    ( klein
    , gross
    , zahlen
    , sonder
    , erzeugePasswort
    , kopiereZwischenablage
    , anzahlGruppen
    , berechneEntropie
    , zeigePasswortFenster
    ) where

import qualified Data.ByteString as BS
import qualified Zufallswerk.Core as Core
import Data.Word
import System.IO
import System.Process
import qualified Data.Text as T

import qualified GI.Gtk as Gtk

klein :: String
klein = ['a'..'z']

gross :: String
gross = ['A'..'Z']

zahlen :: String
zahlen = ['0'..'9']

sonder :: String
sonder = "!@#$%&*-_?"

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
    fromIntegral laenge *
    logBase 2 (fromIntegral zeichensatzGroesse)

zeigePasswortFenster :: Gtk.Window -> IO ()
zeigePasswortFenster parent = do

    window <- Gtk.new Gtk.Window
        [ (#title Gtk.:= "Passwort generieren")
        , (#defaultWidth Gtk.:= 650)
        , (#defaultHeight Gtk.:= 450)
        , (#windowPosition Gtk.:= Gtk.WindowPositionCenterOnParent)
        ]

    Gtk.windowSetTransientFor window (Just parent)
    Gtk.windowSetModal window True

    box <- Gtk.new Gtk.Box
        [ (#orientation Gtk.:= Gtk.OrientationVertical)
        , (#spacing Gtk.:= 15)
        , (#marginStart Gtk.:= 30)
        , (#marginEnd Gtk.:= 30)
        , (#marginTop Gtk.:= 30)
        , (#marginBottom Gtk.:= 30)
        ]

    title <- Gtk.new Gtk.Label
        [ (#label Gtk.:= "🔐  Passwort generieren")
        , (#halign Gtk.:= Gtk.AlignStart)
        ]

    Gtk.boxPackStart box title False False 0

    description <- Gtk.new Gtk.Label
        [ (#label Gtk.:= "Erstelle ein sicheres Zufallspasswort.")
        , (#halign Gtk.:= Gtk.AlignStart)
        ]

    Gtk.boxPackStart box description False False 0

    lengthLabel <- Gtk.new Gtk.Label
        [ (#label Gtk.:= "Passwortlänge")
        , (#halign Gtk.:= Gtk.AlignStart)
        ]

    Gtk.boxPackStart box lengthLabel False False 0

    lengthSpin <- Gtk.spinButtonNewWithRange
        4
        256
        1

    Gtk.spinButtonSetValue lengthSpin 16

    Gtk.boxPackStart box lengthSpin False False 0

    charsetLabel <- Gtk.new Gtk.Label
        [ (#label Gtk.:= "Zeichensatz")
        , (#halign Gtk.:= Gtk.AlignStart)
        ]

    Gtk.boxPackStart box charsetLabel False False 0

    lowerCheck <- Gtk.new Gtk.CheckButton
        [ (#label Gtk.:= "Kleinbuchstaben (a-z)")
        , (#active Gtk.:= True)
        ]

    upperCheck <- Gtk.new Gtk.CheckButton
        [ (#label Gtk.:= "Großbuchstaben (A-Z)")
        , (#active Gtk.:= True)
        ]

    numberCheck <- Gtk.new Gtk.CheckButton
        [ (#label Gtk.:= "Zahlen (0-9)")
        , (#active Gtk.:= True)
        ]

    specialCheck <- Gtk.new Gtk.CheckButton
        [ (#label Gtk.:= "Sonderzeichen (!@#$%&*-_?)")
        , (#active Gtk.:= True)
        ]

    Gtk.boxPackStart box lowerCheck False False 0
    Gtk.boxPackStart box upperCheck False False 0
    Gtk.boxPackStart box numberCheck False False 0
    Gtk.boxPackStart box specialCheck False False 0

    generateButton <- Gtk.new Gtk.Button
        [ (#label Gtk.:= "🔄 Passwort generieren")
        ]

    Gtk.boxPackStart box generateButton False False 0

    resultView <- Gtk.new Gtk.TextView
        [ (#editable Gtk.:= False)
        , (#wrapMode Gtk.:= Gtk.WrapModeWordChar)
        , (#hexpand Gtk.:= True)
        , (#vexpand Gtk.:= False)
        ]

    Gtk.widgetSetSizeRequest resultView 0 80

    Gtk.boxPackStart box resultView False False 0

    statusLabel <- Gtk.new Gtk.Label
        [ (#label Gtk.:= "")
        , (#halign Gtk.:= Gtk.AlignStart)
        ]

    Gtk.boxPackStart box statusLabel False False 0

    entropyLabel <- Gtk.new Gtk.Label
        [ (#label Gtk.:= "")
        , (#halign Gtk.:= Gtk.AlignStart)
        ]

    strengthLabel <- Gtk.new Gtk.Label
        [ (#label Gtk.:= "")
        , (#halign Gtk.:= Gtk.AlignStart)
        ]

    Gtk.boxPackStart box entropyLabel False False 0
    Gtk.boxPackStart box strengthLabel False False 0

    _ <- Gtk.on generateButton #clicked $ do
        laenge <- Gtk.spinButtonGetValueAsInt lengthSpin

        kleinAktiv <- Gtk.toggleButtonGetActive lowerCheck
        grossAktiv <- Gtk.toggleButtonGetActive upperCheck
        zahlenAktiv <- Gtk.toggleButtonGetActive numberCheck
        sonderAktiv <- Gtk.toggleButtonGetActive specialCheck

        let zeichensatz =
                (if kleinAktiv then klein else "")
                ++ (if grossAktiv then gross else "")
                ++ (if zahlenAktiv then zahlen else "")
                ++ (if sonderAktiv then sonder else "")

        if null zeichensatz
            then do
                buffer <- Gtk.textViewGetBuffer resultView
                Gtk.textBufferSetText buffer
                    "Bitte mindestens eine Option auswählen."
                    (-1)

                Gtk.labelSetText statusLabel
                    "⚠️ Bitte mindestens eine Option auswählen."

            else do
                passwort <- erzeugePasswort
                    (fromIntegral laenge)
                    zeichensatz

                let entropie =
                        Core.berechneEntropie
                            (fromIntegral laenge)
                            (length zeichensatz)

                    staerke =
                        Core.bewerteEntropie entropie

                buffer <- Gtk.textViewGetBuffer resultView
                Gtk.textBufferSetText
                    buffer
                    (T.pack passwort)
                    (-1)

                kopiereZwischenablage passwort

                Gtk.labelSetText statusLabel
                    "✅ Passwort wurde in die Zwischenablage kopiert."

                Gtk.labelSetText entropyLabel
                    (T.pack
                        ("📊 Entropie: "
                        ++ show (round entropie :: Int)
                        ++ " Bit"))

                Gtk.labelSetText strengthLabel
                    (T.pack
                        ("💪 Stärke: "
                        ++ staerke))

                buffer <- Gtk.textViewGetBuffer resultView
                Gtk.textBufferSetText buffer (T.pack passwort) (-1)

                kopiereZwischenablage passwort

                Gtk.labelSetText statusLabel
                    "✅ Passwort wurde in die Zwischenablage kopiert."

    closeButton <- Gtk.new Gtk.Button
        [ (#label Gtk.:= "Schließen")
        ]

    _ <- Gtk.on closeButton #clicked $
        Gtk.widgetDestroy window

    Gtk.boxPackEnd box closeButton False False 0

    Gtk.containerAdd window box
    Gtk.widgetShowAll window