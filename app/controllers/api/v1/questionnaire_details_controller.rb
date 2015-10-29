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
  param :language, String,
    desc: 'Where available display data in language given by ISO code (e.g. "EN"). Defaults to questionnaire\'s default language.'

  def show
    @questionnaire = Questionnaire.where(id: params[:id]).with_language(@language).first
    respond_with @questionnaire
  end

  private

  def permitted_params
    [:id, :language, :format]
  end

end
