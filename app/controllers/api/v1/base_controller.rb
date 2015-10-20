class Api::V1::BaseController < ApplicationController
  before_action :authenticate

  # this end-point to be used to test exception notifier
  def test_exception_notifier
    raise 'This is a test. This is only a test.'
  end

  private

  def authenticate
    token = params[:api_key]
    @user = User.where(single_access_token: token).first if token
    if @user.nil?
      head status: :unauthorized
      return false
    end
  end

end
