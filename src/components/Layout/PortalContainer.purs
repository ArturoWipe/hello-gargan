module Hello.Components.Layout.PortalContainer (portalContainer) where

import Prelude

import Hello.Plugins.Core.UI as UI
import Reactix as R
import Reactix.DOM.HTML as H

-- | DOM Element container for a basic React Portal
portalContainer :: UI.Leaf ()
portalContainer = UI.leaf component

cname :: String
cname = "portal-container"

component :: R.Component ()
component = R.hooksComponent cname cpt where
  cpt _ _ = pure $ H.div { id: cname } []
