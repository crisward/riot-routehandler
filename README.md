# Riot Routehandler

[![Build Status](https://travis-ci.org/crisward/riot-routehandler.svg)](https://travis-ci.org/crisward/riot-routehandler) 
[![Coverage Status](https://coveralls.io/repos/crisward/riot-routehandler/badge.svg?branch=master&service=github)](https://coveralls.io/github/crisward/riot-routehandler?branch=master) 
[![NPM Downloads](https://img.shields.io/npm/dm/riot-routehandler.svg)](https://www.npmjs.com/package/riot-routehandler)
[![NPM Downloads](https://img.shields.io/npm/v/riot-routehandler.svg)](https://www.npmjs.com/package/riot-routehandler)


## Installing

```
npm install riot-routehandler
```

## Demo

Basic demo [here](http://codepen.io/crisward/pen/xwGJpM?editors=101)

## Usage

This has been designed to be used with a common js compiler. I mainly use 'Browserify', though it should work fine
with webpack. You'll also need something like `riotify` to require your tags in.

First you'll need to setup your routes and tag files. Each route can be assigned 
a tag. When the route is navigated to your tag will be loaded into the  routehandler tag.
Mount will be called when your tag is added and unmount will be called when it is navigated away from.

```javascript
//app.js
riot = require('riot');
require('riot-routehandler');
require('home.tag')
require('about.tag')
require('settings.tag')
require('settings1.tag')
require('settings2.tag')

routes = [
    {route:"/",tag:"home"},
    {route:"/about/",tag:"about"},
    {route:"/settings/",tag:"settings",routes:[
      {route:"setting1/",tag:"settings1"},
      {route:"setting2/:name?",tag:"settings2"},
    ]}
  ];

app = riot.mount('routehandler',{routes:routes,routeroptions:{hashbang:true}});
```

You'll also need to add the routehandler to your html file.
If you add links to your page which match those in your router, they'll be 
intercepted to use your client side routes.

```html
<!DOCTYPE html>
<html>
  <head>
    <title>Sample Doc</title>
  </head>
  <body>
    <a href='/'>Home</a>
    <a href='/about/'>About</a>
    <a href='/settings/'>Settings</a>

    <routehandler></routehandler>
    <script src="app.js"></script>
  </body>
</html>
```

### Subroutes

In the example above the settings section has two sub-routes, `/settings/setting1/` and
`/settings/setting2/:name?`.

For these to work, the settings tag will also need a routehandler.

```html
<settings>
  <h3>Settings Panel</h3>
  <routehandler></routehandler>
</settings>
```

### Parameters

Any parameters passed into routes are made available on your tag as opts.params.
So in the example above, the name parameter would be accessed as...

```html
<settings2>
  <h3>Hello {opts.params.name}</h3>
</settings2>
```

### Passing in data

Any properties passed into the top level routehandler will be passed into
all sub-routehandlers too. This can be useful for passing down 'stores'.

`app = riot.mount('routehandler',{routes:routes,routeroptions:{hashbang:true},stores:stores})`

### Navigation

Navigation can be done programmatically via opts.page. Riot-routehandler
uses [page.js](https://github.com/visionmedia/page.js), so naviating is done with this
passed in function. ie to go to about page

`opts.page('/about/')`

### Default Routes

It is possible to have a default subroute. This can be done by simply using the `/`
in your subroutes. With the following routes, `subpage` tag will be shown by default
if you navigate to `/page/`.

```html
routes = [
    {route:"/",tag:"home"},
    {route:"/page/",tag:"settings",routes:[
      {route:"/",tag:"subpage"},
      {route:"/another/",tag:"subpage2"},
    ]}
  ];
```

### Middleware

It is sometimes useful to run code before a tag is displayed, perhaps for permission
checking or even animation (ie changing classes on the body tag)

This is possible by passing functions into the router in the form of middleware. 
Each middleware function will be passed a context object and a next callback. `this` within 
your middleware will be bound to the `page` object so you have access to the various
page methods. eg.

```javascript
var auth = function(ctx,next){
  if(loggedin) return next();
  this.redirect('/login')
}

routes = [
    {route:"/",tag:"home"},
    {route:"/admin/",use:auth},
    {route:"/admin/",tag:"adminpanel",routes:[
      {route:"/",tag:"mainadmin"},
      {route:"/user/",tag:"useradmin"},
    ]}
  ];

```

### Options

Any options your want to pass into the [page.js](https://github.com/visionmedia/page.js) 
system can be done via `routeroptions`. The above example is using hashbang routing.
Other options can be [found here](https://github.com/visionmedia/page.js#pageoptions)


## About

Couldn't find anything for riot which gave this ui-router type functionality.
I also wanted a familiar path syntax, so used page.js as it uses the same route
matching as express.js. Also thought this would aid in making this work server
side eventually. Finally I wanted something to be small and simple in the spirit of riot.
Angular ui-router does a ton of stuff I never use, so I've kept this to do
exaclty what I need and no more. Page.js is apparently 1200bytes and this library
is <50 lines of code.


## Running Tests

```
npm install
npm test
```

## Compatibility

Internet Explorer versions 9 and below don't support the pushstate api, so require the addition of a browser shim to make this work. Page.js recommends <https://github.com/devote/HTML5-History-API>. This is available via a cdn, and if
included with a conditional comment, would only be loaded in IE9 and below.

```html
<!--[if lte IE 9 ]>
  <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/html5-history-api/4.2.2/history.min.js"></script>
<![endif]-->
```


## Todo

* Add an examples folder and a pretty site. 
* Maybe add a demo video.


## Credit

Thanks to vision media for [page.js](https://github.com/visionmedia/page.js) which this depends on and the
other routers which inspired this including [angular-ui-router](https://github.com/angular-ui/ui-router)

## License

(The MIT License)

Copyright (c) 2015 Cris Ward

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

