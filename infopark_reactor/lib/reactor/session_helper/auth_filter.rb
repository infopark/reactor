module Reactor
  module SessionHelper
    module AuthFilter
      def self.included(base)
        base.__send__(:before_action, :rsession_auth)
      end
    end
  end
end
