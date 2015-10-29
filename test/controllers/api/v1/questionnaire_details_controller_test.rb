require 'test_helper'

describe Api::V1::QuestionnaireDetailsController do
  describe "#show" do
    before do
      @questionnaire = FactoryGirl.create(:questionnaire)
      @questionnaire.questionnaire_fields << FactoryGirl.create(
        :questionnaire_field, language: 'en', title: 'English title', is_default_language: true
      )
      @questionnaire.questionnaire_fields << FactoryGirl.create(
        :questionnaire_field, language: 'pl', title: 'Polski tytuł'
      )
    end

    it "should respond with 401" do
      get :show, id: @questionnaire.id
      assert_response 401
    end

    it "should respond with success" do
      as_signed_in_api_user do |api_user|
        get :show, id: @questionnaire.id, format: :json
        assert_response :success
      end
    end

    describe 'language filter' do
      it "should retrieve title in default language" do
        as_signed_in_api_user do |api_user|
          get :show, id: @questionnaire.id, format: :json
          assert_equal 'English title', assigns(:questionnaire).title
        end
      end

      it "should retrieve title in requested language" do
        as_signed_in_api_user do |api_user|
          get :show, id: @questionnaire.id, language: 'PL', format: :json
          assert_equal 'Polski tytuł', assigns(:questionnaire).title
        end
      end

      it "should retrieve title in default language when requested language unavailable" do
        as_signed_in_api_user do |api_user|
          get :show, id: @questionnaire.id, language: 'ES', format: :json
          assert_equal 'English title', assigns(:questionnaire).title
        end
      end

      it "should return an unprocessable entity response when unpermitted parameters are specified" do
        as_signed_in_api_user do |api_user|
          get :show, id: @questionnaire.id, param: 'something'
          assert_response 422
        end
      end
    end

    describe 'JSON' do
      it "should include questionnaire" do
        as_signed_in_api_user do |api_user|
          get :show, id: @questionnaire.id, format: :json
          json = JSON.parse(response.body)
          assert json.has_key?('questionnaire')
        end
      end
    end

    describe 'XML' do
      it "should include questionnaire" do
        as_signed_in_api_user do |api_user|
          get :show, id: @questionnaire.id, format: :xml
          xml = Nokogiri::XML(response.body)
          assert_not_nil xml.xpath('//questionnaire')
        end
      end
    end
  end

end
