{-# LANGUAGE OverloadedLabels #-}
{-# LANGUAGE OverloadedStrings #-}

module Zufallswerk.Settings
    ( ladeSprache
    , speichereSprache
    , ladePasswortLaenge
    , speicherePasswortLaenge
    , ladePassphraseWortmodus
    , speicherePassphraseWortmodus
    , ladePassphraseWortlistenSprache
    , speicherePassphraseWortlistenSprache
    , zeigeEinstellungen
    ) where

import qualified GI.Gtk as Gtk
import qualified Data.Text as T
import Control.Exception (IOException, evaluate, try)

import Zufallswerk.Language

import System.Directory
    ( getHomeDirectory
    , createDirectoryIfMissing
    )

import System.FilePath
    ( (</>)
    , takeDirectory
    )
import Text.Read (readMaybe)


-- =========================================================
-- Sprache speichern / laden
-- =========================================================

settingsDatei :: IO FilePath
settingsDatei = do
    home <- getHomeDirectory
    return (home </> ".config" </> "zufallswerk" </> "language")

praeferenzDatei :: String -> IO FilePath
praeferenzDatei name = do
    home <- getHomeDirectory
    return (home </> ".config" </> "zufallswerk" </> name)

ladeDatei :: FilePath -> IO (Maybe String)
ladeDatei datei = do
    result <- try $ do
        inhalt <- readFile datei
        _ <- evaluate (length inhalt)
        return inhalt
    return (either (const Nothing) Just (result :: Either IOException String))

speichereDatei :: FilePath -> String -> IO ()
speichereDatei datei inhalt = do
    let ordner = takeDirectory datei
    _ <- try (createDirectoryIfMissing True ordner >> writeFile datei inhalt)
        :: IO (Either IOException ())
    return ()


ladeSprache :: IO Sprache
ladeSprache = do
    datei <- settingsDatei
    inhalt <- ladeDatei datei
    return $ case inhalt of
        Just "English\n" -> English
        Just "English" -> English
        _ -> Deutsch


speichereSprache :: Sprache -> IO ()
speichereSprache sprache = do
    datei <- settingsDatei
    speichereDatei datei $ case sprache of
        Deutsch -> "Deutsch\n"
        English -> "English\n"

ladePasswortLaenge :: IO Int
ladePasswortLaenge = do
    datei <- praeferenzDatei "password-length"
    inhalt <- ladeDatei datei
    return $ case inhalt >>= readMaybe . trim of
        Just wert | wert >= 4 && wert <= 256 -> wert
        _ -> 16
  where
    trim = reverse . dropWhile (== '\n') . reverse

speicherePasswortLaenge :: Int -> IO ()
speicherePasswortLaenge wert = do
    datei <- praeferenzDatei "password-length"
    if wert >= 4 && wert <= 256
        then speichereDatei datei (show wert ++ "\n")
        else return ()

ladePassphraseWortmodus :: IO Bool
ladePassphraseWortmodus = do
    datei <- praeferenzDatei "passphrase-mode"
    inhalt <- ladeDatei datei
    return (maybe True ((== "words") . trim) inhalt)
  where
    trim = reverse . dropWhile (== '\n') . reverse

speicherePassphraseWortmodus :: Bool -> IO ()
speicherePassphraseWortmodus wortmodus = do
    datei <- praeferenzDatei "passphrase-mode"
    speichereDatei datei (if wortmodus then "words\n" else "blocks\n")

ladePassphraseWortlistenSprache :: IO String
ladePassphraseWortlistenSprache = do
    datei <- praeferenzDatei "passphrase-wordlist-language"
    inhalt <- ladeDatei datei
    return $ case fmap trim inhalt of
        Just "en" -> "en"
        _ -> "de"
  where
    trim = reverse . dropWhile (== '\n') . reverse

speicherePassphraseWortlistenSprache :: String -> IO ()
speicherePassphraseWortlistenSprache sprache = do
    datei <- praeferenzDatei "passphrase-wordlist-language"
    if sprache == "en" || sprache == "de"
        then speichereDatei datei (sprache ++ "\n")
        else return ()


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
