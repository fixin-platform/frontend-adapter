class Adapter
  constructor: (config) ->
    check(config, Match.ObjectIncluding
        appKey: String # appKey will be merged with slug
        slug: String
        domainMatchers: [Match.OneOf(String, RegExp)]
    )
    _.extend @, config
    _.defaults @,
      js: []
      css: []
      loaders: []
      addons: _.clone(addons)
      helpers: _.clone(helpers)
      handlers: _.clone(handlers)
  load: (loader) -> @loaders.push(loader)
  debug: (pack, loader) -> @loaders.push(loader) if Foreach.isDebug and Meteor.settings.public.pack is pack
  handleLoad: -> loader.call(@) for loader in @loaders
  app: -> Apps.findOne({key: @appKey})
  appId: -> @app()._id

addons = {}

helpers = {}

handlers =
  createDrop: (options) ->
    if not Foreach.window.FixinDrop
      Foreach.window.FixinDrop = Foreach.window.Drop.createContext(
        classPrefix: "fixin-drop"
      ,
        content: ""
        openOn: "click"
        constrainToWindow: true
        remove: true
        position: "bottom left"
        classes: "fixin"
      )
    drop = new Foreach.window.FixinDrop(options)
    drop.on "open", ->
      $(@drop).css("z-index": 2147483000) # queen of the hill; login modal is the king
      $(@content).addClass(AdapterFactory.current.cssClass)
    drop
