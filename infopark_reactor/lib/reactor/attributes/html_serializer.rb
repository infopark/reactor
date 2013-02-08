# -*- encoding : utf-8 -*-
require 'reactor/support/link_matcher'

module Reactor
  module Attributes
    class HTMLSerializer
      def initialize(attr, value)
        @attr, @value = attr, value.to_str
      end

      def serialize
        serialize_html
      end

      private
      def serialize_html
        link_expressions = [/(href|src)\s*=\s*"([^"]*)"/, /(href|src)\s*=\s*'([^']*)'/]
        link_expressions.each do |expr|
          @value.gsub!(expr) do |string|
            link = Reactor::Support::LinkMatcher.new($2)
            if link.recognized?
              "#{$1}=\"#{link.rewrite_url}\""
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
