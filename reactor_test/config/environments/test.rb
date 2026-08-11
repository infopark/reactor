require "active_support/core_ext/integer/time"

RailsConnector::Configuration.mode = :editor

ReactorTest::Application.configure do
  if config.respond_to?(:enable_reloading)
    config.enable_reloading = true
  else
    config.cache_classes = false
  end

  # Show full error reports and disable caching
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates
  if Rails::VERSION::MAJOR >= 8 || (Rails::VERSION::MAJOR == 7 && Rails::VERSION::MINOR >= 1)
    config.action_dispatch.show_exceptions = :none
  else
    config.action_dispatch.show_exceptions = false
  end

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection = false

  # Tell Action Mailer not to deliver emails to the real world.
  config.action_mailer.delivery_method = :test

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr

  config.eager_load = false

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []
end
