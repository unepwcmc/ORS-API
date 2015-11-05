require 'active_support/concern'

module WithLanguage
  extend ActiveSupport::Concern

  included do
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
end