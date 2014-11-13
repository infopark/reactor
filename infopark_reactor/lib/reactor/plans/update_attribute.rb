# -*- encoding : utf-8 -*-
module Reactor
  module Plans
    class UpdateAttribute < CommonAttribute
      def initialize(*args)
        super()
        (name, x), options = separate_arguments(*args)
        @name = name || options[:name]
      end

      def prepapre!
        error("name is nil") if @name.nil?
        error("attribute #{@name} not found") if not Reactor::Cm::Attribute.exists?(@name)
        prepare_params!(nil)
      end

      def migrate!
        attrib = Reactor::Cm::Attribute.get(@name)
        migrate_params!(attrib)
      end

    end
  end
end
