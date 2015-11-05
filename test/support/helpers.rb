def create_questionnaire(title='English title', language='EN', is_default_language=true)
  questionnaire = FactoryGirl.create(:questionnaire)
  questionnaire.questionnaire_fields << FactoryGirl.create(
    :questionnaire_field, language: language, title: title, is_default_language: is_default_language
  )
  questionnaire
end

def create_section(title='English section title', language='EN', is_default_language=true)
  section = FactoryGirl.create(:section)
  section.section_fields << FactoryGirl.create(
    :section_field, language: language, title: title, is_default_language: is_default_language
  )
  section
end
