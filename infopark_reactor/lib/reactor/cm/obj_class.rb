require "reactor/cm/xml_request"
require "reactor/cm/xml_response"
require "reactor/cm/xml_request_error"

module Reactor
  module Cm
    class ObjClass
      def self.exists?(name)
        klass = ObjClass.new
        begin
          klass.send(:get, name).ok?
        rescue StandardError
          false
        end
      end

      def self.create(name, type)
        klass = ObjClass.new
        klass.send(:create, name, type)
        klass
      end

      def self.get(name)
        klass = ObjClass.new
        klass.send(:get, name)
        klass
      end

      def self.rename(current_name, new_name)
        request = XmlRequest.prepare do |xml|
          xml.tag!("objClass-where") do
            xml.tag!("name", current_name)
          end
          xml.tag!("objClass-set") do
            xml.tag!("name", new_name)
          end
        end
        request.execute!
      end

      def set(key, value, options = {})
        @params_options[key.to_sym] = (!options.nil? && !options.empty? && options) || {}
        @params[key.to_sym] = value
      end

      def preset(key, value)
        @preset[key] = value
      end

      def preset_attributes
        request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, "name", @name)
          xml.get_key_tag!(base_name, "presetAttributes")
        end
        response = request.execute!
        result = response.xpath("//dictitem")
        result = [result] unless result.is_a?(Array)
        result.map do |dictitem|
          key = dictitem.children.detect { |c| c.name == "key" }.text
          raw_value = dictitem.children.detect { |c| c.name == "value" }
          value = if raw_value.children.detect { |c| c.is_a?(::REXML::Text) }
                    raw_value.text
                  else
                    raw_value.children.map { |c| c.text }
                  end
          { key => value }
        end.inject({}, &:merge)
      end

      def save!
        request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, "name", @name)
          xml.set_tag!(base_name) do
            @params.each do |key, value|
              if @params_options[key][:cdata]
                xml.tag!(key.to_s) do
                  xml.cdata!(value)
                end
              else
                xml.value_tag!(key.to_s, value)
              end
            end
            unless @preset.empty?
              preset_attributes.merge(@preset)
              xml.tag!("presetAttributes") do
                @preset.each do |key, value|
                  xml.tag!("dictitem") do
                    xml.tag!("key") do
                      xml.text!(key.to_s)
                    end
                    xml.tag!("value") do
                      if value.is_a?(Array)
                        value.each do |item|
                          xml.tag!("listitem") do
                            xml.text!(item.to_s)
                          end
                        end
                      else
                        xml.text!(value.to_s)
                      end
                    end
                  end
                end
              end
            end
          end
        end
        request.execute!
      end

      def has_attribute?(attr_name)
        attributes.include? attr_name
      end

      def attributes
        __attributes_get("attributes")
      end

      def attributes=(attr_arr)
        __attributes_set("attributes", attr_arr)
      end

      def mandatory_attributes
        __attributes_get("mandatoryAttributes")
      end

      def mandatory_attributes=(attr_arr)
        __attributes_set("mandatoryAttributes", attr_arr)
      end

      def delete!
        request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, "name", @name)
          xml.tag!("#{base_name}-delete")
        end
        request.execute!
      end

      protected

      def base_name
        "objClass"
      end

      def initialize(name = nil)
        @name = name
        @params = {}
        @params_options = {}
        @preset = {}
      end

      def get(name)
        request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, "name", name)
          xml.get_key_tag!(base_name, "name")
        end
        response = request.execute!
        @name = name
        response
      end

      def create(name, type)
        request = XmlRequest.prepare do |xml|
          xml.create_tag!(base_name) do |xml|
            xml.tag!("name") do
              xml.text!(name)
            end
            xml.tag!("objType") do
              xml.text!(type)
            end
          end
        end
        response = request.execute!
        @name = name
        response
      end

      private

      def __attributes_get(field)
        request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, "name", @name)
          xml.get_key_tag!(base_name, field)
        end
        response = request.execute!
        items = response.xpath("//listitem/text()")
        return [items.to_s] unless items.is_a?(Array)

        items.map(&:to_s)
      end

      def __attributes_set(field, attr_arr)
        request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, "name", @name)
          xml.set_key_tag!(base_name, field, attr_arr)
        end
        request.execute!
      end
    end
  end
end
