module Hello.Plugins.Core.StartUp (startUp) where

import Prelude

import Data.Time.Duration (Milliseconds(..))
import Effect.Aff (delay, launchAff_)
import Effect.Class (liftEffect)
import Hello.Plugins.Core.Console as C
import Hello.Plugins.Core.UI as UI
import Hello.Plugins.Hooks.Stores (useStores)
import Reactix as R
import Toestand as T

startUp :: UI.Tree ()
startUp = UI.tree component

cname :: String
cname = "start-up"

console :: C.Console
console = C.encloseContext C.Plugin cname

component :: R.Component ()
component = R.hooksComponent cname cpt where
  cpt _ children = do
    rootStore <- useStores
    -- (?) Component will render only on start up computations done
    onPendingBox <- T.useBox false
    onPending <- UI.useLive' onPendingBox
    -- (?) Use this hooks as an entry point for every computations
    --     needed to be made pre-app-render (eg. Config API, etc.)
    R.useEffectOnce' $ launchAff_ do
      delay $ Milliseconds 1000.0
      liftEffect $ T.write_ true onPendingBox
      liftEffect $ console.log "start up done"

    pure $

      UI.if_ (onPending) $
        children
