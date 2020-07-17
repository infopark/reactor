module Reactor
  class Engine < Rails::Engine
    rake_tasks do
      load "tasks/cm_migrate.rake"
      load "tasks/cm_seeds.rake"
    end

    initializer "reactor.upgrade" do
      if Gem::Specification.find_all_by_name("infopark_reactor_migrations").any? || Gem::Specification.find_all_by_name("infopark_rails_connector_meta").any?
        raise "Please remove 'infopark_reactor_migrations' and 'infopark_rails_connector_meta' from your Gemfile. They are deprecated and no longer needed."
      end
    end

    initializer "reactor.rsession" do |_app|
      ActionController::Base.include Reactor::SessionHelper::RsessionHelper
      ActionController::Base.__send__(:helper_method, :rsession)

      ActionController::Base.include Reactor::SessionHelper::AuthHelper
      ActionController::Base.include Reactor::SessionHelper::AuthFilter
    end
  end
end
