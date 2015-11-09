class Question < ActiveRecord::Base
  after_initialize :readonly!
  self.table_name = :api_questions_tree_view
  self.primary_key = :id
  include WithLanguage

  belongs_to :section
  has_many :answers
  has_many :section_looping_contexts, -> { includes :looping_answers}, through: :section
end
