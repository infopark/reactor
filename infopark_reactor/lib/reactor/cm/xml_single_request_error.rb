# -*- encoding : utf-8 -*-
require 'reactor/cm/xml_request_error'

module Reactor
  module Cm
    class XmlSingleRequestError < XmlRequestError
      def initialize(response)
        @response = response
        super(phrase)
      end

      def phrase
        result = @response.xpath('//phrase')
        result = [result] unless result.kind_of?(Array)

        result.map(&:to_s).join("\n")
      end

    end
  end
end
