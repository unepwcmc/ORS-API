require 'test_helper'

describe Api::V1::QuestionnairesController do
  describe "#index" do
    before do
      @questionnaire = create_questionnaire
      @questionnaire.questionnaire_fields << FactoryGirl.create(
        :questionnaire_field, language: 'pl', title: 'Polski tytuł', is_default_language: false
      )
    end

    it "should respond with 401" do
      get :index
      assert_response 401
    end

    it "should respond with success" do
      as_signed_in_api_user do |api_user|
        get :index, format: :json
        assert_response :success
      end
    end

    describe 'language filter' do
      it "should retrieve title in default language" do
        as_signed_in_api_user do |api_user|
          get :index, format: :json
          assert_equal 'English title', assigns(:questionnaires).first.title
        end
      end

      it "should retrieve title in requested language" do
        as_signed_in_api_user do |api_user|
          get :index, language: 'PL', format: :json
          assert_equal 'Polski tytuł', assigns(:questionnaires).first.title
        end
      end

      it "should retrieve title in default language when requested language unavailable" do
        as_signed_in_api_user do |api_user|
          get :index, language: 'ES', format: :json
          assert_equal 'English title', assigns(:questionnaires).first.title
        end
      end

      it "should return an unprocessable entity response when unpermitted parameters are specified" do
        as_signed_in_api_user do |api_user|
          get :index, param: 'something'
          assert_response 422
        end
      end

      it "returns a bad request error when incorrect page value" do
        as_signed_in_api_user do |api_user|
          get :index, page: 'something'
          assert_response 400
        end
      end

      it "returns a bad request error when incorrect per_page value" do
        as_signed_in_api_user do |api_user|
          get :index, per_page: 'something'
          assert_response 400
        end
      end
    end

    describe 'JSON' do
      it "should include questionnaires" do
        as_signed_in_api_user do |api_user|
          get :index, format: :json
          json = JSON.parse(response.body)
          assert json.has_key?('questionnaires')
        end
      end
    end

    describe 'XML' do
      it "should include questionnaires" do
        as_signed_in_api_user do |api_user|
          get :index, format: :xml
          xml = Nokogiri::XML(response.body)
          assert_not_nil xml.xpath('//questionnaires')
        end
      end
    end
  end

end
