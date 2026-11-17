{-# LANGUAGE OverloadedStrings #-}

module Zufallswerk.Updater
    ( Release(..)
    , latestRelease
    , installedPackageVersion
    , installRelease
    ) where

import Control.Exception (SomeException, try)
import Data.Char (isSpace)
import System.Directory (createDirectoryIfMissing, getXdgDirectory, XdgDirectory(..))
import System.Exit (ExitCode(..))
import System.FilePath ((</>))
import System.Process (readProcessWithExitCode)

data Release = Release
    { releaseVersion :: String
    , releaseAssetUrl :: String
    , releasePageUrl :: String
    } deriving (Eq, Show)

repo :: String
repo = "wildcardcharacter/Zufallswerk"

latestRelease :: IO (Either String Release)
latestRelease = do
    archResult <- (try $ readProcessWithExitCode "dpkg" ["--print-architecture"] "")
        :: IO (Either SomeException (ExitCode, String, String))
    case archResult of
        Left err -> pure (Left ("Die Debian-Architektur konnte nicht ermittelt werden: " ++ show err))
        Right (ExitSuccess, arch, _) -> do
            result <- try $ readProcessWithExitCode "python3" ["-c", releaseScript, trim arch] ""
            pure $ case result of
                Left err -> Left ("GitHub konnte nicht abgefragt werden: " ++ show (err :: SomeException))
                Right (ExitSuccess, output, _) -> case lines output of
                    (version:assetUrl:pageUrl:_) -> Right (Release version assetUrl pageUrl)
                    _ -> Left "GitHub hat unvollständige Release-Daten zurückgegeben."
                Right (_, _, err) -> Left (nonEmpty err "Das GitHub-Release konnte nicht gefunden werden.")
        Right (_, _, err) -> pure (Left (nonEmpty err "Die Debian-Architektur konnte nicht ermittelt werden."))
  where
    releaseScript = unlines
        [ "import json, sys, urllib.request"
        , "repo = '" ++ repo ++ "'"
        , "req = urllib.request.Request('https://api.github.com/repos/' + repo + '/releases/latest', headers={'Accept': 'application/vnd.github+json', 'User-Agent': 'Zufallswerk'})"
        , "with urllib.request.urlopen(req, timeout=20) as response: release = json.load(response)"
        , "tag = str(release.get('tag_name', '')).strip()"
        , "version = tag[1:] if tag[:1].lower() == 'v' else tag"
        , "asset_name = 'zufallswerk_' + version + '_' + sys.argv[1] + '.deb'"
        , "assets = release.get('assets', [])"
        , "asset = next((item for item in assets if item.get('name') == asset_name), {})"
        , "print(version)"
        , "print(asset.get('browser_download_url', ''))"
        , "print(release.get('html_url', 'https://github.com/' + repo + '/releases/latest'))"
        ]

installedPackageVersion :: IO (Maybe String)
installedPackageVersion = do
    result <- (try $ readProcessWithExitCode "dpkg-query"
        ["-W", "-f=${Status}\n${Version}", "zufallswerk"] "")
        :: IO (Either SomeException (ExitCode, String, String))
    pure $ case result of
        Right (ExitSuccess, output, _) -> case lines output of
            ("install ok installed":version:_) -> Just (dropEpoch version)
            _ -> Nothing
        _ -> Nothing
  where
    dropEpoch version = case break (== ':') version of
        (_, []) -> version
        (_, _:rest) -> rest

installRelease :: Release -> IO (Either String ())
installRelease release = do
    result <- try $ do
        cache <- getXdgDirectory XdgCache "zufallswerk/updates"
        createDirectoryIfMissing True cache
        let package = cache </> ("zufallswerk_" ++ releaseVersion release ++ ".deb")
        download <- readProcessWithExitCode "python3" ["-c", downloadScript, releaseAssetUrl release, package] ""
        case download of
            (ExitSuccess, _, _) -> do
                install <- readProcessWithExitCode "pkexec" ["apt-get", "install", "-y", package] ""
                pure $ case install of
                    (ExitSuccess, _, _) -> Right ()
                    (_, _, err) -> Left (nonEmpty err "Die Paketinstallation wurde abgebrochen oder ist fehlgeschlagen.")
            (_, _, err) -> pure (Left (nonEmpty err "Das Updatepaket konnte nicht heruntergeladen werden."))
    pure $ case result of
        Left err -> Left ("Update fehlgeschlagen: " ++ show (err :: SomeException))
        Right outcome -> outcome
  where
    downloadScript = unlines
        [ "import shutil, sys, urllib.request"
        , "url, path = sys.argv[1], sys.argv[2]"
        , "if not url.startswith('https://github.com/') and not url.startswith('https://objects.githubusercontent.com/'): raise ValueError('Ungültige Download-Adresse')"
        , "req = urllib.request.Request(url, headers={'User-Agent': 'Zufallswerk'})"
        , "with urllib.request.urlopen(req, timeout=60) as response, open(path, 'wb') as output: shutil.copyfileobj(response, output)"
        , "if __import__('os').path.getsize(path) < 1024: raise ValueError('Das heruntergeladene Paket ist unerwartet klein')"
        ]

trim :: String -> String
trim = reverse . dropWhile isSpace . reverse . dropWhile isSpace

nonEmpty :: String -> String -> String
nonEmpty value fallback = case trim value of
    "" -> fallback
    other -> other
