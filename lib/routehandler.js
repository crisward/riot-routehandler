
riot.tag('routehandler', '<div riot-tag="{tagname}"></div>', function(opts) {var page;

if (typeof require !== "undefined" && require !== null) {
  page = require('page');
} else if (window.page == null) {
  return console.log('Page.js not found - please check it has been npm installed or included in your page');
} else {
  page = window.page;
}

this.page = page;

this.on('mount', (function(_this) {
  return function() {
    var basepath, ref;
    _this.tagstack = [];
    if( opts.routeroptions && opts.routeroptions.pagehandlers != undefined)
      for( p in opts.routeroptions.pagehandlers ) 
        page(p,opts.routeroptions.pagehandlers[p])
    if (opts.routes) {
      _this.mountRoutes({
        handler: _this
      }, opts.routes);
      if ((ref = opts.options) != null ? ref.base : void 0) {
        basepath = opts.options.base;
        page.base(basepath);
        delete opts.options.base;
      }
      return page(opts.options);
    }
  };
})(this));

this.mountRoutes = (function(_this) {
  return function(parent, routes) {
    var route;
    return route = _this.findRoute(null, routes, function(tree, req) {
      var i, idx, len, nexttag, removeTag, results, routeopts, tag;
      delete opts.routes;
      routeopts = opts;
      routeopts.page = page;
      routeopts.params = req.params;
      tag = _this;
      for (idx = i = 0, len = tree.length; i < len; idx = ++i) {
        route = tree[idx];
        if (_this.tagstack[idx] && _this.tagstack[idx].tagname === route.tag) {
          nexttag = _this.tagstack[idx].nexttag;
          riot.update();
        } else {
          nexttag = tag.setTag(route.tag, routeopts);
        }
        _this.tagstack[idx] = {
          tagname: route.tag,
          nexttag: nexttag,
          tag: tag
        };
        tag = nexttag[0].tags.routehandler;
      }
      results = [];
      while (idx < _this.tagstack.length) {
        removeTag = _this.tagstack.pop();
        results.push(removeTag.nexttag[0].unmount(true));
      }
      return results;
    });
  };
})(this);

this.setTag = (function(_this) {
  return function(tagname, routeopts) {
    _this.update({
      tagname: tagname
    });
    return riot.mount(tagname, routeopts);
  };
})(this);

this.findRoute = (function(_this) {
  return function(parents, routes, cback) {
    var fn, i, len, parentpath, results, route, subparents;
    parentpath = parents ? parents.map(function(ob) {
      return ob.route;
    }).join("").replace(/\/\//g, '/') : "";
    fn = function(subparents) {
      var mainroute, thisroute;
      thisroute = route;
      mainroute = (parentpath + route.route).replace(/\/\//g, '/');
      return page(mainroute, function(req, next) {
        var ref;
        cback(subparents, req);
        if ((ref = thisroute.routes) != null ? ref.filter(function(route) {
          return route.route === "/";
        }).length : void 0) {
          return next();
        }
      });
    };
    results = [];
    for (i = 0, len = routes.length; i < len; i++) {
      route = routes[i];
      subparents = parents ? parents.slice() : [];
      subparents.push(route);
      fn(subparents);
      if (route.routes) {
        results.push(_this.findRoute(subparents, route.routes, cback));
      } else {
        results.push(void 0);
      }
    }
    return results;
  };
})(this);

});
