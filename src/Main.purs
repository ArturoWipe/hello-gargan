module Main (main) where

import Prelude

import Effect (Effect)
import Hello.Plugins.Contexts.Stores (storesProvider)
import Hello.Plugins.Core.App (app)
import Hello.Plugins.Core.Stores (storesFactory)
import Hello.Plugins.Core.UI (inject')

main :: Effect Unit
main = do
  -- Create a Stores reference to hydrate a <Store.Provider> Element instance
  -- (!) do not use store binds (eg. `useStores` hooks) in these computations
  --     as the context reference would be unknown (cf. "Composition/Stores
  --     module)
  stores <- pure $ storesFactory unit
  -- Rendering main application
  inject' $ storesProvider stores [ app {} ]
