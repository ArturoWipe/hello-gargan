# Milestones


## Scoped CSS features

[Scoped CSS](https://css-tricks.com/saving-the-day-with-scoped-css/) is a huge advancement towards clean CSS for applications. Unfortunately, browsers [compliancy](https://caniuse.com/style-scoped) is a big issue. However frameworks and libraries, likes NuxtJS and Svelte, embed this feature thanks to automation process.

- [ ] POC an implementation for PureScript + Reactix (difficulty :star: :star: :star:)

## Regarding bootstrap component constants

* `status`, `variant`, etc.: does that need types?
* How to set an open "constants" of data in PureScript? (see this "react-bootstrap" TypeScript [example](https://github.com/react-bootstrap/react-bootstrap/blob/master/src/types.tsx#L1-L10))


### DOM Attributes POC


#### a) :x: as an Open Records Props


```purescript
  myComponent { attrs: { className: "hello" }}
```
  * ***only works as a required props**: use is OK, but it definitely should not be a required prop*
  * ***usage with optional props must include some `unsafe...`**: totally not ideal*

####  b) :x: as a SharedProps for every UI Component

Just the likes of "react-basic" [base components props](https://github.com/lumihq/purescript-react-basic/blob/v0.7.1/src/React/Basic/DOM.purs#L33-L114)

```purescript
  myComponent { className: "hello" }
```

* **default value issue**: not suitable here, as every attrs props would need a default value

####  c) :wavy_dash: Array of attributes

Same idea as the "react-basic" [API for props](https://github.com/purescript-contrib/purescript-react/blob/v9.0.0/src/React/DOM/Props.purs)

```purescript
  myComponent { attrs: [ P.className "hello" ] }
```
* ***ideas on this?***

####  d) :heavy_check_mark: YAGNI

Statistically throughout all of my previous dashboard projects, cases were DOM attributes are used in such a way are on:
* base components
* bootstrap components, majority of "className"

**YAGNI solution here**:
  * *don't think it is worth polluting every component with the SharedProps solution*
  * *hence better go with a YAGNI: set "className" as Props by default for every bootstrap components AND rely more on wrapped based components if needed*
  * *for specific use cases (such as other situations dirrent from the simple "className" one), create an "attrs" Row on the Props RowType (solution a) )*
