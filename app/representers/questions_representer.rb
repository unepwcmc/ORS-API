require 'roar/decorator'
require 'roar/json'
require 'roar/xml'

class QuestionsRepresenter < Roar::Decorator
  include Representable::JSON::Collection
  include Representable::XML::Collection

  self.representation_wrap = :questions

  items extend: QuestionRepresenter, class: Question
end