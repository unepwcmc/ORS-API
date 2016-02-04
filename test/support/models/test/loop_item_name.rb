class Test::LoopItemName < ActiveRecord::Base
  belongs_to :loop_source
  belongs_to :loop_item_type
  has_many :loop_items
  has_many :loop_item_name_fields
end
