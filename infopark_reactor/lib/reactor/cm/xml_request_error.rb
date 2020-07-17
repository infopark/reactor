module Reactor
  module Cm
    class XmlRequestError < StandardError
      def phrase
        message
      end
    end
  end
end
