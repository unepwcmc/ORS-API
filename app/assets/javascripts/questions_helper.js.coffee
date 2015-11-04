window.QuestionsHelper = class QuestionsHelper
  parse_questions: (questions, @$questions_container) ->
    sections = {
      sections: _.groupBy(questions, (q) ->
        q.path[0]
      )
    }
    @$questions_container.append(HandlebarsTemplates['questionnaire/questions'](sections))
