require 'reactor/cm/object_base'
require 'reactor/configuration'
require 'reactor/cm/language'
require 'reactor/tools/xml_attributes'

module Reactor

  module Cm

    class User

      class Internal < Reactor::Cm::ObjectBase
        set_base_name 'user'

        # Attribute definitions
        attribute :login,         :except => [:set]
        attribute :super_user,    :except => [:set], :name => :isSuperUser
        attribute :default_group, :name => :defaultGroup
        attribute :groups,        :type => :list
        attribute :real_name,     :name => :realName

        def change_password(new_password)
          request = XmlRequest.prepare do |xml|
            xml.where_key_tag!(base_name, primary_key, primary_key_value)
            xml.set_tag!(base_name) do
              xml.tag!('password', :verifyNewPassword => new_password) do
                xml.text!(new_password)
              end
            end
          end

          response = request.execute!

          response.ok?
        end

        primary_key :login

        # Returns true if user is root, false otherwise
        def super_user?
          super_user == '1'
        end

        # Creates a user with given login and sets its default group
        # Returns instance of the class for user with given login
        def self.create(login, default_group)
          super(login, {:login => login, :defaultGroup => default_group})
        end

      end

      include XmlAttributes

      attribute :name
      attribute :groups, :type => :list

      primary_key 'login'

      def initialize(name)
        @name = name
      end

      def is_root?
        request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, self.class.primary_key, self.name)
          xml.get_key_tag!(base_name, 'isSuperUser')
        end

        response = request.execute!

        response.xpath('//isSuperUser/text()') == '1'
      end

      def language
        Reactor::Cm::Language.get(self.name)
      end

      def groups
        xml_attribute = self.class.xml_attribute(:groups)

        request = XmlRequest.prepare do |xml|
          xml.where_key_tag!(base_name, self.class.primary_key, self.name)
          xml.get_key_tag!(base_name, xml_attribute.name)
        end

        response = request.execute!

        self.class.response_handler.get(response, xml_attribute)
      end

      protected
      def base_name
        'userProxy'
      end

    end

  end

end
