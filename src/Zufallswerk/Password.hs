{-# LANGUAGE OverloadedLabels #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE ScopedTypeVariables #-}

module Zufallswerk.Password
    ( kopiereZwischenablage
    , zeigePasswortFenster
    ) where

import qualified Zufallswerk.Core as Core
import System.Process
import System.Exit (ExitCode(..))
import System.Directory (findExecutable)
import System.Environment (lookupEnv)
import System.IO (hPutStr, hClose)
import Control.Exception (SomeException, IOException, try)
import Control.Concurrent (forkIO, threadDelay)
import qualified Data.Text as T

import qualified GI.Gtk as Gtk

import Zufallswerk.Language
import Zufallswerk.Settings (ladePasswortLaenge, speicherePasswortLaenge)

kopiereZwischenablage :: String -> IO (Either String ())
kopiereZwischenablage text = do
    command <- clipboardCommand
    case command of
        Nothing -> return (Left "Install wl-clipboard on Wayland or xclip on X11")
        Just (executable, arguments) -> do
            result <- try $ do
                (input, _, _, process) <- createProcess
                    (proc executable arguments) { std_in = CreatePipe }
                case input of
                    Nothing -> ioError (userError "Clipboard process did not provide stdin")
                    Just hin -> hPutStr hin text >> hClose hin
                threadDelay 50000
                exitCode <- getProcessExitCode process
                case exitCode of
                    Just (ExitFailure code) ->
                        ioError (userError (executable ++ " exited with code " ++ show code))
                    _ -> do
                        -- Clipboard owners can stay alive until another app
                        -- replaces the selection. Reap them off the GTK thread.
                        _ <- forkIO (waitForProcess process >> return ())
                        return ()
            case result of
                Left (exception :: SomeException) -> return (Left (show exception))
                Right () -> return (Right ())

clipboardCommand :: IO (Maybe (FilePath, [String]))
clipboardCommand = do
    wayland <- lookupEnv "WAYLAND_DISPLAY"
    let candidates = case wayland of
            Just (_:_) -> [("wl-copy", []), ("xclip", ["-selection", "clipboard"])]
            _ -> [("xclip", ["-selection", "clipboard"]), ("wl-copy", [])]
    choose candidates
  where
    choose [] = return Nothing
    choose ((name, arguments):rest) = do
        found <- findExecutable name
        case found of
            Just path -> return (Just (path, arguments))
            Nothing -> choose rest

zeigePasswortFenster :: Gtk.Window -> Sprache -> IO ()
zeigePasswortFenster parent sprache = do

    window <- Gtk.new Gtk.Window
        [ (#title Gtk.:= T.pack (passwortTitel sprache))
        , (#defaultWidth Gtk.:= 650)
        , (#defaultHeight Gtk.:= 540)
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

    defaultLength <- ladePasswortLaenge
    Gtk.spinButtonSetValue lengthSpin (fromIntegral defaultLength)

    _ <- Gtk.on lengthSpin #valueChanged $ do
        value <- Gtk.spinButtonGetValueAsInt lengthSpin
        speicherePasswortLaenge (fromIntegral value)

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

    entropyNote <- Gtk.new Gtk.Label
        [ (#label Gtk.:= T.pack (entropieHinweis sprache))
        , (#halign Gtk.:= Gtk.AlignStart)
        , (#wrap Gtk.:= True)
        ]
    Gtk.boxPackStart box entropyNote False False 0

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
                result <- try (Core.erzeugePasswort
                    (fromIntegral laenge)
                    zeichensatz) :: IO (Either IOException String)

                case result of
                    Left _ -> Gtk.labelSetText statusLabel (T.pack (generierungsFehler sprache))
                    Right passwort -> do
                        let entropie = Core.berechneEntropie
                                (fromIntegral laenge) (length zeichensatz)
                            staerke = Core.bewerteEntropie entropie
                        buffer <- Gtk.textViewGetBuffer resultView
                        Gtk.textBufferSetText buffer (T.pack passwort) (-1)
                        copied <- kopiereZwischenablage passwort
                        Gtk.labelSetText statusLabel
                            (T.pack (either (const (clipboardFehler sprache)) (const (passwortKopiert sprache)) copied))
                        Gtk.labelSetText entropyLabel (T.pack (passwortEntropie sprache entropie))
                        Gtk.labelSetText strengthLabel (T.pack (passwortStaerke sprache staerke))

    closeButton <- Gtk.new Gtk.Button
        [ (#label Gtk.:= T.pack (passwortSchliessen sprache))
        ]

    _ <- Gtk.on closeButton #clicked $
        Gtk.widgetDestroy window

    Gtk.boxPackEnd box closeButton False False 0

    Gtk.containerAdd window box
    Gtk.widgetShowAll window
