module Main where

import Control.Monad (unless)
import Zufallswerk.Core

assert :: String -> Bool -> IO ()
assert name condition = unless condition (ioError (userError ("FAIL: " ++ name)))

main :: IO ()
main = do
    assert "password entropy" (abs (berechneEntropie 10 2 - 10) < 0.000001)
    assert "word entropy" (abs (berechnePassphraseEntropie 3 7776 - 38.775) < 0.01)
    assert "strength thresholds" (bewerteEntropie 39 == "Sehr schwach" && bewerteEntropie 100 == "Sehr stark")
    assert "group counting" (anzahlGruppen (klein ++ zahlen) == 2)
    assert "separator join" (verbindeMit "-" ["eins", "zwei", "drei"] == "eins-zwei-drei")
    assert "empty join" (verbindeMit "." [] == "")
    putStrLn "Core tests passed."
