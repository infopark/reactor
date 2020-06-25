# -*- encoding : utf-8 -*-
require 'reactor/attributes/date_serializer'
require 'reactor/attributes/html_serializer'
require 'reactor/attributes/link_list_serializer'

require 'reactor/attributes/link_list_extender'

require 'singleton'

module Reactor
  class AttributeHandlers
    include Singleton

    def initialize
      # t1 = Time.now
      self.generate_attribute_handlers
      # Rails.logger.debug "Reactor::AttributeHandlers: generate_attribute_handlers took #{Time.now - t1}"
    end

    # Use this method to install attributes into class
    def self.install_attributes(klass)
      Reactor::AttributeHandlers.instance.install(klass, obj_class(klass))
    end

    # Use this method if attributes changed and you wish to reinstall them
    def self.reinstall_attributes(klass, obj_class)
      Reactor::AttributeHandlers.instance.tap do |handler|
        handler.regenerate_attribute_handler(obj_class)
        handler.install(klass, obj_class)
      end
    end

    def self.obj_class(klass)
      klass.name.split('::').last
    end

    def install(klass, obj_class)
      if obj_class_known?(obj_class)
        klass.send(:include, handler_module(obj_class))
      end
    end

    def regenerate_attribute_handler(obj_class_name)
      generate_attribute_handler(RailsConnector::Meta::EagerLoader.instance.obj_class(obj_class_name))
    end

    protected

    def handler_module(obj_class)
      Reactor::AttributeHandlers.const_get('Handler__' + obj_class.to_s)
    end

    def obj_class_known?(obj_class)
      Reactor::AttributeHandlers.const_defined?('Handler__' + obj_class.to_s)
    end

    def generate_attribute_handlers
      RailsConnector::Meta::EagerLoader.instance.obj_classes.each do |_, obj_class|
        # Rails.logger.debug "Reactor::AttributeHandlers: preparing obj class #{obj_class.name}"
        generate_attribute_handler(obj_class) if obj_class.try(:name) =~ /^[A-Z]/
      end
    end

    def generate_attribute_handler(obj_class)
      # Rails.logger.debug "Reactor::AttributeHandlers: generating handler for #{obj_class.name}"
      attribute_methods = []
      writers = []

      obj_class.custom_attributes.each do |attribute, attribute_data|
        writers << attribute.to_sym
        writers << attribute.to_s.underscore.to_sym

        # Custom attribute readers: prevent unwanted nils
        case attribute_data.attribute_type.to_sym
        when :html
          attribute_methods << <<-EOC
            def #{attribute}
              self[:#{attribute}] || ''.html_safe
            end
          EOC
        when :date, :enum
          attribute_methods << <<-EOC
            def #{attribute}
              self[:#{attribute}]
            end
          EOC
        when :linklist
          attribute_methods << <<-EOC
            def #{attribute}
              self[:#{attribute}] || RailsConnector::LinkList.new([])
            end
          EOC
        when :multienum
          attribute_methods << <<-EOC
            def #{attribute}
              self[:#{attribute}] || []
            end
          EOC
        else
          attribute_methods << <<-EOC
            def #{attribute}
              self[:#{attribute}] || ''
            end
          EOC
        end

        # active model dirty tracking
        attribute_methods << <<-EOC
        def #{attribute}_changed?(**options)
          attribute_changed?(:#{attribute}, options)
        end
        EOC
      end



      [:contentType].each do |attribute|
        writers << attribute.to_sym
        writers << attribute.to_s.underscore.to_sym
      end

      Reactor::Cm::Obj::OBJ_ATTRS.each do |attribute|
        writers << attribute.to_sym
        writers << attribute.to_s.underscore.to_sym
      end

      writers.uniq!

      writers.each do |attribute|
        attribute_methods << <<-EOC
          def #{attribute}=(value)
            set(:#{attribute},value)
          end
        EOC
      end

      # if a handler for this obj class has been defined previously, purge its methods
      if Reactor::AttributeHandlers.const_defined?("Handler__#{obj_class.name}")
        mod = Reactor::AttributeHandlers.const_get("Handler__#{obj_class.name}")
        mod.instance_methods.each do |method|
          mod.send(:remove_method, method)
        end
      end

      Reactor.class_eval <<-EOC
        class AttributeHandlers
          module Handler__#{obj_class.name}
            def self.included(base)
              # store allowed attributes
              allowed_attrs = %w|#{writers * ' '}|.map(&:to_sym)
              base.send(:instance_variable_set, '@_o_allowed_attrs', allowed_attrs)
            end

            # attribute readers and writers
            #{attribute_methods.join("\n")}

            # parent-setting handling
            def parent=(parent_something)
              set_parent(parent_something)
            end
          end
        end
      EOC

      handler_module(obj_class.name)
      # "Reactor::AttributeHandlers::Handler__#{obj_class.name}"
    end
  end
end
