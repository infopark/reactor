# -*- encoding : utf-8 -*-
module Reactor
  module Plans
    class CommonObjClass
      include Prepared

      ALLOWED_PARAMS = [:completionCheck, :isEnabled, :recordSetCallback, :title,
        :validContentTypes, :workflowModification]

      def initialize
        @take_attrs = []
        @drop_attrs = []
        @mandatory_attrs = []
        @mandatory_drop_attrs = []
        @preset_attrs = {}
        @params = {}
        @params_options = {}
      end

      def set(key, value, options={})
        @params_options[key.to_sym] = options
        @params[key.to_sym] = value
      end

      def take(attr_name, opts={})
        attr_name = attr_name.to_s
        @take_attrs << attr_name
        @drop_attrs.delete(attr_name)
        @mandatory_attrs << attr_name if opts[:mandatory] == true
        @mandatory_drop_attrs << attr_name if opts[:mandatory] == false
        @preset_attrs[attr_name] = opts[:preset] if opts.key? :preset
      end

      def drop(attr_name, opts={})
        attr_name = attr_name.to_s
        @drop_attrs << attr_name
        @take_attrs.delete(attr_name)
        @mandatory_attrs.delete(attr_name)
        @preset_attrs.delete(attr_name)
      end

      def migrate!
        raise "#{self.class.name} did not implement migrate!"
      end

      protected
      def prepare_attrs!(klass=nil)
        @take_attrs.each do |attr|
          error("attribute doesn't exist #{attr}") unless Reactor::Cm::Attribute.exists?(attr)
        end
      end

      def prepare_params!(klass=nil)
        @params.keys.each{|k| error("unknown parameter: #{k}") unless ALLOWED_PARAMS.include? k}
      end

      def migrate_attrs!(klass)
        attrs = (klass.attributes + @take_attrs).uniq - @drop_attrs
        klass.attributes = attrs
        klass.mandatory_attributes = ((klass.mandatory_attributes + @mandatory_attrs).uniq - @drop_attrs - @mandatory_drop_attrs)
      end

      def migrate_params!(klass)
        @params.each{|k,v|klass.set(k,v,@params_options[k])}
        klass.preset_attributes.merge(@preset_attrs).each{|k,v|klass.preset(k,v)}
        klass.save!
      end
    end
  end
end
