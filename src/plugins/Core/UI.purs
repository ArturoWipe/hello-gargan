module Hello.Plugins.Core.UI
  ( Tree, Leaf, OptTree, OptLeaf
  , tree, leaf, optLeaf, optTree
  , appContainer, inject, inject', spreadAttrs, if', if_
  , buff, scuff, getPortalHost
  , useLive', useBox'
  ) where

import Prelude

import DOM.Simple (Element, document)
import DOM.Simple.Console (log)
import Data.Maybe (Maybe(..))
import Data.Nullable (toMaybe)
import Data.Tuple (Tuple)
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import FFI.Simple (delay, (...))
import Hello.Plugins.Core.ConvertableOptions (class Defaults, defaults) as CO
import React (ReactElement)
import Reactix as R
import Record.Unsafe (unsafeGet)
import Record.Unsafe.Union (unsafeUnion)
import Toestand as T
import Unsafe.Coerce (unsafeCoerce)

-- | UI Component type with only required props and children
type Tree p = Record p -> Array R.Element -> R.Element

-- | UI Component type with only required props and no child
type Leaf p = Record p -> R.Element

-- | UI Component type containing optional props and children
type OptTree options props provided = CO.Defaults (Record options) (Record provided) (Record props)
  => Record provided -> Array R.Element -> R.Element

-- | UI Component type containing optional props and no child
type OptLeaf options props provided = CO.Defaults (Record options) (Record provided) (Record props)
  => Record provided -> R.Element

tree :: forall cpt p. R.IsComponent cpt p (Array R.Element)
  => cpt -> Record p -> Array R.Element -> R.Element
tree component props children = R.createElement component props children

leaf :: forall cpt p. R.IsComponent cpt p (Array R.Element)
  => cpt -> Record p -> R.Element
leaf component props = R.createElement component props []

optTree :: forall r r' cpt p.
     CO.Defaults r r' (Record p)
  => R.IsComponent cpt p (Array R.Element)
  => cpt -> r -> r' -> Array R.Element -> R.Element
optTree component options props children = R.createElement component props' children where
  props' = CO.defaults options props

optLeaf :: forall r r' cpt p.
     CO.Defaults r r' (Record p)
  => R.IsComponent cpt p (Array R.Element)
  => cpt -> r -> r' -> R.Element
optLeaf component options props = R.createElement component props' [] where
  props' = CO.defaults options props

-- | Container where the magic will be painted
-- | note that: "Rendering components directly into document.body is discouraged, since its children are often manipulated by third-party scripts and browser extensions."
appContainer :: Maybe Element
appContainer = toMaybe $ document ... "querySelector" $ [ "#app" ]

-- | Inject given Reactix Element to a DOM Element
inject :: R.Element -> Maybe Element -> Effect Unit
inject _ Nothing = log "[main] Container not found"
inject el (Just c) = R.render el c

-- | Directly inject given Reactix Element to the main container
inject' :: R.Element -> Effect Unit
inject' el = el `inject` appContainer

-- | Turns a ReactElement into aReactix Element
-- | buff (v.) to polish
buff :: ReactElement -> R.Element
buff = unsafeCoerce

-- | Turns a Reactix Element into a ReactElement.
-- | scuff (v.) to spoil the gloss or finish of.
scuff :: R.Element -> ReactElement
scuff = unsafeCoerce

-- | We just assume it works, so make sure it's in the html
getPortalHost :: R.Hooks Element
getPortalHost = R.unsafeHooksEffect $ delay unit $ \_ -> pure $ document ... "getElementById" $ ["portal-container"]

-- | Smelly workaround to spread unsafe record of DOM attributes (parent
-- | component side) and inject them into a child ReactComponent
spreadAttrs :: forall r r1 r2. Record r -> Record r1 -> Record r2
spreadAttrs r r' = unsafeUnion r (unsafeGet "attrs" r')

-- | One-liner `if` simplifying render writing
-- | (best for one child)
if' :: Boolean -> R.Element -> R.Element
if' = if _ then _ else mempty

-- | One-liner `if` simplifying render writing
-- | (best for multiple children)
if_ :: Boolean -> Array (R.Element) -> R.Element
if_ pred arr = if pred then (R.fragment arr) else mempty

-- | Toestand `useLive` automatically sets to "unchanged" behavior
useLive' :: forall box b. T.Read box b => Eq b => box -> R.Hooks b
useLive' = T.useLive T.unequal

-- | Toestand `useBox` + `useLive'` shorthand following same patterns as
-- | React StateHooks API
useBox' :: forall b. Eq b => b -> R.Hooks (Tuple b (T.Box b))
useBox' default = do
  box <- T.useBox default
  b <- useLive' box
  pure $ b /\ box
