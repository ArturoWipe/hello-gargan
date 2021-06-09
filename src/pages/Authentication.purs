module Hello.Pages.Authentication (page, premount, layout) where

import Prelude

import Data.Either (Either(..))
import Data.Foldable (intercalate)
import Data.Tuple.Nested ((/\))
import Effect.Aff (Aff, launchAff_)
import Effect.Class (liftEffect)
import Hello.Components.Bootstrap as B
import Hello.Components.Example.CreateAccount (createAccount)
import Hello.Components.Example.Login (login)
import Hello.Plugins.Core.Conditional ((?))
import Hello.Plugins.Core.Console as C
import Hello.Plugins.Core.Layouts as Layouts
import Hello.Plugins.Core.Routes as RT
import Hello.Plugins.Core.Stores (RootStore)
import Hello.Plugins.Core.UI as UI
import Hello.Plugins.Hooks.LinkHandler (useLinkHandler)
import Hello.Plugins.Hooks.Stores (useStores)
import Hello.Plugins.Hooks.Toast (useToast)
import Hello.Stores.Public.Account as AccountStore
import Hello.Stores.Public.Authentication as AuthenticationStore
import Reactix as R
import Reactix.DOM.HTML as H
import Record.Extra (pick)
import Toestand as T

page :: UI.Leaf ()
page = UI.leaf component

layout :: Layouts.Layout
layout = Layouts.Blank

cname :: String
cname = "page-authentication"

console :: C.Console
console = C.encloseContext C.Page cname

premount :: Record RootStore -> Aff Unit
premount _ = pure unit

component :: R.Component ()
component = R.hooksComponent cname cpt where
  cpt _ _ = do
    { "public/authentication": authenticationStore
    , "public/account": accountStore
    , "user/session": sessionStore
    } <- useStores
    -- State
    onSigninPending <- UI.useLive' authenticationStore.onPending
    onSignupPending <- UI.useLive' accountStore.onPending
    (printedView /\ setPrintedView) <- R.useState' Signin
    (onRedirection /\ setOnRedirection) <- R.useState' false
    -- Custom hooks
    toast <- useToast
    linkHandler <- useLinkHandler
    -- @loginCallback
    loginCallback <- pure $ \fdata -> launchAff_ do

      fdata' <- pure (pick fdata :: Record AuthenticationStore.LoginData)

      result <- AuthenticationStore.login authenticationStore fdata'

      liftEffect do
        console.log2 "login" result
        case result of
          Left _  -> toast.error "An error occured"
          Right _ -> toast.success "Welcome back"
                  *> T.write_ (fdata.email) sessionStore.name
                  *> T.write_ true sessionStore.isAuthenticated
                  *> setOnRedirection (\_ -> true)
                  *> linkHandler.goToRoute RT.Home

    -- @createAccountCallBack
    createAccountCallback <- pure $ \fdata -> launchAff_ do

      fdata' <- pure (pick fdata :: Record AccountStore.CreateData)

      result <- AccountStore.create accountStore fdata'

      liftEffect do
        console.log2 "createAccount" result
        case result of
          Left _  -> toast.error "An error occured"
          Right _ -> toast.success "Welcome !"
                  *> T.write_ (fdata.email) sessionStore.name
                  *> T.write_ true sessionStore.isAuthenticated
                  *> setOnRedirection (\_ -> true)
                  *> linkHandler.goToRoute RT.Home

    -- Render
    let

      -- @TODO focus email input on component render
      signinBlock =

        H.div { className: "card" }
        [
          H.div { className: "card-body" }
          [
            login
            { callback: loginCallback
            , status: onSigninPending || onRedirection ? "deferred" $ "enabled"
            }

          , B.buttonLink
              { callback: \_ -> setPrintedView $ const Signup
              , className: intercalate " "
                  [ cname <> "__footer-link"
                  , "text-secondary"
                  ]
              }
              [ H.text "No account yet? Sign in here" ]
          ]
        ]

      signupBlock =

        H.div { className: "card" }
        [
          H.div { className: "card-body" }
          [
            createAccount
            { callback: createAccountCallback
            , status: onSignupPending  || onRedirection ? "deferred" $ "enabled"
            }

          , B.buttonLink
            { callback: \_ -> setPrintedView $ const Signin
            , className: intercalate " "
                [ cname <> "__footer-link"
                , "text-secondary"
                ]
            }
            [ H.text "I already have an account" ]
          ]
        ]

    pure $

      H.div
      { className: cname }
      [ H.div { className: cname <> "__inner" }
        [ UI.if' (printedView == Signin)  signinBlock
        , UI.if' (printedView ==  Signup) signupBlock
        ]
      ]

data PrintedView =
    Signin
  | Signup

derive instance eqPrintedView :: Eq PrintedView
