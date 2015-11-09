window.Questionnaires = class Questionnaires
  constructor: (@$container_el, @$list_container) ->
    @questionnaire_helper = new QuestionnaireHelper()
    @get_questionnaires()

  get_questionnaires: ->
    $.ajax 'http://demo-ors-api.ort-staging.linode.unep-wcmc.org/api/v1/questionnaires.json',
      type: 'GET'
      dataType: 'json'
      contentType: 'text/plain'
      beforeSend: (request) ->
        request.setRequestHeader("X-Authentication-Token", 'xzBA8HXinAO2zprPr')
      error: (jqXHR, textStatus, errorThrown) ->
        @$container_el.append "AJAX Error: #{textStatus}"
      success: (data, textStatus, jqXHR) =>
       @append_questionnaires([].concat data.questionnaires)

  append_questionnaires: (questionnaires) ->
    for questionnaire in questionnaires
      questionnaire = questionnaire.questionnaire
      [respondents, submissions] = @questionnaire_helper.submission_percentage(questionnaire)
      @$list_container.append(
        """
          <li>
            <a href="questionnaires/#{questionnaire.id}">#{questionnaire.title}</a>
            ( #{submissions}/#{respondents} submitted )
          </li>
        """
      )
