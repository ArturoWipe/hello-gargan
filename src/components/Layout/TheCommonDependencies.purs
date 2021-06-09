module Hello.Components.Layout.TheCommonDependencies (theCommonDependencies) where

import Prelude

import Hello.Components.Layout.PortalContainer (portalContainer)
import Hello.Components.Layout.ToastContainer (toastContainer)
import Hello.Plugins.Core.UI as UI
import Reactix as R

theCommonDependencies :: UI.Leaf ()
theCommonDependencies = UI.leaf component

cname :: String
cname = "the-common-dependencies"

component :: R.Component ()
component = R.hooksComponent cname cpt where
  cpt _ _ = do
    -- Render
    pure $

      R.fragment
      [ toastContainer {}
      , portalContainer {}
      ]
