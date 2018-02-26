class Answer < ActiveRecord::Base
  after_initialize :readonly!
  self.table_name = :api_answers_view
  self.primary_key = :id

  belongs_to :respondent, class_name: "Respondent", foreign_key: 'user_id'
end
