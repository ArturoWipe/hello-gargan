# A cookbook to component style patterns

- [ ] add PureScript examples

### Base components
* deepest node of the component tree
* only contain HTML element, other base components and 3rd-party UI components
* ReactJS base components are even more deeper nodes

<a title="see VueJS documentation" href="https://vuejs.org/v2/style-guide/#Base-component-names-strongly-recommended"><img src="https://seeklogo.com/images/V/vuejs-logo-17D586B587-seeklogo.com.png" height="16"></a>
&nbsp;
<a title="see ReactJS documentation" href="https://vasanthk.gitbooks.io/react-bits/styling/05.base-component.html"><img src="https://reactjs.org/favicon.ico" height="16"></a>


***

### Container components
* wrapping an existing component
* communicate with the store or other data-relation library (eg. Relay)
* dispatch behaviours and data

- [ ] [smart and dumb components](https://medium.com/@dan_abramov/smart-and-dumb-components-7ca2f9a7c7d0) article (for examples)

***

### Deep dependency injection
* sharing data that can be considered "global" for the component tree
* use of `provide()` and  `inject()` VueJS APIs
* use the `context` API in ReactJS

<a title="see VueJS documentation" href="https://vuejs.org/v2/guide/components-edge-cases.html#Dependency-Injection"><img src="https://seeklogo.com/images/V/vuejs-logo-17D586B587-seeklogo.com.png" height="16"></a>
&nbsp;
<a title="see ReactJS documentation" href="https://reactjs.org/docs/context.html"><img src="https://reactjs.org/favicon.ico" height="16"></a>

***

### Dual binding
* offer a two-way binding on a form input element or a component
* exclusive to VueJS via the `v-model` directive
* sugar binding of `value` attribute, and emitting its changes (customisation is possible, but not recommended)

<a title="see VueJS documentation" href="https://vuejs.org/v2/api/#v-model"><img src="https://seeklogo.com/images/V/vuejs-logo-17D586B587-seeklogo.com.png" height="16"></a>
&nbsp;
<a title="see VueJS form input examples documentation" href="https://vuejs.org/v2/guide/forms.html"><img src="https://seeklogo.com/images/V/vuejs-logo-17D586B587-seeklogo.com.png" height="16"></a> <sup><sub>form input examples</sub></sup>

- [x] add dualbinding with "FormValidation" hook for inputs
- [ ] idem, via Toestand (maybe check how Formula library is written)

***

### Instance reference
* use of `$ref` in VueJS (`ref` in ReactJS)
* allow parent component to perform DOM manipulation

<a title="see VueJS documentation" href="https://vuejs.org/v2/guide/components-edge-cases.html#Accessing-Child-Component-Instances-amp-Child-Elements"><img src="https://seeklogo.com/images/V/vuejs-logo-17D586B587-seeklogo.com.png" height="16"></a>
&nbsp;
<a title="see ReactJS documentation" href="https://reactjs.org/docs/refs-and-the-dom.html"><img src="https://reactjs.org/favicon.ico" height="16"></a>

***

### Layout component
* a type of component used once per page
* naming format adopting the `<the-component>` prefix

- [ ] put the example of the project `<the-common-dependencies>`

***

### Composition component
* surcharge a component with another given one
* VueJS provides `mixin()` also comes with `extend()` method, inversing the extend direction
* previous major React API also provide "mixins", today deprecated for obvious reasons, now "hooks API" is the main word

<a title="see VueJS documentation" href="https://vuejs.org/v2/guide/mixins.html"><img src="https://seeklogo.com/images/V/vuejs-logo-17D586B587-seeklogo.com.png" height="16"></a>

***

### Placeholder component
* clone of an existing component displayed while on pending process for example
* template created from a generator

<a title="see CodeSandbox example" href="https://create-vue-content-loader.netlify.com/"><img src="https://seeklogo.com/images/C/code-sandbox-logo-0746E97CA1-seeklogo.com.png" height="16"></a>


***

### Transcluded component
* in VueJS: dispatch content from a parent component into child defined slots ; child slots can also provide additional props via `slot-scope` API
* in ReactJS: a lot simpler, as implementation of slots can be done by Props bearing components

<a title="see VueJS documentation" href="https://vuejs.org/v2/guide/components-slots.html"><img src="https://seeklogo.com/images/V/vuejs-logo-17D586B587-seeklogo.com.png" height="16"></a>
&nbsp;
