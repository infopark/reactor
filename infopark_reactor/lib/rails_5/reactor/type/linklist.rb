require 'reactor/link/temporary_link'
require 'infopark_fiona_connector'
module Reactor
  module Type
    class Linklist < ActiveModel::Type::String

      def type
        :linklist
      end

      def serialize(value)
        linklist = RailsConnector::LinkList.new([])
        enumerate(value).each do |link_data|
          linklist << link_data
        end
        linklist.change!
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
