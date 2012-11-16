module Reactor
  module Cm
    class Attribute
      def self.exists?(name)
        begin
          return Attribute.new.send(:get,name).ok?
        rescue
          return false
        end
      end

      def self.get(name)
        attr = Attribute.new
        attr.send(:get,name)
        attr
      end

      def self.create(name, type)
        attr = Attribute.new
        attr.send(:create,name,type)
        attr
      end

      def set(key, value)
        @params[key.to_sym] = value
      end

      def save!
        request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, 'name', @name)
          xml.set_tag!(base_name) do
            @params.each do |key, value|
              xml.value_tag!(key.to_s, value)
            end
          end
        end
        response = request.execute!
      end

      def delete!
        request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, 'name', @name)
          xml.tag!("#{base_name}-delete")
        end
        response = request.execute!
      end

      protected
      def base_name
        'attribute'
      end

      def initialize
        @params = {}
      end

      def get(name)
        request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, 'name', name)
          xml.get_key_tag!(base_name, 'name')
        end
        response = request.execute!
        @name = name
        response
      end

      def create(name, type)
        request = XmlRequest.prepare do |xml|
          xml.create_tag!(base_name) do
            xml.tag!('name') do
              xml.text!(name)
            end
            xml.tag!('type') do
              xml.text!(type)
            end
          end
        end
        response = request.execute!
        @name = name
        response
      end
    end
  end
end