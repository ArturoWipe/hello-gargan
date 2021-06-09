module Hello.Plugins.Hooks.LinkHandler
  ( useLinkHandler
  , goToRoute, goToURL, goToPreviousPage
  , module RT
  ) where

import Prelude

import Effect (Effect)
import Hello.Plugins.Core.Routes (Route, path) as RT
import Reactix as R
import Web.HTML (window)
import Web.HTML.History (back)
import Web.HTML.Location (assign, setHref)
import Web.HTML.Window (history, location)

type Methods =
  ( goToRoute        :: RT.Route -> Effect Unit
  , goToPreviousPage :: Unit -> Effect Unit
  , goToURL          :: String -> Effect Unit
  , route            :: RT.Route -> String
  )

useLinkHandler :: R.Hooks (Record Methods)
useLinkHandler = pure
  { goToRoute: goToRoute
  , goToPreviousPage: const goToPreviousPage
  , goToURL: goToURL
  , route: RT.path
  }

-- (?) Also exporting implementation methods, as it can be useful in an
--     outside-of-hook context

goToRoute :: RT.Route -> Effect Unit
goToRoute route = window >>= location >>= (assign $ RT.path route)

goToPreviousPage :: Effect Unit
goToPreviousPage = window >>= history >>= back

goToURL :: String -> Effect Unit
goToURL url = window >>= location >>= setHref url
