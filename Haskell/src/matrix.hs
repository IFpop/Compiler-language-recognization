{-# LANGUAGE BangPatterns #-}
import Text.Printf
import System.CPUTime
import Control.DeepSeq
import Data.Array.ST
import Data.Array.Unboxed
import System.IO

-- 使用句柄读写文件
hGetLines :: Handle -> IO [String]
hGetLines h = do fileOk <- hIsOpen h
                 fileEof <- hIsEOF h
                 if fileOk && not fileEof
                 then do current <- hGetLine h
                         others  <- hGetLines h
                         return $ current:others
                 else return []

-- 对文件进行分割
split :: Eq a => a -> [a] -> [[a]]
split symbol [] = []
split symbol s = x : split symbol (drop 1 y) where (x,y) = span (/= symbol) s

-- 将字符串变为整数
makeInteger :: [String] -> [Int]
makeInteger = map read 

-- 进行切割
matrix str = makeInteger (split ' ' str)
makeMatrix = map matrix

fold _ _ u [] _          = u
fold _ _ u _ []          = u
fold f g u (x:as) (y:bs) = fold f g (g u (f x y)) as bs

fold1 f g (x:as) (y:bs) = fold f g (f x y) as bs

mul as bs = map (\us -> fold1 (\u vs -> map ((*) u) vs) (zipWith (+)) us bs) as

main = do
    printf "Matrix multiplication implemented by Haskell.\n"
    -- 读取文件A
    h1 <- openFile ("dataA.txt") ReadMode
    contentA <- hGetLines h1
    -- 将其构造出矩阵
    let a = makeMatrix contentA
    -- 读取文件B
    h2 <- openFile ("dataB.txt") ReadMode
    -- 将其构造成矩阵
    contentB <- hGetLines h2
    let b = makeMatrix contentB
    start <- getCPUTime 
    let ans = mul a b
    end <- ans `deepseq` getCPUTime 
    let diff = (fromIntegral (end - start)) / (10^9)
    printf "cost time: %.0f ms.\n" (diff :: Double)