module Hello.Components.Example.Login
  ( login
  ) where

import Prelude

import Data.Either (Either(..))
import Data.Foldable (intercalate)
import Effect (Effect)
import Hello.Components.Bootstrap as B
import Hello.Plugins.Hooks.FormState (useFormState)
import Hello.Plugins.Hooks.FormValidation (VForm)
import Hello.Plugins.Hooks.FormValidation as FV
import Hello.Plugins.Core.Conditional ((?))
import Hello.Plugins.Core.Console as C
import Hello.Plugins.Core.UI as UI
import Reactix as R
import Reactix.DOM.HTML as H

type Props =
  ( callback :: Record FormData -> Effect Unit
  , status :: String
  )

login :: UI.Leaf Props
login = UI.leaf component

cname :: String
cname = "login"

console :: C.Console
console = C.encloseContext C.Component cname

type FormData =
  ( email :: String
  , password :: String
  )

defaultData :: Record FormData
defaultData =
  { email: ""
  , password: ""
  }

component :: R.Component Props
component = R.hooksComponent cname cpt where
  cpt props _ = do
    -- Custom Hooks
    fv <- FV.useFormValidation
    r@{ state, setStateKey, bindStateKey } <- useFormState defaultData
    -- @onEmailChange: showing UI best practices regarding validation
    onEmailChange <- pure \value -> do

      setStateKey "email" value

      if (fv.tryCount > 0)

      then pure unit
      <*   fv.removeError' "email"
      <*   fv.try' (\_ -> validateEmail state)

      else pure unit

    -- @onPasswordChange: showing UI best practices regarding validation
    onPasswordChange <- pure \value -> do

      setStateKey "password" value

      if (fv.tryCount > 0)

      then pure unit
      <*   fv.removeError' "password"
      <*   fv.try' (\_ -> validatePassword state)

      else pure unit

    -- @onSubmit: exec whole form validation and exec callback
    onSubmit <- pure \_ -> do

      result <- fv.try (\_ -> globalValidation state)

      case result of
        Left err -> console.warn3 "form error" state err
        Right _  -> props.callback state

    -- Render
    pure $

      H.form
      { className: cname
      }
      [
        -- Email
        H.div
        { className: intercalate " "
            [ "form-group"
            , (fv.hasError' "email") ?
                "form-group--error" $
                mempty
            ]
        }
        [
          H.div { className: "form-group__label" }
          [
            H.label {} [ H.text "Email"]
          ]

        , H.div { className: "form-group__field" }
          [
            B.formInput
            { callback: onEmailChange
            , value: state.email
            }

          , UI.if' (fv.hasError' "email")
            ( H.div { className: "form-group__error" }
              [ H.text "Please enter a valid email address" ]
            )
          ]
        ]

        -- Password
      , H.div
        { className: intercalate " "
          [ "form-group"
          , (fv.hasError' "password") ?
              "form-group--error" $
              mempty
          ]
        }
        [
          H.div { className: "form-group__label" }
          [
            H.label {} [ H.text "Password" ]
          ]

        , H.div { className: "form-group__field" }
          [

            B.formInput $
            { type: "password"
            , callback: onPasswordChange
            , value: state.password
            }

          , UI.if' (fv.hasError' "password")
            ( H.div { className: "form-group__error" }
              [ H.text "Please enter a valid password" ]
            )
          ]
        ]

        -- Submit
      , H.div { className: cname <> "__submit" }
        [
          B.button
          { callback: onSubmit
          , status: props.status == "deferred" ? "deferred" $ "enabled"
          , variant: "primary"
          , type: "submit"
          , block: true
          }
          [ H.text "Login" ]
        ]
      ]


validateEmail :: Record FormData -> VForm
validateEmail r = FV.nonEmpty "email" r.email
               <> FV.email "email" r.email

validatePassword :: Record FormData -> VForm
validatePassword r = FV.nonEmpty "password" r.password

globalValidation :: Record FormData -> VForm
globalValidation r = validateEmail r <> validatePassword r
