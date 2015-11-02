FactoryGirl.define do

  factory :question, class: Test::Question do

  end

  factory :question_field, class: Test::QuestionField do
    language 'en'
    is_default_language true
  end

end