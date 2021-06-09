module Hello.Plugins.Core.NavigationParser
  ( getPagePremount, getPageLayout, getPageElement
  , getLayoutElement, getLayoutPremount
  ) where

import Prelude

import Data.Maybe (Maybe(..))
import Effect.Aff (Aff)
import Hello.Layouts.Blank as LayoutBlank
import Hello.Layouts.Dashboard as LayoutDashboard
import Hello.Pages.Authentication as PageAuthentication
import Hello.Pages.Home as PageHome
import Hello.Pages.Misc as PageMisc
import Hello.Plugins.Core.Layouts as LT
import Hello.Plugins.Core.Routes as RT
import Hello.Plugins.Core.Stores (RootStore)
import Reactix as R

-- @TODO: real automation

getLayoutElement :: Maybe LT.Layout -> Array R.Element -> R.Element
getLayoutElement = case _ of
  Nothing                 -> R.fragment
  Just LT.Blank           -> LayoutBlank.layout {}
  Just LT.Dashboard       -> LayoutDashboard.layout {}

getPagePremount :: RT.Route -> Record RootStore -> Aff Unit
getPagePremount = case _ of
  RT.Authentication       -> PageAuthentication.premount
  RT.Home                 -> PageHome.premount
  RT.Misc                 -> PageMisc.premount

getPageLayout :: RT.Route -> LT.Layout
getPageLayout = case _ of
  RT.Authentication       -> PageAuthentication.layout
  RT.Home                 -> PageHome.layout
  RT.Misc                 -> PageMisc.layout

getPageElement :: Maybe RT.Route -> R.Element
getPageElement = case _ of
  Nothing                 -> mempty
  Just RT.Authentication  -> PageAuthentication.page {}
  Just RT.Home            -> PageHome.page {}
  Just RT.Misc            -> PageMisc.page {}

getLayoutPremount :: LT.Layout -> Record RootStore -> Aff Unit
getLayoutPremount = case _ of
  LT.Blank                -> LayoutBlank.premount
  LT.Dashboard            -> LayoutDashboard.premount
