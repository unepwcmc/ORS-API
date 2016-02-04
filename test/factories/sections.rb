FactoryGirl.define do

  factory :section, class: Test::Section do
    section_type 2 # regular
  end

  factory :section_field, class: Test::SectionField do
    title 'English section title'
    language 'en'
    is_default_language true
    section
  end

end
