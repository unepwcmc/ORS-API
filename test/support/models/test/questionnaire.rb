#require Rails.root + 'test/support/models/test/questionnaire_field.rb'
class Test::Questionnaire < ActiveRecord::Base
  has_many :questionnaire_fields
end
