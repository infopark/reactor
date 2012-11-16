module Reactor
  module Cm
    class XmlRequestError < StandardError
      def initialize(response)
        @response = response
        @xml = response.xml
        super(phrase)
      end

      def phrase
        @response.xpath('//phrase').to_s
      end

    end
  end
end