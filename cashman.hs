{- Copyright Pranesh Srinivasan 2009 - 
 - Released under the GNU GPL 3 license -}
module Main where
import System.Environment
import System.Directory
import System.Time
import System.FilePath (pathSeparator)

{- The log for each friend is your asset with him. Money lent to him is 
 - a plus. Money borrowed from him is a minus -}

programName, programVersion, currency :: String
programName = "cashman"
programVersion = "0.2"
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
                , "report              -> make a report of the current status"
                , "\n"
                , "Each of the 'give' and 'take', can be optionally suffixed with a"
                , "string that acts as an annotation for the transfer \n\n"
                , "In all the above, amount is integral"
                , "\n"
                , "Examples : program's name is assumed to be " ++ programName
                , programName ++ " add smith    -> adds smith as a friend "
                , programName ++ " take smith 5 -> borrow 5 from Smith"
                , programName ++ " give smith 20 'coffee' -> lend Smith 20 for a cofee  \n\n "]

prefixDir :: IO FilePath
prefixDir = getUserDocumentsDirectory >>= (\x -> return (x ++ ps ++ "." ++ programName ++ ps)) 
                where ps = [pathSeparator]
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
              if e then readFile fname 
                  else do putStrLn "User Does Not Exist. The users in the system are : "
                          getUsers >>= putStrLn . unlines
                          putStrLn "Maybe you want to add him (yes/no)?"
                          ans <- getLine
                          if ans == "yes" ||  ans == "y" 
                              then addUser name >> readFile fname
                                else error "User not created."

-- Write file after check on the list of string as input
wfac :: String -> String -> IO ()
wfac name str = do fname <- makeFileName name 
                   putStrLn ((last . lines $  str) ++ name)
                   writeFile fname str

-- a small function for printing the money
showMoney :: Integer -> String
showMoney n | n < 0 = "You owe " ++ currency ++ " " ++ (show n) ++ " to "
            | n > 0 = "You need to get " ++ currency ++ " " ++ (show n) ++ " from "
            | otherwise = "Nothing lent/borrowed  "

{-======================================================================-}
readi :: String -> Integer
readi = read

listUsers :: [String] -> [String]
listUsers us = let  lex = length extension
                    rex = reverse extension
                    f x = take lex (reverse x) == rex
                    users = filter f us in 
                    if users == [] then ["No Users Found. You may want to use the add command."]
                        else map (reverse . drop lex . reverse) users

modifyAccount :: String -> String -> String -> String -> String -> String
modifyAccount amount log time file comment =  let
      lfile = lines file
      iamnt = readi (head lfile)
      amnt  = readi amount

      change iamnt "take" = iamnt - amnt
      change iamnt "give" = iamnt + amnt
      change iamnt "reset" = 0

      past "take" = "took " ++ amount
      past "give" = "gave " ++ amount
      past "reset" = "reset "
                   in 
                   concat [ show (change iamnt log) ++ "\n"
                           , unlines (tail lfile)
                           , time ++ " :: " ++ (past log) 
                              ++ "  " ++ comment ++ "\n"]

{-======================================================================-}
-- IO Functions

manageMoney :: String -> String -> String -> String -> IO ()
manageMoney name amount comment action = do  
                s <- rfac name
                time <- getTime
                wfac name $ modifyAccount amount action time s comment

addUser :: String -> IO ()
addUser name  = do fname  <- makeFileName name
                   exists <- doesFileExist fname
                   time   <- getTime
                   if exists then putStrLn "User already exists. Please delete user before adding."
                        else do wfac name $ unlines ["0", time ++ " :: User " ++ name ++  " Created"]

deleteUser :: String -> IO ()
deleteUser name = do fname  <- makeFileName name
                     exists <- doesFileExist fname
                     time   <- getTime
                     if exists 
                         then do putStrLn ("Are you Sure you want to remove " ++ name ++ " (yes/no) ? ")
                                 answer <- getLine
                                 if answer == "yes" then removeFile fname >> putStrLn ("Removed user " ++ name)
                                     else putStrLn ("Not removing " ++ name)
                         else putStrLn "No such user exists "

getUsers :: IO [String]
getUsers = prefixDir >>=getDirectoryContents >>= (return . listUsers)

{-======================================================================-}
-- Functions to make A report
readFirstLine :: String -> IO String
readFirstLine user = makeFileName user >>= readFile  >>= (return . head . lines)

padr, padl :: Int -> String ->  String
padl n s = take n (s ++ repeat ' ')
padr n s = reverse $ padl n (reverse s)

reportHeader = ["Each number shown is your asset with that person. In other words, a negative"
               ,"amount indicates that you owe the person, and a positive that the person owes"
               ,"you. \n\n"]
sumDebts :: [String] -> Integer
sumDebts u = sum . map readi $ u

makeReport :: IO ()
makeReport = do let lnames = 15 
                    lcash = 8
                    lline = lnames + lcash + 1
                users <- getUsers 
                userDebts <- mapM readFirstLine users
                putStr . unlines $ reportHeader
                putStr . unlines $ [padl lnames u ++ " " ++ padr lcash d | (u, d) <- zip users userDebts]
                putStrLn $ padr lline $ take lcash (repeat '-') 
                putStrLn $ padr lline $ show . sumDebts $ userDebts
                putStrLn $ "\n\n" ++ showMoney (sumDebts userDebts) ++ "others"

{-======================================================================-}

parseArgs :: [String] -> IO ()
parseArgs [] = putStrLn programUsage
parseArgs ["help"]               = putStrLn programUsage
parseArgs ["list"]               = getUsers >>= putStrLn . unlines 

-- Money Managing Functions
parseArgs ["take", name, amount]          = manageMoney name amount "" "take"
parseArgs ["take", name, amount, comment] = manageMoney name amount comment "take"

parseArgs ["give", name, amount]          = manageMoney name amount "" "give"
parseArgs ["give", name, amount, comment] = manageMoney name amount comment "give"

parseArgs ["reset", name]                 = manageMoney name "0" "" "reset"

-- Other Functions
parseArgs ["report"]             = makeReport
parseArgs ["show", name]         = rfac name >>= (\s -> putStrLn $ showMoney (read . head . lines $ s) ++ name)
parseArgs ["add", name]          = addUser name
parseArgs ["delete", name]       = deleteUser name
parseArgs ["history", name]      = rfac name >>= putStr . unlines . tail . lines 
-- error argument list
parseArgs argList                = putStrLn $ "Option Not Found \n\n" ++ programUsage

main = do args <- getArgs
          pd   <- prefixDir
          exist <- doesDirectoryExist pd
          if exist then parseArgs args
              else do
                    createDirectory pd
                    parseArgs args

