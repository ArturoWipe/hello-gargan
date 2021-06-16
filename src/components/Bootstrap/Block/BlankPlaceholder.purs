module Hello.Components.Bootstrap.BlankPlaceholder
  ( blankPlaceholder
  ) where

import Prelude

import Data.Foldable (intercalate)
import Hello.Plugins.Core.UI as UI
import Reactix as R
import Reactix.DOM.HTML as H


type Props   = ( | Options )
type Options =
  ( className :: String
  )

options :: Record Options
options =
  { className: ""
  }

-- | Blank content placeholder for "Placeholder Component" (see Cookbook
-- | component patterns in project wiki)
-- |
-- |    * used as a background placeholder
-- |    * taking full size of its parent
-- |    * best on `$white` parent background
blankPlaceholder :: forall r. UI.OptLeaf Options Props r
blankPlaceholder = UI.optLeaf component options

cname :: String
cname = "b-blank-placeholder"

component :: R.Component Props
component = R.hooksComponent cname cpt where
  cpt props _ = do
    -- Computed
    className <- pure $ intercalate " "
      -- provided custom className
      [ props.className
      -- BEM clasNames
      , cname
      ]
    -- Render
    pure $

      H.div
      { className }
      [ H.div
        { className: cname <> "__sweeper" }
        [ H.text "" ]
      ]
