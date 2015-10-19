class Api::V1::QuestionnairesController < Api::V1::BaseController

  resource_description do
    formats ['JSON', 'XML']
    api_base_url 'api/v1/questionnaires'
    name 'Questionnaires'
  end

  api :GET, '/', 'Lists questionnaires'

  param :page, String,
    desc: 'Page number for paginated responses.',
    required: false
  param :per_page, String,
    desc: 'How many objects returned per page for paginated responses (50 by default)',
    required: false

  def index
    @questionnaires = []
  end

end
