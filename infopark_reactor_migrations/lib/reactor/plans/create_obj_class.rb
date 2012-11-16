require 'reactor/plans/common_obj_class'

module Reactor
  module Plans
    class CreateObjClass < CommonObjClass
      def initialize(*args)
        super()
        (name, type), options = separate_arguments(*args)
        @name = name || options[:name]
        @type = type || options[:objType] || options[:type]
      end

      def prepare!
        error("name is nil") if @name.nil?
        error("type is nil") if @type.nil?
        error("objClass #{@name} already exists") if Reactor::Cm::ObjClass.exists?(@name)
        prepare_attrs!(nil)
        prepare_params!(nil)
      end

      def migrate!
        klass = Reactor::Cm::ObjClass.create(@name, @type)
        migrate_attrs!(klass)
        migrate_params!(klass)
      end
    end
  end
end