require 'test_helper'

class Api::V1::QuestionnairesControllerTest < ActionController::TestCase
  test "should respond with 401" do
    get :index
    assert_response 401
  end
end
