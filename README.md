# Hello Gargan

This project is articulated on two aspects:

1. Learning PureScript / Reactix / Toestand
2. Structuring a React project into a pseudo-framework easing the process of writing UI/UX code and global application architecture

> **Why?** When PureScript is envisaged as an evolution of frontend application, we are facing a main issue regarding the libraries to considered. Thermite, Halogen, Concur, React-Basic, etc. are definitely presents, but does not accomodate very well for new learners. Learning curve is tough, code sometimes hard to reason with. Both Reactix and Toestand offer a great addition to this regard. The following will try to continue this aim by proposing few interfaces helping developing frontend application as a whole. This is by no means a coercive opinion, rather a mix of modeste additions.

## Usage

```bash
# install psc-package
yarn add psc-package

# install dependencies
yarn install -D && yarn install-ps
```

```bash
# or use docker
./help.sh stack:reset
```

## Application Structure

The likes of [NextJS](https://nextjs.org/) or [NuxtJS](https://nuxtjs.org/) offers clean architecture concerning folders and files. Not to mention all the automations available, they provide a simple architecture delimiting:
1. entry points (ie. our pages)
2. UI/UX components
3. some "view-model" logic
4. non-UX/UI related stuffs

### Components
* it is easier for newcomers to provide a clean `"/components"` folder, each file containing its unique component
* it can be heavy, but always well decomposed (eg. the [Diffgram project](https://github.com/diffgram/diffgram/tree/master/frontend/src/components), or simply by adhering to nested folders strategy)
* it can be a mix of business's folders (`"/components/employee"`, `"/components/authentication"`), or applicative ones (`"/components/bootstrap"`: bearing all the reused custom components for UI/UX)

### Pages
* discerning entry points is a nice addition, these components will bear the maximum of logic: sometimes for prefetching data for the future printed view, other times for handling a maximum of UI-async logic (eg. starting prefetching data, displaying some placeholders/spinners during the process)
* here are the similarities with NuxtJS:
    * provide a "premount" [hook](https://nuxtjs.org/docs/2.x/components-glossary/pages-fetch) used to fetch data to hydrate the page to be rendered
    * provide [middleware](https://nuxtjs.org/docs/2.x/directory-structure/middleware/) possibilities that can be registered from the "premount" hook
    * provide a `"/layouts"` folder, expressily used for reused purposes (each "pages" needing to [subscribe](https://nuxtjs.org/docs/2.x/components-glossary/pages-layout/) to a layout)

***

- [ ] *POC on nested pages*
- [ ] *automated the hydration of the `Routes`*
- [ ] *automated the hydration of the `Layouts`*

### Predictable state container businesses
* not every project needs such libraries, as [Dan Abramov](https://twitter.com/dan_abramov/status/1241756566048694272) says, *its all about local vs. global*
* more on that, [he also says](https://github.com/reduxjs/redux/issues/1287#issuecomment-175351978) that this is fundamentaly a pragmatic question
* so with this in mind, the proposed architecture of NextJS (or NuxtJS) just offer both option
* and basically, the Store implemented in this project is not so far from what we can see with [Vuex](https://vuex.vuejs.org/), ie:
    1. *on application mount, generate all the store boxes from default values*
    2. *before application first render, add an entry point hook (cf. `"~/src/plugins/Core/StartUp`)*
    3. *each component/hook/context can asked for a reference to the Store (`"~/src/plugins/Hooks/useStores`): usage is basically the same as the ["purescript-react" `getProps`](https://pursuit.purescript.org/packages/purescript-react/9.0.0/docs/React#v:getProps)*

***

- [ ] *automates the hydration of the `RootStore`*

### How this project is structured

```
  ├─┬─ components
  │ ├──── bootstrap: structural components of Bootstrap v4
  │ └──── ~
  │
  ├─── pages: containing a component, a layout subscription, and a premount hook
  │
  ├─── layouts: containing a component, and a premount hook
  │
  ├─── stores: each file containing a store (ie. a record of Toestand boxes)
  │
  ├─┬─ plugins
  │ ├──── core: core application related businesses
  │ ├──── hooks
  │ └──── contexts
  │
  ├─┬─ assets/sass
  │ ├──── main: Gargantext main CSS file
  │ ├──── bootstrap: Bootstrap v4 CSS file
  │ └──── vendor: other misc CSS files
```

### Routing operations

* provide a hook easing redirection (component side or hook side)
* add a native loading bar component [such as NuxtJS](https://nuxtjs.org/docs/2.x/features/loading/): whenever the page is rendered and take a certain amount of time, a feedback is displayed to the user
* cancel current premount hook computation if a change of route is being made in parallel
* safely redirect on middleware or premount error (eg. if the user is not authenticated)


## CSS Components

### Compiling SASS assets

* as writing CSS for an application can quickly become a tedious task, this project follows some opinionated guidelines

**[See "CSS integration model" wiki](wiki/css_integration_model.md)**


* overall, structuring the main CSS file will follow this pattern:

```
  ├─┬─ assets/sass
  │ ├──┬─ main
  │ │  ├──── abstract: containing members (ie. functions, mixins, variables), so SASS logic
  │ │  ├──── base    : all the cascading styles building the main files, accessed globally and purely CSS logic
  │ │  └──── modules : other isolated SASS logics, have to be imported (`@use`) when needed
  │ │
  │ └──── ~
```

### Automations

* in the same manner as NuxtJS does with its files, every components/pages/layouts of the project can have a dedicated style (just name a `.sass` or `.scss` with the same name, within the same folder)
* each style will be automatically imported to generate the main CSS file
* each style will be automatically re-writed with an import of all the main variables (ie. if we set a `$green-color` in the main variables, it will be accessible within the file ; other custom SASS logic, eg. in the `modules` folder needs to be manually added)

### [@TODO] Scoped feature

* provide a native solution for style scope feature, such as [NuxtJS](https://vue-loader.vuejs.org/guide/scoped-css.html) or [Svelte](https://css-tricks.com/what-i-like-about-writing-styles-with-svelte/#styles-are-scoped-by-default)
* scope feature works extremely great with SASS + BEM

***
- [x] *Bootstrap customisation clean up*
- [x] *distinguish old and new SASS API (ie. SASS modules and lack of Bootstrap compliancy)*
- [x] *add CSS sourcemaps*
- [x] *provide directory shortcut: `"~"` (relative to the `/src/...`) ; `"@"` (relative to the root project `/`, eg. for accessing node modules)*


## Component Structure

### Boilerplates

From the tediousness of jQuery, to AngularJS (v1: producer, directives, ... heavy API) to modern frontend libraries, an evolution regarding structure and boilerplate emerges.

* first of all recent JavaScript frontend libraries offers a simple yet comprehensive creational/structural/behavioral paradigms. ReactJS (Hooks API) opts for a fully JavaScript-ly functional composition paradigm. VueJS adheres to a [Single-File-Component](https://vuejs.org/v2/guide/single-file-components.html) abstraction. The former more difficult to understand for newcomers, but the latter less flexible. It is not a surprise here, but Reactix + Toestand in a PureScript context *is* the most reliable paradigm
* secondly, regarding the boilerplate: when we see a VueJS Single-File-Component and a [Svelte component format](https://svelte.dev/docs), we can only applause the reduction of boilerplate. Each JavaScript frontend libraries offers an iteration in this regards. This is one of the reason to adopt the following structure for each component of the project:

```purescript
-- Spec parts for <bar>
type Props =
  ( foo :: Foo
  )

bar :: UI.Leaf Props
bar = UI.leaf component

component :: R.Component Props
component = R.hooksComponent "bar" cpt where
  cpt _ _ = do
    -- Component parts for <bar>
    -- ...
```

### Optional props

There is a distinction to be noted here, mainly due to PureScript paradigms. As a fully FP language, it is a requirement to be explicit with null coalescing values. But if we look closer, eg. by taking the "purescript-react-basic" [library](https://github.com/lumihq/purescript-react-basic/blob/v0.7.1/src/React/Basic/DOM.purs#L4-L6), we can see an inclination opposite to this requirement. In what measures can we write PureScript component specs by knowing this variadic arity in their attributes/props?


Here is were the optional props comes to mind. For now, let's put aside the fact that a base component (such as `<a/>`) can have an undefined amount yet possibly numerous of attributes. Here we will focus on component that receive spec-ed props. For example:

```purescript
-- Specs for the <icon> component
type Props =
  ( name :: String
  | Options
  )

type Options =
  ( theme :: Theme
  )

options :: Record Options
options =
  { theme: Theme.Filled -- filled/two-tones/outlined/etc. Filled is the default theme of Google Material Design Icons
  }


icon :: forall r. UI.OptLeaf Options Props r
icon = UI.optLeaf component options

component :: R.Component Props
component = R.hooksComponent "icon" cpt where
      -- Component parts for <icon>
      -- ...
```

### [@TODO] DOMAttrs Prop

As we can see in [ReactJS](https://www.reactenlightenment.com/react-jsx/5.7.html), all non props (ie. all non used variable inside a component) could be DOM attributes passing through the parent: _“note that attributes/props just become arguments to a function”_)


In [VueJS](https://vuejs.org/v2/guide/components-props.html#Non-Prop-Attributes), a distinction is made between props and DOM attributes, as props have to respect an implementation. So we can decide to either inherit the DOM attributes, or pass it via a variable to another inner child component.


The transmission of DOM Attributes (programmatically or not) is a useful feature, either for base components or to avoid extra unwanted `<div>` just to set some BEM classes ("div blindness").


Ideally with PureScript + Reactix, the aim could be to have a Row such as `attrs :: DOMAttrs`. Where DOMAttrs could be used as a Record of optional values (such as the use in "purescript-react-basic"). Hence, two tweaks to work: attrs has to be optional, the content of the attrs Record also have to be optional. They have not vocation to be programmatically treated, just handed over from one component to another.


## Form validation

PureScript possesses some already existing libraries regarding validation ("purescript-formless-independent", "purescript-home-run-ball", etc.), but they seemed far too clunky to be used in a simple way for simple things. The project contains an interface with the native "purescript-validation"

**[See "On Validation" wiki](wiki/on_validation.md)**

***

- [ ] *provide a set of Toestand-ready validation helper methods*

## Form State Hooks

This is a hook inspired from this [article](https://blog.logrocket.com/forms-in-react-in-2020/). It greatly simplifies all behaviors regarding form inputs and value changes.

> **Why starting the hook with the use of stateHook instead of Toestand?** Simply because stateHook delivers its fields unwrapped from any monad. It is then limited in terms of patterns (in a FP way), but simpler to managed them as purely vanilla values. As the astute reader will see on the "Component cookbook" part, there is a requirement in frontend patterns inclining us to managed a decomposition of complexity throughout the Component tree (ie. the more deeper, the more dumber). Nonetheless, we are dealing with PureScript, and it is mostly certain that some use cases will benefits for an addition of Toestand for this hook. (a milestone has been put in that direction)

***

- [ ] *provide a parallel Toestand-ready hook*
- [ ] *using SProxy to avoid the `unsafeSet`*

## Bootstrap components

With modern framework, every frontend applications have know the requirement of a reusable set of components. Indeed, as we can simply import a frontend CSS + JS + HTML library (such as [Material Design](https://material.io/design) or [Bootstrap](https://getbootstrap.com/)), most of their vanilla components will inherit of: a possible logic (that it is best to implement within the paradigm of the language/frontend library/framework) ; or a set of constants.


At this moment in PureScript, only few examples remain (we can think of ["purescript-react-material-ui"](https://github.com/nwolverson/purescript-react-material-ui)). Our project started a set of components for Bootstrap v4 (and ["react-bootstrap"](https://react-bootstrap.github.io/) can be an inspiration to look for). It will also contains basic components independent from Bootstrap, but registered as "bootstrap" (ie. "bootstrap" semantic as in reusable set of components).

### Other re-usable logic

> **Does every components existing in the Bootstrap library should be written in PureScript?** Basically no, two reasons:

1. **absence of logic**: dumbest of the dumb vanilla components should remain vanilla. For example, what would be the point of creating PureScript Bootstrap component for a text node bearing a [color variant](https://bootstrap-vue.org/docs/reference/color-variants) (eg. `"text-primary"`). Keep It Simple Stupid here.
2. **declarative vs. implementation**: If we look what vanilla Bootstrap offers for form inputs, we can see a [plethora](https://getbootstrap.com/docs/4.6/components/forms/) of great declarative CSS classNames ("form-control" to set a UI context, add "is-valid" to the DOM element to colorize every border and text in green, etc.). But if we take a look at what the React Bootstrap offers to the [same effect](https://react-bootstrap.github.io/components/forms/), we see a profusion of intricated-but-yet-not-related components, mixing logic, limiting the possible implementations (ie. what happens if we write our vanilla HTML code differently?) As we can see in the `"~/src/assets/sass/main/base/_form.scss"` file, it is far better to just offer simple declarative CSS classNames. So YAGNI here.

### Other non-related Bootstrap library component

- [ ] *`<blank-placeholder>` component: this is a truly needed addition, please check the "Placeholder" part of the "Component Cookbook" wiki*
- [ ] *`<cloak>` overly ["react-suspense"](https://reactjs.org/docs/concurrent-mode-suspense.html) simplified component*
- [ ] *`<reset>` component + context provider for resetting a page*
- [ ] *`<role-control>` component gateway regarding user roles*

## Component Cookbook (design pattern)

There is a lot of existing simple rules to follow while creating a Component Tree for a frontend application, such as: avoid *["prop drilling"](https://scotch.io/courses/10-react-challenges-beginner/use-context-to-pass-data)* ; or what we said earlier *"the deeper, the dumber"*. This cookbook presents some design patterns reusable for PureScript Reactix components.


**[See "Cook to component style patterns" wiki](wiki/a_cookbook_to_component_style_patterns.md)**

### About Modals

> **By any means:** avoid modal whenever it is possible

1. difficult to maintain, as each FFI library as its share of "how-to", most of times it lacks of what another can do (and vice-versa)
2. not a separate component logic / not a fully inherent member of a parent component logic, its hybridness is technically handicapping
3. idem, but with a UI/UX point of view: is the modal content a new page? or is it a fully wrapped-isolated page (such as an iframe)?
4. unwanted added complexity, this is a common smelly situation: when we use a modal in a page, it is anticipated that actions made within it will have a consequence on the host page itself. Which behaviors should be taken into account:
    * when the modal is still there (ie. by making some UI feedbacks behind the modal)?
    * or waiting for the modal to be closed?


*How to limit the uses of modals:*
* ***Keep It Simple Stupid**: limit the use of actions, so that just an alert component type would be truly fit for the purpose (such as "react-material-ui" [dialogs](https://material-ui.com/components/dialogs/) ; or "vue-bootstrap" [sidebar](https://bootstrap-vue.org/docs/components/sidebar))*
* ***YAGNI**: just simply don't, prefer a change of component within the page (such as the project "Authentication" page)*

## Milestones

More details **[here]**(wiki/milestones.md)

@TODO bootstrap declarative class
