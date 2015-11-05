window.QuestionnaireDetails = class QuestionnaireDetails
  constructor: (@$container_el, @$tab_container,
    @$details_container, @$questions_container) ->

    @questionnaire_helper = new QuestionnaireHelper()
    @questionnaire_id = @$container_el.data('questionnaire_id')
    @get_questionnaire_details()
    new Questions(@$questions_container, @questionnaire_id)
    @init_events()

  get_questionnaire_details: ->
    $.ajax(
      url: "/api/v1/questionnaires/#{@questionnaire_id}"
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
    @sort_respondents(questionnaire.respondents)
    $.extend(questionnaire,{submissions: submissions, no_respondents: respondents})

    @$details_container.append(HandlebarsTemplates['questionnaire/details'](questionnaire))

  sort_respondents: (respondents) ->
    respondents.sort( (a,b) ->
      if a.respondent.full_name < b.respondent.full_name
        return -1
      else if a.respondent.full_name > b.respondent.full_name
        return 1
      return 0
    )

  init_events: ->
    @tabs_selection()

  tabs_selection: ->
    @$container_el.on('click', (event) ->
      event.preventDefault()
    )

    opts = @$container_el.find('li')
    self = @

    opts.on('click', ->
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
