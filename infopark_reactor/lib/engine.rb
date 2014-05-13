# -*- encoding : utf-8 -*-
module Reactor

  class Engine < Rails::Engine

    initializer "reactor.rsession" do
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
            
        elsif (session_var = Reactor::Configuration.xml_access[:trusted_session_var]).present? && session[session_var].present?
          Rails.logger.info "** Using trusted session var \"#{session_var}\": #{session[session_var]}"
          rsession.login_with_session_var(session[session_var], session[:session_id])
          Rails.logger.info %|Logged in as "#{rsession.user_name}".| if rsession.user?
        else
          rsession.destroy
        end
      end
      ActionController::Base.__send__(:before_filter, :rsession_auth)
    end

  end

end
