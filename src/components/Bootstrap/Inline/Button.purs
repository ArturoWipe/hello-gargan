module Hello.Components.Bootstrap.Button (button) where

import Prelude

import Data.Array (elem)
import Data.Foldable (intercalate)
import Effect (Effect)
import Hello.Components.Bootstrap.Spinner (spinner)
import Hello.Plugins.Core.Conditional ((?))
import Hello.Plugins.Core.UI as UI
import React.SyntheticEvent as SE
import Reactix as R
import Reactix.DOM.HTML as H

type Props =
  ( callback :: Unit -> Effect Unit
  | Options
  )

type Options =
  ( status    :: String
  , size      :: String
  , variant   :: String
  , type      :: String
  , className :: String
  , block     :: Boolean
  )

options :: Record Options
options =
  { status    : "enabled"
  , size      : "md"
  , variant   : "primary"
  , type      : "button"
  , className : ""
  , block     : false
  }

-- | Structural Component for the Bootstrap button
-- |
-- |    * size: `"md" (default) | "sm" | "lg"`
-- |
-- | https://getbootstrap.com/docs/4.0/components/buttons/
button :: forall r. UI.OptTree Options Props r
button = UI.optTree component options

componentName :: String
componentName = "b-button"

bootstrapName :: String
bootstrapName = "btn"

component :: R.Component Props
component = R.hooksComponent componentName cpt where
  cpt props@{ callback
            , status
            } children = do
    -- Computed
    className <- pure $ intercalate " "
      -- provided custom className
      [ props.className
      -- BEM classNames
      , componentName
      , componentName <> "--" <> status
      -- Bootstrap specific classNames
      , bootstrapName
      , bootstrapName <> "-" <> props.variant
      , bootstrapName <> "-" <> props.size
      , props.block == true ?
          bootstrapName <> "-block" $
          mempty
      ]
    -- @click
    click <- pure $ \event -> onClick status callback event
    -- Render
    pure $

      H.button
      { className
      , on: { click }
      , disabled: elem status [ "disabled", "deferred" ]
      , type: props.type
      }

      [ UI.if' (status == "deferred") $
          spinner
          { className: componentName <> "__spinner"
          }

      , H.span
        { className: componentName <> "__inner"
        }
        children
      ]

-- | Clicked event will effectively be triggered according to the
-- | component status props
onClick :: forall event.
     String
  -> (Unit -> Effect Unit)
  -> SE.SyntheticEvent_ event
  -> Effect Unit
onClick status callback event = do
  SE.preventDefault event
  if   status == "enabled"
  then callback unit
  else pure $ unit
