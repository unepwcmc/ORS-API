window.Question = class Question
  constructor: (@$container_el) ->
    @init_events()

  init_events: ->
    @question_selection()

  question_selection: ->
    questions = @$container_el.find('.question-row')
    questions.on('click', =>
      question = @get_question()
      @$container_el.append(HandlebarsTemplates['question/question_modal'](question))
      document.location = '#question_modal'
    )
    @$container_el.on('click', '.close', ->
      $('#question_modal').remove()
    )

  get_question: ->
    data = @question_data().question
    if data.type == "Numeric"
      data
    else
      $.extend(data, {grouped_responses: @group_responses_by_option(data)})

  group_responses_by_option: (data) ->
    options = data.options
    responses = data.responses
    grouped_responses = {}
    for option in options
      grouped_responses[option] = []
      for response in responses
        if option in response.response.answer
          grouped_responses[option].push(response.response.respondent_name)
    grouped_responses


  question_data: ->
    {
      question: {
        "id": 1,
        "url": null,
        "title": "Please confirm the occurrence of the species in the country",
        "path": [
          "3. Species Status",
          "#[Species]"
        ],
        "loop_items": [
          {
            type: "Species",
            names: [
                {
                    id: 1,
                    name: 'Canis lupus',
                    "url": "/api/v1/questionnaires/16/questions/1/1",
                },
                {
                    id: 2,
                    name: 'Panthera leo',
                    "url": "/api/v1/questionnaires/16/questions/1/2",
                }
            ]
          }
        ],
        "type": "MultiAnswer",
        "single": true,
        "is_mandatory": true,
        "options": ["apple", "orange", "banana"],
        "responses": [
          {
            "response": {
              "respondent_name": "Ferdinando"
              "answer": ["apple"]
            }
          },
          {
            "response": {
              "respondent_name": "Andrea"
              "answer": ["orange", "banana"]
            }
          },
          {
            "response": {
              "respondent_name": "Roger"
              "answer": ["banana"]
            }
          }
        ]
      }
    }
