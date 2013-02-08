# -*- encoding : utf-8 -*-
# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

# require 'vcr'
# require 'database_cleaner'

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  # config.use_transactional_fixtures = true

  # # Add VCR integration
  # config.extend VCR::RSpec::Macros

  # Add my helper methods
  config.include RCSupport

  # # DatabaseCleaner setup
  # config.before(:suite) do
  #   DatabaseCleaner.strategy = :transaction
  # end
  # 
  # config.before(:each) do
  #   DatabaseCleaner.start
  # end
  # 
  # config.after(:each) do
  #   DatabaseCleaner.clean
  # end
end

# VCR.config do |c|
#   c.cassette_library_dir     = 'spec/cassettes'
#   c.stub_with                :webmock
#   # VERY important to match against body !!
#   c.default_cassette_options = { :record => :new_episodes, :match_requests_on => [:method, :uri, :body] }
#   c.allow_http_connections_when_no_cassette = true
# end
