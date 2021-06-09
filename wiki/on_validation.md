# On Validation

> The project "FormValidation" hook's basis relies on other concepts visited in a previous VueJS homemade library from another project. The API will naturally be different (as you will read below), but the hypothesis remain the same.

## Motivations

During the years we have seen a profusion of frontend libraries and frameworks. Each one having their little tweaks or characteristics, making them different from one another. Same can be said for one of the most important aspect of the frontend world: validation process. While assimilating this problematic to our project, this [article](https://www.monterail.com/blog/2016/rethinking-validations-for-vue-js) from Damian Dulisz is a good starting point to begin our thought process:

> [...] if you work on a more data oriented application you’ll notice that you’re validating much more than just your inputs. Then you have to combine the above approach with custom validation methods or computed values. This introduces additional noise both in the templates and in your code. I also believe that templates are not the best place for declaring application logic.

Nevertheless, based on experiences with previous projects, we are inclined to approve this contrasting assertion by [Daniel Steigerwald](https://medium.com/@steida/why-validation-libraries-suck-b63b5ff70df5):

> Almost all validation libraries I have seen (and I wrote) suck. Everything is nice and all with *isRequired* and *isEmail*, but then suddenly things become complicated. Custom validations, async validation, cross form fields or even cross forms validation rules, we all have been there. The reason for all of that is simple. There is no such thing as an ideal validation library. [...] Duplication is far cheaper than the wrong abstraction.

These opposite conclusions lead us to a hybrid proposition, taking benefits from both. So we made a simple library which:
* **Relies on a set of robust validators functions**. This [slideshare](https://www.slideshare.net/JosephKachmar/lc2018-input-validation-in-purescript) of Joseph Kachmar invited us to use the PureScript native "purescript-validation" [vendor](https://github.com/chriso/validator.js). These simple use cases can easily be redone in every component/hook/store possible.
* **Proposes the most simple abstraction**. We have abstracted the process throughout two main actions: a method to check a specific entity, another one to check the entire set.

## Behavior

1. methods checking the whole set of entities, the whole set of form fields: we click on the main call-to-action of the form, a global validation is attended.
2. methods dynamically checking one or a few entity: controlling one particular async fields, validating a specific field while writing on it, etc.
3. each global validation increment a step, as if it was lap ; dynamic validation does not

## API
* **"purescript-validation" (SemiGroup)** Provide basic [API](https://pursuit.purescript.org/packages/purescript-validation/5.0.0/docs/Data.Validation.Semigroup#t:V) were we can append validation rules for multiple fields
    * some already existing rules can be retrieved within the *~/plugins/Hooks/FormValidation*
    * every rules will returned a `SemiGroup` `VForm`




* **~/plugins/Hooks/formValidation** component to be reused for composition pattern
```purescript
type Methods =
  -- | Check if previous "try/asyncTry" contains error
  -- |
  -- | variant: * constraining to a given field,
  -- |          * idem + provided error
  ( hasError      ::                    Boolean
  , hasError'     ::          Field  -> Boolean
  , hasError_     :: Field -> String -> Boolean
  -- | Remove all current error without running parallel side effects
  -- |
  -- | variant: * constrained to a given field
  , removeError   ::          Effect Unit
  , removeError'  :: Field -> Effect Unit
  -- | Store number of "try/asyncTry" made (ie. "global" validation made)
  , tryCount      :: Int
  -- | Exec a synchronous validation, run parallel side effects, return result
  -- |
  -- | variant: * Effect/Aff monad dependent validation rules
  , try           :: (Unit ->     VForm) -> Effect EForm
  , asyncTry      :: (Unit -> Aff VForm) -> Aff    EForm
  -- | Exec a dynamic synchronous validation, no parallel side effects runned,
  -- | returned only provided validation part (ie. not the whole result)
  -- | nor returned result)
  -- |
  -- | variant: * Effect/Aff monad dependent validation rules
  , try'          :: (Unit ->     VForm) -> Effect EForm
  , asyncTry'     :: (Unit -> Aff VForm) -> Aff    EForm
  )
```

## Use cases

### Basic validation
* perform a global validation when user clicks on a submit button
* display a global error message if any entity is invalid

```purescript
type FormData =
  ( email :: String
  , password :: String
  )

defaultData :: Record FormData
defaultData =
  { email: ""
  , password: ""
  }

validateEmail :: Record FormData -> VForm
validateEmail r = FV.nonEmpty "email" r.email
               <> FV.email "email" r.email

validatePassword :: Record FormData -> VForm
validatePassword r = FV.nonEmpty "password" r.password

globalValidation :: Record FormData -> VForm
globalValidation r = validateEmail r <> validatePassword r

component :: R.Component ()
component = R.hooksComponent cname cpt where
  cpt _props_ _ = do
    fv <- FV.useFormValidation
    { state, setStateKey, bindStateKey } <- useFormState defaultData
    -- @onSubmit: exec whole form validation and exec callback
    onSubmit <- pure \_ -> do

      result <- fv.try (\_ -> globalValidation state)

      case result of
        Left err -> console.warn3 "form error" state err
        Right _  -> props.callback state
    -- @render
    ...
      if (fv.hasError)
        H.text "Form error!"

      ...

      H.button { on { click: onSubmit } }

      ...
```

### Dynamic validation
* validate a specific input when user enters a new value
* display an error message below the element

```purescript
type FormData =
  ( email :: String
  , password :: String
  )

defaultData :: Record FormData
defaultData =
  { email: ""
  , password: ""
  }

validateEmail :: Record FormData -> VForm
validateEmail r = FV.nonEmpty "email" r.email
               <> FV.email "email" r.email

validatePassword :: Record FormData -> VForm
validatePassword r = FV.nonEmpty "password" r.password

globalValidation :: Record FormData -> VForm
globalValidation r = validateEmail r <> validatePassword r

component :: R.Component ()
component = R.hooksComponent cname cpt where
  cpt _props_ _ = do
    fv <- FV.useFormValidation
    { state, setStateKey, bindStateKey } <- useFormState defaultData
    -- @onEmailChange: dynamically check the format as the user write on input
    onEmailChange <- pure \value -> do

      setStateKey "email" value

      fv.removeError' "email"
      fv.try' (\_ -> validateEmail state)
    -- @render
      ...

        B.formInput
        { callback: onEmailChange
        , value: state.email
        }

        if (fv.hasError' "email")
          H.text "Please enter a valid email address"

        ...
```
### Debouncing validation & Async validation
* defer a validation operation (see David Corbacho's [article](https://css-tricks.com/debouncing-throttling-explained-examples/) for details explanation about debouncing)
* check for specific error for a field to display
* call an asynchronous method executing a validation business for an element

```purescript
type FormData =
  ( email :: String
  , password :: String
  )

defaultData :: Record FormData
defaultData =
  { email: ""
  , password: ""
  }

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

component :: R.Component ()
component = R.hooksComponent cname cpt where
  cpt _props_ _ = do
    fv <- FV.useFormValidation
    { state, setStateKey, bindStateKey } <- useFormState defaultData
    -- @onEmailChange: exec async validation for email unicity
    onEmailChange <- useDebounce 1000 \value -> launchAff_ do

      liftEffect do
        setStateKey "email" value
        console.info "attempting dynamic validation on email"

      result <- fv.asyncTry' (\_ -> dynamicValidation value)

      liftEffect $ console.log result
    -- @render
      ...

        B.formInput
        { callback: onEmailChange
        , value: state.email
        }

        if (fv.hasError_ "email" "emailUnicity")
          H.text "This email is already being used"

        ...
```

### Shared configuration validation
* execute a validation outside of a component
* perform identical validation operations from multiple scopes

```purescript

-- @TODO: make an example where the validation rules and execution are being
--        made from within a Store (need Toestand library re-writing)

```


### Evolutive validation type
* start with a basic validation
* if first submission fails, switch to a dynamic validation

> *Why? It is a common case in UX. First deliver a basic form to the user. No need to afraid him during the process: no error is delivered on input focus and changes. When the user submit its form, it there that the error arrise. Now, if the user rightfully managed to correct an errored input (eg. the password confirmation field was not equal to the original password value), then it is a good practice to dynamically validate this field. It will show, lively, that the user has know entered the attended value (ie. more "reward" given to correct the rest of the form)

```purescript

    ...

    -- @onPasswordChange: showing UI best practices regarding validation
    onPasswordChange <- pure \value -> do

      setStateKey "password" value

      if (fv.tryCount > 0) -- (!) only if one submit has been already made

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

    ...
```
