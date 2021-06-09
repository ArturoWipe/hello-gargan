module Hello.Components.Layout.ToastContainer (toastContainer) where

import Prelude

import Hello.Plugins.Core.UI as UI
import Reactix as R
import Reactix.DOM.HTML as H

-- | DOM Element container for Toast
toastContainer :: UI.Leaf ()
toastContainer = UI.leaf component

cname :: String
cname = "toast-container"

component :: R.Component ()
component = R.hooksComponent cname cpt where
  cpt _ _ = pure $ H.div { id: cname } []
