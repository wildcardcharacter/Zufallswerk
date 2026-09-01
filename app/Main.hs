{-# LANGUAGE OverloadedLabels #-}
{-# LANGUAGE OverloadedStrings #-}

module Main where

import qualified GI.Gtk as Gtk
import qualified GI.Gdk as Gdk
import qualified Data.Text as T
import qualified GI.Gtk.Objects.CssProvider as CssProvider
import qualified GI.Gtk.Objects.StyleContext as StyleContext
import Zufallswerk.Password
import Zufallswerk.Passphrase
import System.Process (callCommand)
import Paths_zufallswerk (version)
import Data.Version (showVersion)

main :: IO ()
main = do
    _ <- Gtk.init Nothing

    -- CSS laden
    css <- CssProvider.cssProviderNew
    CssProvider.cssProviderLoadFromPath css "data/style.css"

    screen <- Gdk.screenGetDefault

    case screen of
        Nothing -> return ()
        Just s ->
            Gtk.styleContextAddProviderForScreen
                s
                css
                (fromIntegral Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)

    -- Hauptfenster
    window <- Gtk.new Gtk.Window
        [ (#title Gtk.:= T.pack ("Zufallswerk " ++ showVersion version))
        , (#defaultWidth Gtk.:= 760)
        , (#defaultHeight Gtk.:= 500)
        , (#windowPosition Gtk.:= Gtk.WindowPositionCenter)
        ]

    _ <- Gtk.on window #destroy Gtk.mainQuit

    -- Hauptcontainer
    mainBox <- Gtk.new Gtk.Box
        [ (#orientation Gtk.:= Gtk.OrientationVertical)
        , (#spacing Gtk.:= 0)
        ]

    -- =========================================================
    -- HEADER
    -- =========================================================

    header <- Gtk.new Gtk.Box
        [ (#orientation Gtk.:= Gtk.OrientationVertical)
        , (#spacing Gtk.:= 4)
        , (#halign Gtk.:= Gtk.AlignCenter)
        , (#marginTop Gtk.:= 28)
        , (#marginBottom Gtk.:= 20)
        ]

    logo <- Gtk.new Gtk.Label
        [ (#label Gtk.:= "🔐")
        , (#halign Gtk.:= Gtk.AlignCenter)
        ]

    title <- Gtk.new Gtk.Label
        [ (#label Gtk.:= "Zufallswerk")
        , (#halign Gtk.:= Gtk.AlignCenter)
        ]

    subtitle <- Gtk.new Gtk.Label
        [ (#label Gtk.:= "Sichere Passwörter & Passphrasen")
        , (#halign Gtk.:= Gtk.AlignCenter)
        ]

    Gtk.widgetSetName title "header-title"
    Gtk.widgetSetName subtitle "header-subtitle"

    Gtk.boxPackStart header logo False False 0
    Gtk.boxPackStart header title False False 0
    Gtk.boxPackStart header subtitle False False 0

    Gtk.boxPackStart mainBox header False False 0

    -- =========================================================
    -- INHALT
    -- =========================================================

    content <- Gtk.new Gtk.Box
        [ (#orientation Gtk.:= Gtk.OrientationVertical)
        , (#spacing Gtk.:= 10)
        , (#marginStart Gtk.:= 50)
        , (#marginEnd Gtk.:= 50)
        , (#marginTop Gtk.:= 20)
        ]

    heading <- Gtk.new Gtk.Label
        [ (#label Gtk.:= "Was möchtest du erzeugen?")
        ]

    description <- Gtk.new Gtk.Label
        [ (#label Gtk.:= "Wähle eine sichere Generierungsart.")
        ]

    Gtk.boxPackStart content heading False False 0
    Gtk.boxPackStart content description False False 0

    -- =========================================================
    -- AUSWAHLKARTEN
    -- =========================================================

    cards <- Gtk.new Gtk.Box
        [ (#orientation Gtk.:= Gtk.OrientationHorizontal)
        , (#spacing Gtk.:= 20)
        , (#marginTop Gtk.:= 30)
        , (#marginBottom Gtk.:= 10)
        ]

    -- Passwort
    passwordButton <- Gtk.new Gtk.Button []

    passwordBox <- Gtk.new Gtk.Box
        [ (#orientation Gtk.:= Gtk.OrientationVertical)
        , (#spacing Gtk.:= 8)
        , (#halign Gtk.:= Gtk.AlignCenter)
        ]

    passwordIcon <- Gtk.new Gtk.Label
        [ (#label Gtk.:= "🔐")
        ]

    passwordTitle <- Gtk.new Gtk.Label
        [ (#label Gtk.:= "Passwort")
        ]

    passwordDescription <- Gtk.new Gtk.Label
        [ (#label Gtk.:= "Sicheres Zufallspasswort erzeugen")
        ]

    passwordContext <- Gtk.widgetGetStyleContext passwordButton
    StyleContext.styleContextAddClass passwordContext "card"
    Gtk.widgetSetName passwordTitle "card-title"
    Gtk.widgetSetName passwordDescription "card-description"

    Gtk.boxPackStart passwordBox passwordIcon False False 0
    Gtk.boxPackStart passwordBox passwordTitle False False 0
    Gtk.boxPackStart passwordBox passwordDescription False False 0

    Gtk.containerAdd passwordButton passwordBox

    _ <- Gtk.on passwordButton #clicked $
        zeigePasswortFenster window

    -- Passphrase
    passphraseButton <- Gtk.new Gtk.Button []

    passphraseBox <- Gtk.new Gtk.Box
        [ (#orientation Gtk.:= Gtk.OrientationVertical)
        , (#spacing Gtk.:= 8)
        , (#halign Gtk.:= Gtk.AlignCenter)
        ]

    passphraseIcon <- Gtk.new Gtk.Label
        [ (#label Gtk.:= "💬")
        ]

    passphraseTitle <- Gtk.new Gtk.Label
        [ (#label Gtk.:= "Passphrase")
        ]

    passphraseDescription <- Gtk.new Gtk.Label
        [ (#label Gtk.:= "Deutsche Passphrase erzeugen")
        ]

    passphraseContext <- Gtk.widgetGetStyleContext passphraseButton
    StyleContext.styleContextAddClass passphraseContext "card"
    Gtk.widgetSetName passphraseTitle "card-title"
    Gtk.widgetSetName passphraseDescription "card-description"

    Gtk.boxPackStart passphraseBox passphraseIcon False False 0
    Gtk.boxPackStart passphraseBox passphraseTitle False False 0
    Gtk.boxPackStart passphraseBox passphraseDescription False False 0

    Gtk.containerAdd passphraseButton passphraseBox
    _ <- Gtk.on passphraseButton #clicked $
        zeigePassphraseFenster window

    Gtk.boxPackStart cards passwordButton True True 0
    Gtk.boxPackStart cards passphraseButton True True 0

    Gtk.boxPackStart content cards True True 0
    Gtk.boxPackStart mainBox content True True 0

-- =========================================================
-- UNTERE LEISTE
-- =========================================================

    footer <- Gtk.new Gtk.Box
        [ (#orientation Gtk.:= Gtk.OrientationHorizontal)
        , (#spacing Gtk.:= 10)
        , (#marginStart Gtk.:= 28)
        , (#marginEnd Gtk.:= 28)
        , (#marginTop Gtk.:= 30)
        , (#marginBottom Gtk.:= 20)
        , (#halign Gtk.:= Gtk.AlignEnd)
        ]

    settingsButton <- Gtk.new Gtk.Button
        [ (#label Gtk.:= "⚙ Einstellungen")
        ]

    aboutButton <- Gtk.new Gtk.Button
        [ (#label Gtk.:= "ℹ Über Zufallswerk")
        ]

    _ <- Gtk.on aboutButton #clicked $
        zeigeUeberDialog window

    exitButton <- Gtk.new Gtk.Button
        [ (#label Gtk.:= "⏻ Beenden")
        ]

    Gtk.widgetSetName settingsButton "footer-button"
    Gtk.widgetSetName aboutButton "footer-button"
    Gtk.widgetSetName exitButton "footer-button"

    -- Beenden
    _ <- Gtk.on exitButton #clicked Gtk.mainQuit

    Gtk.boxPackEnd footer exitButton False False 0
    Gtk.boxPackEnd footer aboutButton False False 10
    Gtk.boxPackEnd footer settingsButton False False 10

    Gtk.boxPackEnd mainBox footer False False 0

    -- Fenster anzeigen
    Gtk.containerAdd window mainBox
    Gtk.widgetShowAll window

    Gtk.main

zeigeUeberDialog :: Gtk.Window -> IO ()
zeigeUeberDialog parent = do
    dialog <- Gtk.new Gtk.Dialog
        [ (#title Gtk.:= "Über Zufallswerk")
        , (#transientFor Gtk.:= parent)
        , (#modal Gtk.:= True)
        , (#defaultWidth Gtk.:= 520)
        ]

    contentArea <- Gtk.dialogGetContentArea dialog

    box <- Gtk.new Gtk.Box
        [ (#orientation Gtk.:= Gtk.OrientationVertical)
        , (#spacing Gtk.:= 10)
        , (#marginStart Gtk.:= 30)
        , (#marginEnd Gtk.:= 30)
        , (#marginTop Gtk.:= 25)
        , (#marginBottom Gtk.:= 25)
        ]

    logo <- Gtk.new Gtk.Label
        [ (#label Gtk.:= "🔐")
        , (#halign Gtk.:= Gtk.AlignCenter)
        ]

    title <- Gtk.new Gtk.Label
        [ (#label Gtk.:= T.pack ("Zufallswerk " ++ showVersion version))
        , (#halign Gtk.:= Gtk.AlignCenter)
        ]

    subtitle <- Gtk.new Gtk.Label
        [ (#label Gtk.:= "Secure Password Generator · Written in Haskell")
        , (#halign Gtk.:= Gtk.AlignCenter)
        ]

    entropyTitle <- Gtk.new Gtk.Label
        [ (#label Gtk.:= "Was bedeutet Entropie?")
        , (#halign Gtk.:= Gtk.AlignStart)
        ]

    entropyText <- Gtk.new Gtk.Label
        [ (#label Gtk.:=
            "Die Entropie beschreibt den theoretischen Suchraum.\n\n\
            \Je höher der Wert, desto mehr Kombinationen sind möglich.\n\n\
            \80 Bit → 2^80   |   128 Bit → 2^128   |   1580 Bit → 2^1580")
        , (#halign Gtk.:= Gtk.AlignStart)
        , (#wrap Gtk.:= True)
        ]

    copyright <- Gtk.new Gtk.Label
        [ (#label Gtk.:= "© 2026 Markus")
        , (#halign Gtk.:= Gtk.AlignCenter)
        ]

    links <- Gtk.new Gtk.Box
        [ (#orientation Gtk.:= Gtk.OrientationHorizontal)
        , (#spacing Gtk.:= 15)
        , (#halign Gtk.:= Gtk.AlignCenter)
        ]

    websiteButton <- Gtk.new Gtk.Button
        [ (#label Gtk.:= "🌐 Website")
        ]

    githubButton <- Gtk.new Gtk.Button
        [ (#label Gtk.:= "💻 GitHub")
        ]

    supportButton <- Gtk.new Gtk.Button
        [ (#label Gtk.:= "☕ Support")
        ]

    _ <- Gtk.on websiteButton #clicked $
        callCommand "xdg-open https://wildcardcharacter.github.io"

    _ <- Gtk.on githubButton #clicked $
        callCommand "xdg-open https://github.com/wildcardcharacter/Zufallswerk"

    _ <- Gtk.on supportButton #clicked $
        callCommand "xdg-open https://buymeacoffee.com/wildcardcharacter"

    Gtk.boxPackStart links websiteButton False False 0
    Gtk.boxPackStart links githubButton False False 0
    Gtk.boxPackStart links supportButton False False 0

    license <- Gtk.new Gtk.Label
        [ (#label Gtk.:= "MIT License")
        , (#halign Gtk.:= Gtk.AlignCenter)
        ]

    Gtk.boxPackStart box logo False False 0
    Gtk.boxPackStart box title False False 0
    Gtk.boxPackStart box subtitle False False 5
    Gtk.boxPackStart box entropyTitle False False 15
    Gtk.boxPackStart box entropyText False False 0
    Gtk.boxPackStart box copyright False False 15
    Gtk.boxPackStart box links False False 5
    Gtk.boxPackStart box license False False 5

    Gtk.containerAdd contentArea box

    _ <- Gtk.dialogAddButton dialog "OK" 0

    _ <- Gtk.on dialog #response $ \_ ->
        Gtk.widgetDestroy dialog

    Gtk.widgetShowAll dialog