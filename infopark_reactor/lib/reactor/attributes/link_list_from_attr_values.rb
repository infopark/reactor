module Reactor
  module Attributes
    class LinkListFromAttrValues
      def initialize(obj, attribute)
        self.obj       = obj
        self.attribute = attribute
      end

      def call
        (self.obj.attr_values[self.attribute.to_s] || []).map do |link_data|
          RailsConnector::Link.new(link_data)
        end
      end

      protected
      attr_accessor :obj, :attribute
    end
  end
end
