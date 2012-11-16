module Reactor
  module Link
    class External
      attr_accessor :url

      def external? ; true  ; end
      def internal? ; false ; end

      def initialize(url)
        raise TypeError, "#{self.class.name} is deprecated!"
        self.url = url
      end

      def id
        nil
      end
    end
  end
end