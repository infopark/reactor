# -*- encoding : utf-8 -*-
require 'reactor/link/temporary_link'
require 'infopark_rails_connector'

module Reactor
  module Attributes
    class LinkListSerializer
      def initialize(attr, value)
        @attr, @value = attr, value
      end

      def serialize
        linklist = RailsConnector::LinkList.new([])
        enumerate(@value).each do |link_data|
          linklist << link_data
        end
        linklist
      end

      private
      def enumerate(value)
        return [] if value.nil? || value.blank?
        return [value] unless value.kind_of?(Array)
        return value
      end
    end
  end
end
