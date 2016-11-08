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

      def self.included(base)
        base.__send__(:before_filter, :rsession_auth)
      end
    end

    module RsessionHelper
      def rsession
        @__rsession ||= RsessionHelper.from_session(self.session)
      end

      def self.from_session(session)
        Reactor::Session.new(
          # This passes the very powerfull rails session object
          SessionState.new(session)
        )
      end
    end

    class SessionState < Reactor::Session::State
      USER_NAME_KEY  = "rsession$user_name"
      SESSION_ID_KEY = "rsession$session_id"

      def initialize(session)
        self.session = session
        super(session[USER_NAME_KEY], session[SESSION_ID_KEY])
      end

      def user_name=(new_user_name)
        # this is a little bit of magic: it will trigger
        # the the session serialization routine, and will
        # persist the new information after processing the request
        self.session[USER_NAME_KEY] = new_user_name
        new_user_name
      end

      def session_id=(new_session_id)
        # see above
        self.session[SESSION_ID_KEY] = new_session_id
        new_session_id
      end

      protected
      attr_accessor :session
    end
  end
end
