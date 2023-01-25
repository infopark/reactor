module Reactor
  module SessionHelper
    module RsessionHelper
      def rsession
        @__rsession ||= RsessionHelper.from_session(session)
      end

      def self.from_session(session)
        Reactor::Session.new(
          # This passes the very powerfull rails session object
          SessionState.new(session)
        )
      end
    end
  end
end
