source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.4'
# Use postgresql as the database for Active Record
gem 'pg'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON / XML API
gem 'rabl'
# Also add either `oj` or `yajl-ruby` as the JSON parser
gem 'oj'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc
# generate API documentation
gem 'apipie-rails', '=0.3.3' # https://github.com/Apipie/apipie-rails/issues/353

group :staging, :production do
  gem 'dotenv-rails'
  gem 'exception_notification'
  gem 'slack-notifier', '~> 1.0'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'capistrano', '~> 3.4.0'
  gem 'capistrano-multiconfig', require: false
  gem 'capistrano-rails'
  gem 'capistrano-bundler'
  gem 'capistrano-rvm'
  gem 'capistrano-maintenance', '~> 1.0', require: false
  gem 'capistrano-passenger', '~> 0.1.1', require: false

end

group :test do
  gem 'simplecov', require: false
  gem 'codeclimate-test-reporter', require: nil
end
