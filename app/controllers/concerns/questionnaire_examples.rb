require 'active_support/concern'

module QuestionnaireExamples
  extend ActiveSupport::Concern

  included do
    resource_description do
      formats ['JSON', 'XML']
      api_base_url 'api/v1/questionnaires'
      resource_id 'questionnaires'
      name 'Questionnaire'
    end

  error code: 400, desc: "Bad Request"
  error code: 401, desc: "Unauthorized"
  error code: 404, desc: "Not Found"
  error code: 422, desc: "Unprocessable Entity"
  error code: 500, desc: "Internal Server Error"
  end

  class_methods do
    def field_description
  <<-EOS
  The following questionnaire fields are returned:

  [id] unique identifier of a questionnaire
  [url] API URL path of questionnaire details
  [title] title of the questionnaire (translated where available)
  [language] current language (given as ISO code)
  [languages] all available languages (given as array of ISO codes)
  [status] one of 'Active', 'Inactive' or 'Closed'
  [activated_on] date when questionnaire was activated
  [questionnaire_date] date set by administrator
  [respondents] array of respondents and the completion status
  EOS
    end

    def json_example
<<-EOS
  {
    "questionnaire":{
      "id":16,
      "url":"/api/v1/questionnaires/16",
      "title":"Biennial Report",
      "language":"EN",
      "languages":["EN"],
      "status":"Active",
      "activated_on":"2015-04-16",
      "questionnaire_date":"2015-01-01",
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
EOS
    end

    def xml_example
<<-EOS
  <questionnaire>
    <id>16</id>
    <url>/api/v1/questionnaires/16</url>
    <title>Biennial Report</title>
    <language>EN</language>
    <languages>["EN"]</languages>
    <status>Active</status>
    <activated_on>2015-04-16</activated_on>
    <questionnaire_date>2015-01-01</questionnaire_date>
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
EOS
    end
  end
end
