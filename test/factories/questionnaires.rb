FactoryGirl.define do

  factory :questionnaire, class: Test::Questionnaire do
    status 2
    user
  end

  factory :questionnaire_field, class: Test::QuestionnaireField do
    title 'English title'
    language 'en'
    is_default_language true
  end

  factory :questionnaire_part, class: Test::QuestionnairePart

end
