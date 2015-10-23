require 'roar/decorator'
require 'roar/json'
require 'roar/xml'

class RespondentRepresenter < Roar::Decorator
  include Roar::JSON
  include Roar::XML

  self.representation_wrap = :respondent

  property :id
  property :user_id
  property :full_name
  property :status
end
