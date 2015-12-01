# Change Log


## [1.2.1]
### Added
* Change Middleware callback parameters to (ctx,next,page)
* Allowed `use` and `tag` to be used together on the same route declaration

## [1.2.0]
### Added
* Middleware, tag can now be replace with use within route, which accepts a callback

## [1.1.0]
### Added
* Default routes using '/', allowing subroutes to autoload when parent routehandler changes