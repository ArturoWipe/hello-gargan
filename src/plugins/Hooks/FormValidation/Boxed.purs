module Hello.Plugins.Hooks.FormValidation.Boxed
  ( class Equals, equals
  , class NonEmpty, nonEmpty
  , class Minimum, minimum
  , class Maximum, maximum
  , lowercase, uppercase, email
  ) where

import Prelude

import Data.String (toLower, toUpper)
import Data.String.CodeUnits (length)
import Data.String.Regex (test)
import Data.Tuple.Nested ((/\))
import Data.Validation.Semigroup (invalid)
import Effect (Effect)
import Hello.Plugins.Hooks.FormValidation.Types (Field, VForm, emailPattern)
import Toestand as T

class Eq a <= Equals a where
  equals :: Field -> T.Box a -> T.Box a -> Effect VForm

class NonEmpty a where
  nonEmpty :: Field -> T.Box a -> Effect VForm

class Ord a <= Minimum a where
  minimum :: Field -> T.Box a -> Int -> Effect VForm

class Ord a <= Maximum a where
  maximum :: Field -> T.Box a -> Int -> Effect VForm

-- Regarding String field value

instance equalsString :: Equals String where
  equals field box box' = do
    input  <- T.read box
    input' <- T.read box'
    case unit of
      _
        | (not eq input input') -> pure $ invalid [ field /\ "equals" ]
        | otherwise             -> pure $ pure unit

instance nonEmptyString :: NonEmpty String where
  nonEmpty field = T.read >=> case _ of
    input
      | input == "" -> pure $ invalid [ field /\ "nonEmpty" ]
      | otherwise   -> pure $ pure unit

instance minimumString :: Minimum String where
  minimum field box min = T.read box >>= case _ of
    input
      | (length input) < min -> pure $ invalid [ field /\ "minimum" ]
      | otherwise            -> pure $ pure unit

instance maximumString :: Maximum String where
  maximum field box max = T.read box >>= case _ of
    input
      | (length input) > max -> pure $ invalid [ field /\ "maximum" ]
      | otherwise            -> pure $ pure unit

uppercase :: Field -> T.Box String -> Effect VForm
uppercase field = T.read >=> case _ of
  input
    | (toLower input) == input -> pure $ invalid [ field /\ "uppercase" ]
    | otherwise                -> pure $ pure unit

lowercase :: Field -> T.Box String -> Effect VForm
lowercase field = T.read >=> case _ of
  input
    | (toUpper input) == input -> pure $ invalid [ field /\ "lowercase" ]
    | otherwise                -> pure $ pure unit

email :: Field -> T.Box String -> Effect VForm
email field = T.read >=> case _ of
  input
    | (not $ test emailPattern input) -> pure $ invalid [ field /\ "email" ]
    | otherwise                       -> pure $ pure unit
