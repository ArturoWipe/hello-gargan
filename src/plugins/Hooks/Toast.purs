module Hello.Plugins.Hooks.Toast
  ( useToast
  ) where

import Prelude

import DOM.Simple (document)
import Data.Maybe (Maybe(..))
import Data.Nullable (toMaybe)
import Effect (Effect)
import FFI.Simple ((...))
import Hello.Components.Bootstrap.SimpleToast (simpleToast, Props)
import Hello.Plugins.Core.UI as UI
import Reactix as R
import Reactix.DOM.HTML as H

foreign import generateRandomId :: Effect String
foreign import createToastWrapper :: String -> Effect Unit
foreign import showToast :: Effect Unit

type Methods =
  ( light   :: String -> Effect Unit
  , success :: String -> Effect Unit
  , warning :: String -> Effect Unit
  , error   :: String -> Effect Unit
  , info    :: String -> Effect Unit

  , show    :: Record Props -> Array R.Element -> Effect Unit
  )

-- | Popup a Simple Toast on screen
-- |
-- | ```purescript
-- | toast <- useToast
-- | ...
-- | -- use the provided sugared method
-- | -- (autohiding toast)
-- | toast.light "Hello!"
-- | ...
-- | -- of prefer the configurable one
-- | toast.show { variant: "error", ttl: Nothing } [ H.text "Error here" ]
-- | ```
useToast :: R.Hooks (Record Methods)
useToast =
  let
    props :: String -> Record Props
    props    = { variant: _, ttl: Just 5000 }

    children :: String -> Array R.Element
    children s = [ H.text s ]

  in
    pure
      { light   : \s -> render $ simpleToast (props "light")   (children s)
      , success : \s -> render $ simpleToast (props "success") (children s)
      , warning : \s -> render $ simpleToast (props "warning") (children s)
      , error   : \s -> render $ simpleToast (props "error")   (children s)
      , info    : \s -> render $ simpleToast (props "info")    (children s)

      , show    : \a -> \b -> render $ simpleToast a b
      }


render :: R.Element -> Effect Unit
render toast = do
  randomId <- generateRandomId
  createToastWrapper randomId
  el <- pure $ document ... "querySelector" $ [ "#" <> randomId ]
  UI.inject (toast) (toMaybe el)
  showToast
