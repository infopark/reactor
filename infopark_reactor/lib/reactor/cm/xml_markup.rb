# -*- encoding : utf-8 -*-
require 'builder'

module Reactor
  module Cm
    class XmlMarkup < Builder::XmlMarkup

      def where_key_tag!(base_name, key, value)
        where_tag!(base_name) do |xml|
          xml.tag!(key.to_s) do
            xml.text!(value.to_s)
          end
        end
      end

      def where_tag!(base_name)
        tag!("#{base_name}-where") do |xml|
          yield xml
        end
      end

      def create_tag!(base_name)
        tag!("#{base_name}-create") do |xml|
          yield xml
        end
      end

      def delete_tag!(base_name)
        tag!("#{base_name}-delete")
      end

      def get_key_tag!(base_name, key)
        get_tag!(base_name) do |xml|
          if key.kind_of?(::Array)
            key.each {|k| xml.tag!(k.to_s) }
          else
            xml.tag!(key.to_s) ; end
        end
      end

      def get_tag!(base_name)
        tag!("#{base_name}-get") do |xml|
          yield xml
        end
      end

      def set_key_tag!(base_name, key, value, options = {})
        set_tag!(base_name) do
          value_tag!(key, value, options)
        end
      end

      def set_tag!(base_name)
        tag!("#{base_name}-set") do |xml|
          yield xml
        end
      end

      def value_tag!(key, value, options = {})
        if value.kind_of? ::Array then array_value_tag!(key, value, options)
        elsif value.kind_of? ::Hash then hash_value_tag!(key, value)
        else tag!(key.to_s) { text!(value.to_s) }
        end
      end

      def array_value_tag!(name, values, options = {})
        tag!(name.to_s, options) do
          values.each do |value|
            tag!('listitem') do
              text!(value.to_s)
            end
          end
        end
      end

      def hash_value_tag!(name, hash)
        hash.each do |value, attr_hash|
          tag!(name.to_s, attr_hash) do
            text!(value.to_s)
          end
        end
      end

    end
  end
end
