class Question < ActiveRecord::Base
  after_initialize :readonly!
  self.table_name = :api_questions_tree_view
  self.primary_key = :id
  include WithLanguage

  belongs_to :section
  has_many :answers, -> (object) {
    where(looping_identifier: nil, language: object.language)
  }
  has_many :looping_contexts, -> (object) { where("#{LoopingContext.table_name}.language" => object.language).order(:li_lft) }
end
