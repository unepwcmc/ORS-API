class Test::Section < ActiveRecord::Base
  has_one :questionnaire_part, as: :part
  has_many :section_fields
  belongs_to :loop_item_type
end
