FactoryGirl.define do

  factory :user do
    first_name Faker::Name.first_name
    last_name Faker::Name.last_name
    language "en"
    sequence(:email) {|n| n.to_s + Faker::Internet.email }
    password Faker::Internet.password
    password_confirmation { password }
  end

end
