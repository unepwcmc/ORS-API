class Api::V1::QuestionDetailsController < Api::V1::BaseController
  before_action :load_questionnaire, only: [:show]
  represents :json, Question
  represents :xml, Question

  resource_description do
    formats ['JSON', 'XML']
    api_base_url 'api/v1/questionnaires'
    resource_id 'questions'
    name 'Questions'
  end

  api :GET, '/:questionnaire_id/questions/:id', 'Question details'

  param :id, String,
    desc: 'Id of the question',
    required: true
  param :language, String,
    desc: 'Where available display data in language given by ISO code (e.g. "EN"). Defaults to questionnaire\'s default language.'

  def show
    @question = @questionnaire.questions.where(id: params[:id]).with_language(@language).first
    respond_with @question
  end

  private

  def permitted_params
    [:questionnaire_id, :id, :language, :format]
  end

end
