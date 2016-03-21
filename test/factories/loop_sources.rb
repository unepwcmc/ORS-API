FactoryGirl.define do

  factory :loop_source, class: Test::LoopSource do
    name Faker::Lorem.word
    questionnaire
  end

end
