module Hello.Plugins.Hooks.Debounce
  ( useDebounce
  ) where

import Prelude

import Data.Maybe (Maybe(..))
import Effect (Effect)
import Effect.Timer (TimeoutId, clearTimeout, setTimeout)
import Reactix as R

-- | Create a debounce function
-- |
-- | ```purescript
-- | debouncedLog <- useDebounce 2000 (\s -> log s)
-- |
-- | ...
-- |
-- | debouncedLog "hello"
-- | ```
useDebounce :: forall a.
     Int
  -> (a -> Effect Unit)
  -> R.Hooks (a -> Effect Unit)
useDebounce period func = do

  timer <- R.useRef (Nothing :: Maybe TimeoutId)

  pure \arg -> do

    case R.readRef timer of
      Nothing -> pure unit
      Just t  -> clearTimeout t

    newTimer <- setTimeout period $ func arg

    R.setRef timer (Just newTimer)
