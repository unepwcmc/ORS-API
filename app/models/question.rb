class Question < ActiveRecord::Base
  after_initialize :readonly!
  self.table_name = :api_questions_tree_view
  self.primary_key = :id

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
