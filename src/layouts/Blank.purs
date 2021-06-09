module Hello.Layouts.Blank (layout, premount) where

import Prelude

import Effect.Aff (Aff)
import Hello.Components.Layout.TheCommonDependencies (theCommonDependencies)
import Hello.Plugins.Core.Stores (RootStore)
import Hello.Plugins.Core.UI as UI
import Reactix as R
import Reactix.DOM.HTML as H

layout :: UI.Tree ()
layout = UI.tree component

cname :: String
cname = "layout-blank"

premount :: Record RootStore -> Aff Unit
premount _ = pure unit

component :: R.Component ()
component = R.hooksComponent cname cpt where
  cpt _ children = do
    -- Render
    pure $

      R.fragment
      [
        H.div
        { className: cname }
        children
      , theCommonDependencies {}
      ]
