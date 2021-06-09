module Hello.Plugins.Hooks.FormValidation
  ( useFormValidation, VForm, Field
  , append', (<!>)
  , class Equals, equals
  , class NonEmpty, nonEmpty
  , class Minimum, minimum
  , class Maximum, maximum
  , lowercase, uppercase, email
  ) where

import Prelude

import Data.Array (filter, find)
import Data.Either (Either(..), isLeft)
import Data.Maybe (isJust)
import Data.String (toLower, toUpper)
import Data.String.CodeUnits (length)
import Data.String.Regex (Regex, test)
import Data.Tuple (Tuple, fst, snd)
import Data.Tuple.Nested ((/\))
import Data.Validation.Semigroup (V(..), invalid, toEither)
import Effect (Effect)
import Effect.Aff (Aff, forkAff, joinFiber)
import Effect.Class (liftEffect)
import Reactix as R

foreign import emailPattern :: Regex

type Field = String

type EForm = Either (Array (Tuple Field String)) Unit
type VForm = V      (Array (Tuple Field String)) Unit

type Methods =
  ( hasError      ::                    Boolean
  , hasError'     ::          Field  -> Boolean
  , hasError_     :: Field -> String -> Boolean

  , removeError   ::          Effect Unit
  , removeError'  :: Field -> Effect Unit

  , tryCount      :: Int

  , try           :: (Unit ->     VForm) -> Effect EForm
  , asyncTry      :: (Unit -> Aff VForm) -> Aff    EForm

  , try'          :: (Unit ->     VForm) -> Effect EForm
  , asyncTry'     :: (Unit -> Aff VForm) -> Aff    EForm
  )

useFormValidation :: R.Hooks (Record Methods)
useFormValidation = do
  -- | Store number of "try/asyncTry" made
  tryCount /\ setTryCount <- R.useState' 0
  -- | Store the "try/asyncTry" validation result
  result <- R.useRef (V (Right mempty) :: VForm)
  -- | Check if previous "try/asyncTry" contains error
  hasError <- R.useMemo1 result $ const $

    hasErrorImpl $ R.readRef result
  -- | Check if previous "try/asyncTry" contains error for given field
  hasError' <- R.useMemo1 result $ const $

    \field -> hasErrorImpl' field $ R.readRef result
  -- | Chekf if previous "try/asyncTry" contains error for given field AND
  -- | stringed error (eg. "nonEmpty")
  hasError_ <- R.useMemo1 result $ const $

    \field -> \value -> hasErrorImpl_ field value $ R.readRef result
  -- | Exec a synchronous validation, run parallel side effects, return result
  try <- pure \thunk -> do
    res <- pure $ thunk unit
    R.setRef result res
    setTryCount (_ + 1)
    pure $ toEither res
  -- | Exec an asynchronous validation, then run parallel side effects,
  -- | and return result
  -- |
  -- | Every Effect or Aff dependent validation lead to this method
  asyncTry <- pure \thunk -> do

    fiber <- forkAff $ thunk unit
    res   <- joinFiber fiber

    liftEffect do
      R.setRef result res
      setTryCount (_ + 1)

    pure $ toEither res

  -- | Exec a dynamic synchronous validation, no parallel side effects runned,
  -- | returned only provided validation part (ie. not the whole result)
  -- | nor returned result)
  try' <- pure \thunk -> do
    res  <- pure $ thunk unit
    res' <- pure $ res <> R.readRef result
    R.setRef result res'
    pure $ toEither res'
  -- | Exec a dynamic asynchronous validation, no parallel side effects runned,
  -- | returned only provided validation part (ie. not the whole result)
  -- |
  -- | Every Effect or Aff dependent validation lead to this method
  asyncTry' <- pure \thunk -> do

      fiber <- forkAff $ thunk unit
      res   <- joinFiber fiber
      res'  <- pure $ res <> R.readRef result

      liftEffect do
        R.setRef result res'

      pure $ toEither res'
  -- | Remove all current error without running parallel side effects
  removeError <- pure $ R.setRef result (V (Right mempty) :: VForm)
  -- | Remove every Tuple "key - error type" found for given key
  removeError' <- pure $ \field ->

    let res = R.readRef result

    in case res of
      V (Right _)  -> pure unit
      V (Left err) -> do
        res' <- pure $ filter (\t -> not isDuplicate field t) err
        R.setRef result $ invalid res'

  -- | Available hooks
  pure
    { tryCount
    , hasError
    , hasError'
    , hasError_
    , try
    , asyncTry
    , try'
    , asyncTry'
    , removeError
    , removeError'
    }

hasErrorImpl :: VForm -> Boolean
hasErrorImpl = toEither >>> isLeft

hasErrorImpl' :: String -> VForm -> Boolean
hasErrorImpl' field (V (Right _))  = false
hasErrorImpl' field (V (Left err)) = isJust $ find (fst >>> eq field) err

hasErrorImpl_ :: String -> String -> VForm -> Boolean
hasErrorImpl_ field _     (V (Right _))  = false
hasErrorImpl_ field value (V (Left err)) = isJust $ find (a && b) err
  where
    a = fst >>> eq field
    b = snd >>> eq value

isDuplicate :: String -> Tuple Field String -> Boolean
isDuplicate field = fst >>> eq field

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
append' :: VForm -> VForm -> VForm
append' a b =
  case toEither a of
    Left  _ -> a
    Right _ -> a <> b

infixr 5 append' as <!>


-- | Helpers methods
-- |
-- | @TODO: typed error?

class Eq a <= Equals a where
  equals :: Field -> a -> a -> VForm

class NonEmpty a where
  nonEmpty :: Field -> a -> VForm

class Ord a <= Minimum a where
  minimum :: Field -> a -> Int -> VForm

class Ord a <= Maximum a where
  maximum :: Field -> a -> Int -> VForm

-- Regarding String field value

instance equalsString :: Equals String where
  equals field input input'
    | (not eq input input') = invalid [ field /\ "equals" ]
    | otherwise             = pure unit

instance nonEmptyString :: NonEmpty String where
  nonEmpty field "" = invalid [ field /\ "nonEmpty" ]
  nonEmpty _ _      = pure unit

instance minimumString :: Minimum String where
  minimum field input min
    | (length input) < min = invalid [ field /\ "minimum" ]
    | otherwise            = pure unit

instance maximumString :: Maximum String where
  maximum field input max
    | (length input) > max = invalid [ field /\ "maximum" ]
    | otherwise            = pure unit

uppercase :: Field -> String -> VForm
uppercase field input
  | (toLower input) == input = invalid [ field /\ "uppercase" ]
  | otherwise                = pure unit

lowercase :: Field -> String -> VForm
lowercase field input
  | (toUpper input) == input = invalid [ field /\ "lowercase" ]
  | otherwise                = pure unit

email :: Field -> String -> VForm
email field input
  | (not $ test emailPattern input) = invalid [ field /\ "email" ]
  | otherwise                       = pure unit
