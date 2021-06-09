module Hello.Components.Bootstrap.Icon (icon) where

import Prelude

import Data.Foldable (intercalate)
import Hello.Plugins.Core.UI as UI
import Reactix as R
import Reactix.DOM.HTML as H

type Props =
  ( name :: String
  | Options
  )

type Options =
  ( theme :: String
  , className :: String
  )

options :: Record Options
options =
  { theme: "filled"
  , className: ""
  }

-- | Structural Component for Material Design Icon
-- |
-- |    * theme: `"filled" (default) | "outlined"`
-- |
-- | https://fonts.google.com/icons?selected=Material+Icons
icon :: forall r. UI.OptLeaf Options Props r
icon = UI.optLeaf component options

cname :: String
cname = "b-icon"

component :: R.Component Props
component = R.hooksComponent cname cpt where
  cpt props@{ name } _ = do
    -- Computed
    className <- pure $ intercalate " "
      [ props.className
      , cname
      , cname <> "--" <> props.theme
      ]
    -- Render
    pure $

      H.span
      { className }
      [ H.text name ]
