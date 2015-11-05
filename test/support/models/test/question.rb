class Test::Question < ActiveRecord::Base
  belongs_to :section
  has_one :questionnaire_part, as: :part
  has_many :question_fields
end
