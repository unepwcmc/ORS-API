class Test::LoopItem < ActiveRecord::Base
  belongs_to :loop_item_type
  belongs_to :loop_item_name
end
