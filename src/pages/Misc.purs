module Hello.Pages.Misc (page, premount, layout) where

import Prelude

import Data.Maybe (Maybe(..))
import Data.Tuple.Nested ((/\))
import Effect.Aff (Aff, Milliseconds(..), delay, launchAff_)
import Effect.Class (liftEffect)
import Hello.Components.Bootstrap as B
import Hello.Plugins.Core.Console as C
import Hello.Plugins.Core.Layouts as Layouts
import Hello.Plugins.Core.Routes as RT
import Hello.Plugins.Core.Stores (RootStore)
import Hello.Plugins.Core.UI as UI
import Hello.Plugins.Hooks.LinkHandler (useLinkHandler)
import Hello.Plugins.Middlewares.Authenticated (authenticated)
import Reactix as R
import Reactix.DOM.HTML as H
import Toestand as T

page :: UI.Leaf()
page = UI.leaf component

layout :: Layouts.Layout
layout = Layouts.Dashboard

cname :: String
cname = "page-misc"

console :: C.Console
console = C.encloseContext C.Page cname

premount :: Record RootStore -> Aff Unit
premount rootStore = authenticated rootStore

component :: R.Component ()
component = R.hooksComponent cname cpt where
  cpt _ _ = do
    -- Custom hooks
    { route } <- useLinkHandler
    -- State
    onPending /\ onPendingBox <- UI.useBox' true
    -- Effects (simulate an async store action fetching data  and
    -- finishing after this page first render)
    R.useEffectOnce' $ launchAff_ do
      simulateAPIRequest
      liftEffect $ T.write_ false onPendingBox
    -- Render
    let
      cloakSlot =
        B.blankPlaceholder
        { className: cname <> "__placeholder" }

      defaultSlot =
        H.div
        { className: cname <> "__inner" }
        [
          H.h3 {} [ H.text "This is the Misc page" ]
        ,
          H.a
          { href: route RT.Home }
          [ H.text "go to home page" ]
        ,
          H.a
          { href: route RT.Authentication }
          [ H.text "go to auth page" ]
        ]

    pure $


      H.div
      { className: cname }
      [
        B.cloak
        { isDisplayed: not onPending
        , idlingPhaseDuration: Just 20
        , sustainingPhaseDuration: Just 400
        , cloakSlot
        , defaultSlot
        }
      ]

simulateAPIRequest :: Aff Unit
simulateAPIRequest = delay $ Milliseconds 3000.0
