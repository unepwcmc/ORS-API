class Test::Section < ActiveRecord::Base
  has_one :questionnaire_part, as: :part
  has_many :section_fields
end
