class Api::V1::BaseController < ApplicationController
  include Roar::Rails::ControllerAdditions
  respond_to :json, :xml
  before_action :authenticate, except: [:test_exception_notifier]
  before_action :set_language
  before_action :set_page

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

  def set_language
    @language = params[:language].try(:upcase).try(:strip)
  end

  MAX_PER_PAGE = 100
  def set_page
    @page = params[:page]
    @per_page = params[:per_page] && params[:per_page].to_i
    @per_page = MAX_PER_PAGE if @per_page.blank? || @per_page > MAX_PER_PAGE
  end

end
