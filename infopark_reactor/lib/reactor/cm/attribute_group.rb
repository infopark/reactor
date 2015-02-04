require 'reactor/cm/object_base'

module Reactor
  module Cm
    class AttributeGroup < ObjectBase 
      set_base_name 'attributeGroup'

      attribute :obj_class, name: :objClass
      attribute :name
      attribute :title

      attribute :attributes, :except => [:set], :type => :list
      attribute :index

      # virtual attribute!
      primary_key :identifier

      def identifier
        primary_key_value
      end

      def identifier=(val)
        primary_key_value_set(val)
      end

      def self.exists?(pk_val)
        request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, primary_key, pk_val)
          xml.get_key_tag!(base_name, :name)
        end

        response = request.execute!

        return response.ok?

      rescue XmlRequestError => e
        return false
      end


      def self.create(obj_class, name, index=nil)
        pk = [obj_class, name].join('.')
        attributes = {
          objClass: obj_class,
          name: name
        }
        attributes[:index] = index if index

        super(pk, attributes)
      end

      def add_attributes(attributes)
        add_or_remove_attributes(attributes, 'add')
      end

      def remove_attributes(attributes)
        add_or_remove_attributes(attributes, 'remove')
      end

      def move_attribute(attribute, index)
        request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, primary_key, primary_key_value)
          xml.tag!("#{base_name}-moveAttribute") do
            xml.tag!('attribute') do
              xml.text!(attribute.to_s)
            end
            xml.tag!('index') do
              xml.text!(index.to_s)
            end
          end

        end

        response = request.execute!

        response.ok? && reload
      end

      def set(attr, value)
        self.send(:"#{attr}=", value)
      end

      protected
      def primary_key_value
        "#{self.obj_class}.#{self.name}"
      end

      def primary_key_value_set(value)
        a = value.split('.')
        self.obj_class = a.first
        self.name = a.last
      end

      def add_or_remove_attributes(attributes, add_or_remove)
        request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, primary_key, primary_key_value)
          xml.tag!("#{base_name}-#{add_or_remove}Attributes") do
            attributes.each do |attribute|
              xml.tag!('listitem') do
                xml.text!(attribute)
              end
            end
          end

        end

        response = request.execute!

        response.ok? && reload
      end
    end
  end
end
