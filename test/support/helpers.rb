def create_questionnaire(title='English title', language='EN', is_default_language=true)
  questionnaire = FactoryGirl.create(:questionnaire)
  questionnaire.questionnaire_fields << FactoryGirl.create(
    :questionnaire_field, language: language, title: title, is_default_language: is_default_language
  )
  questionnaire
end

def create_section(questionnaire, title='English section title', language='EN', is_default_language=true)
  section = FactoryGirl.create(:section)
  section.section_fields << FactoryGirl.create(
    :section_field, language: language, title: title, is_default_language: is_default_language
  )
  FactoryGirl.create(
    :questionnaire_part, part_id: section.id, part_type: 'Section', questionnaire: questionnaire
  )
  section
end

def create_subsection(section, title='English subsection title', language='EN', is_default_language=true)
  subsection = FactoryGirl.create(:section)
  subsection.section_fields << FactoryGirl.create(
    :section_field, language: language, title: title, is_default_language: is_default_language
  )
  FactoryGirl.create(
    :questionnaire_part, part_id: subsection.id, part_type: 'Section', parent: section.questionnaire_part
  )
  subsection
end

def create_question(section, type, title='English question title', language='EN', is_default_language=true)
  question = FactoryGirl.create(
    :question, section: section, answer_type_type: type
  )
  question.question_fields << FactoryGirl.create(
    :question_field, language: language, title: title, is_default_language: is_default_language
  )
  FactoryGirl.create(
    :questionnaire_part, part_id: question.id, part_type: 'Question', parent: section.questionnaire_part
  )
  question
end
