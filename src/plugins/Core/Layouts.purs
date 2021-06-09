module Hello.Plugins.Core.Layouts
  ( Layout(..)
  ) where

import Prelude

-- @TODO: real automation

data Layout =
    Blank
  | Dashboard

derive instance eqLayout :: Eq Layout
