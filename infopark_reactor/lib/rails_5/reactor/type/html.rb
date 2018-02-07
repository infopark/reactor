require 'reactor/support/link_matcher'
module Reactor
  module Type
    class Html < ActiveModel::Type::String
      
      def type
        :html
      end

      def serialize(value)
        if value.blank?
          ''.html_safe
        else
          link_expressions = [/(href|src|usemap)\s*=\s*"([^"]*)"/, /(href|src|usemap)\s*=\s*'([^']*)'/]
          link_expressions.each do |expr|
            value.gsub!(expr) do |string|
              link = Reactor::Support::LinkMatcher.new($2)
              if link.recognized?
                "#{$1}=\"#{link.rewrite_url}\""
              else
                string
              end
            end
          end
          value
        end
      end
    end
  end
end
