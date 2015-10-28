class Api::V1::QuestionnairesController < Api::V1::BaseController
  before_action :validate_params, only: [:index]
  after_action only: [:index] { set_pagination_headers(:questionnaires) }
  represents :json, Questionnaire
  represents :xml, Questionnaire

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
  param :language, String,
    desc: 'Where available display data in language given by ISO code (e.g. "EN"). Defaults to questionnaire\'s default language.'

  def index
    @questionnaires = Questionnaire.
      includes(:respondents).references(:respondents).
      where(status: ['Active', 'Closed'])
    @questionnaires = if @language
      @questionnaires.
      where(
        "languages @> ARRAY[:language] AND language = :language
        OR NOT languages @> ARRAY[:language] AND is_default_language",
        language: @language
      )
    else
      @questionnaires.where(is_default_language: true)
    end.paginate(
      page: @page,
      per_page: @per_page
    ).order(:activated_on).to_a
    respond_with @questionnaires
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

  def validate_page_format
    return true unless params[:page]
    /\A\d+\Z/.match(params[:page])
  end

  def validate_per_page_format
    return true unless params[:per_page]
    /\A\d+\Z/.match(params[:per_page])
  end

  def permitted_params
    [:page, :per_page, :language, :format]
  end
end
