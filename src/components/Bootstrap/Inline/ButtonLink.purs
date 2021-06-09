module Hello.Components.Bootstrap.ButtonLink (buttonLink) where

import Prelude

import Data.Foldable (elem, intercalate)
import Effect (Effect)
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
  , className :: String
  )

options :: Record Options
options =
  { status    : "enabled"
  , className : ""
  }

buttonLink :: forall r. UI.OptTree Options Props r
buttonLink = UI.optTree component options

cname :: String
cname = "b-button-link"

component :: R.Component Props
component = R.hooksComponent cname cpt where
  cpt props@{ callback
            , status
            } children = do
    -- Computed
    className <- pure $ intercalate " "
      -- provided custom className
      [ props.className
      -- BEM classNames
      , cname
      , cname <> "--" <> status
      ]
    -- @onClick
    click <- pure $ \event -> onClick status callback event
    -- Render
    pure $

      H.a
      { className
      , on: { click }
      , "aria-disabled": elem status [ "disabled" ]
      }

      children

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
