module Reactor
  module Link
    class Internal
      attr_accessor :destination_object

      def external?
        false
      end

      def internal?
        true
      end

      def initialize(_anything)
        raise TypeError, "#{self.class.name} is deprecated!"
      end

      def id
        nil
      end
    end
  end
end
