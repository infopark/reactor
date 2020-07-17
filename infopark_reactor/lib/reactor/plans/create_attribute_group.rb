require "reactor/plans/common_attribute_group"

module Reactor
  module Plans
    class CreateAttributeGroup < CommonAttributeGroup
      def initialize(*args)
        super()
        (obj_class, name, index), options = separate_arguments(*args)
        @name = name || options[:name]
        @obj_class = obj_class || options[:obj_class]
        @index = index || options[:index]
      end

      def prepare!
        error("name ist nil") if @name.nil?
        error("obj_class is nil") if @obj_class.nil?
        prepare_params!(nil)
      end

      def migrate!
        attrib = Reactor::Cm::AttributeGroup.create(@obj_class, @name, @index)
        migrate_params!(attrib)
      end
    end
  end
end
