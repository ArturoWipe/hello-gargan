module Hello.Components.Example.Login
  ( login
  ) where

import Prelude

import Data.Either (Either(..))
import Data.Foldable (intercalate)
import Effect (Effect)
import Hello.Components.Bootstrap as B
import Hello.Plugins.Core.Conditional ((?))
import Hello.Plugins.Core.Console as C
import Hello.Plugins.Core.UI as UI
import Hello.Plugins.Hooks.FormValidation (VForm, useFormValidation)
import Hello.Plugins.Hooks.FormValidation.Unboxed as FV
import Hello.Plugins.Hooks.StateRecord (useStateRecord)
import Reactix as R
import Reactix.DOM.HTML as H
import Toestand as T

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

component :: R.Component Props
component = R.hooksComponent cname cpt where
  cpt props _ = do
    -- Custom Hooks
    { state, stateBox, setStateKey, bindStateKey } <- useStateRecord defaultData
    fv <- useFormValidation
    -- @onEmailChange: showing UI best practices regarding validation
    onEmailChange <- pure \value -> do

      setStateKey "email" value

      if (fv.tryCount > 0)

      then do
        -- As we have just modified the "email" value above
        -- performing a validation via `state` data will not reflect this change
        -- So we have to use Toestand API to retrieve the very-last state
        state' <- T.read stateBox
        fv.removeError' "email"
        _ <- fv.try' (\_ -> validateEmail state')
        pure unit

      else pure unit

    -- @onPasswordChange: showing UI best practices regarding validation
    onPasswordChange <- pure \value -> do

      setStateKey "password" value

      if (fv.tryCount > 0)

      then do
        -- As we have just modified the "email" value above
        -- performing a validation via `state` data will not reflect this change
        -- So we have to use Toestand API to retrieve the very-last state
        state' <- T.read stateBox
        fv.removeError' "password"
        _ <- fv.try' (\_ -> validatePassword state')
        pure unit

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
      { className: cname }
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
          H.div
          { className: "form-group__label" }
          [
            H.label {} [ H.text "Email"]
          ]
        ,
          H.div
          { className: "form-group__field" }
          [
            B.formInput
            { callback: onEmailChange
            , value: state.email
            }
          ,
            UI.if' (fv.hasError' "email")
            ( H.div { className: "form-group__error" }
              [ H.text "Please enter a valid email address" ]
            )
          ]
        ]
      ,
        -- Password
        H.div
        { className: intercalate " "
          [ "form-group"
          , (fv.hasError' "password") ?
              "form-group--error" $
              mempty
          ]
        }
        [
          H.div
          { className: "form-group__label" }
          [
            H.label {} [ H.text "Password" ]
          ]
        ,
          H.div
          { className: "form-group__field" }
          [
            B.formInput
            { type: "password"
            , callback: onPasswordChange
            , value: state.password
            }
          ,
            UI.if' (fv.hasError' "password") $
              H.div { className: "form-group__error" }
              [ H.text "Please enter a valid password" ]
          ]
        ]
      ,
        -- Submit
        H.div
        { className: cname <> "__submit" }
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


type FormData =
  ( email    :: String
  , password :: String
  )

defaultData :: Record FormData
defaultData =
  { email   : ""
  , password: ""
  }

validateEmail :: Record FormData -> Effect VForm
validateEmail r = FV.nonEmpty "email" r.email
               <> FV.email "email" r.email

validatePassword :: Record FormData -> Effect VForm
validatePassword r = FV.nonEmpty "password" r.password

globalValidation :: Record FormData -> Effect VForm
globalValidation r = validateEmail r
                  <> validatePassword r
