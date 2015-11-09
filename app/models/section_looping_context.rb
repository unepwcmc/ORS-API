class SectionLoopingContext < ActiveRecord::Base
  after_initialize :readonly!
  self.table_name = :api_sections_looping_contexts_view
  self.primary_key = :id

  has_many :looping_answers, class_name: 'Answer',
    foreign_key: :looping_identifier, primary_key: :looping_identifier

end
