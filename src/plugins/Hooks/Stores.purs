module Hello.Plugins.Hooks.Stores where

import Hello.Plugins.Contexts.Stores (storesContext)
import Hello.Plugins.Core.Stores (RootStore)
import Reactix as R

useStores :: R.Hooks (Record RootStore)
useStores = R.useContext storesContext
