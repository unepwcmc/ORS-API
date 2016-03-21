class Test::LoopItemType < ActiveRecord::Base
  belongs_to :loop_source
  has_many :loop_items
  has_many :loop_item_names
  has_many :loop_item_name_fields, :through => :loop_item_names
  has_many :sections
end
