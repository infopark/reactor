# -*- encoding : utf-8 -*-
module Reactor
  module Cm
    class XmlRequestError < StandardError
      def phrase
        self.message
      end

    end
  end
end
