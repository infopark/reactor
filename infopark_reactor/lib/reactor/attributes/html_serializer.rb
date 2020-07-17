require "reactor/support/link_matcher"

module Reactor
  module Attributes
    class HTMLSerializer
      def initialize(attr, value)
        @attr = attr
        @value = value.to_str
      end

      def serialize
        serialize_html
      end

      private

      def serialize_html
        link_expressions = [/(href|src|usemap)\s*=\s*"([^"]*)"/, /(href|src|usemap)\s*=\s*'([^']*)'/]
        link_expressions.each do |expr|
          @value.gsub!(expr) do |string|
            link = Reactor::Support::LinkMatcher.new(Regexp.last_match(2))
            if link.recognized?
              "#{Regexp.last_match(1)}=\"#{link.rewrite_url}\""
            else
              string
            end
          end
        end
        @value
      end
    end
  end
end
