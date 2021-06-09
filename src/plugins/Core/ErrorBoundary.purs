module Hello.Plugins.Core.ErrorBoundary where

import Prelude

import Data.Maybe (Maybe(..), fromMaybe)
import Data.Symbol (SProxy(..))
import Effect.Exception as Exception
import Hello.Plugins.Core.Console as C
import Hello.Plugins.Core.UI as UI
import React as R2
import React.DOM as D
import React.DOM.Props as P
import Reactix as R
import Record (get)
import Unsafe.Coerce (unsafeCoerce)

-- | Catching error component, relying on React previous Class API
-- |
-- | https://reactjs.org/docs/error-boundaries.html
errorBoundary :: Array R.Element -> R.Element
errorBoundary children = UI.buff $ R2.createElement component {} $ UI.scuff <$> children

cname :: String
cname = "error-boundary"

console :: C.Console
console = C.encloseContext C.Plugin cname

type State =
  ( error     :: Maybe Exception.Error
  -- see https://pursuit.purescript.org/packages/purescript-react/9.0.0/docs/React#t:ComponentDidCatch
  , errorInfo :: Maybe (Record (componentStack :: String ))
  )

component :: R2.ReactClass { children :: R2.Children }
component = R2.component cname cpt where
  cpt this = pure
    { state:
        ({ error: Nothing
         , errorInfo: Nothing
         } :: Record State)

    , componentDidCatch: \error errorInfo -> do

        console.error2 error errorInfo

        R2.setState this
          { error: unsafeCoerce $ Just error
          , errorInfo: unsafeCoerce $ Just errorInfo
          }

    , render: do
        { error, errorInfo } <- R2.getState this
        { children } <- R2.getProps this

        case error of
          Nothing -> pure $

            R2.fragmentWithKey "errorBoundary" $ R2.childrenToArray children

          Just err -> pure $

            let
              message = Exception.message err

              stack = fromMaybe "no stack trace" $ Exception.stack err

              componentStack = fromMaybe "no component stack trace" key where
                key = get (SProxy :: SProxy "componentStack") <$> errorInfo

            in D.div
            [ P.className cname ]
            [ D.div
              [ P.className $ cname <> "__border" ]
              [ D.text mempty ]

            , D.h1
              [ P.className $ cname <> "__message" ]
              [ D.b' [ D.text "Error: " ]
              , D.text message
              ]

            , D.p
              [ P.className $ cname <> "__stack" ]
              [ D.text stack
              ]

            , D.p
              [ P.className $ cname <> "__stack" ]
              [ D.text componentStack
              ]
            ]
    }
