Template.fixinPopover.helpers
  title: -> Template.instance().currentSlide()["title"]
  template: -> Template.instance().currentSlide()["template"]
  data: -> Template.instance().currentSlide()["data"]
  isFirstSlide: ->
    instance = Template.instance()
    slug = instance.slug.get()
    firstSlide = _.first(instance.slides)
    not slug or firstSlide.slug is slug

Template.fixinPopover.onCreated ->
  check(@data.slides, [Object])
  _.extend @,
    slides: _.clone(@data.slides)
    slug: new ReactiveVar(null)
    currentSlide: ->
      slugValue = @slug.get()
      if slugValue
        _.findWhere(@slides, {slug: slugValue})
      else
        _.first(@slides)
    resetFromCurrentSlide: ->
      slugValue = @slug.get()
      return if not slugValue # no other slides should be present
      for slide, index in @slides
        if slide.slug is slugValue
          @slides.splice(index + 1, @slides.length - index)
          break
    back: ->
      slugValue = @slug.get()
      return if not slugValue # already the first slide
      previousSlide = null
      for slide in @slides
        if slide.slug is slugValue and previousSlide
          @slug.set(previousSlide.slug)
          break
        previousSlide = slide
    forward: ->
      slugValue = @slug.get()
      if not slugValue
        index = 0
      else
        for slide, index in @slides
          if slide.slug is slugValue
            break
      return if not @slides[index + 1]
      @slug.set(@slides[index + 1].slug)

Template.fixinPopover.events
  "click .fixin-popover-close-btn": grab encapsulate (event, template) ->
    $(event.currentTarget).trigger("drop:close")
  "click .fixin-popover-back-btn": grab encapsulate (event, template) ->
    Template.instance().back()

# @see AdapterFactory::addFixinPopoverEvents()
