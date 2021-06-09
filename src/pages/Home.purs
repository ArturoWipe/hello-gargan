module Hello.Pages.Home (page, premount, layout) where

import Prelude

import Effect.Aff (Aff, Milliseconds(..), delay)
import Hello.Plugins.Core.Console as C
import Hello.Plugins.Core.Layouts as Layouts
import Hello.Plugins.Core.Routes as RT
import Hello.Plugins.Core.Stores (RootStore)
import Hello.Plugins.Core.UI as UI
import Hello.Plugins.Hooks.LinkHandler (useLinkHandler)
import Hello.Plugins.Middlewares.Authenticated (authenticated)
import Reactix as R
import Reactix.DOM.HTML as H

page :: UI.Leaf()
page = UI.leaf component

layout :: Layouts.Layout
layout = Layouts.Dashboard

cname :: String
cname = "page-home"

console :: C.Console
console = C.encloseContext C.Page cname

premount :: Record RootStore -> Aff Unit
premount rootStore = do
  -- Simulate a Store hydration via XHR/Graph
  authenticated rootStore
  delay $ Milliseconds 2000.0

component :: R.Component ()
component = R.hooksComponent cname cpt where
  cpt _ _ = do
    -- Custom hooks
    { route } <- useLinkHandler
    -- Render
    pure $

      H.div
      { className: cname }
      [
        H.h3 {} [ H.text "This is the Home page" ]
      , H.a
        { href: route RT.Misc }
        [ H.text "go to misc page" ]
      ]
