window.QuestionnaireDetails = class QuestionnaireDetails
  constructor: (@$container_el)->
    @opts = @$container_el.find('li')
    @init_events()

  init_events: ->
    @opts.on('click', ->
    )
