window.QuestionsHelper = class QuestionsHelper
  parse_questions: (questions, @$questions_container) ->
    sections = []
    for question in questions
      root_section = question.path[0]
      if root_section not in sections
        @create_table(question, root_section)
        sections.push root_section
      else
        @add_to_table(question, root_section)

  create_table: (question, root_section) ->
    @$questions_container.append(
      """
        <h3> #{root_section} </h3>
        <table id="#{@format_section_name(root_section)}">
        <thead><tr><th>Title</th><th>Type</th></tr></thead>
        <tbody><tr><td>#{question.title}</td><td>#{question.type}</td></tr></tbody>
        </table><br>
      """
    )

  add_to_table: (question, root_section) ->
    $("##{@format_section_name(root_section)} tbody").append(
      """
      <tr><td>#{question.title}</td><td>#{question.type}</td></tr>
      """
    )

  format_section_name: (section) ->
    section.replace /\s+|\./g, ""
