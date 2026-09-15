{-# LANGUAGE OverloadedLabels #-}
{-# LANGUAGE OverloadedStrings #-}

module Zufallswerk.Passphrase
    ( zeigePassphraseFenster
    ) where

import qualified GI.Gtk as Gtk
import qualified Data.Text as T

import Zufallswerk.Core
import Zufallswerk.Password (kopiereZwischenablage)
import Zufallswerk.Language

zeigePassphraseFenster :: Gtk.Window -> Sprache -> IO ()
zeigePassphraseFenster parent sprache = do

    window <- Gtk.new Gtk.Window
        [ (#title Gtk.:= T.pack (passphraseTitel sprache))
        , (#defaultWidth Gtk.:= 650)
        , (#defaultHeight Gtk.:= 500)
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
        [ (#label Gtk.:= T.pack (passphraseTitel sprache))
        , (#halign Gtk.:= Gtk.AlignStart)
        ]

    Gtk.boxPackStart box title False False 0

    description <- Gtk.new Gtk.Label
        [ (#label Gtk.:= T.pack (passphraseBeschreibung sprache))
        , (#halign Gtk.:= Gtk.AlignStart)
        ]

    Gtk.boxPackStart box description False False 0

    modeLabel <- Gtk.new Gtk.Label
        [ (#label Gtk.:= T.pack (passphraseModus sprache))
        , (#halign Gtk.:= Gtk.AlignStart)
        ]

    Gtk.boxPackStart box modeLabel False False 0

    wordRadio <- Gtk.new Gtk.RadioButton
        [ (#label Gtk.:= T.pack (passphraseWoerter sprache))
        ]

    blockRadio <- Gtk.new Gtk.RadioButton
        [ (#label Gtk.:= T.pack (passphraseZeichenbloecke sprache))
        ]

    Gtk.radioButtonJoinGroup blockRadio (Just wordRadio)

    Gtk.boxPackStart box wordRadio False False 0
    Gtk.boxPackStart box blockRadio False False 0

    -- Einstellungen für Wörter

    wordBox <- Gtk.new Gtk.Box
        [ (#orientation Gtk.:= Gtk.OrientationVertical)
        , (#spacing Gtk.:= 8)
        ]

    wordLabel <- Gtk.new Gtk.Label
        [ (#label Gtk.:= T.pack (passphraseAnzahlWoerter sprache))
        , (#halign Gtk.:= Gtk.AlignStart)
        ]

    Gtk.boxPackStart wordBox wordLabel False False 0

    wordSpin <- Gtk.spinButtonNewWithRange
        2
        36
        1

    Gtk.spinButtonSetValue wordSpin 4

    Gtk.boxPackStart wordBox wordSpin False False 0

    Gtk.boxPackStart box wordBox False False 0

    -- Einstellungen für Zeichenblöcke

    blockBox <- Gtk.new Gtk.Box
        [ (#orientation Gtk.:= Gtk.OrientationVertical)
        , (#spacing Gtk.:= 8)
        ]

    blockCountLabel <- Gtk.new Gtk.Label
        [ (#label Gtk.:= T.pack (passphraseAnzahlBloecke sprache))
        , (#halign Gtk.:= Gtk.AlignStart)
        ]

    Gtk.boxPackStart blockBox blockCountLabel False False 0

    blockCountSpin <- Gtk.spinButtonNewWithRange
        2
        12
        1

    Gtk.spinButtonSetValue blockCountSpin 4

    Gtk.boxPackStart blockBox blockCountSpin False False 0

    blockLengthLabel <- Gtk.new Gtk.Label
        [ (#label Gtk.:= T.pack (passphraseZeichenProBlock sprache))
        , (#halign Gtk.:= Gtk.AlignStart)
        ]

    Gtk.boxPackStart blockBox blockLengthLabel False False 0

    blockLengthSpin <- Gtk.spinButtonNewWithRange
        2
        12
        1

    Gtk.spinButtonSetValue blockLengthSpin 4

    Gtk.boxPackStart blockBox blockLengthSpin False False 0

    Gtk.boxPackStart box blockBox False False 0

    Gtk.widgetHide blockBox

    -- Trennzeichen

    separatorLabel <- Gtk.new Gtk.Label
        [ (#label Gtk.:= T.pack (passphraseTrennzeichen sprache))
        , (#halign Gtk.:= Gtk.AlignStart)
        ]

    Gtk.boxPackStart box separatorLabel False False 0

    separatorEntry <- Gtk.new Gtk.Entry
        [ (#text Gtk.:= "-")
        , (#maxLength Gtk.:= 5)
        ]

    Gtk.boxPackStart box separatorEntry False False 0

    -- Moduswechsel

    _ <- Gtk.on wordRadio #toggled $ do
        aktiv <- Gtk.toggleButtonGetActive wordRadio

        if aktiv
            then do
                Gtk.widgetShow wordBox
                Gtk.widgetHide blockBox
            else return ()

    _ <- Gtk.on blockRadio #toggled $ do
        aktiv <- Gtk.toggleButtonGetActive blockRadio

        if aktiv
            then do
                Gtk.widgetHide wordBox
                Gtk.widgetShow blockBox
            else return ()

    -- Generieren

    generateButton <- Gtk.new Gtk.Button
        [ (#label Gtk.:= T.pack (passphraseGenerieren sprache))
        ]

    Gtk.boxPackStart box generateButton False False 0

    resultView <- Gtk.new Gtk.TextView
        [ (#editable Gtk.:= False)
        , (#wrapMode Gtk.:= Gtk.WrapModeWordChar)
        , (#hexpand Gtk.:= True)
        , (#vexpand Gtk.:= False)
        ]

    Gtk.widgetSetSizeRequest resultView 0 100

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
        trennzeichen <- Gtk.entryGetText separatorEntry

        wordMode <- activeWordMode wordRadio

        if wordMode
            then do
                -- Wörter-Modus

                anzahlWoerter <-
                    fromIntegral <$>
                    Gtk.spinButtonGetValueAsInt wordSpin

                wortlistenPfad <- findeWortliste

                case wortlistenPfad of
                    Nothing ->
                        Gtk.labelSetText statusLabel
                            (T.pack (passphraseWortlisteFehlt sprache))

                    Just pfad -> do
                        wortliste <- ladeWortliste pfad

                        if null wortliste
                            then
                                Gtk.labelSetText statusLabel
                                    (T.pack (passphraseWortlisteLeer sprache))
                            else do
                                passphrase <- erzeugePassphrase
                                    anzahlWoerter
                                    wortliste
                                    (T.unpack trennzeichen)

                                let entropie =
                                        berechnePassphraseEntropie
                                            anzahlWoerter
                                            (length wortliste)

                                    staerke =
                                        bewerteEntropie entropie

                                zeigeErgebnis
                                    sprache
                                    resultView
                                    statusLabel
                                    entropyLabel
                                    strengthLabel
                                    passphrase
                                    entropie
                                    staerke

            else do
                -- Zeichenblock-Modus

                anzahlBloecke <-
                    fromIntegral <$>
                    Gtk.spinButtonGetValueAsInt blockCountSpin

                blockLaenge <-
                    fromIntegral <$>
                    Gtk.spinButtonGetValueAsInt blockLengthSpin

                passphrase <- erzeugeZeichenblockPassphrase
                    anzahlBloecke
                    blockLaenge
                    buchstabenUndZahlen
                    (T.unpack trennzeichen)

                let entropie =
                        berechneEntropie
                            (anzahlBloecke * blockLaenge)
                            (length buchstabenUndZahlen)

                    staerke =
                        bewerteEntropie entropie

                zeigeErgebnis
                    sprache
                    resultView
                    statusLabel
                    entropyLabel
                    strengthLabel
                    passphrase
                    entropie
                    staerke

    closeButton <- Gtk.new Gtk.Button
        [ (#label Gtk.:= T.pack (passphraseSchliessen sprache))
        ]

    _ <- Gtk.on closeButton #clicked $
        Gtk.widgetDestroy window

    Gtk.boxPackEnd box closeButton False False 0

    Gtk.containerAdd window box
    Gtk.widgetShowAll window


activeWordMode :: Gtk.RadioButton -> IO Bool
activeWordMode radio =
    Gtk.toggleButtonGetActive radio


zeigeErgebnis
    :: Sprache
    -> Gtk.TextView
    -> Gtk.Label
    -> Gtk.Label
    -> Gtk.Label
    -> String
    -> Double
    -> String
    -> IO ()
zeigeErgebnis sprache resultView statusLabel entropyLabel strengthLabel
    passphrase entropie staerke = do

    buffer <- Gtk.textViewGetBuffer resultView

    Gtk.textBufferSetText
        buffer
        (T.pack passphrase)
        (-1)

    kopiereZwischenablage passphrase

    Gtk.labelSetText statusLabel
        (T.pack (passphraseKopiert sprache))

    Gtk.labelSetText entropyLabel
        (T.pack
            (passphraseEntropie sprache
            ++ ": "
            ++ show (round entropie :: Int)
            ++ " Bit"))

    Gtk.labelSetText strengthLabel
        (T.pack
            (passphraseStaerke sprache
            ++ ": "
            ++ staerkeText sprache staerke))