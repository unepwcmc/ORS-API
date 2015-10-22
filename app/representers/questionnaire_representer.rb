require 'roar/decorator'
require 'roar/json'
require 'roar/xml'

class QuestionnaireRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::XML

  self.representation_wrap = :questionnaire

  property :id
  property :title
  property :language
  property :languages
  property :status
  property :created_on
  property :activated_on
  property :deadline_on
  collection :respondents, extend: RespondentRepresenter, wrap: :respondents
end