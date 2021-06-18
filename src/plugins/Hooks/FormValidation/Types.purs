module Hello.Plugins.Hooks.FormValidation.Types
  ( VForm, EForm, Field
  , emailPattern
  ) where

import Prelude

import Data.Either (Either)
import Data.String.Regex (Regex)
import Data.Tuple (Tuple)
import Data.Validation.Semigroup (V)

foreign import emailPattern :: Regex

-- @TODO: types for errors (`Tuple Field String`)?

type Field = String

type EForm = Either (Array (Tuple Field String)) Unit
type VForm = V      (Array (Tuple Field String)) Unit
