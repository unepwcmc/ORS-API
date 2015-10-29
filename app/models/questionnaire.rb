class Questionnaire < ActiveRecord::Base
  after_initialize :readonly!
  self.table_name = :api_questionnaires_view
  self.primary_key = :id

  has_many :respondents

  default_scope {
    includes(:respondents).references(:respondents).
      where(status: ['Active', 'Closed'])
  }

  scope :with_language, -> (language) {
    if language
      where(
        "languages @> ARRAY[:language] AND language = :language
        OR NOT languages @> ARRAY[:language] AND is_default_language",
        language: language
      )
    else
      where(is_default_language: true)
    end
  }
end
