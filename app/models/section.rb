class Section < ActiveRecord::Base
  after_initialize :readonly!
  self.table_name = :api_sections_tree_view
  self.primary_key = :id
end