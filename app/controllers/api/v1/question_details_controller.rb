class Api::V1::QuestionDetailsController < Api::V1::BaseController
  before_action :load_questionnaire, only: [:show]
  represents :json, Question
  represents :xml, Question
  include QuestionExamples

  api :GET, '/:questionnaire_id/questions/:id', 'Question details'

  description field_description{ field_description_answers }

  example json_example{ json_example_answers }

  example xml_example{ xml_example_answers }

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
