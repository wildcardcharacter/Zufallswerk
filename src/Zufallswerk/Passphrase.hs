{-# LANGUAGE OverloadedLabels #-}
{-# LANGUAGE OverloadedStrings #-}

module Zufallswerk.Passphrase
    ( zeigePassphraseFenster
    ) where

import qualified GI.Gtk as Gtk
import qualified Data.Text as T

import Zufallswerk.Core
import Zufallswerk.Password (kopiereZwischenablage)

zeigePassphraseFenster :: Gtk.Window -> IO ()
zeigePassphraseFenster parent = do

    window <- Gtk.new Gtk.Window
        [ (#title Gtk.:= "Passphrase generieren")
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
        [ (#label Gtk.:= "💬  Passphrase generieren")
        , (#halign Gtk.:= Gtk.AlignStart)
        ]

    Gtk.boxPackStart box title False False 0

    description <- Gtk.new Gtk.Label
        [ (#label Gtk.:= "Erstelle eine sichere deutsche Passphrase.")
        , (#halign Gtk.:= Gtk.AlignStart)
        ]

    Gtk.boxPackStart box description False False 0

    wordLabel <- Gtk.new Gtk.Label
        [ (#label Gtk.:= "Anzahl Wörter")
        , (#halign Gtk.:= Gtk.AlignStart)
        ]

    Gtk.boxPackStart box wordLabel False False 0

    wordSpin <- Gtk.spinButtonNewWithRange
        2
        36
        1

    Gtk.spinButtonSetValue wordSpin 4

    Gtk.boxPackStart box wordSpin False False 0

    separatorLabel <- Gtk.new Gtk.Label
        [ (#label Gtk.:= "Trennzeichen")
        , (#halign Gtk.:= Gtk.AlignStart)
        ]

    Gtk.boxPackStart box separatorLabel False False 0

    separatorEntry <- Gtk.new Gtk.Entry
        [ (#text Gtk.:= "-")
        , (#maxLength Gtk.:= 5)
        ]

    Gtk.boxPackStart box separatorEntry False False 0

    generateButton <- Gtk.new Gtk.Button
        [ (#label Gtk.:= "🔄 Passphrase generieren")
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
        anzahlWoerter <- fromIntegral <$> Gtk.spinButtonGetValueAsInt wordSpin
        trennzeichen <- Gtk.entryGetText separatorEntry

        wortlistenPfad <- findeWortliste

        case wortlistenPfad of
            Nothing ->
                Gtk.labelSetText statusLabel
                    "⚠️ Deutsche Wortliste wurde nicht gefunden."

            Just pfad -> do
                wortliste <- ladeWortliste pfad

                if null wortliste
                    then
                        Gtk.labelSetText statusLabel
                            "⚠️ Die Wortliste ist leer."
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

                        buffer <- Gtk.textViewGetBuffer resultView

                        Gtk.textBufferSetText
                            buffer
                            (T.pack passphrase)
                            (-1)

                        kopiereZwischenablage passphrase

                        Gtk.labelSetText statusLabel
                            "✅ Passphrase wurde in die Zwischenablage kopiert."

                        Gtk.labelSetText entropyLabel
                            (T.pack
                                ("📊 Entropie: "
                                ++ show (round entropie :: Int)
                                ++ " Bit"))

                        Gtk.labelSetText strengthLabel
                            (T.pack
                                ("💪 Stärke: "
                                ++ staerke))

                        kopiereZwischenablage passphrase

                        Gtk.labelSetText statusLabel
                            "✅ Passphrase wurde in die Zwischenablage kopiert."

    closeButton <- Gtk.new Gtk.Button
        [ (#label Gtk.:= "Schließen")
        ]

    _ <- Gtk.on closeButton #clicked $
        Gtk.widgetDestroy window

    Gtk.boxPackEnd box closeButton False False 0

    Gtk.containerAdd window box
    Gtk.widgetShowAll window