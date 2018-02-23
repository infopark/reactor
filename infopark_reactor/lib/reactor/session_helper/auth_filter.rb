module Reactor
  module SessionHelper
    module AuthFilter
      def self.included(base)
        base.__send__(:before_filter, :rsession_auth)
      end
    end
  end
end
