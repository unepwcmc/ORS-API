require 'test_helper'

describe UsersController do
  describe :new do
    it "should render new" do
      get :new
      assert_template "new"
    end
  end
  describe :create do
    before { FactoryGirl.create(:role) }
    it "should create user with api role when valid" do
      assert_difference 'User.count' do
        post :create, user: {
          email: 'test@test.com',
          password: 'password',
          password_confirmation: 'password'
        }
      end
      assert_equal 'api', assigns(:user).roles.first.name
    end
    it "should render new when invalid" do
      assert_no_difference 'User.count' do
        post :create, user: {
          email: 'test@test.com',
          password: 'password',
          password_confirmation: 'other_password'
        }
      end
      assert_template "new"
    end
  end
  describe :show do
    it "should redirect if not logged in" do
      @user = FactoryGirl.create(:user)
      get :show, id: @user.id
      assert_redirected_to new_user_session_url
    end
    it "should render show" do
      @user = FactoryGirl.create(:user)
      sign_in @user
      get :show, id: @user.id
      assert_response :success
      assert_template "show"
    end
  end
  describe :generate_token do
    it "should redirect if not logged in" do
      @user = FactoryGirl.create(:user)
      get :show, id: @user.id
      assert_redirected_to new_user_session_url
    end
    it "should redirect to show" do
      @user = FactoryGirl.create(:user)
      sign_in @user
      post :generate_new_token
      assert_redirected_to @user
    end
  end
end
