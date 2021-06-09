module Hello.Stores.Public.Authentication
  ( state
  , State
  , Store
  , login
  , LoginData
  ) where

import Prelude

import Data.Either (Either)
import Effect.Aff (Aff, Error, Milliseconds(..), attempt, delay)
import Effect.Class (liftEffect)
import Toestand as T

type Store =
  ( onPending :: T.Box (Boolean)
  )

type State =
  ( onPending :: Boolean
  )

state :: Unit -> Record State
state = \_ ->
  { onPending: false
  }

type LoginData =
  ( email :: String
  , password :: String
  )

login :: Record Store -> Record LoginData -> Aff (Either Error Unit)
login { onPending } _  = do

  liftEffect $ T.write_ true onPending

  result <- attempt $ simulateAPIRequest

  liftEffect $ T.write_ false onPending

  pure $ result

simulateAPIRequest :: Aff Unit
simulateAPIRequest = delay $ Milliseconds 2000.0
