{- Copyright Pranesh Srinivasan 2009 - 
 - Released under the GNU GPL 3 license -}
module Main where
import System.Environment
import System.Directory
import System.Time
import System.FilePath

{- The log for each friend is your asset with him. Money lent to him is 
 - a plus. Money borrowed from him is a minus -}

programName, programVersion, currency :: String
programName = "cashman"
programVersion = "0.1"
currency = "Rs."

programUsage, extension :: String
-- fix this later so that it works on windows
extension = ".frnd"
programUsage = unlines $ [ programName, "\n"
                , "Options"
                , "help                -> display this message"
                , "take  friend amount -> take amount money from friend "
                , "give  friend amount -> give amount money to friend "
                , "reset friend        -> reset money owed to/by friend to 0 (keeps logs)"
                , "show  friend        -> show money owed to/by friend"
                , "add   friend        -> add a friend with the name friend"
                , "history friend      -> display entire log history of friend"
                , "list                -> list all friends"
                , "\n"
                , "In all the above, amount is integral"
                , "\n"
                , "Examples : program's name is assumed to be " ++ programName
                , programName ++ " add smith    -> adds smith as a friend "
                , programName ++ " take smith 5 -> borrow 5 from Smith   \n\n "]

prefixDir :: IO FilePath
prefixDir = getUserDocumentsDirectory >>= (\x -> return (x ++ "/." ++ programName ++ "/"))
{-======================================================================-}
-- Utility Functions
-- =================

makeFileName :: String -> IO FilePath
makeFileName name = prefixDir >>= (\x -> return (x ++ name ++ extension))

getTime :: IO String
getTime = do [d, m, date, time, zone, year] <- getClockTime >>= (return . words . show)
             return (unwords [d, m, date, year])

-- Read File After Check
rfac :: String -> IO String
rfac name = do
              fname <- makeFileName name
              e <- doesFileExist fname
              if e then readFile fname else error "User Does not exist. Please use help."

-- Write file after check on the list of string as input
wfac :: String -> String -> IO ()
wfac name str = do fname <- makeFileName name 
                   putStrLn (last . lines $  str)
                   writeFile fname str


-- a small function for printing the money
showMoney :: Integer -> String
showMoney n | n < 0 = "You owe " ++ currency ++ " " ++ (show n) ++ " to "
            | n > 0 = "You need to get " ++ currency ++ " " ++ (show n) ++ " from "
            | otherwise = "Nothing lent/borrowed  "

{-======================================================================-}

readi :: String -> Integer
readi = read

listUsers us = let  lex = length extension
                    rex = reverse extension
                    f x = take lex (reverse x) == rex
                    users = filter f us in 
                    if users == [] then "No Users Found. You may want to use the add command."
                        else unlines (map (reverse . drop lex . reverse) users)

{-======================================================================-}

modifyAccount :: String -> String -> String -> String -> String
modifyAccount amount log time file = let lfile = lines file
                                         iamnt = readi (head lfile)
                                         amnt  = readi amount
                                         change iamnt "take" = iamnt - amnt
                                         change iamnt "give" = iamnt + amnt
                                         change iamnt "reset" = 0
                                         past "take" = "took " ++ amount
                                         past "give" = "gave " ++ amount
                                         past "reset" = "reset "
                                         in 
                                         unlines [ show (change iamnt log)
                                                 , unlines (tail lfile)
                                                 , time ++ " :: " ++ (past log)]

{-======================================================================-}

parseArgs :: [String] -> IO ()
parseArgs [] = putStrLn programUsage
parseArgs ["help"]               = putStrLn programUsage
parseArgs ["list"]               = do pd <- prefixDir 
                                      getDirectoryContents pd >>= (return . listUsers) >>= putStrLn

parseArgs ["take", name, amount] = do 
                                    s <- rfac name
                                    time <- getTime
                                    wfac name $ modifyAccount amount "take" time s

parseArgs ["give", name, amount] = do 
                                    s <- rfac name
                                    time <- getTime
                                    wfac name $ modifyAccount amount "give" time s

parseArgs ["reset", name] = do 
                                    s <- rfac name
                                    time <- getTime
                                    wfac name $ modifyAccount "0" "reset" time s

parseArgs ["show", name]         = do 
                                    s <- rfac name
                                    putStrLn $ showMoney (read . head . lines $ s) ++ name
                                    
parseArgs ["add", name]          = do
                                    fname  <- makeFileName name
                                    exists <- doesFileExist fname
                                    time   <- getTime
                                    if exists then putStrLn "User already exists. Please delete user before adding."
                                        else do wfac name $ unlines ["0", time ++ " :: User " ++ name ++  " Created"]
                                                
parseArgs ["delete", name]       = do
                                    fname  <- makeFileName name
                                    exists <- doesFileExist fname
                                    time   <- getTime
                                    if exists then removeFile fname >> putStrLn ("Removed user " ++ name)
                                        else putStrLn "No such user exists "

parseArgs ["history", name]      = do
                                    s <- rfac name
                                    putStrLn s
                                    
parseArgs argList                = putStrLn $ "Option Not Found \n\n" ++ programUsage

main = do args <- getArgs
          pd   <- prefixDir
          exist <- doesDirectoryExist pd
          if exist then parseArgs args
              else do
                    createDirectory pd
                    parseArgs args


