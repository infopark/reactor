require "reactor/tools/response_handler/xml_attribute"
require "reactor/tools/xpath_extractor"
require "rexml/document"

module Reactor
  module Cm
    class XmlResponse
      attr_reader :xml, :xml_str

      def initialize(xml)
        @xml_str = xml
        @xml = REXML::Document.new(xml)
        @handler = Reactor::ResponseHandler::XmlAttribute.new
        @xpath = Reactor::XPathExtractor.new(@xml)
      end

      def xpath(expr)
        @xpath.match(expr)
      end

      def ok?
        xp = xpath("//cm-code")

        if xp.is_a?(Array)
          codes = xp.map { |result| result.attribute("numeric").value }.uniq

          return codes.size == 1 && codes.first == "200"
        end

        xp.attribute("numeric").value == "200"
      end
    end
  end
end
