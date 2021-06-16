module Hello.Components.Bootstrap.Cloak
  ( cloak
  ) where

import Prelude

import Data.Foldable (elem, intercalate)
import Data.Maybe (Maybe, fromMaybe)
import Data.Tuple.Nested ((/\))
import Effect.Timer (setTimeout)
import Hello.Plugins.Core.UI as UI
import Reactix as R
import Toestand as T


type Props =
  ( defaultSlot             :: R.Element
  , cloakSlot               :: R.Element
  , isDisplayed             :: Boolean
  , idlingPhaseDuration     :: Maybe Int -- Milliseconds
  , sustainingPhaseDuration :: Maybe Int -- Milliseconds
  | Options
  )

type Options =
  ( className :: String
  )

options :: Record Options
options =
  { className: ""
  }

-- |  Abstract component type easing the transition display between a content
-- |  component and transitional (or cloak) component
-- |
-- |
-- |  Inputs:
-- |    * `defaultSlot :: Element` transclude pattern providing elements
-- |       to be finally displayed
-- |    * `cloakSlot :: Element` transclude pattern proviging elements
-- |       displayed during first phases (see lifecycle explanation below)
-- |    * `isDisplayed :: Boolean` flag defining if the main content is
-- |       ready to be displayed
-- |    * `idlingPhaseDuration :: Maybe Int` if defined, perform idling
-- |       phase (see lifecyle explanation below)
-- |    * `sustainingPhaseDuration :: Maybe Int` if defined, perform sustaining
-- |       phase (see lifecyle explanation below)
-- |
-- |
-- |  The lifecycle is structured into 4 phases:
-- |    1. OPTIONAL, a primary idle phase, where no component is being displayed
-- |      ↳ why? if the flag switched from "off" to "on" in a particularly fast
-- |        pace, it will jump the sustain and wait phases (ie. the display
-- |        of the transitional component, see below) which won't be
-- [        needed anymore
-- |    2. OPTIONAL a sustain phase, where the transitional component will be
-- |        displayed for a defined amount of time
-- |        ↳ why? same heuristic as above, if the switch is too fast, the cloak
-- |          will be displayed at such speed that it will create a flickering
-- |          effect, this phase will avoid it
-- |    3. a waiting phase, where the cloak will be displayed until the switch
-- |        will be set to "on"
-- |    4. a final display phase, where the main content component will be shown
-- |
-- |
-- |  Simple transition:
-- |
-- |    ```purescript
-- |      cloak
-- |      { isDisplayed             : onPendingFlag
-- |      , cloakSlot               : blankPlaceholder {}
-- |      , defaultSlot             : componentToBeDisplayed {} []
-- |      , idlingPhaseDuration     : Nothing
-- |      , sustainingPhaseDuration : Nothing
-- |      }
-- |    ```
-- |
-- |
-- |    Smart transition
-- |
-- |    ```purescript
-- |      cloak
-- |      { isDisplayed             : onPendingFlag
-- |      , cloakSlot               : blankPlaceholder {}
-- |      , defaultSlot             : componentToBeDisplayed {} []
-- |      -- Idling phase set up
-- |      --
-- |      -- * if the computation for display makes less than 20ms, no
-- |      --   transition at all will be displayed, and the content will arrive
-- |      --   as soon as the 20ms delay is consumed
-- |      -- * if the computation takes more, following phases will be set up
-- |      --   (according to the configuration provided)
-- |      , idlingPhaseDuration     : Just 20
-- |      -- Sustaining phase set up
-- |      --
-- |      -- * now let's say the computation talking above makes 35ms before
-- |      --   displaying its content, setting this parameter will avoid a:
-- |      --      35ms (computation) - 20ms (idling) = 15ms (sustaining)
-- |      -- * this very short delay will be considered as a UI flickering
-- |      --   effect for the user, which is a UX smelly design
-- |      -- * by setting the sustaining phase to 400ms, we ensure a period
-- |      --   of time that eliminates this effect
-- |      , sustainingPhaseDuration  : Just 400
-- |      }
-- |    ```
cloak :: forall r. UI.OptLeaf Options Props r
cloak = UI.optLeaf component options

cname :: String
cname = "b-cloak"

component :: R.Component Props
component = R.hooksComponent cname cpt where
  cpt props _ = do
    -- State
    phase /\ phaseBox <- UI.useBox' (Idle :: Phase)

    -- Computed
    className <- pure $ intercalate " "
      -- provided custom className
      [ props.className
      -- BEM clasNames
      , cname
      ]

    canCloakBeDisplayed   <- pure $ elem phase [ Sustain, Wait ]
    canContentBeDisplayed <- pure $ elem phase [ Display ]

    -- @executeDisplayingPhase
    execDisplayingPhase <- pure $ const $
      T.write_ Display phaseBox

    -- Helpers
    execDisplayingPhaseOr <- pure $ \fn ->

      if props.isDisplayed
      then execDisplayingPhase unit
      else fn

    -- @executeWaitingPhase
    execWaitingPhase <- pure $ const $ execDisplayingPhaseOr $
          T.write_ Wait phaseBox

    -- @executeSustainingPhase
    execSustainingPhase <- pure $ const $ execDisplayingPhaseOr $
          T.write_ Sustain phaseBox

      <*  setTimeout
            (fromMaybe 0 props.sustainingPhaseDuration)
            (execWaitingPhase unit)

    -- @executeIdlingPhase
    execIdlingPhase <- pure $ const $ execDisplayingPhaseOr $
          T.write_ Idle phaseBox

      <*  setTimeout
            (fromMaybe 0 props.idlingPhaseDuration)
            (execSustainingPhase unit)

    -- Effects
    R.useEffectOnce' $ execIdlingPhase unit

    R.useEffect1' props.isDisplayed $

      if (props.isDisplayed && phase == Wait)
      then execDisplayingPhase unit
      else pure unit

    -- Render
    pure $

      R.fragment
      [
        UI.if' canCloakBeDisplayed    props.cloakSlot
      ,
        UI.if' canContentBeDisplayed  props.defaultSlot
      ]


data Phase =
    Idle
  | Sustain
  | Wait
  | Display

derive instance eqPhase :: Eq Phase
