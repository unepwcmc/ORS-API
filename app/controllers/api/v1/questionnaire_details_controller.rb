class Api::V1::QuestionnaireDetailsController < Api::V1::BaseController
  represents :json, Questionnaire
  represents :xml, Questionnaire
  include QuestionnaireExamples

  api :GET, '/:id', 'Questionnaire details'

  description field_description

  param :id, String,
    desc: 'Id of the questionnaire',
    required: true
  param :language, String,
    desc: 'Where available display data in language given by ISO code (e.g. "EN"). Defaults to questionnaire\'s default language.'

  example json_example

  example xml_example

  def show
    @questionnaire = Questionnaire.where(id: params[:id]).with_language(@language).first
    respond_with @questionnaire
  end

  private

  def permitted_params
    [:questionnaire_id, :id, :language, :format]
  end

end
