# -*- encoding : utf-8 -*-
require 'reactor/tools/response_handler/base'

module Reactor

  module ResponseHandler
    
    class XmlAttribute < Base
      
      def get(response, attribute)
        super(response, attribute)

        name = attribute.name
        type = attribute.type

        method_name = "extract_#{type}"

        self.send(method_name, name)
      end

      private

      # Extracts a string value with the given +name+ and returns a string.
      def extract_string(name)
        self.response.xpath("//#{name}/text()").to_s
      end

      # Extracts a list value with the given +name+ and returns an array of strings.
      def extract_list(name)
        result = self.response.xpath("//#{name}/listitem/text()")
        result = result.kind_of?(Array) ? result : [result]

        result.map(&:to_s)
      end

      # This shit will break with the slightest change of the CM.
      def extract_signaturelist(name)
        signatures = []
        self.response.xpath("//#{name}/").each do |potential_signature|
          if (potential_signature.name.to_s == "listitem")
            attribute = potential_signature.children.first.text.to_s
            group = potential_signature.children.last.text.to_s
            signatures << {:attribute => attribute, :group => group}
          end
        end
        signatures
      end

      def extract_schedule(name)
        schedule_entries = []
        self.response.xpath("//#{name}/listitem").each do |potential_schedule|
          entry = {}
          potential_schedule.children.find_all {|c| c.name == "dictitem" }.each do |item|
            key = item.children.find {|c| c.name == "key" }.text
            values_item = item.children.find {|c| c.name == "value" }
            values = values_item.children.find_all { |c| c.name == "listitem" }.map {|i| i.text.to_s }
            entry[key.to_sym] = values
          end
          schedule_entries << entry
        end

        schedule_entries
      end

    end
    
  end

end
