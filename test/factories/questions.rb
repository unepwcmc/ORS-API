FactoryGirl.define do

  factory :question, class: Test::Question do
    section
  end

  factory :question_field, class: Test::QuestionField do
    title 'English question title'
    language 'en'
    is_default_language true
    question
  end

end
