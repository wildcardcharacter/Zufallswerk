import qualified Data.ByteString as BS
import Data.Word
import System.IO
import System.Process
import Text.Read (readMaybe)
import Control.Exception (SomeException, try)

zeichen :: String
zeichen =
    ['a'..'z']
    ++ ['A'..'Z']
    ++ ['0'..'9']
    ++ "!@#$%&*-_?"

byteZuZeichen :: Word8 -> Char
byteZuZeichen b =
    zeichen !! (fromIntegral b `mod` length zeichen)

erzeugePasswort :: Int -> IO String
erzeugePasswort laenge = do
    h <- openBinaryFile "/dev/urandom" ReadMode
    bytes <- BS.hGet h laenge
    hClose h
    return (map byteZuZeichen (BS.unpack bytes))

programmSchleife :: IO ()
programmSchleife = do
    ergebnis <- try (
        readProcess
            "yad"
            [ "--form"
            , "--title=Zufallswerk"
            , "--width=350"
            , "--field=Passwortlänge"
            , "20"
            , "--button=Generieren:0"
            , "--button=Beenden:1"
            ]
                        "") :: IO (Either SomeException String)

    case ergebnis of
        Left _ ->
            return ()

        Right eingabe -> do
            let sauber = takeWhile (/= '|') eingabe

            case readMaybe sauber :: Maybe Int of
                Nothing -> do
                    _ <- readProcess "yad"
                        [ "--error"
                        , "--title=Fehler"
                        , "--text=Keine gültige Zahl."
                        ]
                        ""
                    programmSchleife

                Just laenge ->
                    if laenge < 1 || laenge > 256
                    then do
                        _ <- readProcess "yad"
                            [ "--error"
                            , "--title=Fehler"
                            , "--text=Bitte Länge zwischen 1 und 256 wählen."
                            ]
                            ""
                        programmSchleife
                    else do
                        passwort <- erzeugePasswort laenge

                        _ <- readProcess "yad"
                            [ "--info"
                            , "--no-markup"
                            , "--title=Zufallswerk"
                            , "--width=500"
                            , "--text=Passwort erzeugt:\n\n" ++ passwort
                            ]
                            ""

                        programmSchleife

main :: IO ()
main = programmSchleife