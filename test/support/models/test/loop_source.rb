class Test::LoopSource < ActiveRecord::Base
  has_one :loop_item_type
  has_many :sections
  belongs_to :questionnaire
  has_many :loop_item_names
end
