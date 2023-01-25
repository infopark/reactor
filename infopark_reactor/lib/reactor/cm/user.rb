require "reactor/cm/object_base"
require "reactor/configuration"
require "reactor/cm/language"
require "reactor/tools/xml_attributes"
require "reactor/tools/where_query"

require "reactor/cm/permissions"

module Reactor
  module Cm
    class User
      class Internal < Reactor::Cm::ObjectBase
        set_base_name "user"

        # Attribute definitions
        attribute :login,         except: [:set]
        attribute :super_user,    except: [:set], name: :isSuperUser
        attribute :default_group, name: :defaultGroup
        attribute :groups,        type: :list
        attribute :real_name,     name: :realName
        attribute :email

        include Permissions

        def name
          login
        end

        def change_password(new_password)
          request = XmlRequest.prepare do |xml|
            xml.where_key_tag!(base_name, primary_key, primary_key_value)
            xml.set_tag!(base_name) do
              xml.tag!("password", verifyNewPassword: new_password) do
                xml.text!(new_password)
              end
            end
          end

          response = request.execute!

          response.ok?
        end

        def has_password?(password)
          ::Reactor::Cm::User.new(login).has_password?(password)
        end

        primary_key :login

        # Returns true if user is root, false otherwise
        def super_user?
          super_user == "1"
        end

        # Creates a user with given login and sets its default group
        # Returns instance of the class for user with given login
        def self.create(login, default_group)
          super(login, { login: login, defaultGroup: default_group })
         end
      end

      include XmlAttributes
      extend WhereQuery

      attribute :login
      attribute :groups, type: :list
      attribute :global_permissions, name: :globalPermissions, type: :list
      attribute :email
      attribute :default_group, name: :defaultGroup
      attribute :real_name, name: :realName

      primary_key "login"

      def initialize(name = nil)
        @login = name
      end

      def name
        login
      end

      def self.all(match = nil)
        where("userText", match)
      end

      def has_password?(password)
        request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, self.class.primary_key, login)
          xml.get_tag!(base_name) do |xml3|
            xml3.tag!("hasPassword", password: password)
          end
        end
        response = request.execute!
        response.xpath("//hasPassword/text()") == "1"
      end

      def is_root?
        request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, self.class.primary_key, login)
          xml.get_key_tag!(base_name, "isSuperUser")
        end

        response = request.execute!

        response.xpath("//isSuperUser/text()") == "1"
      end

      def language
        Reactor::Cm::Language.get(login)
      end

      def global_permissions
        val = instance_variable_get(:@global_permissions)
        return val unless val.nil?

        xml_attribute = self.class.xml_attribute(:global_permissions)

        request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, self.class.primary_key, login)
          xml.get_key_tag!(base_name, xml_attribute.name)
        end

        response = request.execute!

        self.class.response_handler.get(response, xml_attribute)
      end

      def groups
        val = instance_variable_get(:@groups)
        return val unless val.nil?

        xml_attribute = self.class.xml_attribute(:groups)

        request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, self.class.primary_key, login)
          xml.get_key_tag!(base_name, xml_attribute.name)
        end

        response = request.execute!

        self.class.response_handler.get(response, xml_attribute)
      end

      def email
        val = instance_variable_get(:@email)
        return val unless val.nil?

        xml_attribute = self.class.xml_attribute(:email)

        request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, self.class.primary_key, login)
          xml.get_key_tag!(base_name, xml_attribute.name)
        end

        response = request.execute!

        self.class.response_handler.get(response, xml_attribute)
      end

      def real_name
        val = instance_variable_get(:@real_name)
        return val unless val.nil?

        xml_attribute = self.class.xml_attribute(:real_name)

        request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, self.class.primary_key, login)
          xml.get_key_tag!(base_name, xml_attribute.name)
        end

        response = request.execute!

        self.class.response_handler.get(response, xml_attribute)
      end

      protected

      def base_name
        self.class.base_name
      end

      def self.base_name
        "userProxy"
      end
    end
  end
end
