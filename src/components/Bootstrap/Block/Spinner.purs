module Hello.Components.Bootstrap.Spinner(spinner) where

import Prelude

import Data.Foldable (intercalate)
import Hello.Plugins.Core.UI as UI
import Reactix as R
import Reactix.DOM.HTML as H

type Props   = ( | Options)
type Options =
  ( theme :: String
  , className :: String
  )

options :: Record Options
options =
  { theme: "border"
  , className: ""
  }

-- | Structural Component for the Bootstrap spinner
-- |
-- |    * theme: `"border" (default) | "grow"`
-- |
-- | https://getbootstrap.com/docs/4.4/components/spinners/
spinner :: forall r. UI.OptLeaf Options Props r
spinner = UI.optLeaf component options

componentName :: String
componentName = "b-spinner"

bootstrapName :: String
bootstrapName = "spinner"

component :: R.Component Props
component = R.hooksComponent componentName cpt where
  cpt props _ = do
    -- Computed
    className <- pure $ intercalate " "
      -- provided custom className
      [ props.className
      -- BEM classNames
      , componentName
      -- Bootstrap specific classNames
      , bootstrapName <> "-" <> props.theme
      ]
    -- Render
    pure $

      H.div
      { className }
      []
