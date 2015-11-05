class Test::QuestionnairePart < ActiveRecord::Base
  belongs_to :questionnaire
  belongs_to :part, polymorphic: true
  belongs_to :parent, class_name: Test::QuestionnairePart
end
