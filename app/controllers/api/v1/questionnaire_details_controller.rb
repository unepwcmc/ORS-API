class Api::V1::QuestionnaireDetailsController < Api::V1::BaseController
  before_action :load_questionnaire, only: [:show]
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
    respond_with @questionnaire
  end

  private

  def permitted_params
    [:id, :language, :format]
  end

end
