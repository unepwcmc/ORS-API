require 'roar/decorator'
require 'roar/json'
require 'roar/xml'

class AnswerRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::XML

  self.representation_wrap = :answer

  property :respondent
  property :user_id
  property :answer_text
end
