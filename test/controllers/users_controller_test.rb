require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "should create user with api role" do
    FactoryGirl.create(:role)
    assert_difference 'User.count' do
      post :create, user: {
        email: 'test@test.com',
        password: 'password',
        password_confirmation: 'password'
      }
    end
    assert_equal 'api', User.last.roles.first.name
  end
end
