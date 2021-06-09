module Hello.Layouts.Dashboard (layout, premount) where

import Prelude

import Effect.Aff (Aff)
import Hello.Components.Layout.TheCommonDependencies (theCommonDependencies)
import Hello.Plugins.Core.Stores (RootStore)
import Hello.Plugins.Core.UI as UI
import Hello.Plugins.Middlewares.Authenticated (authenticated)
import Reactix as R
import Reactix.DOM.HTML as H

layout :: UI.Tree ()
layout = UI.tree component

cname :: String
cname = "layout-dashboard"

premount :: Record RootStore -> Aff Unit
premount rootStore = authenticated rootStore

component :: R.Component ()
component = R.hooksComponent cname cpt where
  cpt _ children = do
    -- Render
    pure $

      R.fragment
      [
        H.div
        { className: cname
        }
        [ H.div
          { className: cname <> "__header"
          }
          [
            H.img { src: "images/logoSmall.png" }
          ]

        , H.div
          { className: cname <> "__body" }
          [
            H.div
            { className: cname <> "__left-column"
            }
            [
              H.h6 {} [ H.text "menu" ]
            ]

          , H.div
            { className: cname <> "__right-column"
            }
            [ H.div
              { className: cname <> "__content card"
              }
              [
                H.div
                { className: "card-body" }
                children
              ]
            ]
          ]
        ]

      , theCommonDependencies {}
      ]
