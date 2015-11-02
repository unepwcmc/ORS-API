$(document).on 'ready page:load', ->
  new Questionnaires($('.questionnaires-container'), $('.questionnaires'))
  new QuestionnaireDetails($('.questionnaire-info'))
