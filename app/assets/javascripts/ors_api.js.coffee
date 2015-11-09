$(document).on 'ready page:load', ->
  new Questionnaires($('.questionnaires-container'), $('.questionnaires'))

  if $('.questionnaire-info').length > 0
    new QuestionnaireDetails($('.questionnaire-info'),
      $('.questionnaire-tab-container'), $('.questionnaire-details'), $('.questions'))
