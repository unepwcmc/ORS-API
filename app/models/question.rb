class Question < ActiveRecord::Base
  after_initialize :readonly!
  self.table_name = :api_questions_tree_view
  self.primary_key = :id
  include WithLanguage

  belongs_to :section
  has_many :answers, -> { where(looping_identifier: nil) }
  has_many :looping_contexts
end
