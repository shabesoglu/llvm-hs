{-# LANGUAGE
  CPP,
  OverloadedStrings,
  RecordWildCards,
  ScopedTypeVariables
  #-}
module LLVM.Test.Target where

import Test.Tasty
import Test.Tasty.HUnit
import Test.Tasty.QuickCheck
import Test.QuickCheck

import Control.Applicative
import Control.Monad
import Control.Monad.IO.Class
import qualified Data.ByteString.Char8 as ByteString
import Data.Char
import Data.Map (Map)
import Foreign.C.String

import LLVM.Context
import LLVM.Internal.Coding
import LLVM.Internal.EncodeAST
import LLVM.Internal.DecodeAST
import LLVM.Target
import LLVM.Target.Options
import LLVM.Target.LibraryFunction

instance Arbitrary FloatABI where
  arbitrary = elements [minBound .. maxBound]

instance Arbitrary FloatingPointOperationFusionMode where
  arbitrary = elements [minBound .. maxBound]

instance Arbitrary Options where
  arbitrary = do
    printMachineCode <- arbitrary
    unsafeFloatingPointMath <- arbitrary
    noInfinitiesFloatingPointMath <- arbitrary
    noNaNsFloatingPointMath <- arbitrary
    honorSignDependentRoundingFloatingPointMathOption <- arbitrary
    noZerosInBSS <- arbitrary
    guaranteedTailCallOptimization <- arbitrary
    enableFastInstructionSelection <- arbitrary
    useInitArray <- arbitrary
    disableIntegratedAssembler <- arbitrary
    compressDebugSections <- arbitrary
    trapUnreachable <- arbitrary
    stackAlignmentOverride <- arbitrary
    floatABIType <- arbitrary
    allowFloatingPointOperationFusion <- arbitrary
    return Options { .. }

instance Arbitrary DebugCompressionType where
  arbitrary = elements [CompressNone, CompressGNU, CompressZ]

arbitraryASCIIString :: Gen String
#if MIN_VERSION_QuickCheck(2,10,0)
arbitraryASCIIString = getASCIIString <$> arbitrary
#else
arbitraryASCIIString = arbitrary
#endif

instance Arbitrary CPUFeature where
  arbitrary = CPUFeature . ByteString.pack <$>
    suchThat arbitraryASCIIString (\s -> not (null s) && all isAlphaNum s)

tests = testGroup "Target" [
  testGroup "Options" [
     testProperty "basic" $ \options -> ioProperty $ do
       withTargetOptions $ \to -> do
         pokeTargetOptions options to
         options' <- peekTargetOptions to
         return $ options === options'
   ],
  testGroup "LibraryFunction" [
    testGroup "set-get" [
       testCase (show lf) $ do
         triple <- getDefaultTargetTriple
         withTargetLibraryInfo triple $ \tli -> do
           setLibraryFunctionAvailableWithName tli lf "foo"
           nm <- getLibraryFunctionName tli lf
           nm @?= "foo"
       | lf <- [minBound, maxBound]
     ],
    testCase "get" $ do
      triple <- getDefaultTargetTriple
      withTargetLibraryInfo triple $ \tli -> do
        lf <- getLibraryFunction tli "printf"
        lf @?= Just LF__printf
   ],
  testCase "Host" $ do
    features <- getHostCPUFeatures
    return (),
  testGroup "CPUFeature" [
    testProperty "roundtrip" $ \cpuFeatures -> ioProperty $
        withContext $ \context -> runEncodeAST context $ do
          encodedFeatures :: CString <- (encodeM cpuFeatures)
          decodedFeatures :: Map CPUFeature Bool <- liftIO $ runDecodeAST (decodeM encodedFeatures)
          return (cpuFeatures == decodedFeatures)

   ]
 ]
