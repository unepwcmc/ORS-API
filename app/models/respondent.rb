class Respondent < ActiveRecord::Base
  after_initialize :readonly!
  self.table_name = :api_respondents_view
  self.primary_key = :id
end
