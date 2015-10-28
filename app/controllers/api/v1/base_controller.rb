class Api::V1::BaseController < ApplicationController
  include Roar::Rails::ControllerAdditions
  respond_to :json, :xml
  before_action :authenticate, except: [:test_exception_notifier]
  before_action :validate_params
  before_action :set_language
  before_action :set_page

  rescue_from StandardError, with: :return_exception_error

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

  def validate_params
    always_permitted = ActionController::Parameters.always_permitted_parameters
    unpermitted_keys = params.keys - permitted_params.map(&:to_s) - always_permitted
    if unpermitted_keys.any?
      return_api_error("Unpermitted parameters (#{unpermitted_keys.join(', ')})", 422)
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

  def return_exception_error(exception)
    if Rails.env.production? || Rails.env.staging?
      ExceptionNotifier.notify_exception(exception,
        env: request.env, data: { message: "Something went wrong" }
      )
    else
      Rails.logger.error exception.message
      Rails.logger.error exception.backtrace.join("\n")
    end
    render json: { message: "We are sorry, but something went wrong while processing your request" }, status: 500
  end

  def return_api_error(message, code)
    render json: { message: message }, status: code
  end

end
