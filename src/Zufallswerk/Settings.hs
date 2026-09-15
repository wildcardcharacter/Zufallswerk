{-# LANGUAGE OverloadedLabels #-}
{-# LANGUAGE OverloadedStrings #-}

module Zufallswerk.Settings
    ( ladeSprache
    , speichereSprache
    , zeigeEinstellungen
    ) where

import qualified GI.Gtk as Gtk
import qualified Data.Text as T
import Control.Exception (evaluate)

import Zufallswerk.Language

import System.Directory
    ( getHomeDirectory
    , doesFileExist
    , createDirectoryIfMissing
    )

import System.FilePath
    ( (</>)
    , takeDirectory
    )


-- =========================================================
-- Sprache speichern / laden
-- =========================================================

settingsDatei :: IO FilePath
settingsDatei = do
    home <- getHomeDirectory
    return (home </> ".config" </> "zufallswerk" </> "language")


ladeSprache :: IO Sprache
ladeSprache = do
    datei <- settingsDatei
    existiert <- doesFileExist datei

    if not existiert
    then return Deutsch
    else do
        inhalt <- readFile datei
        _ <- evaluate (length inhalt)

        return $
            case inhalt of
                "English\n" -> English
                "English"   -> English
                _           -> Deutsch


speichereSprache :: Sprache -> IO ()
speichereSprache sprache = do
    datei <- settingsDatei
    let ordner = takeDirectory datei

    createDirectoryIfMissing True ordner

    writeFile datei $
        case sprache of
            Deutsch -> "Deutsch\n"
            English -> "English\n"


-- =========================================================
-- Einstellungen
-- =========================================================

zeigeEinstellungen :: Gtk.Window -> Sprache -> (Sprache -> IO ()) -> IO ()
zeigeEinstellungen parent sprache onSpracheGeaendert = do

    dialog <- Gtk.new Gtk.Dialog
        [ (#title Gtk.:= T.pack (einstellungenTitel sprache))
        , (#transientFor Gtk.:= parent)
        , (#modal Gtk.:= True)
        , (#defaultWidth Gtk.:= 420)
        , (#defaultHeight Gtk.:= 220)
        ]

    contentArea <- Gtk.dialogGetContentArea dialog

    box <- Gtk.new Gtk.Box
        [ (#orientation Gtk.:= Gtk.OrientationVertical)
        , (#spacing Gtk.:= 12)
        , (#marginStart Gtk.:= 30)
        , (#marginEnd Gtk.:= 30)
        , (#marginTop Gtk.:= 25)
        , (#marginBottom Gtk.:= 25)
        ]

    languageLabel <- Gtk.new Gtk.Label
        [ (#label Gtk.:= T.pack (einstellungenSprache sprache))
        , (#halign Gtk.:= Gtk.AlignStart)
        ]

    deutschRadio <- Gtk.new Gtk.RadioButton
        [ (#label Gtk.:= T.pack (einstellungenDeutsch sprache))
        ]

    englishRadio <- Gtk.new Gtk.RadioButton
        [ (#label Gtk.:= T.pack (einstellungenEnglish sprache))
        ]

    Gtk.radioButtonJoinGroup englishRadio (Just deutschRadio)

    case sprache of
        Deutsch ->
            Gtk.toggleButtonSetActive deutschRadio True

        English ->
            Gtk.toggleButtonSetActive englishRadio True

    Gtk.boxPackStart box languageLabel False False 0
    Gtk.boxPackStart box deutschRadio False False 0
    Gtk.boxPackStart box englishRadio False False 0

    Gtk.containerAdd contentArea box

    _ <- Gtk.dialogAddButton
        dialog
        (T.pack (einstellungenSchliessen sprache))
        0

    _ <- Gtk.on dialog #response $ \_ -> do
        deutsch <- Gtk.toggleButtonGetActive deutschRadio

        let neueSprache =
                if deutsch
                then Deutsch
                else English

        speichereSprache neueSprache
        Gtk.widgetDestroy dialog
        onSpracheGeaendert neueSprache

    Gtk.widgetShowAll dialog