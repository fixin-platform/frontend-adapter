Template.fixinBlueprints.helpers
  subscriptionsReady: ->
    BlueprintsHandle.ready()
  blueprints: ->
    app = AdapterFactory.current.app()
    return [] if not app # not loaded yet
    Blueprints.find({appId: app._id, tags: @tag, isImplemented: true})
  name: ->
    @areaname or @name

Template.fixinBlueprints.onCreated ->

Template.fixinBlueprints.events
  "click a": grab encapsulate secure (event, template) ->
    $target = $(event.currentTarget)
    $popover = $target.closest(".fixin-popover")
    popoverView = Blaze.getView($popover[0])
    popoverTemplateInstance = popoverView.templateInstance()
    recipe = @generateRecipe(
      userId: Meteor.userId()
    )
    popoverTemplateInstance.resetFromCurrentSlide()
    popoverTemplateInstance.slides.push(
      slug: recipe._id
      title: recipe.name
      template: "recipeBody"
      data:
        recipeId: recipe._id
    )
    popoverTemplateInstance.slug.set(recipe._id)
#    $target = $(event.currentTarget)
#    $target.trigger("drop:close")
#    Checkmarks.find({model: "TrelloCard"}).forEach (checkmark) ->
#      $link = $("a[href^='/c/#{checkmark.handle}']", Foreach.document.body)
#      $link.closest(".list-card").remove()
#    # temp
#    isMultiSelectEnabled = not Foreach.currentUserOption("Trello", "isMultiSelectEnabled")
#    Meteor.users.update(Meteor.userId(), {$set: {"options.Trello.isMultiSelectEnabled": isMultiSelectEnabled}})
#    if not isMultiSelectEnabled
#      Checkmarks.find({model: "TrelloCard"}).forEach (checkmark) ->
#        Checkmarks.remove(checkmark._id)

