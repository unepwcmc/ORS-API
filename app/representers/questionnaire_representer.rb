require 'roar/decorator'
require 'roar/json'
require 'roar/xml'

class QuestionnaireRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::XML

  self.representation_wrap = :questionnaire

  property :id
  property :url, getter: lambda { |*| "/api/v1/questionnaires/#{id}" }
  property :title
  property :language
  property :languages
  property :status
  property :created_on
  property :activated_on
  property :questionnaire_date
  collection :respondents, extend: RespondentRepresenter, wrap: :respondents
  property :questions_url, getter: lambda { |*| "/api/v1/questionnaires/#{id}/questions" }
end
