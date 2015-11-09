require 'roar/decorator'
require 'roar/json'
require 'roar/xml'

class QuestionRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::XML

  self.representation_wrap = :question

  property :id
  property :section_id
  property :looping_section_id
  property :url, getter: lambda { |*| "/api/v1/questionnaires/#{questionnaire_id}/questions/#{id}" }
  property :title
  property :language
  property :path
  property :answer_type_type, as: :type
  property :is_mandatory
  property :options
  collection :answers, extend: AnswerRepresenter, class: Answer,
    wrap: :answers
  collection :section_looping_contexts, extend: SectionLoopingContextRepresenter,
    class: SectionLoopingContext, wrap: :looping_answers
end
