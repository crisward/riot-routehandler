routehandler
  div(riot-tag="{tagname}")

  script(type='text/coffeescript').
    page = null
    if require?
      page = require 'page'
    else if !window.page?
      return console.log 'Page.js not found - please check it has been npm installed or included in your page'
    else
      page = window.page
    @on 'mount',=>
      @tagstack = []
      if opts.routes
        @mountRoutes({handler:@},opts.routes)
        if opts.options?.base
          basepath = opts.options.base
          page.base(basepath)
          delete opts.options.base
        page(opts.options)

    @mountRoutes = (parent,routes)=>
      route = @findRoute null,routes,(tree,req)=>
        delete opts.routes
        routeopts = opts
        routeopts.page = page        
        routeopts.params = req.params
        tag = @
        for route,idx in tree
          if @tagstack[idx] && @tagstack[idx].tagname == route.tag            
            nexttag = @tagstack[idx].nexttag
            riot.update()
          else
            nexttag = tag.setTag(route.tag,routeopts) if route?.tag #dont mount middlware
          @tagstack[idx] = {tagname:route.tag,nexttag:nexttag,tag:tag}
          tag = nexttag?[0]?.tags.routehandler
        while idx < @tagstack.length
          removeTag = @tagstack.pop()
          removeTag.nexttag[0].unmount(true)

    @setTag = (tagname,routeopts)=>
      @update(tagname:tagname)
      riot.mount(tagname,routeopts)

    @findRoute = (parents,routes,cback)=>
      parentpath = if parents then parents.map((ob)->ob.route).join("").replace(/\/\//g,'/') else ""
      for route in routes
        if route.use? && typeof route.use == "function"
          do (route)->
            page route.route,(ctx,next)-> 
              route.use(ctx,next,page)
              cback([route],ctx) if route.route !="*" #dont call unmount with wild

        if route.tag?
          subparents = if parents then parents.slice() else []
          subparents.push(route)
          do (subparents)->
            thisroute = route
            mainroute = (parentpath+route.route).replace(/\/\//g,'/')
            page mainroute, (req,next)->
              cback(subparents,req)
              next() if thisroute.routes?.filter((route)-> route.route=="/").length


        @findRoute(subparents,route.routes,cback) if route.routes