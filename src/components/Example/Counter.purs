module Hello.Components.Example.Counter (counter) where

import Prelude

import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Hello.Plugins.Core.Console as C
import Hello.Plugins.Core.UI as UI
import Reactix as R
import Reactix.DOM.HTML as H

type Props =
  ( initialCount :: Int
  )

counter :: UI.Leaf Props
counter = UI.leaf component

cname :: String
cname = "counter"

console :: C.Console
console = C.encloseContext C.Component cname

component :: R.Component Props
component = R.hooksComponent cname cpt where
  cpt props@{ initialCount } _ = do
    -- State hooks
    (count /\ setCount) <- R.useState' initialCount
    -- Effect hooks
    R.useEffect $ logMount
    -- Computed methods
    click <- pure $ \_event -> setCount $ onButtonClick >>> onButtonClick
    -- Render
    pure $

      H.div
      { className: "counter"
      }
      [ H.button
        { className: "counter__button"
        , on: { click }
        }
        [ H.text "Click here"
        ]

      , H.div
        { className: "counter__content"
        }
        [ H.text $ "Clicked on " <> show count <> " times"
        ]

      , if count < 5 then
          H.div
          { className: "counter__pop-text"
          }
          [ H.text "I will be displayed until count go to 5 and more"
          ]
        else
          mempty
      ]

onButtonClick :: Int -> Int
onButtonClick count = count + 1

logMount :: Effect (Effect Unit)
logMount = do
  console.log "mounted"
  pure $ console.log "unmounted"
