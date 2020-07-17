require "reactor/plans/common_attribute_group"

module Reactor
  module Plans
    class DeleteAttributeGroup < CommonAttributeGroup
      def initialize(*args)
        super()
        (obj_class, name), options = separate_arguments(*args)
        @name = name || options[:name]
        @obj_class = obj_class || options[:obj_class]
        @pk = "#{@obj_class}.#{@name}"
      end

      def prepare!
        error("name ist nil") if @name.nil?
        error("obj_class is nil") if @obj_class.nil?
        error("attribute group #{@pk} does not exist") unless Reactor::Cm::AttributeGroup.exists?(@pk)
      end

      def migrate!
        attrib = Reactor::Cm::AttributeGroup.get(@pk)
        attrib.delete!
      end
    end
  end
end
