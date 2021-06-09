module Hello.Stores.User.Session
  ( state
  , State
  , Store
  ) where

import Prelude

import Toestand as T

type Store =
  ( name            :: T.Box (String)
  , isAuthenticated :: T.Box (Boolean)
  )

type State =
  ( name            :: String
  , isAuthenticated :: Boolean
  )

state :: Unit -> Record State
state = \_ ->
  { name            : ""
  , isAuthenticated : false
  }
