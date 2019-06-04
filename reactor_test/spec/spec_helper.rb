# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  config.mock_with :rspec

  config.include RCSupport

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.full_backtrace = true
end
