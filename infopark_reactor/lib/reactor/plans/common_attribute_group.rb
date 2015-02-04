# -*- encoding : utf-8 -*-
module Reactor
  module Plans
    class CommonAttributeGroup
      include Prepared

      ALLOWED_PARAMS = [:title, :index]

      def initialize
        @params = {}
      end

      def set(key,value)
        @params[key.to_sym] = value
      end

      def add_attributes(attributes)
        @add_attributes = attributes
      end

      def remove_attributes(attributes)
        @remove_attributes = attributes
      end

      def migrate!
        raise "#{self.class.name} did not implement migrate!"
      end

      protected
      def prepare_params!(attribute=nil)
        @params.keys.each{|k| error("unknown parameter: #{k}") unless ALLOWED_PARAMS.include? k}
      end

      def migrate_params!(attribute)
        attribute.add_attributes(@add_attributes) if @add_attributes
        attribute.remove_attributes(@remove_attributes) if @remove_attributes
        @params.each{|k,v|attribute.set(k,v)}
        attribute.save!
      end
    end
  end
end
