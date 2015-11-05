window.Question = class Question
  constructor: (@$container_el) ->
    @init_events()

  init_events: ->
    @question_selection()

  question_selection: ->
    questions = @$container_el.find('.question-row')
    questions.on('click', =>
      @$container_el.append(HandlebarsTemplates['questionnaire/question_modal']())
      document.location = '#question_modal'
    )
    @$container_el.on('click', '.close', ->
      $('#question_modal').remove()
    )

