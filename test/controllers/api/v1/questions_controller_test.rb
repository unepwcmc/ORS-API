require 'test_helper'

describe Api::V1::QuestionsController do
  describe "#index" do
    before(:each) do
      @questionnaire = create_questionnaire
      @root_section = create_section(@questionnaire)
      @question = create_question(@root_section, 'NumericAnswer')
      @question.question_fields << FactoryGirl.create(
        :question_field, language: 'pl', title: 'Polski tytuł pytania', is_default_language: false
      )
    end

    it "should respond with 401" do
      get :index, questionnaire_id: @questionnaire.id
      assert_response 401
    end

    it "should respond with success" do
      as_signed_in_api_user do |api_user|
        get :index, questionnaire_id: @questionnaire.id, format: :json
        assert_response :success
      end
    end

    describe 'language filter' do
      it "should retrieve title in default language" do
        as_signed_in_api_user do |api_user|
          get :index, questionnaire_id: @questionnaire.id, format: :json
          assert_equal 'English question title', assigns(:questions).first.title
        end
      end

      it "should retrieve title in requested language" do
        as_signed_in_api_user do |api_user|
          get :index, questionnaire_id: @questionnaire.id, language: 'PL', format: :json
          assert_equal 'Polski tytuł pytania', assigns(:questions).first.title
        end
      end

      it "should retrieve title in default language when requested language unavailable" do
        as_signed_in_api_user do |api_user|
          get :index, questionnaire_id: @questionnaire.id, language: 'ES', format: :json
          assert_equal 'English question title', assigns(:questions).first.title
        end
      end

      it "should return an unprocessable entity response when unpermitted parameters are specified" do
        as_signed_in_api_user do |api_user|
          get :index, questionnaire_id: @questionnaire.id, param: 'something'
          assert_response 422
        end
      end

      it "returns a bad request error when incorrect page value" do
        as_signed_in_api_user do |api_user|
          get :index, questionnaire_id: @questionnaire.id, page: 'something'
          assert_response 400
        end
      end
    end

    describe 'JSON' do
      it "should include questions" do
        as_signed_in_api_user do |api_user|
          get :index, questionnaire_id: @questionnaire.id, format: :json
          json = JSON.parse(response.body)
          assert json.has_key?('questions')
        end
      end
    end

    describe 'XML' do
      it "should include questions" do
        as_signed_in_api_user do |api_user|
          get :index, questionnaire_id: @questionnaire.id, format: :xml
          xml = Nokogiri::XML(response.body)
          assert_not_nil xml.xpath('//questions')
        end
      end
    end
  end

end
