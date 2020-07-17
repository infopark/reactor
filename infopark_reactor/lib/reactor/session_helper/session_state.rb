module Reactor
  module SessionHelper
    class SessionState < Reactor::Session::State
      USER_NAME_KEY  = "rsession$user_name".freeze
      SESSION_ID_KEY = "rsession$session_id".freeze

      def initialize(session)
        self.session = session
        super(session[USER_NAME_KEY], session[SESSION_ID_KEY])
      end

      def user_name=(new_user_name)
        super
        # this is a little bit of magic: it will trigger
        # the the session serialization routine, and will
        # persist the new information after processing the request
        session[USER_NAME_KEY] = new_user_name
      end

      def session_id=(new_session_id)
        super
        # see above
        session[SESSION_ID_KEY] = new_session_id
      end

      protected

      attr_accessor :session
    end
  end
end
