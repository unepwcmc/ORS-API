require 'roar/decorator'
require 'roar/json'
require 'roar/xml'

class LoopingContextRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::XML

  self.representation_wrap = :looping_context

  property :looping_identifier
  property :looping_context, as: :looping_path
  collection :answers, extend: AnswerRepresenter, class: Answer
end