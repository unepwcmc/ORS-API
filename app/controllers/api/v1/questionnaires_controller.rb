class Api::V1::QuestionnairesController < Api::V1::BaseController
  before_action :validate_params, only: [:index]
  after_action only: [:index] { set_pagination_headers(:questionnaires) }
  represents :json, Questionnaire
  represents :xml, Questionnaire
  include QuestionnaireExamples
  include Pagination

  api :GET, '/', 'List of questionnaires'

  description <<-EOS
#{field_description}

Where more than #{MAX_PER_PAGE} questionnaires are returned, the request is paginated, showing #{MAX_PER_PAGE} objects (or less by passing in an optional 'per_page' parameter) at a time. To fetch the remaining objects, you will need to make a new request and pass the optional ‘page’ parameter as below:

  http://ors-api-host/api/v1/questionnaires?page=2&per_page=25

Information about the remaining pages is provided in the Link header of the API response. For example, making the above request for page two, with a limit of 25 objects per page would return the following in the link header along with a total-count header:

  Link: <http://ors-api-host/api/v1/questionnaires?page=3&per_page=25>; rel="next", <http://ors-api-host/api/v1/questionnaires?page=2570&per_page=25>; rel="last"
  Total-Count: 64230

If there are additional pages, the link header will contain the URL for the next page of results, followed by the URL for the last page of results. The Total-Count header shows the total number of objects returned for this call, regardless of pagination.
  EOS

  param :language, String,
    desc: 'Where available display data in language given by ISO code (e.g. "EN"). Defaults to questionnaire\'s default language.'

example <<-EOS
{
  "questionnaires":[
  #{json_example}
  ]
}
EOS

example <<-EOS
<questionnaires>
#{xml_example}
</questionnaires>
EOS

  def index
    @questionnaires = Questionnaire.with_language(@language).
      paginate(
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

  def permitted_params
    [:page, :per_page, :language, :format]
  end
end
