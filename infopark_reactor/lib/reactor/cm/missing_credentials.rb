module Reactor
  module Cm
    class MissingCredentials < StandardError
      def initialize
        super("CM access credentials are missing. Check your configuration or supplied credentials.")
      end
    end
  end
end
