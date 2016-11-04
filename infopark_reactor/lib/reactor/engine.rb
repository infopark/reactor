require 'reactor/session_helper'

# -*- encoding : utf-8 -*-
module Reactor

  class Engine < Rails::Engine
    rake_tasks do
      load "tasks/cm_migrate.rake"
      load "tasks/cm_seeds.rake"
    end

    initializer "reactor.upgrade" do
      if Gem::Specification.find_all_by_name('infopark_reactor_migrations').any? || Gem::Specification.find_all_by_name('infopark_rails_connector_meta').any?
        raise "Please remove 'infopark_reactor_migrations' and 'infopark_rails_connector_meta' from your Gemfile. They are deprecated and no longer needed."
      end
    end

    initializer "reactor.rsession" do |app|
      if app.config.action_dispatch.cookies_serializer && app.config.action_dispatch.cookies_serializer != :marshal
        Rails.logger.debug "Cookie session serializer #{app.config.action_dispatch.cookies_serializer} is experimental, use at your own risk. :marshal recommended instead."
        ActionController::Base.__send__(:include, Reactor::SessionHelper::SimpleSerializer)
      else
        ActionController::Base.__send__(:include, Reactor::SessionHelper::MarshalSerializer)
      end
      ActionController::Base.__send__(:helper_method, :rsession)

      ActionController::Base.__send__(:include, Reactor::SessionHelper::AuthHelper)
    end

  end

end
