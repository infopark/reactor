# -*- encoding : utf-8 -*-
require 'reactor/plans/common_attribute'

module Reactor
  module Plans
    class CreateAttribute < CommonAttribute
      def initialize(*args)
        super()
        (name, type), options = separate_arguments(*args)
        @name = name || options[:name]
        @type = type || options[:type]
        # Default values for attributes:
        # isSearchableInCM: false
        # isSearchableInTE: false
        set(:isSearchableInCM, 0)
        set(:isSearchableInTE, 0)
      end

      def prepare!
        error("name ist nil") if @name.nil?
        error("type is nil") if @type.nil?
        # TODO: Type check
        prepare_params!(nil)
      end

      def migrate!
        attrib = Reactor::Cm::Attribute.create(@name, @type)
        migrate_params!(attrib)
      end

    end
  end
end
