module Hello.Plugins.Hooks.StateRecord.Behaviors
  ( setter
  , binder
  , TwoWayBinding
  ) where

import Prelude

import Effect (Effect)
import Record.Unsafe (unsafeGet, unsafeSet)
import Toestand as T

type TwoWayBinding a =
  ( callback      :: a -> Effect Unit
  , value         :: a
  )

-- | ```purescript
-- | formInput
-- | { callback: setter stateBox "label" }
-- | ```
setter :: forall box r a.
     T.ReadWrite box (Record r)
  => box
  -> String
  -> a
  -> Effect Unit
setter stateBox field value = T.modify_ (\prev -> unsafeSet field value prev) stateBox

-- | ```purescript
-- | formInput
-- | (binder stateBox state "label" }
-- | ```
binder :: forall box r a.
     T.ReadWrite box (Record r)
  => box
  -> Record r
  -> String
  -> Record (TwoWayBinding a)
binder stateBox state field =
  { callback: \value -> setter stateBox field value
  , value: unsafeGet field state
  }
