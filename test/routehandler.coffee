window.riot = require 'riot'
routehandler = require '../lib/routehandler.js'
page = require 'page'
require './samplepages.tag'
spyclick = null
routes = [
  {route:"/",tag:"home"}
  {route:"/page1/",tag:"page1"}
  {route:"/page1/:name",tag:"page1"}
  {route:"/page2/",tag:"page2",routes:[
    {route:"/",tag:"page4"}
    {route:"/sub/:name?",tag:"page2sub"}
  ]}
  {route:"/page3/",tag:"page2",routes:[
    {route:"sub/",tag:"page3sub",routes:[
      {route:"/",tag:"page5"}
      {route:"three/",tag:"page3subsub"}
      {route:"four/",tag:"page2sub"}
    ]} 
  ]}
]

describe 'routehandler',->

  before ->
    @domnode = document.createElement('routehandler')
    @node = document.body.appendChild(@domnode)
    @tag = riot.mount(@domnode,'routehandler',{options:{hashbang:false},routes,test:'Cheese',page:page})[0]

  after ->
    @domnode = ''
    @tag.unmount()

  it "should exist on the page",->
    expect(document.querySelectorAll('routehandler').length).to.equal(1)

  it "should allow deep routes, event if previous route was not a parent",->
    page('/page2/sub/')
    expect(document.body.innerHTML).to.contain('subpage')

  it "should show home page",->
    page('/')
    expect(document.body.innerHTML).to.contain('Home Page')

  it "should show page2 and default page",->
    page('/page2/')
    expect(document.body.innerHTML).to.contain('Page 2')
    expect(document.body.textContent).to.not.contain('subpage')
    expect(document.body.textContent).to.contain('Default Page')

  it "should show sub page",->
    page('/page2/sub/')
    expect(document.body.innerHTML).to.contain('subpage')

  it "should show sub page inside page 2",->
    page('/page2/sub/')
    expect(document.body.innerHTML).to.contain('Page 2')
    expect(document.body.innerHTML).to.contain('subpage')
 
  it "should show route with parameter",->
    page('/page1/cris')
    expect(document.body.innerHTML).to.contain('cris')

  it "should show subroute with parameter",->
    page('/page2/sub/cris/')
    expect(document.body.innerHTML).to.contain('cris')

  it "should have access to root routehandler opts at all levels",->
    page('/page2/sub/cris')
    expect(document.body.innerHTML).to.contain('Cheese')

  it "should have access to sub sub sub document",->
    page('/page3/sub/three/')
    expect(document.body.innerHTML).to.contain('subsub')

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
    expect(document.body.innerHTML).to.contain('subsub')
    page('/page3/sub/four/')
    expect(document.body.innerHTML).to.contain("I'm a subpage")

  it "should update properties when path changes",->
    page('/page1/')
    expect(document.body.innerHTML).not.to.contain('cris')
    expect(document.body.innerHTML).to.contain("hello I'm page 1")
    page('/page1/cris')
    expect(document.body.innerHTML).to.contain('cris')


