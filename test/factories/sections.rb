FactoryGirl.define do

  factory :section, class: Test::Section do

  end

  factory :section_field, class: Test::SectionField do
    language 'en'
    is_default_language true
  end

end