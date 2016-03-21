class Test::Questionnaire < ActiveRecord::Base
  has_many :questionnaire_fields
  belongs_to :user
end
