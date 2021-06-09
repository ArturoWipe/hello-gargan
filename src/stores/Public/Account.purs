module Hello.Stores.Public.Account
  ( state
  , State
  , Store
  , create
  , CreateData
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

type CreateData = (
  email :: String,
  password :: String,
  name :: String
)

create ::
     Record Store
  -> Record CreateData
  -> Aff (Either Error Unit)
create { onPending } _ = do

  liftEffect $ T.write_ true onPending

  result <- attempt $ simulateAPIRequest

  liftEffect $ T.write_ false onPending

  pure $ result

simulateAPIRequest :: Aff Unit
simulateAPIRequest = delay $ Milliseconds 2000.0
