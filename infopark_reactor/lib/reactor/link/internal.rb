# -*- encoding : utf-8 -*-
module Reactor
  module Link
    class Internal
      attr_accessor :destination_object

      def external? ; false ; end
      def internal? ; true  ; end

      def initialize(anything)
        raise TypeError, "#{self.class.name} is deprecated!"
        self.destination_object = Obj.obj_from_anything(anything)
      end

      def id
        nil
      end
    end
  end
end
