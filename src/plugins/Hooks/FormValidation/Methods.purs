module Hello.Plugins.Hooks.FormValidation.Methods
  ( useFormValidation
  , append', (<!>)
  ) where

import Prelude

import Data.Array (filter, find)
import Data.Either (Either(..), isLeft)
import Data.Maybe (isJust)
import Data.Tuple (Tuple, fst, snd)
import Data.Tuple.Nested ((/\))
import Data.Validation.Semigroup (V(..), invalid, toEither)
import Effect (Effect)
import Effect.Aff (Aff, forkAff, joinFiber)
import Effect.Class (liftEffect)
import Hello.Plugins.Core.UI as UI
import Hello.Plugins.Hooks.FormValidation.Types (Field, VForm, EForm)
import Reactix as R
import Toestand as T

type Methods =
  (
    try           :: (Unit -> Effect VForm) -> Effect EForm
  , asyncTry      :: (Unit -> Aff    VForm) -> Aff    EForm

  , tryCount      ::       Int
  , tryCountBox   :: T.Box Int

  , try'          :: (Unit -> Effect VForm) -> Effect EForm
  , asyncTry'     :: (Unit -> Aff    VForm) -> Aff    EForm

  , hasError      ::                    Boolean
  , hasError'     :: Field           -> Boolean
  , hasError_     :: Field -> String -> Boolean

  , removeError   ::                    Effect Unit
  , removeError'  :: Field           -> Effect Unit
  , removeError_  :: Field -> String -> Effect Unit
  )
-- | ## hasError
-- |
-- | **Check if previous "try/asyncTry" contains error**
-- |
-- | variant:
-- |
-- |   * constraining to a given field,
-- |   * idem + provided error
-- |
-- | ***
-- |
-- | ## removeError
-- |
-- | **Remove all current error without running parallel side effects**
-- |
-- | variant:
-- |
-- |   * constrained to a given field
-- |
-- | ***
-- |
-- | ## tryCount
-- |
-- | **Store number of "try/asyncTry" made (ie. "global" validation made)**
-- |
-- | variant:
-- |
-- |   * boxed wrapped value
-- |
-- | ***
-- |
-- | ## try
-- |
-- | **Exec a synchronous validation, run parallel side effects, return result**
-- |
-- | variant:
-- |
-- |   * Aff monad dependent validation rules
-- |
-- | ***
-- |
-- | ## try'
-- |
-- | **Exec a dynamic synchronous validation, no parallel side effects runned,
-- | returned only provided validation part (ie. not the whole result)
-- | nor returned result)**
-- |
-- | variant:
-- |
-- |   * Aff monad dependent validation rules
-- |
useFormValidation :: R.Hooks (Record Methods)
useFormValidation = do

  tryCount /\ tryCountBox <- UI.useBox' 0
  result   /\ resultBox   <- UI.useBox' (V (Right mempty) :: VForm)

  memoHasError  <- R.useMemo1 result $ const $ hasError result
  memoHasError' <- R.useMemo1 result $ const $ (_ # result # hasError')
  memoHasError_ <- R.useMemo1 result $ const $ (_ # result # hasError_)

  pure
    { tryCount
    , tryCountBox

    , hasError    : memoHasError
    , hasError'   : memoHasError'
    , hasError_   : memoHasError_

    , try         : try          resultBox tryCountBox
    , asyncTry    : asyncTry     resultBox tryCountBox

    , try'        : try'         resultBox
    , asyncTry'   : asyncTry'    resultBox

    , removeError : removeError  resultBox
    , removeError': removeError' resultBox
    , removeError_: removeError_ resultBox
    }

----

hasError :: VForm -> Boolean
hasError = toEither >>> isLeft

hasError' :: VForm -> Field -> Boolean
hasError' (V (Right _))  field = false
hasError' (V (Left err)) field = isJust $ find (fst >>> eq field) err

hasError_ :: VForm -> Field -> String -> Boolean
hasError_ (V (Right _))  field _     = false
hasError_ (V (Left err)) field value = isJust $ find (a && b) err
  where
    a = fst >>> eq field
    b = snd >>> eq value

----

try :: forall box1 box2.
     T.ReadWrite box1 VForm
  => T.ReadWrite box2 Int
  => box1
  -> box2
  -> (Unit -> Effect VForm)
  -> Effect EForm
try resultBox tryCountBox thunk = do
  res <- thunk unit
  T.write_ res resultBox
  T.modify_ (_ + 1) tryCountBox
  pure $ toEither res

asyncTry :: forall box1 box2.
     T.ReadWrite box1 VForm
  => T.ReadWrite box2 Int
  => box1
  -> box2
  -> (Unit -> Aff VForm)
  -> Aff EForm
asyncTry resultBox tryCountBox thunk = do

  fiber <- forkAff $ thunk unit
  res   <- joinFiber fiber

  liftEffect do
    T.write_ res resultBox
    T.modify_ (_ + 1) tryCountBox

  pure $ toEither res

----

try' :: forall box. T.ReadWrite box VForm
  => box
  -> (Unit -> Effect VForm)
  -> Effect EForm
try' resultBox thunk = do
  res <- thunk unit <> (T.read resultBox)
  T.write_ res resultBox
  pure $ toEither res

asyncTry' :: forall box. T.ReadWrite box VForm
  => box
  -> (Unit -> Aff VForm)
  -> Aff EForm
asyncTry' resultBox thunk = do

  fiber <- forkAff $ thunk unit
  res   <- (joinFiber fiber) <> (liftEffect $ T.read resultBox)

  liftEffect $ T.write_ res resultBox

  pure $ toEither res

----

removeError :: forall box. T.ReadWrite box VForm
  => box
  -> Effect Unit
removeError = T.write_ (V (Right mempty) :: VForm)

removeError' :: forall box. T.ReadWrite box VForm
  => box
  -> Field
  -> Effect Unit
removeError' resultBox field = T.read resultBox >>=
  case _ of
    V (Right _)  -> pure unit
    V (Left err) -> do
      res <- pure $ filter (\t -> not isDuplicate field t) err
      T.write_ (invalid res) resultBox

removeError_ :: forall box. T.ReadWrite box VForm
  => box
  -> Field
  -> String
  -> Effect Unit
removeError_ resultBox field error = T.read resultBox >>=
  case _ of
    V (Right _)  -> pure unit
    V (Left err) -> do
      res <- pure $ filter (\t -> not isDuplicate' field error t) err
      T.write_ (invalid res) resultBox

----

isDuplicate :: Field -> Tuple Field String -> Boolean
isDuplicate field = fst >>> eq field

isDuplicate' :: Field -> String -> Tuple Field String -> Boolean
isDuplicate' field error = a && b
  where
    a = fst >>> eq field
    b = snd >>> eq error

-- | @TODO:
-- | Really thinking that I have reinvented the wheel here...
-- |
-- | As `VForm` are used as Semigroup, appending with `<>` will result on
-- | a collection of errors
-- |
-- | This method offers the primary use of `V` (ie. an `Either`) and so breaking
-- | computation if first validation rule was lefty
-- |
-- | ```purescript
-- | let
-- |   a = onError
-- |   b = onErrorToo
-- | in
-- |   a  <> b -- Will output two errors in the final `VForm`
-- |   a <!> b -- Will only output the a) error
-- | ```
append' :: Effect VForm -> Effect VForm -> Effect VForm
append' a b = a >>= \a' ->
  case toEither a' of
    Left  _ -> a
    Right _ -> a <> b

infixr 5 append' as <!>
