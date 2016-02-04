class Test::Answer < ActiveRecord::Base
  belongs_to :user
  belongs_to :question
  belongs_to :questionnaire
end
