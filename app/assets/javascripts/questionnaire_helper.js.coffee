class @QuestionnaireHelper
  submission_percentage: (questionnaire) ->
    respondents = questionnaire.respondents
    no_of_respondents = respondents.length
    no_of_submissions = 0
    for respondent in respondents
      no_of_submissions = no_of_submissions + 1 if respondent.respondent.status == 'Submitted'
    [no_of_respondents, no_of_submissions]
