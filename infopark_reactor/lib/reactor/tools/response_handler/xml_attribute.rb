# -*- encoding : utf-8 -*-
require 'reactor/tools/xpath_extractor'
module Reactor

  module ResponseHandler
    
    class XmlAttribute
      attr_accessor :response
      attr_accessor :context
      
      def get(response, attribute)
        @response = response
        @context = context

        name = attribute.name
        type = attribute.type

        method_name = "extract_#{type}"

        self.send(method_name, name)
      end

      def multiple(elem, attributes)
        values = {}
        attributes.each do |attribute|
          values[attribute.name] = self.get(elem, attribute)
        end
        values
      end

      private

      # Extracts a string value with the given +name+ and returns a string.
      def extract_string(name)
        result = self.xpath(".//#{name}/text()")
        if result.kind_of?(Array)
          return result.first
        else
          return result.to_s
        end
      end

      # Extracts a list value with the given +name+ and returns an array of strings.
      def extract_list(name)
        result = self.xpath(".//#{name}/listitem/text()")
        result = result.kind_of?(Array) ? result : [result]

        result.map(&:to_s)
      end

      # This shit will break with the slightest change of the CM.
      def extract_signaturelist(name)
        signatures = []
        self.xpath(".//#{name}/").each do |potential_signature|
          if (potential_signature.name.to_s == "listitem")
            attribute = potential_signature.children.first.text.to_s
            group = potential_signature.children.last.text.to_s
            signatures << {:attribute => attribute, :group => group}
          end
        end
        signatures
      end

      protected
      def node
        # TODO: clean up this bullshit
        if self.response.kind_of?(Reactor::Cm::XmlResponse)
          self.response.xml
        else
          self.response
        end
      end

      def xpath(expr)
        Reactor::XPathExtractor.new(self.node).match(expr)
      end

    end
    
  end

end
