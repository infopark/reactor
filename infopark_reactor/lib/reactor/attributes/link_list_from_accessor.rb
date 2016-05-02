module Reactor
  module Attributes
    class LinkListFromAccessor
      def initialize(obj, attribute)
        self.obj       = obj
        self.attribute = attribute
      end

      def call
        self.obj[self.attribute.to_sym] || RailsConnector::LinkList.new([])
      end

      protected
      attr_accessor :obj, :attribute
    end
  end
end
