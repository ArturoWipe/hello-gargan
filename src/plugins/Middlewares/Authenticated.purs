module Hello.Plugins.Middlewares.Authenticated
  ( authenticated
  ) where

import Prelude

import Effect.Aff (Aff, error, throwError)
import Effect.Class (liftEffect)
import Hello.Plugins.Core.Console as C
import Hello.Plugins.Core.Routes as RT
import Hello.Plugins.Core.Stores (RootStore)
import Hello.Plugins.Hooks.LinkHandler (goToRoute)
import Toestand as T

console :: C.Console
console = C.encloseContext C.Plugin "middleware-authenticated"

authenticated :: Record RootStore -> Aff Unit
authenticated rootStore@{ "user/session": { isAuthenticated }
                        , "core/navigation": { nextRoute }
                        } = do

  liftEffect do

    nextRoute'       <- T.read nextRoute
    isAuthenticated' <- T.read isAuthenticated

    case isAuthenticated' of
      true  -> pure unit
      false -> do
        console.warn2
          "Catch anonymous user on secured page, will redirect"
          nextRoute'
        goToRoute RT.Authentication
        throwError $ error "middleware-authenticated"
