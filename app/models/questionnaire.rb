class Questionnaire < ActiveRecord::Base
  after_initialize :readonly!
  self.table_name = :api_questionnaires_view
  self.primary_key = :id

  has_many :respondents

end



