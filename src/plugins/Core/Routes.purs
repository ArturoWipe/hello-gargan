module Hello.Plugins.Core.Routes
  ( Route(..)
  , routes, path, hash
  ) where

import Prelude

import Data.Foldable (oneOf)
import Routing.Match (Match, end, lit, root)

-- @TODO: real automation

data Route
  = Authentication
  | Home
  | Misc

derive instance eqRoutes :: Eq Route

routes :: Match Route
routes = oneOf
  [ root $> Home <* (lit "home")
  , root $> Misc <* (lit "misc")
  , root $> Authentication
  , pure Authentication -- matching case where "/#/" is omitted
  ] <* end

path :: Route -> String
path route = append "/#" $ hash route

hash :: Route -> String
hash Authentication = "/"
hash Home           = "/home"
hash Misc           = "/misc"
