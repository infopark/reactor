# -*- encoding : utf-8 -*-
module Reactor
  module Plans
    class UpdateObjClass < CommonObjClass
      include Prepared

      def initialize(*args)
        super()
        (name, x), options = separate_arguments(*args)
        @name = name || options[:name]
      end

      def prepare!
        error("objClass #{@name} not found") if Reactor::Cm::ObjClass.exists?(@name)
        @klass = Reactor::Cm::ObjClass.get(@name)
        prepare_attrs!(@klass)
        prepare_params!(@klass)
      end

      def migrate!
        migrate_attrs!(@klass)
        migrate_params!(@klass)
      end

    end
  end
end
