require 'test_helper'

describe Api::V1::QuestionnairesController do
  describe "#index" do
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