module Hello.Plugins.Core.App (app) where

import Prelude

import Data.Maybe (Maybe(..))
import Hello.Plugins.Core.Console as C
import Hello.Plugins.Core.Router (router)
import Hello.Plugins.Core.StartUp (startUp)
import Hello.Plugins.Core.UI as UI
import Hello.Plugins.Hooks.LoadingProgressBar as Bar
import Reactix as R

app :: UI.Leaf ()
app = UI.leaf component

cname :: String
cname = "app"

console :: C.Console
console = C.encloseContext C.Plugin cname

component :: R.Component ()
component = R.hooksComponent cname cpt where
  cpt _ _ = do
    R.useEffectOnce $ R.thenNothing $ console.log "mounted"
    -- Custom hooks
    Bar.useLoadingProgressBar loadingProgressBarParams
    -- Render
    pure $

      startUp {}
      [ router {}
      ]


loadingProgressBarParams :: Record Bar.Params
loadingProgressBarParams =
  { className : "loading-progress-bar"
  , thickness : 2
  , color     : "#0275D8" -- ie. $c-primary
  , boxShadow : Just "rgba(100, 100, 100, 0.1)"
  }
