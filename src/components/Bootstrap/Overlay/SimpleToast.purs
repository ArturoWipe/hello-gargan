module Hello.Components.Bootstrap.SimpleToast
  ( simpleToast
  , Props
  ) where

import Prelude

import Data.Foldable (intercalate)
import Data.Maybe (Maybe(..), isJust)
import Hello.Plugins.Core.Conditional ((?))
import Hello.Plugins.Core.UI as UI
import Reactix as R
import Reactix.DOM.HTML as H

type Props =
  ( variant :: String
  , ttl :: Maybe Int
  )

-- | Used in conjunction with **Hello.Plugins.Hooks.Toast**
-- | Structural adapter of the Bootstrap Toasts
-- |
-- |  * variant: `"light" | "success" | "warning" | "error" | "info"`
-- |
-- |  * time-to-live: `Nothing | milliseconds :: Int`
-- |
-- |      ↳ with UI close button if persistent
-- |
-- | https://getbootstrap.com/docs/4.3/components/toasts/
simpleToast :: UI.Tree Props
simpleToast = UI.tree component

componentName :: String
componentName = "b-simple-toast"

bootstrapName :: String
bootstrapName = "toast"

component :: R.Component Props
component = R.hooksComponent componentName cpt where
  cpt props@{ variant
            , ttl
            } children = do
    -- Computed
    className <- pure $ intercalate " "
      -- BEM classNames
      [ componentName
      , componentName <> "--" <> variant
      , isJust ttl ?
          componentName <> "--autohide" $
          mempty
      -- Bootstrap classNames
      , bootstrapName
      ]
    -- Render
    pure $

      H.div

        { className
        , role: "alert"
        , "aria-live": "assertive"
        , "aria-atomic": "true"
        , "data-animation": "true"

        , "data-autohide":  case ttl of
                              Nothing -> "false"
                              Just t  -> "true"

        , "data-delay":     case ttl of
                              Nothing -> "0"
                              Just t  -> show t
        }
        [
          H.div
          { className: componentName <> "__inner" }
          [
            H.div
            { className: bootstrapName <> "-header" }
            [
              H.button
              { type: "button"
              , className: "close"
              , "data-dismiss": "toast"
              , "aria-label": "Close"
              }
              [ H.span { "aria-hidden": true } [ H.text "✕" ] ]
            ]

          , H.div
            { className: bootstrapName <> "-body" }
            children

          ]
        ]
