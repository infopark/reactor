# -*- encoding : utf-8 -*-
module Reactor
  module Cm
    class XmlRequestError < StandardError
      def initialize(response)
        @response = response
        @xml = response.xml
        super(phrase)
      end

      def phrase
        r = @response.xpath('//phrase')
        if !r.kind_of?(Array)
          r = [r]
        end
        msg = r.map(&:to_s).join(" ")
      end

    end
  end
end
