module Reactor
  module SessionHelper
    module AuthHelper

      def rsession_auth
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
          if rsession.user?
            Rails.logger.info %|Logged in as "#{rsession.user_name}".|
          end
        else
          rsession.destroy
        end
      end
    end
  end
end
