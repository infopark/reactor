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
        Rails.logger.info "Cookie session serializer #{app.config.action_dispatch.cookies_serializer} unsupported. Enforcing :marshal instead."
        app.config.action_dispatch.cookies_serializer = :marshal
      end

      # FIXME: extract !
      AbstractController::Base.__send__(:define_method, :rsession) do
        self.session[:rsession] ||= Reactor::Session.instance
      end
      ActionController::Base.__send__(:helper_method, :rsession)

      ActionController::Base.__send__(:define_method, :rsession_auth) do
        if RailsConnector::Configuration.mode == :editor && (jsessionid = cookies['JSESSIONID']).present?
          # Why the gsub? It's a dirty hack! Reason: JSESSIONIDs are unescaped
          # when read through Rails and hence all + are converted into spaces.
          # CM Kernel though stores escaped IDs.
          # From the possible generated characters only the + seems to be
          # problematic.
          # CGI.escape would be the solution, but it's deprecated
          # URI.escape does too much
          jsessionid.gsub!(' ','+')

          Rails.logger.info "Trying to log in at #{Reactor::Configuration.xml_access[:host]}:#{Reactor::Configuration.xml_access[:port]} with JSESSIONID=#{jsessionid}."
          rsession.login(jsessionid)
          Rails.logger.info %|Logged in as "#{rsession.user_name}".| if rsession.user?
        else
          rsession.destroy
        end
      end
      ActionController::Base.__send__(:before_filter, :rsession_auth)
    end

  end

end
