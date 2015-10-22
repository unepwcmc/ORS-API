require 'roar/decorator'
require 'roar/json'
require 'roar/xml'

class QuestionnairesRepresenter < Roar::Decorator
  include Representable::JSON::Collection
  include Representable::XML::Collection

  self.representation_wrap = :questionnaires

  items extend: QuestionnaireRepresenter, class: Questionnaire
end