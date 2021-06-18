module Hello.Plugins.Hooks.FormState.Boxed
  ( useFormState
  , TwoWayBinding
  ) where

import Prelude

import Data.Eq (class EqRecord)
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Hello.Plugins.Core.UI as UI
import Prim.RowList (class RowToList)
import Reactix as R
import Record.Unsafe (unsafeGet, unsafeSet)
import Toestand as T

type Methods r a =
  -- | Every provided props will be available within the `formFields` proxy
  ( state         ::        Record r
  , stateBox      :: T.Box (Record r)
  -- | When binded with a form input, any form fields can be handled by
  -- | providing this function
  , setStateKey   :: String -> a -> Effect Unit
  -- | API method proposing a two way data binding (such as "v-model" of
  -- | VueJS)
  , bindStateKey  :: String -> Record (TwoWayBinding a)
  )

type TwoWayBinding a =
  ( callback      :: a -> Effect Unit
  , value         :: a
  )

-- | Hooks inspired from this article
-- |
-- | https://blog.logrocket.com/forms-in-react-in-2020/
-- |
-- | ```purescript
-- |
-- |  r <- useFormState defaultValues
-- |
-- | ...
-- |
-- | B.formInput
-- |   { value: r.state.prop
-- |   , callback: r.setStateKey "prop"
-- |   }
-- |
-- | ...
-- |
-- | -- `bindStateKey` will add both `value: ...` and `callback: ...`
-- | B.formInput $
-- |   { ... } `merge` r.bindStateKey "prop"
-- |
useFormState :: forall a r l.
     RowToList r l
  => EqRecord l r
  => Record r
  -> R.Hooks (Record (Methods r a))
useFormState initialValues = do

  state /\ stateBox <- UI.useBox' initialValues

  pure
    { state
    , stateBox
    , setStateKey : (_ # stateBox # set_)
    , bindStateKey: (_ # stateBox # bind_ $ state)
    }

----

set_ :: forall box r a. T.ReadWrite box (Record r)
  => box
  -> String
  -> a
  -> Effect Unit
set_ stateBox field value = T.modify_ (\prev -> unsafeSet field value prev) stateBox


bind_ :: forall box r a. T.ReadWrite box (Record r)
  => box
  -> Record r
  -> String
  -> Record (TwoWayBinding a)
bind_ stateBox state field =
  { callback: \value -> set_ stateBox field value
  , value: unsafeGet field state
  }
