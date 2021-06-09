module Hello.Plugins.Core.Stores
  ( RootStore
  , storesFactory
  ) where

import Prelude

import Hello.Stores.Core.Navigation as CoreNavigation
import Hello.Stores.Public.Account as PublicAccount
import Hello.Stores.Public.Authentication as PublicAuthentication
import Hello.Stores.User.Session as UserSession
import Prim.RowList (class RowToList)
import Reactix as R
import Toestand as T
import Toestand.Records (class UseFocusedFields)

type RootStore =
  (
    "core/navigation" :: Record CoreNavigation.Store
  , "public/account" :: Record PublicAccount.Store
  , "public/authentication" :: Record PublicAuthentication.Store
  , "user/session" :: Record UserSession.Store
  )

storesFactory :: Unit -> R.Hooks (Record RootStore)
storesFactory = const do

  coreNavigation <- setStoreBoxes $ CoreNavigation.state unit
  publicAccount <- setStoreBoxes $ PublicAccount.state unit
  publicAuthentication <- setStoreBoxes $ PublicAuthentication.state unit
  userSession <- setStoreBoxes $ UserSession.state unit

  pure
    {
      "core/navigation": coreNavigation
    , "public/account": publicAccount
    , "public/authentication": publicAuthentication
    , "user/session": userSession
    }

setStoreBoxes :: forall boxes l state.
     RowToList state l
  => UseFocusedFields l boxes () (T.Box (Record state))
  => Record state
  -> R.Hooks (Record boxes)
setStoreBoxes state = T.useBox state >>= \boxes -> T.useFocusedFields boxes {}
