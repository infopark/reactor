require "reactor/cm/xml_attribute"
require "reactor/tools/response_handler/xml_attribute"

module Reactor
  module XmlAttributes
    extend ActiveSupport::Concern

    included do
      class_attribute :_attributes
      self._attributes = {}

      class_attribute :response_handler
      self.response_handler = ResponseHandler::XmlAttribute.new
    end

    module ClassMethods
      # This method can act as both getter and setter.
      # I admit, that it is not the best design ever.
      # But it makes a pretty good DSL
      def primary_key(new_value = nil)
        if new_value.nil?
          @primary_key
        else
          @primary_key = new_value.to_s
          @primary_key
        end
      end

      def attribute(name, options = {})
        xml_name = options.delete(:name).presence || name
        type = options.delete(:type).presence

        attribute = Reactor::Cm::XmlAttribute.new(xml_name, type, options)

        _attributes[name.to_sym] = attribute

        attr_accessor name
      end

      def attributes(scopes = [])
        scopes = Array(scopes)
        attributes = _attributes

        if scopes.present?
          attributes.reject { |_, xml_attribute| (xml_attribute.scopes & scopes).blank? }
        else
          attributes
        end
      end

      def xml_attribute(name)
        _attributes[name.to_sym]
      end

      def xml_attribute_names
        _attributes.values.map(&:name)
      end

      def attribute_names
        _attributes.keys
      end
    end
  end
end
