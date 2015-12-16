window.riot = require 'riot'
routehandler = require '../lib/routehandler.js'
simulant = require 'simulant'
page = require 'page'
require './samplepages.tag'
spyclick = null
test = {}
test = 
  middleware1:(ctx,next)->
    window.middleran1 = true
    next()
  middleware2:(ctx,next,page)->
    window.middleran2 = true
    page.redirect('/page1/')
  middleware3:(ctx,next,page)->
    window.middleran3 = true
  middleware4:(ctx,next,page)->
    window.middleran4 = true
    router = document.querySelector("routehandler");
    router._tag.setTag("middleware");


routes = [
  {route:"*",use:test.middleware1}
  {route:"/",tag:"home"}
  {route:"/page100/",use:test.middleware2}
  {route:"/page101/",use:test.middleware3,tag:"page1"}
  {route:"/page102/",use:test.middleware4}
  {route:"/page1/",tag:"page1"}
  {route:"/page1/:name",tag:"page1"}
  {route:"/page2/",tag:"page2",routes:[
    {route:"/",tag:"page4"}
    {route:"/sub/:name?",tag:"page2sub"}
  ]}
  {route:"/page3/",tag:"page2",routes:[
    {route:"sub/",tag:"page3sub",routes:[
      {route:"three/",tag:"page3subsub"}
      {route:"/",tag:"page5"}
      {route:"four/",tag:"page2sub"}
    ]} 
  ]}
  {route:"/page103/",tag:"hiddensub",routes:[
    {route:"/page104",tag:"page4"}
  ]}
]

describe 'routehandler',->

  before ->
    @domnode = document.createElement('app')
    @node = document.body.appendChild(@domnode)
    @tag = riot.mount(@domnode,'app',{options:{hashbang:false,base:'/test'},routes,test:'Cheese'})[0]

  after ->
    @domnode = ''
    @tag.unmount()



  it "should call middleware on base route",->
    window.middleran1 = false
    page('/')
    expect(window.middleran1).to.be.true


  it "should redirect from middleware",(done)->
    window.middleran2 = false
    page('/page100/')
    expect(window.middleran2).to.be.true
    setTimeout ->
      expect(document.body.textContent).to.contain("hello I'm page 1")
      done()

  it "should run middleware when declaired on same line as tag",->
    window.middleran3 = false
    page('/page101/')
    expect(window.middleran3).to.be.true

  it "should exist on the page",->
    expect(document.querySelectorAll('routehandler').length).to.equal(1)

  it "should allow deep routes, event if previous route was not a parent",->
    page('/page2/sub/')
    expect(document.body.textContent).to.contain('subpage')

  it "should show home page",->
    page('/')
    expect(document.body.textContent).to.contain('Home Page')

  it "should show page2 and default page",->
    page('/page2/')
    expect(document.body.textContent).to.contain('Page 2')
    expect(document.body.textContent).to.not.contain('subpage')
    expect(document.body.textContent).to.contain('Default Page')

  it "should show sub page",->
    page('/page2/sub/')
    expect(document.body.textContent).to.contain('subpage')

  it "should show sub page inside page 2",->
    page('/page2/sub/')
    expect(document.body.textContent).to.contain('Page 2')
    expect(document.body.textContent).to.contain('subpage')
 
  it "should show route with parameter",->
    page('/page1/cris')
    expect(document.body.textContent).to.contain('cris')

  it "should show subroute with parameter",->
    page('/page2/sub/cris/')
    expect(document.body.textContent).to.contain('cris')

  it "should have access to root routehandler opts at all levels",->
    page('/page2/sub/cris')
    expect(document.body.textContent).to.contain('Cheese')

  it "should have access to sub sub sub document",->
    page('/page3/sub/three/')
    expect(document.body.textContent).to.contain('subsub')

  it "should load default page at the third level",->
    page('/page3/sub/')
    expect(document.body.textContent).to.contain('third level default')

  it "should not mount a tag if it's already mounted",->
    window.mountcount = 0
    page('/page1/')
    expect(window.mountcount).to.equal(1)
    page('/page1/')
    expect(window.mountcount).to.equal(1)
    page('/page1/')
    expect(window.mountcount).to.equal(1)

  it "should unmount a subtag, if it's unmounted",->
    window.submountcount = 0
    page('/page2/sub/test')
    expect(window.submountcount).to.equal(1)
    page('/page2/sub/test')
    expect(window.submountcount).to.equal(1)
    page('/page2/')
    expect(window.submountcount).to.equal(0)

  it "should not unmount a subtag, if it's child is unmounted",->
    window.submountcount = 0
    window.subsubmountcount = 0
    page('/page3/sub/three')
    expect(window.submountcount).to.equal(1)
    expect(window.subsubmountcount).to.equal(1)
    page('/page3/sub/three')
    expect(window.submountcount).to.equal(1)
    expect(window.subsubmountcount).to.equal(1)
    page('/page3/sub/')
    expect(window.submountcount).to.equal(1)
    expect(window.subsubmountcount).to.equal(0)
    page('/page3')
    expect(window.submountcount).to.equal(0)
    expect(window.subsubmountcount).to.equal(0)

  it "should unmount a tag when overwritten",->
    window.mountcount = 0
    page('/page1/')
    expect(window.mountcount).to.equal(1)
    page('/page2/')
    expect(window.mountcount).to.equal(0)

  it "should switch subsubtags",->
    page('/page3/sub/three/')
    expect(document.body.textContent).to.contain('subsub')
    page('/page3/sub/four/')
    expect(document.body.textContent).to.contain("I'm a subpage")

  it "should update properties when path changes",->
    page('/page1/')
    expect(document.body.textContent).not.to.contain('cris')
    expect(document.body.textContent).to.contain("hello I'm page 1")
    page('/page1/cris')
    expect(document.body.textContent).to.contain('cris')

  it "should change route after middleware",->
    # https://github.com/crisward/riot-routehandler/issues/4
    simulant.fire( document.querySelector('a[href="/test/"]'), 'click' )
    expect(document.body.textContent).to.contain('Home Page')

    simulant.fire( document.querySelector('a[href="/test/page102/"]'), 'click' )
    expect(document.body.textContent).to.contain('hello middleware')

    simulant.fire( document.querySelector('a[href="/test/page1/"]'), 'click' )
    expect(document.body.textContent).to.contain("hello I'm page 1")

    simulant.fire( document.querySelector('a[href="/test/page102/"]'), 'click' )
    expect(document.body.textContent).to.contain('hello middleware')

    simulant.fire( document.querySelector('a[href="/test/page1/"]'), 'click' )
    expect(document.body.textContent).to.contain("hello I'm page 1")

    simulant.fire( document.querySelector('a[href="/test/page102/"]'), 'click' )
    expect(document.body.textContent).to.contain('hello middleware')

    simulant.fire( document.querySelector('a[href="/test/page1/"]'), 'click' )
    expect(document.body.textContent).to.contain("hello I'm page 1")

  it "should use routehandlers in yielded tags",->
    page('/page103/')
    expect(document.body.textContent).to.contain('hello hidden sub')
    page('/page103/page104')
    expect(document.body.textContent).to.contain('hello hidden sub')
    expect(document.body.textContent).to.contain('Default Page')

 

