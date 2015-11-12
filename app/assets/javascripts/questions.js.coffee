window.Questions = class Questions
  constructor: (@$container_el, @questionnaire_id) ->
    @get_questions()

  get_questions: ->
    $.ajax(
      url: "http://demo-ors-api.ort-staging.linode.unep-wcmc.org/api/v1/questionnaires/#{@questionnaire_id}/questions"
      type: 'GET'
      dataType: 'json'
      contentType: 'text/plain'
      beforeSend: (request) ->
        request.setRequestHeader("X-Authentication-Token", 'xzBA8HXinAO2zprPr')
      error: (jqXHR, textStatus, errorThrown) ->
        @$container_el.append "AJAX Error: {textStatus}"
      success: (data, textStatus, jqXHR) =>
        @append_questions_details(data.questions)
        new Question(@$container_el, @questionnaire_id)
    )

  append_questions_details: (questions) ->
    sections = {
      sections: _.groupBy(questions, (q) ->
        q.question.path[0]
      )
    }
    @$container_el.append(HandlebarsTemplates['questionnaire/questions'](sections))
