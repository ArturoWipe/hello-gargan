module Hello.Components.Bootstrap.FormInput (formInput) where

import Prelude

import Data.Foldable (elem, intercalate)
import Effect (Effect)
import Hello.Plugins.Core.UI as UI
import Reactix as R
import Reactix.DOM.HTML as H
import Unsafe.Coerce (unsafeCoerce)

type Props =
  ( callback :: String -> Effect Unit
  , value :: String
  | Options
  )

type Options =
  ( status :: String
  , className :: String
  , type :: String
  , placeholder :: String
  , size :: String
  )

options :: Record Options
options =
  { status: "enabled"
  , className: ""
  , type: "text"
  , placeholder: ""
  , size: "md"
  }

-- | Structural Component for the Bootstrap input
-- |
-- |    * size: `"md" (default) | "sm" | "lg"`
-- |
-- | https://getbootstrap.com/docs/4.0/components/forms/
formInput :: forall r.UI.OptLeaf Options Props r
formInput = UI.optLeaf component options

componentName :: String
componentName = "b-form-input"

bootstrapName :: String
bootstrapName = "form-control"

component :: R.Component Props
component = R.hooksComponent componentName cpt where
  cpt props@{ callback
            , status
            } _ = do
    -- Computed
    className <- pure $ intercalate " "
      -- provided custom className
      [ props.className
      -- BEM classNames
      , componentName
      , componentName <> "--" <> status
      -- Bootstrap specific classNames
      , bootstrapName
      , bootstrapName <> "-" <> props.size
      ]

    change <- pure $ onChange status callback
    -- Render
    pure $

      H.input
      { className
      , on: { change }
      , disabled: elem status [ "disabled" ]
      , readOnly: elem status [ "idled" ]
      , placeholder: props.placeholder
      , type: props.type
      , autoComplete: "off"
      }

-- | * Change event will effectively be triggered according to the
-- | component status props
-- | * Also directly returns the newly input value
-- | (usage not so different from `targetValue` of ReactBasic)
onChange :: forall event.
     String
  -> (String -> Effect Unit)
  -> event
  -> Effect Unit
onChange status callback event = do
  if   status == "enabled"
  then callback $ (unsafeCoerce event).target.value
  else pure $ unit
