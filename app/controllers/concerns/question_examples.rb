require 'active_support/concern'

module QuestionExamples
  extend ActiveSupport::Concern

  included do
    resource_description do
      formats ['JSON', 'XML']
      api_base_url 'api/v1/questionnaires'
      resource_id 'questions'
      name 'Question'
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
  The following question fields are returned:

  [id] unique identifier of a question
  [section_id] identifier of section
  [looping_section_id] identifier of closest looping section. When present, question is looping and looping_contexts need to be processed to retrieve answers.
  [url] API URL path of question details
  [title] title of the question (translated where available)
  [language] current language (given as ISO code)
  [path] array of sections in which this question is nested
  [type] one of MultiAnswer, RangeAnswer or NumericAnswer
  [questionnaire_date] date when questionnaire was created
  [is_mandatory] boolean flag denoting whether this question is mandatory to fill in
  [options] array of available options (applicable to MultiAnswer and RangeAnswer)
  #{ yield if block_given? }
      EOS
    end

    def field_description_answers
      <<-EOS
  [answers] array of answer objects when question is not looping
    [respondent] full name of respondent
    [answer_text] answer provided
  [looping_contexts] array of looping context objects when question is looping:
    [looping_identifier] unique identifier of the looping context
    [looping_path] array of loop item names that make up this looping context
    [answers] array of answer objects (like for non-looping sections)
      EOS
    end

    def json_example_answers
      <<-EOS
      "answers":[],
      "looping_contexts":[
        {
          "looping_context":{
            "looping_identifier":"6867S6868S6872",
            "looping_path":[
              "FISHES > CYPRINIFORMES",
              "Cyprinidae",
              "Alburnoides bipunctatus"
            ],
            "answers":[
              {
                "answer":{
                  "respondent":"Kristina Klovaite",
                  "answer_text":"iv.: for research / education / repopulation / reintroduction / necessary breeding"
                }
              }
            ]
          }
        },
        {
          "looping_context":{
            "looping_identifier":"7359S7360S7361",
            "looping_path":[
              "MAMMALS > LAGOMORPHA",
              "Leporidae",
              "Lepus timidus"
            ],
            "answers":[
              {
                "answer":{
                  "respondent":"Tatsiana Trafimovich",
                  "answer_text":"v.: judicious exploitation of certain wild plants in small numbers and under certain conditions"
                }
              }
            ]
          }
        }
      ]
      EOS
    end

    def json_example
      <<-EOS
  {
    "question":{
      "id":384,
      "section_id":244,
      "looping_section_id":242,
      "url":"/api/v1/questionnaires/16/questions/384",
      "title":"Reasons for issuing of licences (art. 9, i. to v.)",
      "language":"EN",
      "path":["EXCEPTIONS CONCERNING PROTECTED FAUNA SPECIES (ART. 7&nbsp;&nbsp;\r\nAPPENDIX III)","Vertebrates","#[Class &gt; Order]","#[Family]","#[Species]","Details"],
      "type":"MultiAnswer",
      "is_mandatory":true,
      "options":[
        "i.: protection of flora /fauna",
        "ii.: prevention of serious damage to crops, livestock, forests, fisheries, water and other forms of property",
        "iii.: in the interests of public health and safety, air safety or other overriding public interests (which?)",
        "iv.: for research / education / repopulation / reintroduction / necessary breeding",
        "v.: judicious exploitation of certain wild plants in small numbers and under certain conditions"
      ]#{ ',' + yield if block_given? }
    }
  }
      EOS
    end

    def xml_example_answers
      <<-EOS
    <answers/>
    <looping_answers>
      <looping_context>
        <looping_identifier>6867S6868S6872</looping_identifier>
        <looping_path>["FISHES &gt; CYPRINIFORMES", "Cyprinidae", "Alburnoides bipunctatus"]</looping_path>
        <answer>
          <respondent>A</respondent>
          <answer_text>iv.: for research / education / repopulation / reintroduction / necessary breeding</answer_text>
        </answer>
      </looping_context>
      <looping_context>
        <looping_identifier>7359S7360S7361</looping_identifier>
        <looping_path>["MAMMALS &gt; LAGOMORPHA", "Leporidae", "Lepus timidus"]</looping_path>
        <answer>
          <respondent>B</respondent>
          <answer_text>v.: judicious exploitation of certain wild plants in small numbers and under certain conditions</answer_text>
        </answer>
      </looping_context>
    </looping_answers>
      EOS
    end

    def xml_example
      <<-EOS
  <question>
    <id>384</id>
    <section_id>244</section_id>
    <looping_section_id>242</looping_section_id>
    <url>/api/v1/questionnaires/16/questions/384</url>
    <title>Reasons for issuing of licences (art. 9, i. to v.)</title>
    <language>EN</language>
    <path>["EXCEPTIONS CONCERNING PROTECTED FAUNA SPECIES (ART. 7&amp;nbsp;&amp;nbsp;\r\nAPPENDIX III)", "Vertebrates", "#[Class &amp;gt; Order]", "#[Family]", "#[Species]", "Details"]</path>
    <type>MultiAnswer</type>
    <is_mandatory>true</is_mandatory>
    <options>["i.: protection of flora /fauna", "ii.: prevention of serious damage to crops, livestock, forests, fisheries, water and other forms of property", "iii.: in the interests of public health and safety, air safety or other overriding public interests (which?)", "iv.: for research / education / repopulation / reintroduction / necessary breeding", "v.: judicious exploitation of certain wild plants in small numbers and under certain conditions"]</options>
    #{ yield if block_given? }
  </question>
      EOS
    end
  end
end
