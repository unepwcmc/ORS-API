class Api::V1::QuestionnaireDetailsController < Api::V1::BaseController
  represents :json, Questionnaire
  represents :xml, Questionnaire

  resource_description do
    formats ['JSON', 'XML']
    api_base_url 'api/v1/questionnaire_details'
    name 'QuestionnaireDetails'
  end

  api :GET, '/', 'Questionnaire details'

  param :id, String,
    desc: 'Id of the questionnaire',
    required: true 

  def show
    @questionnaire = Questionnaire.
      includes(:respondents).references(:respondents).
      where(status: ['Active', 'Closed']).where(id: params[:id]).first
    respond_with @questionnaire
  end

end
