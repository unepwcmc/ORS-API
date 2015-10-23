FactoryGirl.define do

  factory :questionnaire, class: Test::Questionnaire do
    status 2
  end

  factory :questionnaire_field, class: Test::QuestionnaireField do
    language 'en'
    is_default_language true
  end

end
