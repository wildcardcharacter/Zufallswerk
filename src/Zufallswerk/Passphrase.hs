{-# LANGUAGE OverloadedLabels #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Zufallswerk.Passphrase
    ( zeigePassphraseFenster
    ) where

import qualified GI.Gtk as Gtk
import qualified Data.Text as T
import Control.Exception (IOException, catch)

import Zufallswerk.Core
import Zufallswerk.Password (kopiereZwischenablage)
import Zufallswerk.Language
import Zufallswerk.Settings
    ( ladePassphraseWortmodus
    , speicherePassphraseWortmodus
    , ladePassphraseWortlistenSprache
    , speicherePassphraseWortlistenSprache
    )

zeigePassphraseFenster :: Gtk.Window -> Sprache -> IO ()
zeigePassphraseFenster parent sprache = do

    window <- Gtk.new Gtk.Window
        [ (#title Gtk.:= T.pack (passphraseTitel sprache))
        , (#defaultWidth Gtk.:= 600)
        , (#defaultHeight Gtk.:= 520)
        , (#windowPosition Gtk.:= Gtk.WindowPositionCenterOnParent)
        ]

    Gtk.windowSetTransientFor window (Just parent)
    Gtk.windowSetModal window True

    box <- Gtk.new Gtk.Box
        [ (#orientation Gtk.:= Gtk.OrientationVertical)
        , (#spacing Gtk.:= 15)
        , (#marginStart Gtk.:= 24)
        , (#marginEnd Gtk.:= 24)
        , (#marginTop Gtk.:= 24)
        , (#marginBottom Gtk.:= 24)
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

    wordModeByDefault <- ladePassphraseWortmodus
    Gtk.toggleButtonSetActive (if wordModeByDefault then wordRadio else blockRadio) True

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

    wordListLabel <- Gtk.new Gtk.Label
        [ (#label Gtk.:= T.pack (passphraseWortliste sprache))
        , (#halign Gtk.:= Gtk.AlignStart)
        ]
    germanWordList <- Gtk.new Gtk.RadioButton
        [ (#label Gtk.:= T.pack (passphraseDeutsch sprache)) ]
    englishWordList <- Gtk.new Gtk.RadioButton
        [ (#label Gtk.:= T.pack (passphraseEnglisch sprache)) ]
    Gtk.radioButtonJoinGroup englishWordList (Just germanWordList)
    wordListLanguage <- ladePassphraseWortlistenSprache
    Gtk.toggleButtonSetActive
        (if wordListLanguage == "en" then englishWordList else germanWordList)
        True
    Gtk.boxPackStart wordBox wordListLabel False False 0
    Gtk.boxPackStart wordBox germanWordList False False 0
    Gtk.boxPackStart wordBox englishWordList False False 0

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
                Gtk.widgetShowAll wordBox
                Gtk.widgetHide blockBox
                speicherePassphraseWortmodus True
            else return ()

    _ <- Gtk.on blockRadio #toggled $ do
        aktiv <- Gtk.toggleButtonGetActive blockRadio

        if aktiv
            then do
                Gtk.widgetHide wordBox
                Gtk.widgetShowAll blockBox
                speicherePassphraseWortmodus False
            else return ()

    _ <- Gtk.on germanWordList #toggled $ do
        aktiv <- Gtk.toggleButtonGetActive germanWordList
        if aktiv then speicherePassphraseWortlistenSprache "de" else return ()

    _ <- Gtk.on englishWordList #toggled $ do
        aktiv <- Gtk.toggleButtonGetActive englishWordList
        if aktiv then speicherePassphraseWortlistenSprache "en" else return ()

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

    entropyNote <- Gtk.new Gtk.Label
        [ (#label Gtk.:= T.pack (entropieHinweis sprache))
        , (#halign Gtk.:= Gtk.AlignStart)
        , (#wrap Gtk.:= True)
        ]
    Gtk.boxPackStart box entropyNote False False 0

    _ <- Gtk.on generateButton #clicked $ (do
        trennzeichen <- Gtk.entryGetText separatorEntry

        wordMode <- activeWordMode wordRadio

        if wordMode
            then do
                -- Wörter-Modus

                anzahlWoerter <-
                    fromIntegral <$>
                    Gtk.spinButtonGetValueAsInt wordSpin

                useEnglish <- Gtk.toggleButtonGetActive englishWordList
                let listLanguage = if useEnglish then "en" else "de"
                wortlistenPfad <- findeWortliste listLanguage

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
        ) `catch` \(_ :: IOException) ->
            Gtk.labelSetText statusLabel (T.pack (generierungsFehler sprache))

    closeButton <- Gtk.new Gtk.Button
        [ (#label Gtk.:= T.pack (passphraseSchliessen sprache))
        ]

    _ <- Gtk.on closeButton #clicked $
        Gtk.widgetDestroy window

    scroll <- Gtk.scrolledWindowNew
        (Nothing :: Maybe Gtk.Adjustment)
        (Nothing :: Maybe Gtk.Adjustment)
    Gtk.scrolledWindowSetPolicy
        scroll
        Gtk.PolicyTypeNever
        Gtk.PolicyTypeAutomatic
    Gtk.widgetSetHexpand scroll True
    Gtk.widgetSetVexpand scroll True
    Gtk.containerAdd scroll box
    windowBox <- Gtk.new Gtk.Box
        [ (#orientation Gtk.:= Gtk.OrientationVertical)
        , (#spacing Gtk.:= 10)
        , (#marginStart Gtk.:= 16)
        , (#marginEnd Gtk.:= 16)
        , (#marginTop Gtk.:= 16)
        , (#marginBottom Gtk.:= 16)
        ]
    Gtk.boxPackStart windowBox scroll True True 0
    Gtk.boxPackEnd windowBox closeButton False False 0
    Gtk.containerAdd window windowBox
    Gtk.widgetShowAll window
    if wordModeByDefault
        then Gtk.widgetHide blockBox
        else Gtk.widgetHide wordBox


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

    copied <- kopiereZwischenablage passphrase
    Gtk.labelSetText statusLabel
        (T.pack (either (const (clipboardFehler sprache)) (const (passphraseKopiert sprache)) copied))

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
