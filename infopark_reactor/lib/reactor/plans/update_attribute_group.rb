require "reactor/plans/common_attribute_group"

module Reactor
  module Plans
    class UpdateAttributeGroup < CommonAttributeGroup
      def initialize(*args)
        super()
        (obj_class, name), options = separate_arguments(*args)
        @name = name || options[:name]
        @obj_class = obj_class || options[:obj_class]
        @pk = "#{@obj_class}.#{@name}"
      end

      def prepapre!
        error("name ist nil") if @name.nil?
        error("obj_class is nil") if @obj_class.nil?
        error("attribute group #{@pk} does not exist") unless Reactor::Cm::AttributeGroup.exists?(ok)
        prepare_params!(nil)
      end

      def migrate!
        attrib = Reactor::Cm::AttributeGroup.get(@pk)
        migrate_params!(attrib)
      end
    end
  end
end
