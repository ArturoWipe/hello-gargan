module Hello.Stores.Core.Navigation
  ( state
  , State
  , Store
  , Mode(..)
  ) where

import Prelude

import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Effect.Aff (Error, Fiber)
import Effect.Unsafe (unsafePerformEffect)
import Hello.Plugins.Core.Layouts as LT
import Hello.Plugins.Core.Routes as RT
import Routing (match)
import Routing.Hash (getHash)
import Routing.Match (Match)
import Toestand as T

-- Uing buffered `route/nextRoute` values, as a whole process of fetching data
-- PRIOR to mounting is being made
--
-- So the Store.nextRoute is equivalent to the wished route to go in the future
-- Store.route is being set as soon as the premount computations have succeded
--
-- An error in premount process (@TODO), or a change of route made by the
-- user in parallel of the premount process causes the cancelation of the
-- Aff executed for this effect

type Store =
  ( nextRoute     :: T.Box (RT.Route)
  , route         :: T.Box (Maybe RT.Route)
  , layout        :: T.Box (Maybe LT.Layout)
  , fetchingFiber :: T.Box (Maybe (Fiber (Either Error Unit)))
  , mode          :: T.Box (Mode)
  , count         :: T.Box (Int)
  )

type State =
  ( nextRoute     :: RT.Route
  , route         :: Maybe RT.Route
  , layout        :: Maybe LT.Layout
  , fetchingFiber :: Maybe (Fiber (Either Error Unit))
  , mode          :: Mode
  , count         :: Int
  )

state :: Unit -> Record State
state = \_ ->
  { nextRoute     : unsafeCurrentRoute RT.routes RT.Authentication
  , route         : Nothing
  , layout        : Nothing
  , fetchingFiber : Nothing
  , mode          : Idling
  , count         : 0
  }

data Mode =
    Idling
  | Fetching

derive instance eqMode :: Eq Mode


-- @XXX: horrendous workaround avoiding a flickering effect where the provided
--       default route is displayed before the actual route
unsafeCurrentRoute :: forall a. Match a -> a -> a
unsafeCurrentRoute routes default = unsafePerformEffect $ getHash >>= match'
  where
    match' = match routes >>> _fromRight default >>> pure

-- @XXX: different `fromRight` in our packages that the one stated in Pursuit
-- https://github.com/purescript/purescript-either/blob/v5.0.0/src/Data/Either.purs#L243-L243
_fromRight :: forall a b. b -> Either a b -> b
_fromRight _ (Right b) = b
_fromRight default _ = default
