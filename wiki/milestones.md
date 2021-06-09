# Milestones


## Scope features

* (x) no CSS solutions besides style components (one use React Basic)

Better structure
* (todo) autoload components/pages styles (upgrade SASS, add gulp-dart-sass, remove @import deprecated, programmatically add @use in every component/page styles w/ gulp, main and bootstrap file can be reunite)
* (todo) POC style components + CSS transition (otherwise CSS don't need JS: https://dreith.com/blog/a-few-gripes-with-styled-components/)

## Regarding bootstrap component constants

* `status`, `variant`, etc.: does that need types?
* How to set a open "constants" of data in PureScript?
https://github.com/react-bootstrap/react-bootstrap/blob/master/src/types.tsx#L1-L10

### DOM Attributes


##### a) (~) Open records / records with optional values


```purescript
  myComponent { attrs: { className: "hello" }}
```
  * Component with only required props: use is OK, but it should not be a required prop
  * Optional props: usage must include some "unsafe..." in its use, totally not ideal

#####  b) (x) as a SharedProps for every UI Component

Such as
https://github.com/lumihq/purescript-react-basic/blob/v0.7.1/src/React/Basic/DOM.purs#L33-L114
or with just an open record

```purescript
  myComponent { className: "hello" }
```

Same idea as the Optional Component props. Not suitable here, as every attrs props would need a default value

#####  c) (~) Array of attributes

Same idea as the Halogen API for component props and attributes declaration (but with simplification here)

```purescript
  myComponent { attrs: [ "className" /\ "hello" ] }
```

For now just handling a `Tuple String String` to avoid boilerplate issues.
But even that, it is breaking in a way the Reactix API (@WIP: what about Halogen `:=` ?)

#####  d) (=) Choose a Solution

Statistically throughout all of my dashboard projects contains, cases were DOM attributes are used in such a way are on:
* base components
* bootstrap components, majority of "className"

YAGNI solution here:
  * don't think it is worth polluting every component with these ShareProps (solution c) )
  * hence better go with a YAGNI: set "className" as Props by default for every bootstrap components AND rely more on wrapped based components if needed
  * if needed for specific use cases (such as other situations dirrent from the simple "className" one), create an "attrs" Row on the Props RowType (solution b) )
