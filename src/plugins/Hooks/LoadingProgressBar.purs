module Hello.Plugins.Hooks.LoadingProgressBar
  ( useLoadingProgressBar
  , Params
  ) where

import Prelude

import Data.Maybe (Maybe)
import Effect (Effect)
import Hello.Plugins.Core.UI as UI
import Hello.Plugins.Hooks.Stores (useStores)
import Hello.Stores.Core.Navigation as Store
import Reactix as R

-- @XXX: no CSS customisation rules (only JavaScript config object)
type Params =
  ( className :: String
  , thickness :: Int
  , color     :: String -- eg. "rgb(1, 2, 3)"
  , boxShadow :: Maybe String
  )

foreign import showTopbar :: Effect Unit
foreign import hideTopbar :: Effect Unit
foreign import configTopbar :: Record Params -> Effect Unit

-- | Adapting "topbar" foreign library
-- | As the library is pretty simple, we can only have one instance per app
-- |
-- | https://www.cssscript.com/customizable-top-loading-progress-bar-topbar/
useLoadingProgressBar :: Record Params -> R.Hooks (Unit)
useLoadingProgressBar params = do
  -- Store
  { "core/navigation": store } <- useStores
  mode <- UI.useLive' store.mode
  -- Configuring & adapting "topbar" foreign library
  R.useEffectOnce' $ configTopbar params

  R.useEffect1' mode $ case mode of
    Store.Fetching -> showTopbar
    Store.Idling   -> hideTopbar
