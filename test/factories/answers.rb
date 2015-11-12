FactoryGirl.define do

  factory :answer, class: Test::Answer do
    user
    question
  end

  factory :answer_part, class: Test::AnswerPart do
    answer
  end

end
