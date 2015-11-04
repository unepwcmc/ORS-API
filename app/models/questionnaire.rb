class Questionnaire < ActiveRecord::Base
  after_initialize :readonly!
  self.table_name = :api_questionnaires_view
  self.primary_key = :id
  include WithLanguage

  has_many :respondents
  has_many :questions

  default_scope {
    includes(:respondents).references(:respondents).
      where(status: ['Active', 'Closed'])
  }
end
