require 'test_helper'

class Api::V1::QuestionnairesControllerTest < ActionController::TestCase
  test "should respond with 401" do
    get :index
    assert_response 401
  end

  test "should respond with success" do
    as_signed_in_api_user do |api_user|
      get :index
      assert_response :success
    end
  end
end
