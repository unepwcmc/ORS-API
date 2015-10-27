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
  param :lng, String,
    desc: 'Where available display data in language given by ISO code (e.g. "EN"). Defaults to questionnaire\'s default language.'

  def show
    @questionnaire = Questionnaire.
      includes(:respondents).references(:respondents).
      where(status: ['Active', 'Closed']).where(id: params[:id])
    @questionnaire = if @language
      @questionnaire.
      where(
        "languages @> ARRAY[:language] AND language = :language
        OR NOT languages @> ARRAY[:language] AND is_default_language",
        language: @language
      )
    else
      @questionnaire.where(is_default_language: true)
    end.first
    respond_with @questionnaire
  end

end
