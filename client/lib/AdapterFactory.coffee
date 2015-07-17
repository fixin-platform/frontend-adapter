AdapterFactory =
  current: null
  adapters: []
  cssPromises: []
  jsPromises: []
  create: (config) ->
    adapter = new Adapter(config)
    @adapters.push(adapter)
    adapter
  getByDomain: (domain) ->
    for adapter in @adapters
      for matcher in adapter.domainMatchers
        if domain.match(matcher)
          return adapter
  setCurrentByDomain: (domain) ->
    @current = @getByDomain(domain)
  initIframe: (domain) ->
    @setCurrentByDomain(domain)
    # TODO: _.uniq for CSS and JS files
    @cssPromises = []
    @cssPromises.push $.ajax($(link).attr("href"), {dataType: "text"}) for link in $("link[rel='stylesheet']")
    @cssPromises.push $.ajax("/packages/foundation/public/drop/drop.css", {dataType: "text"})
    @cssPromises.push $.ajax(url, {dataType: "text"}) for url in @current.css
    @jsPromises = [] # TODO: now that we have disabled HTTP-on-HTTPS page warnings, we can attach scripts via <script> tag, without evaluator
    @jsPromises.push $.ajax("/packages/foundation/public/drop/drop.js", {dataType: "text"})
    @jsPromises.push $.ajax(url, {dataType: "text"}) for url in @current.js
  initExtension: (domain) ->
    @setCurrentByDomain(domain)
  handleLoadIframe: ->
    @injectCss()
    @injectJs()
    @injectLogin()
    jQuery.when.apply(jQuery, @jsPromises).done => @current.handleLoad()
  handleLoadExtension: ->
    @injectLogin()
    @current.handleLoad()
  injectCss: ->
    # TODO: http://stackoverflow.com/questions/19210451/packaging-a-font-with-a-google-chrome-extension
#    $(Foreach.document.head).append $('<link rel="stylesheet" href="//maxcdn.bootstrapcdn.com/font-awesome/4.3.0/css/font-awesome.min.css">')
    for promise in @cssPromises
      promise.done (content) ->
        ast = css.parse(content)
        processNode(ast.stylesheet)
        content = css.stringify(ast)
        $(Foreach.document.head).append(
          $("<style/>",
            type: "text/css"
            text: content
          )
        )
  injectJs: ->
    for promise in @jsPromises
      promise.done (js) ->
        evaluator = Foreach.window.execScript or (data) ->
          Foreach.window["eval"].call(Foreach.window, data)
        evaluator(js)
  injectLogin: ->
    AT = Package["useraccounts:core"].AccountsTemplates # heck
    AT.avoidRedirect = true # hack
    AT._init() # hock
    AT.setState("signUp") # hick
    Blaze.renderWithData(Template.extensionWrapper, {template: "login"}, Foreach.document.body)
    $(Foreach.document.body).find("#loginPopup").on('shown.bs.modal', (event) ->
      $(document.body).find(".modal-backdrop").insertAfter(event.target)
    )

Foreach.window = window
Foreach.document = document

baseUrl = location.protocol + "//" + location.hostname + (if location.port then ':' + location.port else '')

rewriter = /url\(("|'|)\//gi # quote is optional

processNode = (node) ->
  processNode(rule) for rule in node.rules if node.rules
  rewriteDeclarationUrl(declaration) for declaration in node.declarations when declaration.type is "declaration" if node.declarations
  if node.selectors
    for index in [0..node.selectors.length - 1]
      node.selectors[index] = "html body div.fixin " + node.selectors[index]

rewriteDeclarationUrl = (declaration) ->
  declaration.value = declaration.value.replace(rewriter, "url($1#{baseUrl}/")
