FactoryGirl.define do

  factory :loop_item_type, class: Test::LoopItemType do
    name Faker::Lorem.word
    loop_source
  end

  factory :loop_item_name, class: Test::LoopItemName do
    loop_item_type
    loop_source
  end

  factory :loop_item_name_field, class: Test::LoopItemNameField do
    item_name 'English item name'
    language 'en'
    is_default_language true
  end

  factory :loop_item, class: Test::LoopItem do
    loop_item_name
    loop_item_type
  end

end
