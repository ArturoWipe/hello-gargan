module Hello.Plugins.Contexts.Stores
  ( storesContext
  , storesProvider
  ) where

import Prelude

import Hello.Plugins.Core.Stores (RootStore)
import Reactix as R
import Unsafe.Coerce (unsafeCoerce)

-- (?) As we use "React Provide API", we just want to rely on its Global
--     Reference (and not as Mutable State thanks to "Consumer API")
--     Hence the "unsafe" here, avoiding unwanted computing at each import
--
--     It also implies that every call to the proxy reference (made thanks to
--     below <Store.Provider> are made AFTER first mount of this very,
--     component, otherwise, every call will return the empty `unit`)
storesContext :: R.Context (Record RootStore)
storesContext = R.createContext (unsafeCoerce unit)

-- Set <Store.Provider> bearing Stores as a Context
-- (!) do not use store binds in this specific component (eg. `useStores`)
storesProvider :: R.Hooks (Record RootStore) -> Array R.Element -> R.Element
storesProvider stores = R.createElement (R.hooksComponent "storeProvider" cpt) {}
  where
    cpt _ children = do
      storesReference <- stores
      pure $ R.provideContext storesContext storesReference $ children
