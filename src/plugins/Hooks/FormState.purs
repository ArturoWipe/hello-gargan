module Hello.Plugins.Hooks.FormState
  ( useFormState
  ) where

import Prelude

import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Reactix as R
import Record.Unsafe (unsafeGet, unsafeSet)

type Methods r a =
  ( state :: Record r
  , setStateKey :: String -> a -> Effect Unit
  , bindStateKey :: String -> Record (TwoWayBinding a)
  )

type TwoWayBinding a =
  ( callback :: a -> Effect Unit
  , value :: a
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
-- | ```
useFormState :: forall r a. Record r -> R.Hooks (Record (Methods r a))
useFormState initialValues = do
  -- | Every provided props will be available within the `formFields` proxy
  state /\ setState <- R.useState' initialValues
  -- | When binded with a form input, any form fields can be handled by
  -- | providing this function
  setStateKey <- pure $ \field -> \value -> set_ field value setState
  -- | API method proposing a two way data binding (such as "v-model" of
  -- | VueJS)
  bindStateKey <- pure $ \field -> bind_ field setState state

  pure
    { state
    , setStateKey
    , bindStateKey
    }

set_ :: forall a r. String -> a -> R.Setter (Record r) -> Effect Unit
set_ field value setter = setter $ \prev -> unsafeSet field value prev

bind_ :: forall a r. String -> R.Setter (Record r) -> Record r -> Record (TwoWayBinding a)
bind_ field setter state =
  { callback: \value -> set_ field value setter
  , value: unsafeGet field state
  }
