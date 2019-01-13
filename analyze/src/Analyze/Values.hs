-- | Simple value types and functions.
module Analyze.Values where

import           Analyze.Common      (Key)
import           Control.Monad.Catch (Exception, MonadThrow (..))
import           Data.Text           (Text)
import           Data.Typeable       (Typeable)

class ToValue v where
  toValue :: v -> Value

instance ToValue Int where toValue = VInt
instance ToValue Integer where toValue = VInteger
instance ToValue Double where toValue = VDouble
instance ToValue Char where toValue = VChar
instance ToValue Text where toValue = VText
instance ToValue Bool where toValue = VBool

-- | Singleton type for value types.
data ValueType =
    VTypeText
  | VTypeChar
  | VTypeInteger
  | VTypeInt  
  | VTypeDouble
  | VTypeBool
  deriving (Show, Eq, Enum, Bounded)

-- | Union type for values.
data Value =
    VText Text
  | VChar Char
  | VInteger Integer
  | VInt Int  
  | VDouble Double
  | VBool Bool
  deriving (Show, Eq)

-- | Returns the type of the value.
valueToType :: Value -> ValueType
valueToType (VText _)    = VTypeText
valueToType (VChar _)    = VTypeChar
valueToType (VInteger _) = VTypeInteger
valueToType (VInt _)     = VTypeInt
valueToType (VDouble _)  = VTypeDouble
valueToType (VBool _)    = VTypeBool

-- | Extracts 'Text' from the 'Value'.
getText :: Value -> Maybe Text
getText (VText s) = Just s
getText _         = Nothing

-- | Extracts 'Integer' from the 'Value'.
getInteger :: Value -> Maybe Integer
getInteger (VInteger i) = Just i
getInteger _            = Nothing

-- | Extracts 'Int' from the 'Value'.
getInt :: Value -> Maybe Int
getInt (VInt i) = Just i
getInt _        = Nothing

-- | Extracts 'Double' from the 'Value'.
getDouble :: Value -> Maybe Double
getDouble (VDouble d) = Just d
getDouble _           = Nothing

-- | Extracts 'Bool' from the 'Value'.
getBool :: Value -> Maybe Bool
getBool (VBool b) = Just b
getBool _         = Nothing

-- | Exception for when we encounder unexpected values.
data ValueTypeError k = ValueTypeError k ValueType Value deriving (Show, Eq, Typeable)
instance (Show k, Typeable k) => Exception (ValueTypeError k)

-- | Use with 'Analyze.Decoding.requireWhere' to read 'Text' values.
textual :: (Key k, MonadThrow m) => k -> Value -> m Text
textual _ (VText s) = pure s
textual k v             = throwM (ValueTypeError k VTypeText v)

-- | Use with 'Analyze.Decoding.requireWhere' to read 'Integer' values.
integral :: (Key k, MonadThrow m) => k -> Value -> m Integer
integral _ (VInteger s) = pure s
integral k v                = throwM (ValueTypeError k VTypeInteger v)

-- | Use with 'Analyze.Decoding.requireWhere' to read 'Double' values.
floating :: (Key k, MonadThrow m) => k -> Value -> m Double
floating _ (VDouble s) = pure s
floating k v               = throwM (ValueTypeError k VTypeDouble v)

-- | Use with 'Analyze.Decoding.requireWhere' to read 'Bool' values.
boolean :: (Key k, MonadThrow m) => k -> Value -> m Bool
boolean _ (VBool s) = pure s
boolean k v             = throwM (ValueTypeError k VTypeBool v)
