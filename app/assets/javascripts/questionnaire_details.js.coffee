window.QuestionnaireDetails = class QuestionnaireDetails
  constructor: (@$container_el, @$tab_container,
    @$details_container, @$questions_container) ->

    @questionnaire_helper = new QuestionnaireHelper()
    @opts = @$container_el.find('li')
    @get_questionnaire_details()
    @init_events()

  get_questionnaire_details: ->
    questionnaire_id = @$container_el.data('questionnaire_id')
    $.ajax(
      url: "/api/v1/questionnaires/#{questionnaire_id}"
      type: 'GET'
      dataType: 'json'
      contentType: 'text/plain'
      beforeSend: (request) ->
        request.setRequestHeader("X-Authentication-Token", 'QIrNAOBzbj64yMVbR8j')
      error: (jqXHR, textStatus, errorThrown) ->
        @$container_el.append "AJAX Error: #{textStatus}"
      success: (data, textStatus, jqXHR) =>
       @append_questionnaire_details(data.questionnaire)
    )

  append_questionnaire_details: (questionnaire) ->
    [respondents, submissions] = @questionnaire_helper.submission_percentage(questionnaire)
    @$details_container.find('.details-list').append(
     '<li> <strong>Submission percentage:</strong> ' + submissions + '/' + respondents + '</li>' +
     '<li> <strong>Language:</strong> ' + questionnaire.language + '</li>' +
     '<li> <strong>Available languages:</strong> ' + questionnaire.languages + '</li>' +
     '<li> <strong>Status:</strong> ' + questionnaire.status + '</li>' +
     '<li> <strong>Created on:</strong> ' + questionnaire.questionnaire_date + '</li>'
    )

    respondents_table = @$details_container.find('.respondents-table > tbody')
    for respondent in questionnaire.respondents
      respondent = respondent.respondent
      respondents_table.append('<tr>' +
        '<td>' + respondent.full_name + '</td>' +
        '<td>' + respondent.status + '</td>' +
        '</tr>'
      )

  init_events: ->
    @$container_el.on('click', (event) ->
      event.preventDefault()
    )

    self = @
    @opts.on('click', ->
      opt = $(this)
      if opt.hasClass("active")
        return
      else
        self.$container_el.find(".active").removeClass("active")
        opt.addClass("active")

      data_container = $('.' + $(this).data('container'))
      if data_container.hasClass("active")
        return
      else
        self.$tab_container.find('.active-container').removeClass('active-container').hide()
        data_container.addClass("active-container").show()
    )
