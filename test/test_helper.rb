require 'simplecov'
formatters = [SimpleCov::Formatter::HTMLFormatter]
if ENV['CODECLIMATE_REPO_TOKEN']
  require 'codeclimate-test-reporter'
  formatters.push CodeClimate::TestReporter::Formatter
end
SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[*formatters]
SimpleCov.start 'rails'
SimpleCov.command_name 'test'

ENV["RAILS_ENV"] = "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "minitest/rails"
require "support/helpers"

# To add Capybara feature tests add `gem "minitest-rails-capybara"`
# to the test group in the Gemfile and uncomment the following:
# require "minitest/rails/capybara"

# Uncomment for awesome colorful output
require "minitest/pride"

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

require "minitest/mock"
def as_signed_in_api_user
  @api_user = {
    id: 1,
    single_access_token: 'ABC'
  }
  User.stub :find_by_single_access_token, @api_user do
    @request.headers["X-Authentication-Token"] = @api_user[:single_access_token]
    yield(@api_user)
  end
end
