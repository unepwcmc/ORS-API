require 'test_helper'

describe Api::V1::QuestionDetailsController do
  describe "#show" do
    before do
      @questionnaire = create_questionnaire
      @root_section = create_section
      @question = FactoryGirl.create(
        :question, section: @root_section, answer_type_type: 'NumericAnswer'
      )
      @question.question_fields << FactoryGirl.create(
        :question_field, language: 'en', title: 'English question title'
      )
      @question.question_fields << FactoryGirl.create(
        :question_field, language: 'pl', title: 'Polski tytuł pytania', is_default_language: false
      )
      root_section_qp = FactoryGirl.create(
        :questionnaire_part, part_id: @root_section.id, part_type: 'Section', questionnaire: @questionnaire
      )
      FactoryGirl.create(
        :questionnaire_part, part_id: @question.id, part_type: 'Question', parent: root_section_qp
      )
    end

    it "should respond with 401" do
      get :show, questionnaire_id: @questionnaire.id, id: @question.id
      assert_response 401
    end

    it "should respond with success" do
      as_signed_in_api_user do |api_user|
        get :show, questionnaire_id: @questionnaire.id, id: @question.id, format: :json
        assert_response :success
      end
    end

    describe 'language filter' do
      it "should retrieve title in default language" do
        as_signed_in_api_user do |api_user|
          get :show, questionnaire_id: @questionnaire.id, id: @question.id, format: :json
          assert_equal 'English question title', assigns(:question).title
        end
      end

      it "should retrieve title in requested language" do
        as_signed_in_api_user do |api_user|
          get :show, questionnaire_id: @questionnaire.id, id: @question.id, language: 'PL', format: :json
          assert_equal 'Polski tytuł pytania', assigns(:question).title
        end
      end

      it "should retrieve title in default language when requested language unavailable" do
        as_signed_in_api_user do |api_user|
          get :show, questionnaire_id: @questionnaire.id, id: @question.id, language: 'ES', format: :json
          assert_equal 'English question title', assigns(:question).title
        end
      end

      it "should return an unprocessable entity response when unpermitted parameters are specified" do
        as_signed_in_api_user do |api_user|
          get :show, questionnaire_id: @questionnaire.id, id: @question.id, param: 'something'
          assert_response 422
        end
      end
    end

    describe 'JSON' do
      it "should include questionnaire" do
        as_signed_in_api_user do |api_user|
          get :show, questionnaire_id: @questionnaire.id, id: @question.id, format: :json
          json = JSON.parse(response.body)
          assert json.has_key?('question')
        end
      end
    end

    describe 'XML' do
      it "should include questionnaire" do
        as_signed_in_api_user do |api_user|
          get :show, questionnaire_id: @questionnaire.id, id: @question.id, format: :xml
          xml = Nokogiri::XML(response.body)
          assert_not_nil xml.xpath('//question')
        end
      end
    end
  end

end
