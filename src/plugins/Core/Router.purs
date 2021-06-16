module Hello.Plugins.Core.Router (router) where

import Prelude

import Data.Either (Either(..))
import Data.Maybe (Maybe(..), maybe)
import Effect.Aff (Aff, Canceler, Error, Fiber, attempt, cancelWith, effectCanceler, error, forkAff, joinFiber, killFiber, launchAff_)
import Effect.Class (liftEffect)
import Hello.Plugins.Core.Console as C
import Hello.Plugins.Core.NavigationParser (getLayoutElement, getLayoutPremount, getPageElement, getPageLayout, getPagePremount)
import Hello.Plugins.Core.Routes as RT
import Hello.Plugins.Core.Stores (RootStore)
import Hello.Plugins.Core.UI as UI
import Hello.Plugins.Hooks.Router (useHashRouter)
import Hello.Plugins.Hooks.Stores (useStores)
import Hello.Stores.Core.Navigation (Mode(..))
import Reactix as R
import Toestand as T

router :: UI.Leaf ()
router = UI.leaf component

cname :: String
cname = "router"

console :: C.Console
console = C.encloseContext C.Plugin cname

component :: R.Component ()
component = R.hooksComponent cname cpt where
  cpt _ _ = do
    rootStore@{ "core/navigation": store } <- useStores

    nextRoute <- UI.useLive' store.nextRoute
    layout <- UI.useLive' store.layout
    route <- UI.useLive' store.route
    -- Router configuration
    useHashRouter RT.routes store.nextRoute
    -- @onRouteChange: launch premount process, set new layout and page
    R.useEffect1' nextRoute $ launchAff_ do
      cancelRouting rootStore
      execRouting rootStore
    -- @onRouteChange: logging purpose
    R.useEffect1' route $
      maybe R.nothing console.log route
    -- -- Render
    pure $

      let
        layoutEl = getLayoutElement layout
        pageEl   = getPageElement route

      in
        R.fragment [ layoutEl [ pageEl ] ]

-- (!) Do not be tempted to put these routing actions within the
--     "core/navigation" Store, as a cycling dependency will arise

execRouting :: Record RootStore -> Aff Unit
execRouting rootStore@{ "core/navigation": store } = do
  nextRoute <- liftEffect $ T.read store.nextRoute

  liftEffect $ T.write_ Fetching store.mode

  fiber <- forkAff $ cancelWith (execPremounting rootStore) $ fetchingFiberCanceler console nextRoute

  liftEffect $ T.write_ (Just fiber) store.fetchingFiber

  res <- joinFiber fiber

  case res of
    Left err -> liftEffect $ console.warn2 "aborted premount" err
    Right _  -> liftEffect do
      T.modify_ (_ + 1) store.count
      T.write_ (Just $ getPageLayout nextRoute) store.layout
      T.write_ (Just nextRoute) store.route

  liftEffect do
    T.write_ Nothing store.fetchingFiber
    T.write_ Idling store.mode


cancelRouting :: Record RootStore -> Aff Unit
cancelRouting rootStore@{ "core/navigation": store } = do
  fetchingFiber <- liftEffect $ T.read store.fetchingFiber

  case fetchingFiber of
    Nothing     -> pure unit
    Just fiber  -> cancelPreviousRouting fiber

fetchingFiberCanceler :: C.Console -> RT.Route -> Canceler
fetchingFiberCanceler c r = effectCanceler $ c.warn2 "cancel ongoing premount" r

fetchingFiberCancelerError :: Error
fetchingFiberCancelerError = error "fetching_fiber_canceler_error"

-- @XXX annoying "uncaught error" impossible to catch
--      (attempting to use `try`, `attempt`, `catchError`, `apathized` failed)
cancelPreviousRouting :: Fiber (Either Error Unit) -> Aff Unit
cancelPreviousRouting = killFiber fetchingFiberCancelerError

execPremounting :: Record RootStore -> Aff (Either Error Unit)
execPremounting rootStore@{ "core/navigation": store } = do
  nextRoute <- liftEffect $ T.read store.nextRoute
  nextLayout <- liftEffect $ pure $ getPageLayout nextRoute
  currentLayout <- liftEffect $ T.read store.layout

  willPremountLayout <- case currentLayout of
    Nothing     -> pure $ true
    Just layout -> pure $ notEq layout nextLayout

  res <- case willPremountLayout of
    false -> pure $ Right unit
    true  -> attempt $ getLayoutPremount nextLayout rootStore

  -- @XXX: for some reasons, couldn't managed to rely on `Either` bind
  --       to stop computations on error (instead unDRY solution)
  case res of
    Left _  -> pure res
    Right _ -> attempt $ getPagePremount nextRoute rootStore
