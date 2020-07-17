module Reactor
  module Plans
    class DeleteObjClass < CommonObjClass
      include Prepared

      def initialize(*args)
        super()
        (name, x), options = separate_arguments(*args)
        @name = name || options[:name]
      end

      def prepare!
        error("objClass #{@name} not found") unless Reactor::Cm::ObjClass.exists?(@name)
      end

      def migrate!
        klass = Reactor::Cm::ObjClass.get(@name)
        klass.delete!
      end
    end
  end
end
