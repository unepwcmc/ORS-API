class Api::V1::BaseController < ApplicationController
  include Roar::Rails::ControllerAdditions
  respond_to :json, :xml
  before_action :authenticate

  # this end-point to be used to test exception notifier
  def test_exception_notifier
    raise 'This is a test. This is only a test.'
  end

  private

  def authenticate
    token = request.headers["X-Authentication-Token"]
    @user = User.find_by_single_access_token(token) if token
    if @user.nil?
      head status: :unauthorized
      return false
    end
  end

end
