class Api::V1::QuestionnairesController < Api::V1::BaseController
  after_action only: [:index] { set_pagination_headers(:questionnaires) }
  represents :json, Questionnaire
  represents :xml, Questionnaire

  resource_description do
    formats ['JSON', 'XML']
    api_base_url 'api/v1/questionnaires'
    name 'Questionnaires'
  end

  api :GET, '/', 'Lists questionnaires'

  description <<-EOS
The following questionnaire fields are returned:

[id] unique identifier of a taxon concept
[title] title of the questionnaire (translated where available)
[language] current language (given as ISO code)
[languages] all available languages (given as array of ISO codes)
[status] one of 'Active' or 'Closed'
[created_on] date when questionnaire was created
[activated_on] date when questionnaire was activated
[deadline_on] ???
[respondents] array of respondents and the completion status

Where more than #{MAX_PER_PAGE} taxon concepts are returned, the request is paginated, showing #{MAX_PER_PAGE} objects (or less by passing in an optional 'per_page' parameter) at a time. To fetch the remaining objects, you will need to make a new request and pass the optional ‘page’ parameter as below:

  http://ors-api-host/api/v1/questionnaires?page=2&per_page=25

Information about the remaining pages is provided in the Link header of the API response. For example, making the above request for page two, with a limit of 25 objects per page would return the following in the link header along with a total-count header:

  Link: <http://ors-api-host/api/v1/questionnaires?page=3&per_page=25>; rel="next", <http://ors-api-host/api/v1/questionnaires?page=2570&per_page=25>; rel="last"
  Total-Count: 64230

If there are additional pages, the link header will contain the URL for the next page of results, followed by the URL for the last page of results. The Total-Count header shows the total number of objects returned for this call, regardless of pagination.
  EOS

  param :page, String,
    desc: 'Page number for paginated responses.',
    required: false
  param :per_page, String,
    desc: 'How many objects returned per page for paginated responses (#{MAX_PER_PAGE} by default)',
    required: false
  param :language, String,
    desc: 'Where available display data in language given by ISO code (e.g. "EN"). Defaults to questionnaire\'s default language.'

example <<-EOS
{
  "questionnaires":[
    {
      "questionnaire":{
        "id":16,
        "title":"Biennial Report",
        "language":"EN",
        "languages":["EN"],
        "status":"Active",
        "created_on":"2014-11-11",
        "activated_on":"2015-04-16",
        "deadline_on":"2015-01-01",
        "respondents":[
          {
            "respondent":{
              "id":92,
              "user_id":16,
              "full_name":"Party: AAA",
              "status":"Underway"
            }
          },{
            "respondent":{
              "id":100,
              "user_id":2,
              "full_name":"Party: BBB",
              "status":"Underway"
            }
          }
        ]
      }
    }
  ]
}
EOS

example <<-EOS
<questionnaires>
  <questionnaire>
    <id>16</id>
    <title>Biennial Report</title>
    <language>EN</language>
    <languages>["EN"]</languages>
    <status>Active</status>
    <created_on>2014-11-11</created_on>
    <activated_on>2015-04-16</activated_on>
    <deadline_on>2015-01-01</deadline_on>
    <respondents>
      <respondent>
        <id>92</id>
        <user_id>16</user_id>
        <full_name>Party: AAA</full_name>
        <status>Underway</status>
      </respondent>
      <respondent>
        <id>100</id>
        <user_id>2</user_id>
        <full_name>Party: BBB</full_name>
        <status>Submitted</status>
      </respondent>
    </respondents>
  </questionnaire>
</questionnaires>
EOS

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

end
