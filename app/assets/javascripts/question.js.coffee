window.Question = class Question
  constructor: (@$container_el, @questionnaire_id) ->
    @init_events()

  init_events: ->
    @question_selection()
    @looping_path_selection()

  question_selection: ->
    questions = @$container_el.find('.question-row')
    self = @
    questions.on('click', ->
      self.get_question($(@).data('question_id'))
    )
    @$container_el.on('click', '.close', ->
      $('#question_modal').remove()
    )

  get_question: (question_id) ->
    $.ajax(
      url: "http://demo-ors-api.ort-staging.linode.unep-wcmc.org/api/v1/questionnaires/#{@questionnaire_id}/questions/#{question_id}"
      type: 'GET'
      dataType: 'json'
      contentType: 'text/plain'
      beforeSend: (request) ->
        request.setRequestHeader("X-Authentication-Token", 'xzBA8HXinAO2zprPr')
      error: (jqXHR, textStatus, errorThrown) ->
        @$container_el.append "AJAX Error: #{textStatus}"
      success: (data, textStatus, jqXHR) =>
        question = data.question
        if question.type == "Numeric"
          question
        else
          @group_answers(question)
        @$container_el.append(HandlebarsTemplates['question/question_modal'](question))
        document.location = '#question_modal'
    )

  group_answers: (question) ->
    if question.answers.length > 0
      $.extend(question, {grouped_answers: @group_answers_by_option(question.answers)})
    else
      $.extend(question, {looping_answers: @group_looping_answers(question)})

  group_looping_answers: (question) ->
    grouped_answers = []
    for looping_context in question.looping_contexts
      grouped_answers.push {
        looping_path: looping_context.looping_context.looping_path.join(' > ')
        answers: @group_answers_by_option(looping_context.looping_context.answers)
      }
    grouped_answers

  group_answers_by_option: (answers) ->
    return [] if answers.length <= 0
    _.groupBy(answers, (a) ->
        a.answer.answer_text
    )

  looping_path_selection: ->
    $(@$container_el).on('change', '.looping-paths', ->
      looping_index =  $('.looping-paths option:selected').val()
      $('.looping-answers-table tr.active').removeClass('active')
      $(".looping-answers-table tr.looping_index#{looping_index}").addClass('active')
    )
