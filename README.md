Overview
----
Taggs are defined by three components:
  
  - **a name**, the thing to call them (`<an-orange>`)

  - **options**, how to customize them (`<an-orange age="25d">`)

  - **functions**, that govern how they should act (`grow()`, `pick()`)


Defining a tagg
----
Definitions can be declared in HTML, by using a `definition` attribute, or in javascript:

```html
<an-orange definition>
  <template>
    i'm an orange!
  </template>
</an-orange>
```

```javascript
tagg.define("an-orange", {
  template: "i'm an orange"
})
```


Adding options:
----
Taggs can be defined with options that represent how they can be customized, they represent the state of the tagg. These options are set as attributes in HTML or as fields in javasript:

```html
<orange-tree definition fruits="20"></orange-tree>
```

```javascript
tagg.define("orange-tree", {
  fruits: 20
})
```


Adding functions
----
Each tagg has a set built in-functions. These are 
  
  - `created`: fired for each instance of the tagg found
  - `changed(option, oldVal, newVal)`:  called everytime an attribute is changed 
  - `update(frameNum)`: called every frame, allows you to update behavior based on attributes
  - `removed`: called when an instance is removed
  
When an instance of a tagg is found, it's `created` function is called. In this case, such behavior 
Each tagg has attributes, and life cycle functions. These attributes can be set arbitrarily (`size, color`), and functions can be attached as well (`expand`, `minimize`). Some functions are built in:

```javascript
tagg.define('hello-world', {
  created: function () {
    alert('hello world');
  }
})
```

Tagg naming
----
The name of a tagg, tells you where to find it:

```html
<hello-world></hello-world>
<hello-sunshine></hello-sunshine>
```

is structured, by default, in these files.

```
hello/
  |-----world.html
  |-----sunshine.html
```

HTML definitions
----
Each tagg has the ability in it's definition, to bind to an enclosing definition if it finds itself in. The `function-` family, for instance, binds functions to its parentTagg. 

```html
<hello-world definition>
  <function-created>
    alert('hello world');
  </function-created>
</hello-world>
```


Using a tagg
----
After a tagg has been defined, it can be invoked by attaching an HTML element of it to your page.

```html
  <ul>
    <some-tagg></some-tagg>
    <some-tagg></some-tagg>
  </ul>
```

produces:

```html
  <ul>
    <some-tagg>
      <li>An item</li>
    </some-tagg>
    <some-tagg>
      <li>An item</li>
    </some-tagg>
  <ul>
```


Loading a tagg
----
The tagg library keeps an eye on everything going on a page, and attempts to track down its definition.

```html
<html>
    <body>
        <script src="//tagg.to/go.js"></script>
        <hello-world></hello-world>
    </body>
</html>
```

Tagg banks
----
Tagg banks are nothing more than a collection of definitions, and machinery to find definitions. A `FileBank`, for instance, searches files with similar names:

```
hello/
  |-----world.html
  |-----sunshine.html
```

The above would be the directory structure for `<hello-world>` and `<hello-sunshine>`.

Family banks
----
Family banks are the default bank in Tagg. They allow for a `family.html` to be placed at the root of a family. This file can then control the behavior of the whole family.

```
hello/
  |-----family.html
  |-----world.html
  |-----sunshine.html
```


Tagg attributes
----
Tagg's can have attributes set in their definitions.

```html
<another-tagg definition size="20">
</another-tagg>
```

Whenever an instance of `<another-tagg>` was created, its size would, by default, be set to 20. But this could be overwritten.

```html
<another-tagg size="10">
</another-tagg>
```

These attributes can be accessed in JS.

```javascript
  anotherTagg = document.getElementsByTagName("another-tagg")[0];
  anotherTagg.size = 100;
```

API
----
```javascript
tagg.define(taggName, {

  // built in properties
  style: ""
  libs: ""
  extends: ""
  template: ""

  // custom properties
  size: 40

  // built in functions
  created: function () {} 
  removed: function () {}
  changed: function (attribute, oldVal, newVal) {}
  update: function (frameNum) {}
  bindToParent: function (def) {}

});
```

Allow for the splicing of HTML + JS + CSS. Use HTML as vessel to object orient, to structure, and carry snippets of JS + CSS.


Stream
----
Falls back to the tagg stream
Repos are connected to the tagg stream, or hosted on it.
After searching locally for a definition, Tagg will fall back to tagg stream, connected open-source repos. Definitions, such as `hello-world`can be found at tagg.to/hello/world/

```html
<html>
  <body>
    <script src="http//tagg.to/go.js"></script>
    <hello-world></hello-world>
  </body>
</html>
```


```html
<chartjs-pi slice-1="40%" slice-2="30%" slice-3="30%">
</chartjs-pi>
```

or

```html
<three-scene>
  <three-cube>
  </three-cube>
</three-scene>
```