require 'test_helper'

class Api::V1::QuestionnairesControllerTest < ActionController::TestCase
  test "should respond with success" do
    get :index
    assert_response :success
  end
end
