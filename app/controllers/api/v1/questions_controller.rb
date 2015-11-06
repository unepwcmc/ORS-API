class Api::V1::QuestionsController < Api::V1::BaseController
  before_action :validate_params, only: [:index]
  before_action :load_questionnaire, only: [:index]
  after_action only: [:index] { set_pagination_headers(:questions) }
  represents :json, Question
  represents :xml, Question
  include Pagination

  resource_description do
    formats ['JSON', 'XML']
    api_base_url 'api/v1/questionnaires'
    resource_id 'questions'
    name 'Questions'
  end

  api :GET, '/:questionnaire_id/questions', 'List of questions'

  param :language, String,
    desc: 'Where available display data in language given by ISO code (e.g. "EN"). Defaults to questionnaire\'s default language.'

  def index
    @questions = @questionnaire.questions.with_language(@language).
      paginate(
        page: @page,
        per_page: @per_page).
      order(:lft).
      to_a
    respond_with @questions
  end

  private

  def validate_params
    return unless super()
    [:page, :per_page].each do |param|
      unless send(:"validate_#{param}_format")
        return_api_error("Invalid parameter format: #{param}", 400) and return
      end
    end
  end

  def permitted_params
    [:questionnaire_id, :page, :per_page, :language, :format]
  end

end
