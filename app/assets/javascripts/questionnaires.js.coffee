window.Questionnaires = class Questionnaires
  constructor: (@$container_el, @$list_container) ->
    @get_questionnaires()

  get_questionnaires: ->
    $.ajax '/api/v1/questionnaires.json',
      type: 'GET'
      dataType: 'json'
      contentType: 'text/plain'
      beforeSend: (request) ->
        request.setRequestHeader("X-Authentication-Token", 'QIrNAOBzbj64yMVbR8j')
      error: (jqXHR, textStatus, errorThrown) ->
        @$container_el.append "AJAX Error: #{textStatus}"
      success: (data, textStatus, jqXHR) =>
       @append_questionnaires([].concat data.questionnaires)

  append_questionnaires: (questionnaires) ->
    for questionnaire in questionnaires
      questionnaire = questionnaire.questionnaire
      [respondents, submissions] = @submission_percentage(questionnaire)
      @$list_container.append('<li><a href="questionnaires/'+questionnaire.id+'">'+ questionnaire.title + '</a>' +
        ' ( ' + submissions + '/' + respondents + ' submitted )</li>')

  submission_percentage: (questionnaire) ->
    respondents = questionnaire.respondents
    no_of_respondents = respondents.length
    no_of_submissions = 0
    for respondent in respondents
      no_of_submissions = no_of_submissions + 1 if respondent.respondent.status == 'Submitted'
    [no_of_respondents, no_of_submissions]
