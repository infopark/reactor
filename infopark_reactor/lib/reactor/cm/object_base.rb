require "reactor/tools/xml_attributes"

module Reactor
  module Cm
    class ObjectBase
      def self.inherited(subclass)
        # dynamic binding is required, otherwise class attributes
        # aren't stored in the correct class
        subclass.send(:include, Reactor::XmlAttributes)
      end

      # Default base_name is lowercased class name (without namespaces)
      def self.base_name
        name.split("::").last.downcase
      end

      def base_name
        self.class.base_name
      end

      # Sets the base name for the object. Use it when inheriting the class, for example:
      #     class Obj < ObjectBase
      #       set_base_name 'obj'
      #     end
      def self.set_base_name(base_name_value)
        # we us evaluation of a string in this case, because
        # define_method cannot handle default values
        class_eval <<-EOH
          def self.base_name
            '#{base_name_value}'
          end
        EOH
      end

      private_class_method :new
      # Constructor of this class should never be called directly.
      # Use class methods .get and .create instead (as well as helper method .exists?)
      def initialize(pk_val)
        primary_key_value_set(pk_val)
      end

      # Reloads the data from CM. Fetches all defined attributes.
      def reload
        request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, primary_key, primary_key_value)
          xml.get_key_tag!(base_name, self.class.xml_attribute_names)
        end

        response = request.execute!

        self.class.attributes.each do |attr_name, attr_def|
          send(:"#{attr_name}=", self.class.response_handler.get(response, attr_def))
        end

        self
      end

      # Saves all settable instance attributes to the Content Manager.
      def save!
        request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, primary_key, primary_key_value)
          xml.set_tag!(base_name) do
            self.class.attributes(:set).each do |name, xml_attribute|
              value = send(name)
              serialize_attribute_to_xml(xml, xml_attribute, value)
            end
          end
        end

        response = request.execute!
        response.ok?
      end

      # Alias for #save!
      def save
        save!
      end

      # Proxy method. @see .delete!(login)
      def delete!
        self.class.delete!(primary_key_value)
      end

      def serialize_attribute_to_xml(xml, xml_attribute, value)
        self.class.serialize_attribute_to_xml(xml, xml_attribute, value)
      end

      def self.serialize_attribute_to_xml(xml, xml_attribute, value)
        xml.value_tag!(xml_attribute.name, value)
      end

      # Returns true when object with given primary key exists in CM
      # Returns false otherwise
      def self.exists?(pk_val)
        request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, primary_key, pk_val)
          xml.get_key_tag!(base_name, primary_key)
        end

        response = request.execute!

        response.ok?
      rescue XmlRequestError
        false
      end

      # Returns an instance of the class for object with given primary key
      # XmlRequestError will be raised when error occurs (for example
      # when there is no object with given primary key)
      def self.get(pk_val)
        obj = new(pk_val)
        obj.reload
        obj
      end

      # Removes object with given pk from CM.
      # Returns true on success, raises XmlRequestError on error
      def self.delete!(pk_val)
        request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, primary_key, pk_val)
          xml.delete_tag!(base_name)
        end

        request.execute!.ok?
      end

      # Alias for #delete!
      def delete
        delete!
      end

      class << self
        # This method should never be called directly. It should always be overriden!
        # pk_value is the value of primary key, it should have its double in attributes hash
        # attributes is a hash of attributes set on creation {:name => 'value'}

        protected

        def create(pk_value, attributes)
          request = XmlRequest.prepare do |xml|
            xml.create_tag!(base_name) do
              attributes.each do |attr_name, attr_value|
                # serialize_attribute_to_xml(xml, xml_attribute, value)
                xml.value_tag!(attr_name, attr_value)
              end
            end
          end

          request.execute!

          get(pk_value)
        end
      end

      protected

      def primary_key
        self.class.primary_key
      end

      def primary_key_value
        instance_variable_get("@#{primary_key}")
      end

      def primary_key_value_set(value)
        instance_variable_set("@#{primary_key}", value)
      end
    end
  end
end
