def create_questionnaire(questionnaire_attrs = {}, field_attrs = {})
  questionnaire_attributes = FactoryGirl.attributes_for(:questionnaire).merge(questionnaire_attrs)
  questionnaire = FactoryGirl.create(:questionnaire, questionnaire_attrs)
  field_attributes = FactoryGirl.attributes_for(:questionnaire_field).merge(field_attrs)
  questionnaire.questionnaire_fields << FactoryGirl.create(
    :questionnaire_field, field_attributes
  )
  questionnaire
end

def create_section(questionnaire, section_attrs = {}, field_attrs = {})
  section_attributes = FactoryGirl.attributes_for(:section).merge(section_attrs)
  section = FactoryGirl.create(:section)
  field_attributes = FactoryGirl.attributes_for(:section_field).merge(field_attrs)
  section.section_fields << FactoryGirl.create(
    :section_field, field_attributes
  )
  FactoryGirl.create(
    :questionnaire_part, part_id: section.id, part_type: 'Section', questionnaire: questionnaire
  )
  section
end

def create_subsection(section, section_attrs = {}, field_attrs = {})
  section_attributes = FactoryGirl.attributes_for(:section).merge(section_attrs)
  subsection = FactoryGirl.create(:section, section_attributes)
  field_attributes = FactoryGirl.attributes_for(:section_field).merge(field_attrs)
  subsection.section_fields << FactoryGirl.create(
    :section_field, field_attributes
  )
  FactoryGirl.create(
    :questionnaire_part, part_id: subsection.id, part_type: 'Section', parent: section.questionnaire_part
  )
  subsection
end

def create_question(section, question_attrs = {}, field_attrs = {})
  question_attributes = FactoryGirl.attributes_for(:question).merge(question_attrs).merge(section: section)
  question = FactoryGirl.create(
    :question, question_attributes
  )
  field_attributes = FactoryGirl.attributes_for(:question_field).merge(field_attrs)
  question.question_fields << FactoryGirl.create(
    :question_field, field_attrs
  )
  FactoryGirl.create(
    :questionnaire_part, part_id: question.id, part_type: 'Question', parent: section.questionnaire_part
  )
  question
end

def create_loop_item(loop_item_type)
  loop_item_name = FactoryGirl.create(:loop_item_name)
  FactoryGirl.create(:loop_item_name_field, loop_item_name: loop_item_name)
  FactoryGirl.create(:loop_item, loop_item_type: loop_item_type, loop_item_name: loop_item_name)
end