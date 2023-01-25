module Reactor
  module Link
    class External
      attr_accessor :url

      def external?
        true
      end

      def internal?
        false
      end

      def initialize(_url)
        raise TypeError, "#{self.class.name} is deprecated!"
      end

      def id
        nil
      end
    end
  end
end
