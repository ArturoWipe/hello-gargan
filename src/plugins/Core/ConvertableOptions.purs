module Hello.Plugins.Core.ConvertableOptions
  ( class Defaults, defaults ) where

import Prelude

import Prim.Row (class Nub, class Union)
import Record (merge)

-- | Merging principle with default and provided value
-- |
-- | **(install package when available with "psc-package")**
-- |
-- | https://github.com/natefaubion/purescript-convertable-options
class Defaults defaults provided all | defaults provided -> all where
  defaults :: defaults -> provided -> all

instance defaultsRecord ::
  ( Union provided defaults all'
  , Nub all' all
  ) =>
  Defaults (Record defaults)  (Record provided) (Record all) where
  defaults = flip merge
