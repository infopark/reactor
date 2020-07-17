require "reactor/link/temporary_link"
require "infopark_fiona_connector"

module Reactor
  module Attributes
    class LinkListSerializer
      def initialize(attr, value)
        @attr = attr
        @value = value
      end

      def serialize
        linklist = RailsConnector::LinkList.new([])
        enumerate(@value).each do |link_data|
          linklist << link_data
        end
        linklist.change!
        linklist
      end

      private

      def enumerate(value)
        return [] if value.nil? || value.blank?
        return [value] unless value.is_a?(Array)

        value
      end
    end
  end
end
