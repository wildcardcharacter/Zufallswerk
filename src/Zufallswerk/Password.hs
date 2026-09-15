{-# LANGUAGE OverloadedLabels #-}
{-# LANGUAGE OverloadedStrings #-}

module Zufallswerk.Password
    ( kopiereZwischenablage
    , zeigePasswortFenster
    ) where

import qualified Zufallswerk.Core as Core
import System.Process
import System.IO (hPutStr, hClose)
import qualified Data.Text as T

import qualified GI.Gtk as Gtk

import Zufallswerk.Language

kopiereZwischenablage :: String -> IO ()
kopiereZwischenablage text = do
    (Just hin, _, _, _) <- createProcess
        (proc "xclip" ["-selection", "clipboard"])
            { std_in = CreatePipe }

    hPutStr hin text
    hClose hin

zeigePasswortFenster :: Gtk.Window -> Sprache -> IO ()
zeigePasswortFenster parent sprache = do

    window <- Gtk.new Gtk.Window
        [ (#title Gtk.:= T.pack (passwortTitel sprache))
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
        [ (#label Gtk.:= T.pack (passwortTitel sprache))
        , (#halign Gtk.:= Gtk.AlignStart)
        ]

    Gtk.boxPackStart box title False False 0

    description <- Gtk.new Gtk.Label
        [ (#label Gtk.:= T.pack (passwortBeschreibung sprache))
        , (#halign Gtk.:= Gtk.AlignStart)
        ]

    Gtk.boxPackStart box description False False 0

    lengthLabel <- Gtk.new Gtk.Label
        [ (#label Gtk.:= T.pack (passwortLaenge sprache))
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
        [ (#label Gtk.:= T.pack (passwortZeichensatz sprache))
        , (#halign Gtk.:= Gtk.AlignStart)
        ]

    Gtk.boxPackStart box charsetLabel False False 0

    lowerCheck <- Gtk.new Gtk.CheckButton
        [ (#label Gtk.:= T.pack (passwortKleinbuchstaben sprache))
        , (#active Gtk.:= True)
        ]

    upperCheck <- Gtk.new Gtk.CheckButton
        [ (#label Gtk.:= T.pack (passwortGrossbuchstaben sprache))
        , (#active Gtk.:= True)
        ]

    numberCheck <- Gtk.new Gtk.CheckButton
        [ (#label Gtk.:= T.pack (passwortZahlen sprache))
        , (#active Gtk.:= True)
        ]

    specialCheck <- Gtk.new Gtk.CheckButton
        [ (#label Gtk.:= T.pack (passwortSonderzeichen sprache))
        , (#active Gtk.:= True)
        ]

    Gtk.boxPackStart box lowerCheck False False 0
    Gtk.boxPackStart box upperCheck False False 0
    Gtk.boxPackStart box numberCheck False False 0
    Gtk.boxPackStart box specialCheck False False 0

    generateButton <- Gtk.new Gtk.Button
        [ (#label Gtk.:= T.pack (passwortGenerieren sprache))
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
                (if kleinAktiv then Core.klein else "")
                ++ (if grossAktiv then Core.gross else "")
                ++ (if zahlenAktiv then Core.zahlen else "")
                ++ (if sonderAktiv then Core.sonder else "")

        if null zeichensatz
            then do
                buffer <- Gtk.textViewGetBuffer resultView

                Gtk.textBufferSetText buffer
                    (T.pack (passwortOptionFehlt sprache))
                    (-1)

                Gtk.labelSetText statusLabel
                    (T.pack (passwortOptionFehltStatus sprache))

            else do
                passwort <- Core.erzeugePasswort
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
                    (T.pack (passwortKopiert sprache))

                Gtk.labelSetText entropyLabel
                    (T.pack
                        (passwortEntropie sprache entropie))

                Gtk.labelSetText strengthLabel
                    (T.pack
                        (passwortStaerke sprache staerke))

    closeButton <- Gtk.new Gtk.Button
        [ (#label Gtk.:= T.pack (passwortSchliessen sprache))
        ]

    _ <- Gtk.on closeButton #clicked $
        Gtk.widgetDestroy window

    Gtk.boxPackEnd box closeButton False False 0

    Gtk.containerAdd window box
    Gtk.widgetShowAll window