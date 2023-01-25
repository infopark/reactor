require "reactor/tools/xpath_extractor"
module Reactor
  module ResponseHandler
    class XmlAttribute
      attr_accessor :response, :context

      def get(response, attribute)
        @response = response
        @context = context

        name = attribute.name
        type = attribute.type

        method_name = "extract_#{type}"

        send(method_name, name)
      end

      def multiple(elem, attributes)
        values = {}
        attributes.each do |attribute|
          values[attribute.name] = get(elem, attribute)
        end
        values
      end

      private

      # Extracts a string value with the given +name+ and returns a string.
      def extract_string(name)
        result = xpath(".//#{name}/text()")
        if result.is_a?(Array)
          result.first
        else
          result.to_s
        end
      end

      # Extracts a list value with the given +name+ and returns an array of strings.
      def extract_list(name)
        result = xpath(".//#{name}/listitem/text()")
        result = result.is_a?(Array) ? result : [result]

        result.map(&:to_s)
      end

      # This shit will break with the slightest change of the CM.
      def extract_signaturelist(name)
        signatures = []
        xpath(".//#{name}/").each do |potential_signature|
          next unless potential_signature.name.to_s == "listitem"

          attribute = potential_signature.children.first.text.to_s
          group = potential_signature.children.last.text.to_s
          signatures << { attribute: attribute, group: group }
        end
        signatures
      end

      protected

      def node
        # TODO: clean up this bullshit
        if response.is_a?(Reactor::Cm::XmlResponse)
          response.xml
        else
          response
        end
      end

      def xpath(expr)
        Reactor::XPathExtractor.new(node).match(expr)
      end

      def extract_schedule(name)
        schedule_entries = []
        response.xpath("//#{name}/listitem").each do |potential_schedule|
          entry = {}
          potential_schedule.children.find_all { |c| c.name == "dictitem" }.each do |item|
            key = item.children.find { |c| c.name == "key" }.text
            values_item = item.children.find { |c| c.name == "value" }
            values = values_item.children.find_all { |c| c.name == "listitem" }.map { |i| i.text.to_s }
            entry[key.to_sym] = values
          end
          schedule_entries << entry
        end

        schedule_entries
      end
    end
  end
end
