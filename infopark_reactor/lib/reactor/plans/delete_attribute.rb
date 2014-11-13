# -*- encoding : utf-8 -*-
module Reactor
  module Plans
    class DeleteAttribute < CommonAttribute
      def initialize(*args)
        super()
        (name, x), options = separate_arguments(*args)
        @name = name || options[:name]
      end

      def prepare!
        error("name is nil") if @name.nil?
        error("attribute #{@name} does not exist") if not Reactor::Cm::Attribute.exists?(@name)
        # TODO: check used..
      end

      def migrate!
        attrib = Reactor::Cm::Attribute.get(@name)
        attrib.delete!
      end

    end
  end
end
