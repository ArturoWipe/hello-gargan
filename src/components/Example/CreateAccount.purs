module Hello.Components.Example.CreateAccount(createAccount, FormData) where

import Prelude

import Data.Either (Either(..))
import Data.Foldable (foldl, intercalate)
import Data.Tuple.Nested ((/\))
import Data.Validation.Semigroup (invalid)
import Effect (Effect)
import Effect.Aff (Aff, launchAff_)
import Effect.Class (liftEffect)
import Hello.Components.Bootstrap as B
import Hello.Plugins.Hooks.Debounce (useDebounce)
import Hello.Plugins.Hooks.FormState (useFormState)
import Hello.Plugins.Hooks.FormValidation (VForm, (<!>))
import Hello.Plugins.Hooks.FormValidation as FV
import Hello.Plugins.Core.Conditional ((?))
import Hello.Plugins.Core.Console as C
import Hello.Plugins.Core.UI as UI
import Reactix as R
import Reactix.DOM.HTML as H
import Record (merge)

type Props =
  ( callback :: Record FormData -> Effect Unit
  , status :: String
  | Options
  )

type Options = ( | FormData )

options :: Record Options
options = merge {} defaultData

createAccount :: forall r. UI.OptLeaf Options Props r
createAccount = UI.optLeaf component options

cname :: String
cname = "create-account"

console :: C.Console
console = C.encloseContext C.Component cname

component :: R.Component Props
component = R.hooksComponent cname cpt where
  cpt props _ = do
    -- Custom Hooks
    fv <- FV.useFormValidation
    r@{ state, setStateKey, bindStateKey } <- useFormState defaultData
    -- @onEmailChange: exec async validation for email unicity
    onEmailChange <- useDebounce 1000 \value -> launchAff_ do

      liftEffect do
        setStateKey "email" value
        console.info "attempting dynamic validation on email"

      result <- fv.asyncTry' (\_ -> dynamicValidation value)

      liftEffect $ console.log result

    -- @onSubmit: exec whole form validation and exec callback
    onSubmit <- pure $ launchAff_ do

      result <- fv.asyncTry (\_ -> globalValidation state)

      liftEffect do

        case result of
          Left err -> console.warn3 "form error" state err
          Right _  -> props.callback state

    -- Render
    pure $

      H.form
      { className: cname }
      [
      -- Name
        H.div
        { className: intercalate " "
          [ "form-group"
          , (fv.hasError' "name") ?
              "form-group--error" $
              mempty
          ]
        }
        [
          H.div { className: "form-group__label" }
          [
            H.label {} [ H.text "Name" ]
          ]

        , H.div { className: "form-group__field" }
          [

            B.formInput $
            bindStateKey "name"

          , UI.if' (fv.hasError' "name")
            ( H.div { className: "form-group__error" }
              [ H.text "Please enter a valid name" ]
            )
          ]
        ]

      -- Email
      , H.div
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

          , UI.if' (fv.hasError_ "email" "nonEmpty" ||
                    fv.hasError_ "email" "email"
                   )
            ( H.div { className: "form-group__error" }
              [ H.text "Please enter a valid email address" ]
            )

          , UI.if' (fv.hasError_ "email" "emailUnicity")
            ( H.div
              { className: "form-group__error form-group__error--obtrusive" }
              [ B.div' { className: "mt-1" }
                "This email address is already being used"
              , H.text
                "Please use another one"
              ]
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
            } `merge` bindStateKey "password"

          , UI.if' (fv.hasError' "password")
            ( H.div { className: "form-group__error" }
              [ H.text "Please enter a valid password" ]
            )
          ]
        ]

      -- Password confirmation
      , H.div
        { className: intercalate " "
          [ "form-group"
          , (fv.hasError' "passwordConfirmation") ?
              "form-group--error" $
              mempty
          ]
        }
        [
          H.div { className: "form-group__label" }
          [
            H.label {} [ H.text "Password confirmation" ]
          ]

        , H.div { className: "form-group__field" }
          [

            B.formInput $
            { type: "password"
            } `merge` bindStateKey "passwordConfirmation"

          , UI.if' (fv.hasError' "passwordConfirmation")
            ( H.div { className: "form-group__error" }
              [ H.text "Please enter the same password as the one above" ]
            )
          ]
        ]

        -- Submit
      , H.div { className: cname <> "__submit" }
        [
          B.button
          { callback: \_ -> onSubmit
          , status: props.status == "deferred" ? "deferred" $ "enabled"
          , variant: "primary"
          , type: "submit"
          , block: true
          }
          [ H.text "Submit" ]
        ]
      ]


type FormData =
  ( name                    :: String
  , email                   :: String
  , password                :: String
  , passwordConfirmation    :: String
  , termsAndConditionsFlag  :: Boolean
  )

defaultData :: Record FormData
defaultData =
  { name                    : ""
  , email                   : ""
  , password                : ""
  , passwordConfirmation    : ""
  , termsAndConditionsFlag  : false
  }

globalValidation :: Record FormData -> Aff VForm
globalValidation r =
  let
    sync =
      -- "name" validation
      [ FV.nonEmpty "name" r.name
      -- "email" validation (just take one error at a time for this field)
      , FV.nonEmpty "email" r.email <!>
        FV.email "email" r.email
      -- "password" validation
      , FV.nonEmpty "password" r.password
      -- "passwordConfirmation" validation (also taking just one error)
      , FV.nonEmpty "passwordConfirmation" r.passwordConfirmation <!>
        FV.equals "passwordConfirmation" r.passwordConfirmation r.password
      ]
    -- async "email" validation
    async = dynamicValidation r.email
  in
    -- as this is an "asyncTry" validation (due to the presence of the
    -- simulated XHR for the email, we have to lift the "sync" rules)
    ( pure $ foldl append mempty sync ) <> async



dynamicValidation :: String -> Aff VForm
dynamicValidation s =
  let
    rule = simulateOnlineEmailUnicity "email" s
  in do
    -- simulate call to API
    pure rule

simulateOnlineEmailUnicity :: String -> String -> VForm
simulateOnlineEmailUnicity field value
  | value == "already@used.com" = invalid [ field /\ "emailUnicity" ]
  | otherwise = pure unit
