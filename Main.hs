import qualified Data.ByteString as BS
import Data.Word
import System.IO
import System.Process
import System.Exit
import Text.Read (readMaybe)

klein, gross, zahlen, sonder :: String
klein  = ['a'..'z']
gross  = ['A'..'Z']
zahlen = ['0'..'9']
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
kopiereZwischenablage passwort = do
    (Just hin, _, _, _) <- createProcess
        (proc "xclip" ["-selection", "clipboard"])
            { std_in = CreatePipe }
    hPutStr hin passwort
    hClose hin

baueZeichensatz :: String -> String -> String -> String -> String
baueZeichensatz k g z s =
    concat
        [ if k == "TRUE" then klein else ""
        , if g == "TRUE" then gross else ""
        , if z == "TRUE" then zahlen else ""
        , if s == "TRUE" then sonder else ""
        ]

splitPipe :: String -> [String]
splitPipe "" = []
splitPipe xs =
    let (a, rest) = break (== '|') xs
    in a : case rest of
        []      -> []
        (_:ys)  -> splitPipe ys

passwortStaerke :: Int -> String -> String
passwortStaerke laenge zeichensatz
    | laenge >= 16 && length gruppen >= 4 = "Sehr stark"
    | laenge >= 12 && length gruppen >= 3 = "Stark"
    | laenge >= 8  && length gruppen >= 2 = "Mittel"
    | otherwise = "Schwach"
  where
    gruppen =
        [ ()
        | (aktiv, chars) <-
            [ (any (`elem` klein) zeichensatz, klein)
            , (any (`elem` gross) zeichensatz, gross)
            , (any (`elem` zahlen) zeichensatz, zahlen)
            , (any (`elem` sonder) zeichensatz, sonder)
            ]
        , aktiv
        ]

programmSchleife :: IO ()
programmSchleife = do
    (code, eingabe, _) <- readProcessWithExitCode
        "yad"
        [ "--form"
        , "--title=Zufallswerk"
        , "--width=420"
        , "--field=Passwortlänge"
        , "20"
        , "--field=Kleinbuchstaben:CHK"
        , "TRUE"
        , "--field=Großbuchstaben:CHK"
        , "TRUE"
        , "--field=Zahlen:CHK"
        , "TRUE"
        , "--field=Sonderzeichen:CHK"
        , "TRUE"
        , "--button=Generieren:0"
        , "--button=Beenden:1"
        ]
        ""

    case code of
        ExitFailure _ -> return ()

        ExitSuccess -> do
            let werte = splitPipe eingabe

            case werte of
                (laengeText:k:g:z:s:_) ->
                    case readMaybe laengeText :: Maybe Int of
                        Nothing -> fehler "Keine gültige Zahl." >> programmSchleife

                        Just laenge ->
                            if laenge < 1 || laenge > 256
                            then fehler "Bitte Länge zwischen 1 und 256 wählen." >> programmSchleife
                            else do
                                let zeichensatz = baueZeichensatz k g z s

                                if null zeichensatz
                                then fehler "Bitte mindestens einen Zeichensatz auswählen." >> programmSchleife
                                else do
                                    passwort <- erzeugePasswort laenge zeichensatz
                                    kopiereZwischenablage passwort
                                    let staerke = passwortStaerke laenge zeichensatz
                                    _ <- readProcessWithExitCode "yad"
                                        [ "--info"
                                        , "--no-markup"
                                        , "--title=Zufallswerk"
                                        , "--width=520"
                                        , "--text=Passwort erzeugt und in die Zwischenablage kopiert:\n\n"
                                                ++ passwort
                                                ++ "\n\nPasswortstärke: "
                                                ++ staerke
                                        , "--button=Weiteres Passwort:0"
                                        , "--button=Beenden:1"
                                        ]
                                        ""

                                    programmSchleife

                _ -> fehler "Unerwartete Eingabe." >> programmSchleife

fehler :: String -> IO ()
fehler text = do
    _ <- readProcessWithExitCode "yad"
        [ "--error"
        , "--title=Fehler"
        , "--text=" ++ text
        ]
        ""
    return ()

main :: IO ()
main = programmSchleife