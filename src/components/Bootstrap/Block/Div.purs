module Hello.Components.Bootstrap.Div (div') where

import Reactix as R
import Reactix.DOM.HTML as H

-- | Shorthand for using HTML <div> without writing its text node
div' :: forall r. Record r -> String -> R.Element
div' props content = H.div props [ H.text content ]
